#!/usr/bin/env bash
set -euo pipefail

# Single entrypoint to build and run the app with Docker or run Tauri locally.
# Usage: ./start.sh [tauri]
# - no args: builds images and starts postgres, backend, frontend, and electron container
# - tauri : builds images, starts postgres+backend, then runs Tauri dev locally (requires Rust + GUI)
#
# Requirements for Tauri mode on the host:
# - Docker + docker compose
# - Node.js with npm/npx
# - Rust toolchain (cargo) installed and available on PATH
# - A working Linux GUI session (X11/Wayland) so the Tauri window can be shown

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

# Helper to stop any already running Tauri dev processes to avoid Cargo lock issues
stop_existing_tauri() {
  echo "🔍 Checking for existing Tauri dev processes..."
  if pgrep -f "@tauri-apps/cli@1 dev" >/dev/null 2>&1 || pgrep -f "tauri dev" >/dev/null 2>&1; then
    echo "🛑 Stopping existing Tauri dev processes..."
    pkill -f "@tauri-apps/cli@1 dev" >/dev/null 2>&1 || true
    pkill -f "tauri dev" >/dev/null 2>&1 || true
  else
    echo "✅ No existing Tauri dev processes found."
  fi
}

if [ "${1:-}" = "tauri" ]; then
  echo "🛠️  Starting Tauri dev environment (local)..."

  # Ensure we do not have multiple Tauri dev sessions fighting over Cargo locks
  stop_existing_tauri

  # Frontend dev server is started here so Tauri can use devPath=http://localhost:5173
  if ! command -v npx >/dev/null 2>&1; then
    echo "❌ npx is required to run Tauri. Please install Node.js/npm and try again."
    exit 1
  fi

  if ! command -v cargo >/dev/null 2>&1; then
    echo "❌ cargo (Rust) is required to run Tauri. Please install Rust via rustup and try again."
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
  # Start vite dev server from src-tauri/frontend folder and detach
  npm --prefix src-tauri/frontend run dev > /tmp/frontend-dev.log 2>&1 &

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
