#!/bin/bash

echo "🖥️  Starting Electron Desktop App in Docker..."

# Function to check if service is ready
check_service() {
    local service=$1
    local url=$2
    local max_attempts=30
    local attempt=1
    
    echo "⏳ Checking $service..."
    while [ $attempt -le $max_attempts ]; do
        if curl -s "$url" > /dev/null 2>&1; then
            echo "✅ $service is ready!"
            return 0
        fi
        echo "   Attempt $attempt/$max_attempts..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    echo "❌ $service failed to start"
    return 1
}

# Start services in order
echo "📦 Starting PostgreSQL..."
docker compose up -d postgres

echo "⏳ Waiting for database to be ready..."
sleep 5

echo "🔧 Starting Symfony backend..."
docker compose up -d backend

# Check backend health
if ! check_service "Backend API" "http://localhost:8000"; then
    echo "❌ Backend failed to start, exiting..."
    exit 1
fi

echo "🎨 Starting Vue3 frontend..."
docker compose up -d frontend

# Check frontend health
if ! check_service "Frontend" "http://localhost:5173"; then
    echo "❌ Frontend failed to start, exiting..."
    exit 1
fi

echo "🖥️  Starting Electron desktop app..."
docker compose up -d electron

echo ""
echo "✅ All services started!"
echo ""
echo "🌐 Access URLs:"
echo "   Frontend (Web): http://localhost:5173"
echo "   Backend API:    http://localhost:8000"
echo "   API Docs:       http://localhost:8000/api/docs"
echo ""
echo "🖥️  Electron Desktop App:"
echo "   The Electron app is running in a Docker container"
echo "   It will automatically connect to the frontend service"
echo ""
echo "📊 Check service status:"
echo "   docker compose ps"
echo ""
echo "📝 View logs:"
echo "   docker compose logs -f electron"
echo "   docker compose logs -f backend"
echo "   docker compose logs -f frontend"
echo ""
echo "🛑 Stop all services:"
echo "   docker compose down"
echo ""
echo "🔄 Restart Electron:"
echo "   docker compose restart electron"