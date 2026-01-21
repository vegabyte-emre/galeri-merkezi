# Build stage
FROM node:20-alpine AS builder

# Build arguments for API URLs
ARG NUXT_PUBLIC_API_URL=https://api.otobia.com/api/v1
ARG NUXT_PUBLIC_WS_URL=wss://ws.otobia.com

WORKDIR /app

# Copy package files
COPY frontend/admin/package.json ./

# Install dependencies
RUN npm install --legacy-peer-deps

# Copy source code
COPY frontend/admin/ .

# Build the application (SPA mode)
ENV NODE_ENV=production
ENV NUXT_PUBLIC_API_URL=${NUXT_PUBLIC_API_URL}
ENV NUXT_PUBLIC_WS_URL=${NUXT_PUBLIC_WS_URL}
RUN npm run generate

# Production stage - serve static files with nginx
FROM nginx:alpine AS runner

# Copy built static files
COPY --from=builder /app/.output/public /usr/share/nginx/html

# Nginx config for SPA
RUN echo 'server { \
    listen 80; \
    server_name _; \
    root /usr/share/nginx/html; \
    index index.html; \
    \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
    \
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ { \
        expires 1y; \
        add_header Cache-Control "public, immutable"; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
