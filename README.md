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


## CICD pipeline
The pipeline is to build and provision the infrastructure to kubernetes cluster. 

The pipeline does the following:

Manual Trigger: Allows you to choose whether to apply or destroy infrastructure.
Build: Builds and pushes a Docker image to the Google Container Registry.
Deploy: Configures and manages infrastructure using Terraform, applying or destroying resources based on the selected action.



# How to run the the application: 
On your local:
First things first, Terraform needs the backend bucket to exist before it can initialize the backend configuration. You have to remove it first.
1. Remove the backend gcs configuration block (in main.tf;line 2-5)
2. Authenticate on your cli with the command `gcloud auth application-default login`
3. Create the artifact repository `gcloud artifacts repositories create cloud-engr-test --repository-format=docker`
4. Build the image with `gcloud builds submit --tag europe-west4-docker.pkg.dev/${{ secrets.GCP_PROJECT_ID }}/cloud-engr-test/go-time-api:latest`
5. Setup your personal `terraform.tfvars`. it should contain:
    - project  = 'your project ID'
    - image    = 'your docker image'
    - region   = 'your desired region'
6. Run `terraform init`
7. Run `terraform plan -var-file="terraform.tfvars"`
8. Run ``terraform apply -var-file="terraform.tfvars"`
9. Test that it works:



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
