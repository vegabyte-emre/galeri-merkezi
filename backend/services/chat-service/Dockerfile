FROM node:18-alpine AS builder

WORKDIR /app

# Copy root package files
COPY package.json ./
COPY package-lock.json* ./

# Copy workspace package files
COPY backend/shared/package.json ./backend/shared/
COPY backend/services/chat-service/package.json ./backend/services/chat-service/

# Install dependencies
RUN npm install --legacy-peer-deps

# Copy source files
COPY tsconfig.json ./
COPY backend/shared ./backend/shared
COPY backend/services/chat-service ./backend/services/chat-service

# Build shared first
WORKDIR /app/backend/shared
RUN npm run build

# Build chat-service
WORKDIR /app/backend/services/chat-service
RUN npm run build

# Production stage
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package.json ./
COPY backend/shared/package.json ./backend/shared/
COPY backend/services/chat-service/package.json ./backend/services/chat-service/

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
