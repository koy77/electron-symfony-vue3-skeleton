FROM node:20

# Install X11 and other dependencies for Electron
RUN apt-get update
RUN apt-get install -y libgtk-3-0
RUN apt-get install -y libnotify4
RUN apt-get install -y libnss3
RUN apt-get install -y libxss1
RUN apt-get install -y libxtst6
RUN apt-get install -y xdg-utils
RUN apt-get install -y libatspi2.0-0
RUN apt-get install -y libdrm2
RUN apt-get install -y libgbm1
RUN apt-get install -y libxshmfence1
RUN rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy application code
COPY . .

# Set display for X11
ENV DISPLAY=:0

# Start Electron in dev mode
CMD ["npm", "run", "dev"]
