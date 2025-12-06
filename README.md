# Electron + Vue 3 + Symfony Dockerized Application

A full-stack dockerized application combining Electron desktop capabilities with Vue 3 frontend and Symfony backend.

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

**Start backend and frontend only:**

```bash
docker-compose up -d
```

This will start:
- PostgreSQL database on `localhost:5432`
- Symfony backend on `http://localhost:8000`
- Vue frontend on `http://localhost:5173`

**Start with Electron (requires X11):**

```bash
# On Linux, allow X11 connections
xhost +local:docker

# Start all services including Electron
docker-compose --profile desktop up
```

### 4. Access the Application

- **Web Frontend**: http://localhost:5173
- **API Documentation**: http://localhost:8000/api
- **Electron**: Opens automatically when using `--profile desktop`

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
