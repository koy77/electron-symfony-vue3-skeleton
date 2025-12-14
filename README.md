# Electron + Vue 3 + Symfony Dockerized Application

A full-stack dockerized desktop application built with Electron, featuring a Vue 3 frontend and Symfony backend. The application runs as a native-looking desktop window via Electron, with all components orchestrated through Docker.

## 🚀 Tech Stack

- **Frontend**: Vue 3 with TypeScript, Vite, Vue Router, Pinia
- **Backend**: Symfony 7.1 with API Platform
- **Desktop**: Electron 28
- **Database**: PostgreSQL 16
- **Infrastructure**: Docker & Docker Compose

## 📋 Prerequisites

- Docker (20.10+)
- Docker Compose (2.0+)
- For Electron GUI: X11 server (Linux) or XQuartz (macOS)

## 🏗️ Project Structure

```
.
├── backend/          # Symfony 7.1 API
│   ├── Dockerfile
│   ├── docker-bootstrap.sh
│   └── ...
├── frontend/         # Vue 3 + TypeScript
│   ├── src/
│   ├── Dockerfile
│   └── ...
├── electron/         # Electron desktop app
│   ├── main.js
│   ├── preload.js
│   ├── Dockerfile
│   └── ...
├── docker-compose.yml
└── .env
```

## 🚦 Getting Started

### 1. Clone and Setup

```bash
cd /home/ttt/apps/coding-ui
```

### 2. Configure Environment

Edit `.env` file to customize database credentials and other settings:

```bash
# Database
POSTGRES_DB=app
POSTGRES_USER=app
POSTGRES_PASSWORD=!ChangeMe!

# Symfony
APP_SECRET=changeme_generate_a_real_secret_key
```

### 3. Start the Application

#### a) Using `start.sh` (Docker backend + desktop app)

**Tauri desktop app (recommended for development):**

```bash
./start.sh tauri
```

This script will:
- Build or update Docker images
- Start PostgreSQL and the Symfony backend in Docker
- Wait for the backend at `http://localhost:8001/api`
- Start the Vite dev server at `http://localhost:5173`
- Launch the Tauri desktop window on your host system

**Legacy Electron-in-Docker mode (original Electron setup):**

```bash
./start.sh
```

This script will:
- Configure X11 access for the Electron GUI (see Troubleshooting section)
- Start all services (PostgreSQL, Symfony, Vue, Electron)
- Open the Electron desktop window automatically

#### b) Manual Start

```bash
# Allow X11 connections
xhost +local:docker

# Start all services
docker compose up
```

**Start backend and frontend only (without Electron):**

```bash
# Stop Electron if running
docker compose stop electron

# Access via browser
docker compose up postgres backend frontend
```

### 4. Access the Application

- **Primary Interface**: Electron or Tauri desktop window (opens automatically, depending on how you start the app)
- **Alternative - Web Browser**: http://localhost:5173
- **API Documentation**: http://localhost:8001/api
- **Database**: localhost:5432

## 🔧 Development

### Backend (Symfony)

The backend uses Composer to bootstrap Symfony on first run. The bootstrap script:
1. Creates a new Symfony 7.1 project
2. Installs API Platform and required packages
3. Configures database connection

**Run Symfony commands:**

```bash
docker-compose exec backend php bin/console <command>
```

**Create a new entity:**

```bash
docker-compose exec backend php bin/console make:entity
```

**Run migrations:**

```bash
docker-compose exec backend php bin/console doctrine:migrations:migrate
```

### Frontend (Vue 3)

Hot module replacement is enabled by default. Changes to Vue files will automatically reload.

**Install new packages:**

```bash
docker-compose exec frontend npm install <package>
```

**Build for production:**

```bash
docker-compose exec frontend npm run build
```

### Electron

The Electron app loads the Vue frontend from the dev server in development mode.

**IPC Communication:**

The app includes example IPC handlers in `electron/main.js` and exposes them via `electron/preload.js`. Access them in Vue components:

```typescript
if (window.isElectron) {
  const version = await window.electronAPI.getAppVersion()
  const platform = await window.electronAPI.getPlatform()
}
```

## 🐳 Docker Commands

```bash
# Build all containers
docker-compose build

# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f [service-name]

# Restart a service
docker-compose restart [service-name]

# Remove all data (including database)
docker-compose down -v
```

## 📦 Production Build

### Frontend

```bash
cd frontend
npm run build
```

### Electron

```bash
cd electron
npm install
npm run build  # Requires electron-builder configuration
```

The Electron app can be packaged for Windows, macOS, and Linux using electron-builder.

## 🔍 API Development

The Symfony backend uses API Platform. To create a new API resource:

1. Create an entity:
```bash
docker-compose exec backend php bin/console make:entity Product
```

2. Add API Platform attributes in the entity:
```php
use ApiPlatform\Metadata\ApiResource;

#[ApiResource]
class Product
{
    // ...
}
```

3. Run migrations:
```bash
docker-compose exec backend php bin/console make:migration
docker-compose exec backend php bin/console doctrine:migrations:migrate
```

The API will be automatically available at `/api/products`.

## 🛠️ Troubleshooting

### Electron doesn't display

**Linux:**
```bash
xhost +local:docker
export DISPLAY=:0
```

**macOS:**
Install XQuartz and configure it to allow network connections.

### Backend fails to start

Check if Composer dependencies are installed:
```bash
docker-compose exec backend composer install
```

### Port already in use

Change ports in `docker-compose.yml` or stop conflicting services.

## 📝 License

MIT

## 🤝 Contributing

Feel free to submit issues and enhancement requests!
