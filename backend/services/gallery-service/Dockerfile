FROM node:18-alpine AS builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache python3 make g++

# Copy root package files
COPY package.json ./
COPY package-lock.json* ./

# Copy workspace package files
COPY backend/shared/package.json ./backend/shared/
COPY backend/shared/tsconfig.json ./backend/shared/
COPY backend/services/gallery-service/package.json ./backend/services/gallery-service/
COPY backend/services/gallery-service/tsconfig.json ./backend/services/gallery-service/

# Install all dependencies
RUN npm install --legacy-peer-deps 2>/dev/null || npm install || true

# Copy shared source
COPY backend/shared ./backend/shared

# Build shared
WORKDIR /app/backend/shared
RUN npx tsc || true

# Copy service source
WORKDIR /app
COPY backend/services/gallery-service ./backend/services/gallery-service

# Build service
WORKDIR /app/backend/services/gallery-service
RUN npx tsc || true

# Production stage
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY --from=builder /app/package.json ./
COPY --from=builder /app/backend/shared/package.json ./backend/shared/
COPY --from=builder /app/backend/services/gallery-service/package.json ./backend/services/gallery-service/

# Copy built files
COPY --from=builder /app/backend/shared/dist ./backend/shared/dist
COPY --from=builder /app/backend/services/gallery-service/dist ./backend/services/gallery-service/dist

# Copy node_modules
COPY --from=builder /app/node_modules ./node_modules

WORKDIR /app/backend/services/gallery-service

EXPOSE 3002
ENV PORT=3002
ENV NODE_ENV=production

CMD ["node", "dist/index.js"]
