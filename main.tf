variable "cluster_name" {
  type = string
  validation {
    condition = can(regex("^[a-z]+[-a-z]*[a-z]+$", var.cluster_name))
    error_message = "The cluster_name value must be lower case letters (2+) with optional dashes in between."
  }
}

variable "master_version" {
  type = string
}

variable "node_version" {
  type = string
}

variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "zones" {
  type = list(string)
}

locals {
  clustername = replace(var.cluster_name, "-", "")
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.45.0"
    }
  }
  required_version = "~> 0.13.5"
}

provider "google" {
  project = var.project
}

resource "google_container_cluster" "this" {
  initial_node_count       = 1
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "172.16.0.0/12"
    services_ipv4_cidr_block = "192.168.0.0/16"
  }
  location                 = var.region
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
    password = ""
    username = ""
  }
  min_master_version       = var.master_version
  name                     = var.cluster_name
  node_locations           = var.zones
  remove_default_node_pool = true
  workload_identity_config {
    identity_namespace = "${var.project}.svc.id.goog"
  }
}

resource "google_container_node_pool" "this" {
  cluster    = google_container_cluster.this.name
  location   = var.region
  management {
    auto_upgrade = false
  }
  name       = var.cluster_name
  node_config {
    workload_metadata_config {
      node_metadata = "GKE_METADATA_SERVER"
    }
  }
  node_count = 1
  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }
  version    = var.node_version
}
