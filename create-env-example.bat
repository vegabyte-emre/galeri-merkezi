@echo off
(
echo # Environment Variables Example
echo # Copy this file to .env and update with your values
echo.
echo # Application
echo NODE_ENV=development
echo PORT=3000
echo.
echo # Database
echo POSTGRES_HOST=postgres
echo POSTGRES_PORT=5432
echo POSTGRES_USER=galeri_user
echo POSTGRES_PASSWORD=galeri_password
echo POSTGRES_DB=galeri_db
echo POSTGRES_MAX_CONNECTIONS=20
echo.
echo # Redis
echo REDIS_HOST=redis
echo REDIS_PORT=6379
echo REDIS_PASSWORD=
echo.
echo # RabbitMQ
echo RABBITMQ_HOST=rabbitmq
echo RABBITMQ_PORT=5672
echo RABBITMQ_USER=galeri_user
echo RABBITMQ_PASSWORD=galeri_password
echo RABBITMQ_VHOST=galeri
echo.
echo # JWT
echo JWT_SECRET=change_this_secret_in_production
echo JWT_EXPIRES_IN=15m
echo JWT_REFRESH_EXPIRES_IN=7d
echo.
echo # SMS Provider (NetGSM)
echo SMS_PROVIDER=netgsm
echo NETGSM_USERNAME=
echo NETGSM_PASSWORD=
echo NETGSM_MSG_HEADER=GALERIPLATFORM
echo.
echo # Email (SMTP)
echo SMTP_HOST=smtp.gmail.com
echo SMTP_PORT=587
echo SMTP_USER=
echo SMTP_PASSWORD=
echo SMTP_FROM=noreply@domain.com
echo.
echo # MinIO (S3-compatible storage)
echo MINIO_ENDPOINT=minio
echo MINIO_PORT=9000
echo MINIO_ACCESS_KEY=minioadmin
echo MINIO_SECRET_KEY=minioadmin
echo MINIO_BUCKET=galeri-media
echo MINIO_USE_SSL=false
echo.
echo # Meilisearch
echo MEILISEARCH_HOST=http://meilisearch:7700
echo MEILISEARCH_MASTER_KEY=master_key_change_in_production
echo.
echo # EIDS Integration
echo EIDS_API_URL=
echo EIDS_CLIENT_ID=
echo EIDS_CLIENT_SECRET=
echo EIDS_CALLBACK_URL=
echo.
echo # CORS
echo CORS_ORIGIN=http://localhost:3000,http://localhost:3001,http://localhost:3002
echo.
echo # Frontend URLs
echo LANDING_URL=http://localhost:3000
echo ADMIN_URL=http://localhost:3001
echo PANEL_URL=http://localhost:3002
echo.
echo # WebSocket
echo WS_URL=ws://localhost:3005
) > .env.example















