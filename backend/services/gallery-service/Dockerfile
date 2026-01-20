FROM node:18-alpine AS builder

WORKDIR /app

# Copy root package files
COPY package.json ./
COPY package-lock.json* ./

# Copy workspace package files
COPY backend/shared/package.json ./backend/shared/
COPY backend/services/gallery-service/package.json ./backend/services/gallery-service/

# Install dependencies
RUN npm install --legacy-peer-deps

# Copy source files
COPY tsconfig.json ./
COPY backend/shared ./backend/shared
COPY backend/services/gallery-service ./backend/services/gallery-service

# Build shared first
WORKDIR /app/backend/shared
RUN npm run build

# Build gallery-service
WORKDIR /app/backend/services/gallery-service
RUN npm run build

# Production stage
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package.json ./
COPY backend/shared/package.json ./backend/shared/
COPY backend/services/gallery-service/package.json ./backend/services/gallery-service/

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
