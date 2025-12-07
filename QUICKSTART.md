# Quick Start Guide

## Launch the Desktop Application

### Option 1: Use the Startup Script (Easiest)

```bash
cd /home/ttt/apps/coding-ui
./start-app.sh
```

The Electron window will open automatically.

### Option 2: Manual Start

```bash
# 1. Allow X11 access
xhost +local:docker

# 2. Build containers (first time only)
docker compose build

# 3. Start the application
docker compose up
```

The Electron desktop window will appear once all services are ready.

## What Happens When You Start

1. **PostgreSQL** starts and initializes the database
2. **Symfony Backend** bootstraps using Composer and starts the API server
3. **Vue Frontend** starts the Vite dev server with hot reload
4. **Electron** opens a desktop window displaying the Vue app

## Stopping the Application

Press `Ctrl+C` in the terminal, or run:

```bash
docker compose down
```

## Accessing Components Individually

- **Electron Window**: Starts automatically with `docker compose up`
- **Web Browser**: http://localhost:5173 (same Vue app)
- **API**: http://localhost:8000/api
- **Database**: localhost:5432

## Troubleshooting

### Electron window doesn't appear

```bash
# Ensure X11 is accessible
xhost +local:docker
echo $DISPLAY  # Should show :0 or similar

# Check Electron logs
docker compose logs electron
```

### "Cannot open display" error

Make sure you're running on a system with X11:
- Linux: Should work out of the box
- WSL2: Install an X server like VcXsrv
- macOS: Install XQuartz

### Services not starting

```bash
# Check service status
docker compose ps

# View logs
docker compose logs -f

# Rebuild if needed
docker compose build --no-cache
```

## Development Mode

All services support hot reload:
- **Vue**: Changes to `.vue` files reload instantly
- **Symfony**: Changes to PHP files are reflected immediately
- **Electron**: Restart the electron service to see changes

```bash
# Restart just Electron
docker compose restart electron
```
