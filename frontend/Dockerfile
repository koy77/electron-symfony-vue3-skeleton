FROM node:20-alpine

# Layer 1: Set working directory
WORKDIR /app

# Layer 2: Copy package.json first for better caching
COPY package.json ./

# Layer 3: Copy package-lock.json if exists
COPY package-lock.json* ./

# Layer 4: Install npm dependencies with cache optimization
RUN npm install 
RUN npm cache clean --force

# Layer 5: Copy application source code
COPY src/ ./src/
COPY index.html ./
COPY tsconfig.json ./
COPY tsconfig.node.json ./
COPY vite.config.ts ./

# Layer 6: Copy .env files if they exist
COPY .env* ./

# Layer 7: Expose port
EXPOSE 5173

# Layer 8: Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5173/ || exit 1

# Layer 9: Start development server
CMD ["npm", "run", "dev"]
