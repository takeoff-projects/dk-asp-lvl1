terraform {
  required_version = ">= 0.14"

  required_providers {
    google = ">= 3.8.6"
    # google-beta = ">= 3.63.0"
  }
}
provider "google" {
  project = var.gcp_project_id
  region = var.region
  zone   = var.zone
}

provider "google-beta" {
  project = var.gcp_project_id
  region  = var.region
  zone    = var.zone
}

locals {
  service_name    = "go-api"
  
}

resource "google_project_service" "gcp_services" {
  provider           = google
  for_each           = toset(var.google_apis)
  project            = var.gcp_project_id
  service            = each.key
  disable_on_destroy = false
}
resource "google_cloud_run_service" "api" {
  name     = local.service_name
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.gcp_project_id}/go-api:latest"
        ports {
          container_port = var.server_port
        }
        env {
          name  = "GOOGLE_CLOUD_PROJECT"
          value = var.gcp_project_id
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
  location = google_cloud_run_service.api.location
  project  = google_cloud_run_service.api.project
  service  = google_cloud_run_service.api.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

output "service_url" {
  value = google_cloud_run_service.api.status[0].url
}

# resource "google_api_gateway_api" "api_gw" {
#   provider = google-beta
#   api_id = "api-gw"
# }

# resource "google_api_gateway_api_config" "api_gw" {
#   provider = google-beta
#   api = google_api_gateway_api.api_gw.api_id
#   api_config_id = "config"

#   openapi_documents {
#     document {
#       path = "spec.yaml"
#       contents = filebase64("test-fixtures/apigateway/openapi.yaml")
#     }
#   }
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "google_api_gateway_gateway" "api_gw" {
#   provider = google-beta
#   api_config = google_api_gateway_api_config.api_gw.id
#   gateway_id = "api-gw"
# }