terraform {


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
  config_context         = var.k8s_context
  cluster_ca_certificate = base64decode(google_container_cluster.go_time_app.master_auth[0].cluster_ca_certificate)

  ignore_annotations = [
    "^autopilot\\.gke\\.io\\/.*",
    "^cloud\\.google\\.com\\/.*"
  ]
}
provider "kubectl" {
  config_context = var.k8s_context
}


provider "google" {
  project     = var.project
  region      = var.region
}

provider "helm" {
  kubernetes { 
    config_context = var.k8s_context
  }
}
