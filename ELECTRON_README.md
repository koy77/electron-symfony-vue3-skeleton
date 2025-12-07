# Electron + Vue3 + Symfony Docker App

A complete desktop application built with Electron, Vue3, and Symfony API Platform, all running in Docker containers.

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Electron      │    │     Vue3        │    │   Symfony       │
│   Desktop App   │◄──►│   Frontend      │◄──►│   Backend API   │
│   (Container)   │    │  (Container)    │    │  (Container)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                       │
                                               ┌─────────────────┐
                                               │   PostgreSQL    │
                                               │   Database      │
                                               │  (Container)    │
                                               └─────────────────┘
```

## 🚀 Quick Start

### Start the Complete App
```bash
./start-electron-docker.sh
```

This will start all services in order:
1. PostgreSQL database
2. Symfony backend with API Platform
3. Vue3 frontend
4. Electron desktop app

### Manual Start
```bash
# Start all services
docker compose up -d

# Start specific services
docker compose up -d postgres backend frontend electron
```

## 🖥️ Electron Features

### Desktop Capabilities
- ✅ Native window controls (minimize, maximize, close)
- ✅ Application menu with File, View, Window options
- ✅ File system access (read/write files)
- ✅ System information display
- ✅ Cross-platform support (Windows, macOS, Linux)
- ✅ Development tools integration

### Security Features
- ✅ Context isolation enabled
- ✅ Node integration disabled in renderer
- ✅ Secure IPC communication
- ✅ Preload script for safe API exposure

## 🌐 Access Points

| Service | URL | Description |
|---------|-----|-------------|
| **Electron App** | Desktop Window | Main desktop application |
| **Web Frontend** | http://localhost:5173 | Vue3 web interface |
| **Backend API** | http://localhost:8000 | Symfony REST API |
| **API Documentation** | http://localhost:8000/api/docs | Interactive API docs |
| **Database** | localhost:5432 | PostgreSQL database |

## 📁 Project Structure

```
coding-ui/
├── backend/                 # Symfony + API Platform
│   ├── Dockerfile
│   ├── docker-bootstrap.sh
│   ├── nginx.conf
│   └── supervisord.conf
├── frontend/                # Vue3 + TypeScript
│   ├── src/
│   │   ├── components/
│   │   │   └── ElectronControls.vue
│   │   ├── views/
│   │   ├── stores/
│   │   └── App.vue
│   └── Dockerfile
├── electron/                # Electron Desktop App
│   ├── main.js            # Main process
│   ├── preload.js         # Preload script
│   ├── Dockerfile
│   └── start-electron.sh
├── docker-compose.yml
├── start-electron-docker.sh
└── README.md
```

## 🛠️ Development

### Running in Development Mode
```bash
# Start with development features
./start-electron-docker.sh

# View Electron logs
docker compose logs -f electron

# Access Electron container
docker compose exec electron sh
```

### Building for Production
```bash
# Build Electron app
docker compose exec electron npm run build

# Create distributable
docker compose exec electron npx electron-builder
```

## 🔧 Configuration

### Environment Variables
```bash
# Database Configuration
POSTGRES_DB=app
POSTGRES_USER=app
POSTGRES_PASSWORD=!ChangeMe!

# Symfony Configuration
APP_ENV=dev
APP_SECRET=changeme_generate_a_real_secret_key

# Frontend Configuration
VITE_API_URL=http://backend:8000

# Electron Configuration
DISPLAY=:99
ELECTRON_IS_DEV=1
```

### Docker Compose Services
- **postgres**: PostgreSQL 16 database
- **backend**: Symfony 7 + API Platform
- **frontend**: Vue3 + Vite development server
- **electron**: Electron desktop application

## 📊 Monitoring

### Check Service Status
```bash
docker compose ps
```

### View Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f electron
docker compose logs -f backend
docker compose logs -f frontend
```

### Health Checks
```bash
# Backend API health
curl http://localhost:8000/api

# Frontend health
curl http://localhost:5173
```

## 🐛 Troubleshooting

### Common Issues

1. **Electron window doesn't appear**
   ```bash
   # Check Electron logs
   docker compose logs electron
   
   # Restart Electron service
   docker compose restart electron
   ```

2. **Frontend can't connect to backend**
   ```bash
   # Check backend logs
   docker compose logs backend
   
   # Verify network connectivity
   docker compose exec frontend curl http://backend:8000/api
   ```

3. **Database connection issues**
   ```bash
   # Check database logs
   docker compose logs postgres
   
   # Test database connection
   docker compose exec backend php bin/console doctrine:database:create
   ```

### Reset Services
```bash
# Stop and remove all containers
docker compose down

# Remove volumes (WARNING: This deletes data)
docker compose down -v

# Rebuild and start
docker compose up -d --build
```

## 📦 Dependencies

### Backend (Symfony)
- PHP 8.3
- Symfony 7
- API Platform
- PostgreSQL 16
- Nginx

### Frontend (Vue3)
- Node.js 20
- Vue 3
- TypeScript
- Vite
- Pinia (state management)
- Vue Router

### Electron
- Electron 28
- Node.js 20
- X11 libraries (for GUI display)

## 📄 License

MIT License - see LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with Docker
5. Submit a pull request