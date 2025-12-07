#!/bin/bash

echo "🚀 Starting Electron + Vue 3 + Symfony Application"
echo "=================================================="

# Allow Docker to access X11 display
echo "Configuring X11 access..."
xhost +local:docker

# Check if containers are already running
if [ "$(docker compose ps -q)" ]; then
    echo "Stopping existing containers..."
    docker compose down
fi

# Start all services
echo "Starting services..."
docker compose up

# Cleanup on exit
trap "docker compose down; xhost -local:docker" EXIT
