FROM node:18-alpine AS builder

WORKDIR /app

# Step 1: Copy root package files
COPY package.json ./
COPY package-lock.json* ./

# Step 2: Copy workspace package files (for dependency resolution)
COPY backend/shared/package.json ./backend/shared/
COPY backend/services/api-gateway/package.json ./backend/services/api-gateway/

# Step 3: Install dependencies (workspace dependencies will be linked)
RUN npm install

# Step 4: Copy source files
COPY tsconfig.json ./
COPY backend/shared ./backend/shared
COPY backend/services/api-gateway ./backend/services/api-gateway

# Step 5: Build shared first
WORKDIR /app/backend/shared
RUN npm run build

# Step 6: Build api-gateway
WORKDIR /app/backend/services/api-gateway
RUN npm run build

# Production stage
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package.json ./
COPY backend/shared/package.json ./backend/shared/
COPY backend/services/api-gateway/package.json ./backend/services/api-gateway/

# Copy built files
COPY --from=builder /app/backend/shared/dist ./backend/shared/dist
COPY --from=builder /app/backend/services/api-gateway/dist ./backend/services/api-gateway/dist

# Copy node_modules (includes workspace dependencies)
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/backend/shared/node_modules ./backend/shared/node_modules 2>/dev/null || true
COPY --from=builder /app/backend/services/api-gateway/node_modules ./backend/services/api-gateway/node_modules 2>/dev/null || true

WORKDIR /app/backend/services/api-gateway

EXPOSE 8000

ENV PORT=8000
ENV NODE_ENV=production

CMD ["node", "dist/index.js"]
