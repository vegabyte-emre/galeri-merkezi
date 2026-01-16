import { config as dotenvConfig } from 'dotenv';

dotenvConfig();

export const config = {
  env: process.env.NODE_ENV || 'development',
  port: parseInt(process.env.PORT || '3000'),
  
  // Database
  database: {
    host: process.env.POSTGRES_HOST || 'localhost',
    port: parseInt(process.env.POSTGRES_PORT || '5432'),
    user: process.env.POSTGRES_USER || 'galeri_user',
    password: process.env.POSTGRES_PASSWORD || 'galeri_password',
    database: process.env.POSTGRES_DB || 'galeri_db',
    maxConnections: parseInt(process.env.POSTGRES_MAX_CONNECTIONS || '20')
  },

  // Redis
  redis: {
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT || '6379'),
    password: process.env.REDIS_PASSWORD || undefined
  },

  // RabbitMQ
  rabbitmq: {
    host: process.env.RABBITMQ_HOST || 'localhost',
    port: parseInt(process.env.RABBITMQ_PORT || '5672'),
    user: process.env.RABBITMQ_USER || 'galeri_user',
    password: process.env.RABBITMQ_PASSWORD || 'galeri_password',
    vhost: process.env.RABBITMQ_VHOST || 'galeri'
  },

  // JWT
  jwt: {
    secret: process.env.JWT_SECRET || 'change_this_secret',
    expiresIn: process.env.JWT_EXPIRES_IN || '15m',
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d'
  },

  // SMS
  sms: {
    provider: process.env.SMS_PROVIDER || 'netgsm',
    netgsm: {
      username: process.env.NETGSM_USERNAME || '',
      password: process.env.NETGSM_PASSWORD || '',
      msgHeader: process.env.NETGSM_MSG_HEADER || 'GALERIPLATFORM'
    }
  },

  // Email
  email: {
    smtp: {
      host: process.env.SMTP_HOST || 'smtp.gmail.com',
      port: parseInt(process.env.SMTP_PORT || '587'),
      user: process.env.SMTP_USER || '',
      password: process.env.SMTP_PASSWORD || '',
      from: process.env.SMTP_FROM || 'noreply@domain.com'
    }
  },

  // MinIO
  minio: {
    endpoint: process.env.MINIO_ENDPOINT || 'localhost',
    port: parseInt(process.env.MINIO_PORT || '9000'),
    accessKey: process.env.MINIO_ACCESS_KEY || 'minioadmin',
    secretKey: process.env.MINIO_SECRET_KEY || 'minioadmin',
    bucket: process.env.MINIO_BUCKET || 'galeri-media',
    useSSL: process.env.MINIO_USE_SSL === 'true'
  },

  // Meilisearch
  meilisearch: {
    host: process.env.MEILISEARCH_HOST || 'http://localhost:7700',
    masterKey: process.env.MEILISEARCH_MASTER_KEY || 'master_key'
  },

  // EİDS
  eids: {
    apiUrl: process.env.EIDS_API_URL || '',
    clientId: process.env.EIDS_CLIENT_ID || '',
    clientSecret: process.env.EIDS_CLIENT_SECRET || '',
    callbackUrl: process.env.EIDS_CALLBACK_URL || ''
  }
};
















