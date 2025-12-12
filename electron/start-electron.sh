#!/bin/bash

# Electron App Startup Script for Docker

set -e

echo "🖥️  Starting Electron Desktop App..."

# Function to check if frontend is ready
check_frontend() {
    local max_attempts=30
    local attempt=1
    
    echo "⏳ Checking if frontend is ready..."
    while [ $attempt -le $max_attempts ]; do
        if curl -s "http://frontend:5173" > /dev/null 2>&1; then
            echo "✅ Frontend is ready!"
            return 0
        fi
        echo "   Attempt $attempt/$max_attempts..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    echo "❌ Frontend failed to start"
    return 1
}

# Use host X server instead of virtual display
echo "🖼️  Using host X server..."

# Set up audio (disable to avoid issues)
export AUDIODEV=none

# Check if frontend is ready
if ! check_frontend; then
    echo "❌ Frontend service is not available. Please ensure it's running."
    kill $XVFB_PID 2>/dev/null || true
    exit 1
fi

# Set Electron environment variables
export ELECTRON_IS_DEV=1
export ELECTRON_ENABLE_LOGGING=1
export ELECTRON_ENABLE_STACK_DUMPING=1

echo "🚀 Starting Electron application..."

# Start Electron based on mode
if [ "$1" = "--dev" ]; then
    echo "🔧 Development mode enabled"
    npm run dev
else
    echo "🏭 Production mode"
    npm start
fi

# Cleanup on exit
cleanup() {
    echo "🧹 Cleaning up..."
    exit 0
}

# Trap cleanup signals
trap cleanup SIGINT SIGTERM

# Wait for Electron process
wait