# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build the application
ENV NODE_ENV=production
ENV NUXT_PUBLIC_API_URL=https://api.otobia.com/api/v1
ENV NUXT_PUBLIC_WS_URL=wss://ws.otobia.com
RUN npm run build

# Production stage
FROM node:20-alpine AS runner

WORKDIR /app

# Copy built application
COPY --from=builder /app/.output /app/.output

# Set environment variables
ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=3000
ENV NUXT_PUBLIC_API_URL=https://api.otobia.com/api/v1
ENV NUXT_PUBLIC_WS_URL=wss://ws.otobia.com

EXPOSE 3000

CMD ["node", ".output/server/index.mjs"]
