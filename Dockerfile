FROM golang:1.20-alpine as builder

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy the go.mod and go.sum files to the container
COPY go.mod .

# Download the dependencies
RUN go mod download

# Copy the source code into the container
COPY . .

# Build the Go app
RUN go build -o main .

# Use a minimal base image
FROM alpine:3.18

# Set the Current Working Directory inside the container
WORKDIR /root/

# Copy the Pre-built binary file from the builder stage
COPY --from=builder /app/main .

# Expose port 8080 to the outside world
EXPOSE 8080

# Command to run the executable
CMD ["./main"]
