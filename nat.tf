#Define an external IP for the nat
resource "google_compute_address" "go_time_ip" {
  name         = "go-time-ip"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
}

#Define a nat for the VPC
resource "google_compute_router_nat" "go_time_nat" {
  name   = "go-time-nat"
  router = google_compute_router.vpc_go_time_router.name
  region = var.region

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  nat_ip_allocate_option             = "MANUAL_ONLY"

  subnetwork {
    name                    = google_compute_subnetwork.go_time_app.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  nat_ips = [google_compute_address.go_time_ip.self_link]
}
