variable "project" {
  description = "The GCP project to deploy to"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
  default     = "go-time-apps"
}
variable "image" {
  description = "Name of the container image"
  type        = string
}
variable "k8s_context" {
  description = "context for the k8s cluster"
  type        = string
}
variable "gcp_credentials" {
  description = "service account key in json"
  type        = string
}


