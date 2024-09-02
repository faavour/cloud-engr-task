provider "google" {
  credentials = file("/Users/mac/Downloads/ditto-293914-1155f71f3fc3.json")
  project     = var.project
  region      = var.region
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"  
    config_context = var.k8s_context
  }
}
