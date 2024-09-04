# Create firewall rule
resource "google_compute_firewall" "go_time_app" {
  name    = "go-time-firewall"
  network = google_compute_network.vpc_go_time_app.name
  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080" ]
  }

  source_ranges = ["0.0.0.0/0"]  
  target_tags = ["web"]
}


# Assign an IAM Role

# Create a service account
resource "google_service_account" "go_time_app" {
  account_id   = "go-time-app-sa"
  display_name = "Go Time App Service Account"
}

# Compute engine role
resource "google_project_iam_member" "go_time_app_sa_iam" {
  project = var.project
  role    = "roles/compute.instanceAdmin" 
  member  = "serviceAccount:${google_service_account.go_time_app.email}"
}
# Artifact Registry role (create but not delete privileges)
resource "google_project_iam_member" "go_time_app_sa_artifact_writer" {
  project = var.project
  role    = "roles/artifactregistry.writer" # Write access to Artifact Registry, but cannot delete
  member  = "serviceAccount:${google_service_account.go_time_app.email}"
}


# Compute Engine Network Admin role
resource "google_project_iam_member" "go_time_app_sa_network_admin" {
  project = var.project
  role    = "roles/compute.networkAdmin" 
  member  = "serviceAccount:${google_service_account.go_time_app.email}"
}

# Assign Kubernetes (GKE) Admin role to the service account
resource "google_project_iam_member" "go_time_app_sa_kubernetes_admin" {
  project = var.project
  role    = "roles/container.admin" 
  member  = "serviceAccount:${google_service_account.go_time_app.email}"
}

# Assign Storage Object Admin role to the service account
resource "google_project_iam_member" "go_time_app_sa_storage_admin" {
  project = var.project
  role    = "roles/storage.objectAdmin" 
  member  = "serviceAccount:${google_service_account.go_time_app.email}"
}