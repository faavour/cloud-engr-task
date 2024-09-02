data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.default.endpoint}"
  token                  = data.google_client_config.default.access_token
  config_context         = var.k8s_context
  config_path            = "~/.kube/config" 
  cluster_ca_certificate = base64decode(google_container_cluster.default.master_auth[0].cluster_ca_certificate)

  ignore_annotations = [
    "^autopilot\\.gke\\.io\\/.*",
    "^cloud\\.google\\.com\\/.*"
  ]
}

//The deployment

resource "kubernetes_deployment_v1" "go_time_api" {
  metadata {
    name = var.cluster_name
    labels = {
      app = var.cluster_name
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = var.cluster_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.cluster_name
        }
      }

      spec {
        container {
          image = var.image
          name  = var.cluster_name

          port {
            container_port = 8080
            name           = var.cluster_name
          }
        }
      }
    }

  }
}

//The service

resource "kubernetes_service_v1" "go_time_api" {
  metadata {
    name = var.cluster_name
  }

  spec {
    selector = {
      app = var.cluster_name
    }

    port {
      protocol    = "TCP"
      port        = 8080
      target_port = 8080
    }

    type = "ClusterIP"
  }
}



//The ingress

resource "kubernetes_ingress_v1" "go_time_api" {
  metadata {
    name = var.cluster_name
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path         = "/"
          path_type    = "Prefix"

          backend {
            service {
              name = var.cluster_name
              port {
                number = 8080
              }
            }
          }
        }
      }
    }

    # tls {
    #   secret_name = "tls-secret"
    # }
  }
}
