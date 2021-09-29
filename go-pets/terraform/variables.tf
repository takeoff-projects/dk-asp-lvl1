variable "gcp_project_id" {
  description = "Google cloud platform project name"
}

variable "region" {
  description = "GCP region"
}

variable "zone" {
  description = "GCP region timezone"
}

variable "server_port" {
  description = "Server port for HTTP requests"
}

variable "db_name" {
  description = "Datastore DB name"
}

variable "google_apis" {
  description = "List of enabled apis needed for application"
  type        = list(string)
  default = [
    "cloudapis.googleapis.com",
    "cloudbuild.googleapis.com",
    "run.googleapis.com",
    "servicemanagement.googleapis.com",
    "servicecontrol.googleapis.com",
    "apigateway.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "datastore.googleapis.com",
    "iam.googleapis.com"
  ]
}