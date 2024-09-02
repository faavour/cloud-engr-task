resource "google_container_cluster" "go_time_app" {
  name = var.cluster_name

  location                 = "europe-west4-a"
  enable_autopilot         = false
  enable_l4_ilb_subsetting = true

  network    = google_compute_network.vpc_go_time_app.id
  subnetwork = google_compute_subnetwork.go_time_app.id

  ip_allocation_policy {
    stack_type                    = "IPV4_IPV6"
    services_secondary_range_name = google_compute_subnetwork.go_time_app.secondary_ip_range[0].range_name
    cluster_secondary_range_name  = google_compute_subnetwork.go_time_app.secondary_ip_range[1].range_name
  }
  datapath_provider = "ADVANCED_DATAPATH"
  initial_node_count = 2 
  deletion_protection = false
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "default"  

  set {
    name  = "controller.replicaCount"
    value = "1"
  }

  # Add any additional configurations needed for your setup here
}

