#!/usr/bin/env bash
set -euo pipefail

# Single entrypoint to build and run the app with Docker or run Tauri locally
# Usage: ./start.sh [tauri]
# - no args: builds images and starts postgres, backend, frontend, and electron container
# - tauri : builds images, starts postgres+backend, then runs Tauri dev locally (requires Rust + GUI)

echo "🚀 Building Docker images (pulling latest base images)..."
docker compose build --pull

# Start core services (postgres + backend). Frontend will be started either as a container
# (default) or by the local Tauri tooling when running `./start.sh tauri`.
echo "📦 Starting postgres and backend..."
# Use --build to ensure images are up-to-date and remove-orphans to keep things tidy
docker compose up -d --build --remove-orphans postgres backend

# Wait helper
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

if [ "${1:-}" = "tauri" ]; then
  echo "🛠️  Starting Tauri dev environment (local)..."

  # frontend dev server will be started by Tauri's beforeDevCommand (see src-tauri/tauri.conf.json)
  if ! command -v npx >/dev/null 2>&1; then
    echo "❌ npx is required to run Tauri. Please install Node.js/npm and try again."
    exit 1
  fi

  # Ensure TAURI_DIR is set to the crate folder so the CLI finds the config
  export TAURI_DIR="$(pwd)/src-tauri"
  # Ensure cargo/rust binaries are on PATH when this script runs non-interactively
  export PATH="$HOME/.cargo/bin:$PATH"
  echo "Using TAURI_DIR=$TAURI_DIR"

  # Start the frontend dev server locally (background) so Tauri can load devPath
  echo "🔧 Starting frontend dev server in background (frontend)..."
  if ! command -v npm >/dev/null 2>&1; then
    echo "❌ npm is required to run the frontend dev server. Please install Node.js/npm and try again."
    exit 1
  fi
  # Start vite dev server from frontend folder and detach
  npm --prefix frontend run dev > /tmp/frontend-dev.log 2>&1 &

  # Wait for frontend to become available
  check_url "Frontend (Vite)" "http://localhost:5173/" || { echo "Frontend failed to start"; tail -n +1 /tmp/frontend-dev.log || true; exit 1; }

  # Run Tauri CLI from src-tauri so it finds config
  cd src-tauri
  echo "➡️  Running: npx @tauri-apps/cli@1 dev (this will run in the foreground)"
  exec npx --yes @tauri-apps/cli@1 dev
fi

# Default behaviour: start frontend and (legacy) electron container
echo "📦 Starting frontend container..."
docker compose up -d frontend

# Wait for frontend
check_url "Frontend (Vite)" "http://localhost:5173/" || exit 1

# Start electron container (it will connect to frontend)
echo "🖥️  Starting Electron container..."
docker compose up -d electron

echo "✅ All services started. The Electron app should open on your host display (if X is available)."
echo "To follow logs: docker compose logs -f electron"
echo "To stop everything: docker compose down"

echo "Note: xhost +local:docker was enabled to allow GUI. You can revoke it with: xhost -local:docker"
