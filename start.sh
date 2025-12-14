#!/usr/bin/env bash
set -euo pipefail

# Single entrypoint to build and run the app with Docker
# - Builds images
# - Starts postgres, backend, frontend
# - Waits for services to be ready
# - Starts electron container (connects to host X11)

echo "🚀 Building Docker images (pulling latest base images)..."
docker compose build --pull

# Allow Docker containers to connect to host X11 display
if command -v xhost >/dev/null 2>&1; then
  echo "🔓 Allowing local docker containers to connect to X11 ($DISPLAY)..."
  xhost +local:docker || true
  # Revoke xhost on exit
  cleanup_xhost() {
    echo "🔒 Revoking X11 access for local docker"
    xhost -local:docker || true
  }
  trap cleanup_xhost EXIT
else
  echo "⚠️  xhost not found; ensure host X server allows connections from containers"
fi

# Start core services
echo "📦 Starting postgres, backend and frontend..."
# Use --build to ensure images are up-to-date and remove-orphans to keep things tidy
docker compose up -d --build --remove-orphans postgres backend frontend

# Wait for frontend and backend to be available
check_url() {
  local name="$1"
  local url="$2"
  local retries=30
  local wait=2
  local i=0
  echo "⏳ Waiting for $name at $url"
  until curl -sSf "$url" >/dev/null 2>&1; do
    i=$((i+1))
    if [ $i -ge $retries ]; then
      echo "❌ $name did not become ready after $((retries*wait))s"
      return 1
    fi
    echo "   Attempt $i/$retries..."
    sleep $wait
  done
  echo "✅ $name ready"
}

# Backend is exposed on host port 8001 (container 8000)
check_url "Backend API" "http://localhost:8001/api" || exit 1
check_url "Frontend (Vite)" "http://localhost:5173/" || exit 1

# Start electron container (it will connect to frontend)
echo "🖥️  Starting Electron container..."
docker compose up -d electron

echo "✅ All services started. The Electron app should open on your host display (if X is available)."
echo "To follow logs: docker compose logs -f electron"
echo "To stop everything: docker compose down"

echo "Note: xhost +local:docker was enabled to allow GUI. You can revoke it with: xhost -local:docker"
