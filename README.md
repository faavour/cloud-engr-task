# cloud-engr-task

This task is divided into different phases:

1. The API
2. Containerization of the API 
3. Setting up the Infrastructure with Terraform
4. CICD Pipeline

## 1. The API:
The API is built and written in Go, it implements a simple HTTP server that listens on port 8080.
- It has a single endpoint `/time` that, when accessed, responds with the current UTC time formatted as a JSON.

## 2. Containerization of the API:
The Dockerfile uses a multi-stage build to create a lightweight Docker image.

Stage 1: Build the Go Application:
- Uses the official Go image (golang:1.20-alpine) 
- Sets the working directory inside the container to /app
- Runs `go mod` download to download all necessary dependencies

Stage 2: Create the Runtime Image:
- Uses a minimal Alpine Linux image
- Sets the working directory to /root/
- Copies the binary from the build stage.
- Exposes port 8080 to allow external access to the application.

stage 3: Building with gcloud build:
- Use gcloud cli and cloud build to build the Image
- Push to Artifact repository


## 3. Setting up the Infrastructure with Terraform:
This infrastructure is built with Infra as Code with Terraform:
The infrastructure contains:
- Docker image
- Api (built with Go lang)
- Address
- Subnets
- Cloud Router
- Cloud NAT
- Routes
- kubernetes cluster
- Ingress controller
- Ingress
- Deployments
- Service
- IAM
- Cloudbuild
- Github Actions

There are diffrent files, and these are what the files do:
1. app.tf:
- The `data google_client_config` block retrieves your Google Cloud credentials to authenticate with Google Cloud and interact with the Kubernetes cluster.
- The `Kubernetes namespace` block is where all the k8s resources for the time API will live.
- The `kubernetes_deployment_v1` block defines the deployment for the time API. It specifies how the application should run in Kubernetes
- The `kubernetes_service_v1` block defines a K8s service that exposes the time API application inside the cluster
- The `kubernetes_ingress_v1` block sets up an ingress resource, which exposes tthe time API to external traffic by routing requests from outside the cluster to the service

2. cluster.tf:
- The `google_container_cluster` block defines infrastructure resources for a Google Kubernetes Engine (GKE) cluster needed to run containerized applications in GKE.
 The `helm_release` block installs the NGINX Ingress controller which allows you to manage external access to your services using Terraform.

3. main.tf:
The `terraform` block contains:
- The `Backend` block which uses Google Cloud Storage (GCS) as the backend to store  the Terraform state.
-  The `required_providers` block has:
    -  the `kubernetes` provider which onnects to the GKE cluster using the cluster's API endpoint and access token
    - the `kubectl` provider which allows you to run kubectl commands directly from Terraform.
    - the `google` provider manages Google Cloud resources
    - the `helm` provider allows you to manage Helm charts within the Kubernetes cluster

4. nat.tf:
- The `google_compute_address` block reserves an external IP address which this IP will be used for outbound traffic from the VPC to the internet.
- The `google_compute_router_nat` block provides a A NAT configuration for a Google Cloud router, which ensures that internal resources within the VPC can access the internet using the static external IP while maintaining private internal IP addresses.

5. Security.tf:
- The `google_compute_firewall` block creates a firewall rule which allows ICMP traffic and TCP traffic on ports 80 and 8080, with a source range of `0.0.0.0/0`.
- The `google_service_account` block creates a service account.
- The `google_project_iam_member` assigns the following roles:
    - Grants `roles/compute.instanceAdmin`, allowing it to manage Compute Engine instances.
    - Grants `roles/artifactregistry.writer`, allowing write access to Artifact Registry but not delete permissions.
    -  Grants `roles/compute.networkAdmin`, allowing the service account to manage VPCs and other networking resources.
    - Grants `roles/container.admin`, providing full admin access to Google Kubernetes Engine (GKE) resources.
    - Grants `roles/storage.objectAdmin`, allowing the service account to manage objects in Google Cloud Storage.

6. vpc.tf:
- The `google_compute_network` block creates a custom VPC, with the option for Unique Local Address (ULA) internal IPv6 enabled, meaning auto-created subnetworks are disabled, giving more control over the network setup.
- The `google_compute_router` block creates network router defined to enable dynamic routing within the VPC.
- The `google_compute_subnetwork` block creates a primary subnetwork with both IPv4 and IPv6 stack. IPv6 access is external-facing. Two secondary ranges are also created: one for Kubernetes services

7. variables.tf:
These are the variables that can be configured for deployment.


## CICD pipeline
The pipeline is to build and provision the infrastructure to kubernetes cluster. 

The pipeline does the following:

Manual Trigger: Allows you to choose whether to apply or destroy infrastructure.
Build: Builds and pushes a Docker image to the Google Container Registry.
Deploy: Configures and manages infrastructure using Terraform, applying or destroying resources based on the selected action.



# How to run the the application: 
On your local:
First things first, Terraform needs the backend bucket to exist before it can initialize the backend configuration. You have to remove it first.
1. Remove the backend gcs configuration block (in main.tf;line 2-5) so terraform automatically uses your local to store the backend config.
2. Authenticate on your cli with the command `gcloud auth application-default login`.
3. Create the artifact repository `gcloud artifacts repositories create cloud-engr-test --repository-format=docker`, in this case `cloud-engr-test` is the name of the artifact repo.
4. Build the image with `gcloud builds submit --tag europe-west4-docker.pkg.dev/${{ secrets.GCP_PROJECT_ID }}/cloud-engr-test/go-time-api:latest`, where `GCP_PROJECT_ID` is your project ID for your particular project.
5. Setup your personal `terraform.tfvars`. it should contain:
    - project  = 'your project ID'
    - image    = 'your docker image'
    - region   = 'your desired region'
6. Run `terraform init`
7. Run `terraform plan -var-file="terraform.tfvars"`
8. Run `terraform apply -var-file="terraform.tfvars"`
9. Test that it works:
    - Run `kubectl get ingress go-time-apps -n go-time-apps -o jsonpath='{.status.loadBalancer.ingress[0].ip}'` to retrieve the ip
    - Hit `localhost:8080/time` endpoint.
10. Destroy the infrastructure with `terraform destroy`



## How the application is deployed and ran in the pipeline
The Pipeline was set to manual so that provisioning and destroying the infrastructure are done with serious intention. This way, we can control costs by avoiding accidental resource creation, and ensure that tearing down infrastructure is only done when you're sure it's absolutely the right move.

The api is fully automated and deployed using github Actions. These are the steps to `provision` the infrastructure.
1. On `Actions` tab
2. At the left panel, Select "go-time CI/CD Pipeline"
3. A drop down panel labelled "This workflow has a workflow_dispatch event trigger" will show.
4. Click on Run Workflow
5. Select `Apply`


To `destroy` the infrastructure

1. Follow the previous 4 steps
2. Select `Destroy`
