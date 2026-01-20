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
COPY backend/services/chat-service/package.json ./backend/services/chat-service/
COPY backend/services/chat-service/tsconfig.json ./backend/services/chat-service/

# Install all dependencies
RUN npm install --legacy-peer-deps 2>/dev/null || npm install || true

# Copy shared source
COPY backend/shared ./backend/shared

# Build shared
WORKDIR /app/backend/shared
RUN npx tsc || true

# Copy chat-service source
WORKDIR /app
COPY backend/services/chat-service ./backend/services/chat-service

# Build chat-service
WORKDIR /app/backend/services/chat-service
RUN npx tsc || true

# Verify build
RUN ls -la dist/ 2>/dev/null || echo "No dist folder"

# Production stage
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY --from=builder /app/package.json ./
COPY --from=builder /app/backend/shared/package.json ./backend/shared/
COPY --from=builder /app/backend/services/chat-service/package.json ./backend/services/chat-service/

# Copy built files
COPY --from=builder /app/backend/shared/dist ./backend/shared/dist
COPY --from=builder /app/backend/services/chat-service/dist ./backend/services/chat-service/dist

# Copy node_modules
COPY --from=builder /app/node_modules ./node_modules

WORKDIR /app/backend/services/chat-service

EXPOSE 3005
ENV PORT=3005
ENV NODE_ENV=production

CMD ["node", "dist/index.js"]
