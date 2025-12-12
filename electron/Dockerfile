FROM node:20

# Layer 1: Base apt setup
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        gnupg \
        curl

# Layer 2: GTK stack
RUN set -eux; \
    apt-get install -y --no-install-recommends \
        libgtk-3-0 \
        libgdk-pixbuf2.0-0 \
        libpangocairo-1.0-0 \
        libatk1.0-0 \
        libcairo-gobject2

# Layer 3: Security and X11 helpers
RUN set -eux; \
    apt-get install -y --no-install-recommends \
        libnss3 \
        libxss1 \
        libxtst6 \
        libxrandr2 \
        libxshmfence1

# Layer 4: DRM and GPU
RUN set -eux; \
    apt-get install -y --no-install-recommends \
        libdrm2 \
        libgbm1

# Layer 5: Accessibility + notifications
RUN set -eux; \
    apt-get install -y --no-install-recommends \
        libatspi2.0-0 \
        libnotify4

# Layer 6: Audio
RUN set -eux; \
    apt-get install -y --no-install-recommends \
        libasound2

# Layer 7: Utilities
RUN set -eux; \
    apt-get install -y --no-install-recommends \
        xdg-utils \
        xvfb

# Layer 8: Legacy support + cleanup
RUN set -eux; \
    apt-get install -y --no-install-recommends \
        libgconf-2-4; \
    rm -rf /var/lib/apt/lists/*

# Layer 9: Set working directory
WORKDIR /app

# Layer 10: Copy package.json first for better caching
COPY package.json ./

# Layer 11: Copy package-lock.json if exists
COPY package-lock.json* ./

# Layer 12: Install npm dependencies with cache optimization
RUN npm install --silent && \
    npm cache clean --force

# Layer 13: Copy application source code
COPY main.js ./
COPY preload.js ./

# Layer 14: Create assets directory
RUN mkdir -p assets

# Layer 15: Create a simple icon (placeholder)
RUN echo "Creating placeholder icon..." && \
    echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" | \
    base64 -d > assets/icon.png

# Layer 16: Set display for X11
ENV DISPLAY=:99

# Layer 10: Create startup script
RUN echo '#!/bin/bash\n\
# Start virtual display\n\
Xvfb :99 -screen 0 1024x768x24 > /dev/null 2>&1 &\n\
\n\
# Wait for X server to start\n\
sleep 2\n\
\n\
# Set up audio (optional)\n\
export AUDIODEV=none\n\
\n\
# Start Electron\n\
if [ "$1" = "--dev" ]; then\n\
    echo "Starting Electron in development mode..."\n\
    npm run dev\n\
else\n\
    echo "Starting Electron in production mode..."\n\
    npm start\n\
fi' > /app/start-electron.sh && \
    chmod +x /app/start-electron.sh

# Layer 11: Expose VNC port for debugging (optional)
EXPOSE 5900

# Layer 12: Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD pgrep -f "electron" || exit 1

# Layer 13: Start Electron
CMD ["/app/start-electron.sh", "--dev"]
