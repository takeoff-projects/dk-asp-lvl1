provider "google" {
    project = var.gcp_project_id
    region = var.region
    zone = var.zone
}
locals {
  service_name = "petsapp"
}
resource "google_cloud_run_service" "petsapp" {
  name     = local.service_name
  location = var.region

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/roi-takeoff-user54/petsapp"
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
  location    = google_cloud_run_service.default.location
  project     = google_cloud_run_service.default.project
  service     = google_cloud_run_service.default.name

  policy_data = data.google_iam_policy.noauth.policy_data
}