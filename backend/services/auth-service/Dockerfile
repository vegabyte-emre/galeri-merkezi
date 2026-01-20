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
COPY backend/services/auth-service/package.json ./backend/services/auth-service/
COPY backend/services/auth-service/tsconfig.json ./backend/services/auth-service/

# Install all dependencies
RUN npm install --legacy-peer-deps 2>/dev/null || npm install || true

# Copy shared source and build
COPY backend/shared ./backend/shared
WORKDIR /app/backend/shared
RUN npx tsc || true

# Copy service source and build
WORKDIR /app
COPY backend/services/auth-service ./backend/services/auth-service
WORKDIR /app/backend/services/auth-service
RUN npx tsc || true

# Setup @galeri/shared in node_modules
WORKDIR /app
RUN mkdir -p node_modules/@galeri/shared && \
    cp -r backend/shared/* node_modules/@galeri/shared/ 2>/dev/null || \
    cp -R backend/shared/. node_modules/@galeri/shared/ 2>/dev/null || true

# Production stage
FROM node:18-alpine

WORKDIR /app

# Copy everything from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/backend/shared ./backend/shared
COPY --from=builder /app/backend/services/auth-service/dist ./backend/services/auth-service/dist
COPY --from=builder /app/backend/services/auth-service/package.json ./backend/services/auth-service/

# Ensure @galeri/shared is in node_modules
RUN mkdir -p /app/node_modules/@galeri/shared && \
    cp -r /app/backend/shared/* /app/node_modules/@galeri/shared/ 2>/dev/null || true

WORKDIR /app/backend/services/auth-service

EXPOSE 3001
ENV PORT=3001
ENV NODE_ENV=production

CMD ["node", "dist/index.js"]
