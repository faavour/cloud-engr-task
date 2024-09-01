data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.default.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.default.master_auth[0].cluster_ca_certificate)

  ignore_annotations = [
    "^autopilot\\.gke\\.io\\/.*",
    "^cloud\\.google\\.com\\/.*"
  ]
}

//The deployment

resource "kubernetes_deployment_v1" "default" {
  metadata {
    name = "${var.cluster_name}-deployment"
  }

  spec {
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
            name           = "${var.cluster_name}"
          }

          security_context {
            allow_privilege_escalation = false
            privileged                 = false
            read_only_root_filesystem  = false

            capabilities {
              add  = []
              drop = ["NET_RAW"]
            }
          }
        }

        security_context {
          run_as_non_root = true

          seccomp_profile {
            type = "RuntimeDefault"
          }
        }

        # Toleration is currently required to prevent perpetual diff:
        # https://github.com/hashicorp/terraform-provider-kubernetes/pull/2380
        toleration {
          effect   = "NoSchedule"
          key      = "kubernetes.io/arch"
          operator = "Equal"
          value    = "amd64"
        }
      }
    }
  }
}

//The service

resource "kubernetes_service_v1" "default" {
  metadata {
    name = "${var.cluster_name}-loadbalancer"
    annotations = {
      "networking.gke.io/load-balancer-type" = "Internal" 
    }
  }

  spec {
    selector = {
      app = kubernetes_deployment_v1.default.spec[0].selector[0].match_labels.app
    }

    ip_family_policy = "RequireDualStack"

    port {
      port        = 8080
      target_port = 8080
    }

    type = "LoadBalancer"
  }

  depends_on = [time_sleep.wait_service_cleanup]
}

# Provide time for Service cleanup
resource "time_sleep" "wait_service_cleanup" {
  depends_on = [google_container_cluster.default]

  destroy_duration = "180s"
}


//The ingress

resource "kubernetes_ingress_v1" "example_ingress" {
  metadata {
    name = "${var.cluster_name}-ingress"
  }

  spec {
    default_backend {
      service {
        name = "${var.cluster_name}-loadbalancer"
        port {
          number = 8080
        }
      }
    }

    rule {
      host = "cloud-engr-test.com"
      http {
        path {
          backend {
            service {
              name = var.cluster_name
              port {
                number = 8080
              }
            }
          }

          path = "/"
          path_type = "Prefix"
        }
      }
    }

    tls {
      secret_name = "tls-secret"
    }
  }
}
