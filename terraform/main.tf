provider "google" {
  project = var.gcp_project_id
  region  = var.region
  zone    = var.zone
}
locals {
  service_name = "go-pets"
}
resource "google_cloud_run_service" "default" {
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

resource "google_project_service" "apigateaway.googleapis.com" {
  provider = google
  project  = var.gcp_project_id
  service  = "apigateway.googleapis.com"

  disable_on_destroy = false
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
  location = google_cloud_run_service.default.location
  project  = google_cloud_run_service.default.project
  service  = google_cloud_run_service.default.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_datastore_index" "default" {
  kind = "Pet"
  properties {
    name      = "added"
    direction = "ASCENDING"
  }
  properties {
    name      = "capption"
    direction = "ASCENDING"
  }
  properties {
    name      = "email"
    direction = "ASCENDING"
  }
  properties {
    name      = "image"
    direction = "ASCENDING"
  }
  properties {
    name      = "likes"
    direction = "ASCENDING"
  }
  properties {
    name      = "owner"
    direction = "ASCENDING"
  }
  properties {
    name      = "petname"
    direction = "ASCENDING"
  }
  properties {
    name      = "Name"
    direction = "ASCENDING"
  }
}