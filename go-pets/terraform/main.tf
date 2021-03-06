terraform {
  required_version = ">= 0.14"

  required_providers {
    google = ">= 3.8.6"
    # google-beta = ">= 3.63.0"
  }
}
provider "google" {
  project = var.gcp_project_id
  #   credentials = file("../roi-takeoff-user54-c8acaf8c421a.json")
  region = var.region
  zone   = var.zone
}

# provider "google-beta" {
#   project = var.gcp_project_id
#   region  = var.region
#   zone    = var.zone
# }

locals {
  service_name    = "go-pets"
  index_path_file = "${path.module}/yaml/index.yaml"
}

resource "google_project_service" "gcp_services" {
  provider           = google
  for_each           = toset(var.google_apis)
  project            = var.gcp_project_id
  service            = each.key
  disable_on_destroy = false
}
resource "google_cloud_run_service" "petsapp" {
  name     = local.service_name
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.gcp_project_id}/petsapp:latest"
        ports {
          container_port = var.server_port
        }
        env {
          name  = "GOOGLE_CLOUD_PROJECT"
          value = "roi-takeoff-user54"
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.petsapp.location
  project  = google_cloud_run_service.petsapp.project
  service  = google_cloud_run_service.petsapp.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

output "service_url" {
  value = google_cloud_run_service.petsapp.status[0].url
}