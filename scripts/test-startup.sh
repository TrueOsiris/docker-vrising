#!/bin/bash
set -e

# Configuration
IMAGE_NAME=${1:-"vrising-e2e-test"}
CONTAINER_NAME="vrising-test-run-$(date +%s)"
TIMEOUT_SECONDS=600 # 10 minutes
CHECK_INTERVAL=10
SUCCESS_STRING="Startup Completed"

# Cleanup function
cleanup() {
    echo "Cleaning up..."
    docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
    docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
    if [ -d "$TEST_DIR" ]; then
        # Use a temporary docker container to run rm -rf as root on the CONTENTS of the directory
        # bypassing permission issues from files owned by the 'steam' user
        docker run --rm -v "$TEST_DIR:/test_dir" ubuntu:24.04 bash -c "rm -rf /test_dir/* /test_dir/.* 2>/dev/null || true"
        rm -rf "$TEST_DIR"
    fi
}

# Ensure cleanup on exit
trap cleanup EXIT

if [ -z "$1" ]; then
    echo "No image name provided. Building Docker image locally..."
    docker build -t "$IMAGE_NAME" .
else
    echo "Using provided image: $IMAGE_NAME"
fi

echo "Creating temporary data directory..."
TEST_DIR=$(mktemp -d)
chmod 777 "$TEST_DIR"

echo "Starting container..."
docker run -d \
    --name "$CONTAINER_NAME" \
    -v "$TEST_DIR:/mnt/vrising" \
    "$IMAGE_NAME"

echo "Waiting for server to start (Timeout: ${TIMEOUT_SECONDS}s)..."
START_TIME=$(date +%s)
while true; do
    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - START_TIME))

    if [ "$ELAPSED" -gt "$TIMEOUT_SECONDS" ]; then
        echo "Error: Timeout waiting for server to start after ${TIMEOUT_SECONDS} seconds."
        docker logs "$CONTAINER_NAME" | tail -n 20
        exit 1
    fi

    if docker logs "$CONTAINER_NAME" 2>&1 | grep -q "$SUCCESS_STRING"; then
        echo "Success: Server started successfully!"
        break
    fi

    # Check if container is still running
    if ! docker ps -q --no-trunc | grep -q "^$(docker inspect -f '{{.Id}}' "$CONTAINER_NAME")"; then
        echo "Error: Container stopped unexpectedly."
        docker logs "$CONTAINER_NAME"
        exit 1
    fi

    echo "Still waiting... (${ELAPSED}s elapsed)"
    sleep "$CHECK_INTERVAL"
done

echo "Test passed!"
exit 0
