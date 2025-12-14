#!/bin/bash
set -e

# Start virtual display if not using host X11
if [ -z "${DISPLAY:-}" ] || [ "${DISPLAY}" = ":0" ]; then
  # If host X is available, prefer host display
  echo "Using host X display: ${DISPLAY:-:0}"
else
  echo "Starting virtual Xvfb display :99"
  Xvfb :99 -screen 0 1024x768x24 > /dev/null 2>&1 &
  export DISPLAY=:99
fi

sleep 1

export AUDIODEV=none

if [ "$1" = "--dev" ]; then
  echo "Starting Electron in development mode..."
  npm run dev
else
  echo "Starting Electron in production mode..."
  npm start
fi
