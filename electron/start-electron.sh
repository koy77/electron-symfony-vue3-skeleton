#!/bin/bash
set -e

# Start virtual display if not using host X11
if [ -z "${DISPLAY:-}" ] || [ "${DISPLAY}" = ":0" ]; then
  echo "Using host X display: ${DISPLAY:-:0}"
else
  echo "Starting virtual Xvfb display :99"
  Xvfb :99 -screen 0 1024x768x24 > /dev/null 2>&1 &
  export DISPLAY=:99
fi

sleep 1

export AUDIODEV=none

# Auto-detect frontend dev server or local dist
DEV=0
FRONTENDS=("http://frontend:5173" "http://localhost:5173")
for url in "${FRONTENDS[@]}"; do
  if command -v curl >/dev/null 2>&1; then
    if curl -sSf --max-time 2 "$url" >/dev/null 2>&1; then
      echo "Detected frontend at $url — running Electron in dev mode"
      DEV=1
      break
    fi
  fi
done

# If dist exists and dev server not found, use production
if [ -d "/app/dist" ] && [ "$DEV" -eq 0 ]; then
  if [ -f "/app/dist/index.html" ]; then
    echo "Found /app/dist/index.html — starting Electron in production mode"
    DEV=0
  fi
fi

if [ "$1" = "--dev" ] || [ "$DEV" -eq 1 ]; then
  echo "Starting Electron in development mode..."
  npm run dev
else
  echo "Starting Electron in production mode..."
  npm start
fi
