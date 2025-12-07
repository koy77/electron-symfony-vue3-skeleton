FROM node:20

# Install all system packages in a single layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    gnupg \
    curl \
    libgtk-3-0 \
    libgdk-pixbuf2.0-0 \
    libpangocairo-1.0-0 \
    libatk1.0-0 \
    libcairo-gobject2 \
    libnss3 \
    libxss1 \
    libxtst6 \
    libxrandr2 \
    libxshmfence1 \
    libdrm2 \
    libgbm1 \
    libatspi2.0-0 \
    libnotify4 \
    libasound2 \
    xdg-utils \
    xvfb \
    libgconf-2-4 \
    && rm -rf /var/lib/apt/lists/*

# Layer 2: Set working directory
WORKDIR /app

# Layer 3: Copy package.json first for better caching
COPY package.json ./

# Layer 4: Copy package-lock.json if exists
COPY package-lock.json* ./

# Layer 5: Install npm dependencies with cache optimization
RUN npm ci --only=production --silent && \
    npm cache clean --force

# Layer 6: Copy application source code
COPY main.js ./
COPY preload.js ./

# Layer 7: Create assets directory
RUN mkdir -p assets

# Layer 8: Create a simple icon (placeholder)
RUN echo "Creating placeholder icon..." && \
    echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" | \
    base64 -d > assets/icon.png

# Layer 9: Set display for X11
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
