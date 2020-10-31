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

