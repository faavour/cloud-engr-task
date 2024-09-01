# cloud-engr-task

This task is divided into different phases:

1. The API
2. Containerization of the API 
3. Setting up the Infrastructure with Terraform
4. 





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




