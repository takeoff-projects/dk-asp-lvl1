variable "gcp_project_id" {
  description = "Google cloud platform project name"
}

#variable "credentials_file" {}

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