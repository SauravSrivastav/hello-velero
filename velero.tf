locals {
  clustername = replace(var.cluster_name, "-", "")
}

resource "google_storage_bucket" "this" {
  force_destroy               = true
  location                    = var.region
  name                        = "velero-${var.cluster_name}"
  uniform_bucket_level_access = true
}

resource "google_service_account" "this" {
  account_id   = "velero-${var.cluster_name}"
  display_name = "velero-${var.cluster_name}"
}

resource "google_project_iam_custom_role" "this" {
  permissions = [
    "compute.disks.get",
    "compute.disks.create",
    "compute.disks.createSnapshot",
    "compute.snapshots.get",
    "compute.snapshots.create",
    "compute.snapshots.useReadOnly",
    "compute.snapshots.delete",
    "compute.zones.get"
  ]
  role_id = "velero${local.clustername}"
  title   = "velero-${var.cluster_name}"
}

resource "google_project_iam_binding" "custom_role" {
  role = "projects/${var.project}/roles/${google_project_iam_custom_role.this.role_id}"
  members = [
    "serviceAccount:${google_service_account.this.email}"
  ]
}

resource "google_project_iam_binding" "object_admin" {
  role = "roles/storage.objectAdmin"
  members = [
    "serviceAccount:${google_service_account.this.email}"
  ]
  condition {
    expression = "resource.name.startsWith(\"projects/_/buckets/${var.cluster_name}/objects/\")"
    title = "bucket"
  }
}

resource "google_service_account_iam_binding" "this" {
  service_account_id = google_service_account.this.name
  role = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project}.svc.id.goog[velero/velero]"
  ]
}
