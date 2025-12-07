#!/bin/bash

echo "🚀 Starting Dockerized Symfony + Vue3 App..."

# Start services in order
echo "📦 Starting PostgreSQL..."
docker compose up -d postgres

echo "⏳ Waiting for database to be ready..."
sleep 10

echo "🔧 Starting Symfony backend..."
docker compose up -d backend

echo "⏳ Waiting for backend to be ready..."
sleep 15

echo "🎨 Starting Vue3 frontend..."
docker compose up -d frontend

echo "✅ Services started!"
echo ""
echo "🌐 Access URLs:"
echo "   Frontend: http://localhost:5173"
echo "   Backend API: http://localhost:8000"
echo "   API Docs: http://localhost:8000/api/docs"
echo ""
echo "📊 Check service status:"
echo "   docker compose ps"
echo ""
echo "📝 View logs:"
echo "   docker compose logs -f backend"