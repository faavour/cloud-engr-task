terraform {
  backend "gcs" {                        #remove this block to run locally
    bucket = "go-time-bucket"
    prefix = "terraform/state"
  }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.go_time_app.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.go_time_app.master_auth[0].cluster_ca_certificate)

  ignore_annotations = [
    "^autopilot\\.gke\\.io\\/.*",
    "^cloud\\.google\\.com\\/.*"
  ]
}
provider "kubectl" {
  host                   = "https://${google_container_cluster.go_time_app.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.go_time_app.master_auth[0].cluster_ca_certificate)
}


provider "google" {
  project = var.project
  region  = var.region
}

provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.go_time_app.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.go_time_app.master_auth[0].cluster_ca_certificate)
  }
}

