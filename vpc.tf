resource "google_compute_network" "vpc_go_time_app" {
  name        = var.cluster_name
  description = "VPC + extra services"

  auto_create_subnetworks = false
  enable_ula_internal_ipv6 = true
}

#Define a router for the network
resource "google_compute_router" "vpc_go_time_router" {
  name    = "vpc-go-time-router"
  region  = var.region
  network = google_compute_network.vpc_go_time_app.id
}

# Defining all subnets

#Kubernetes subnetworks
resource "google_compute_subnetwork" "go_time_app" {
  name = var.cluster_name

  ip_cidr_range = "10.0.0.0/24"
  region        = var.region

  stack_type       = "IPV4_IPV6"
  ipv6_access_type = "EXTERNAL" # Change to "EXTERNAL" if creating an external loadbalancer

  network = google_compute_network.vpc_go_time_app.id
  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "192.168.0.0/18"
  }

  secondary_ip_range {
    range_name    = "pod-ranges"
    ip_cidr_range = "192.168.64.0/18"
  }
}