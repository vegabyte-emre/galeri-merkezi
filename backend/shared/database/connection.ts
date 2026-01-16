import { Pool, PoolConfig } from 'pg';
import { logger } from '../utils/logger';

const poolConfig: PoolConfig = {
  host: process.env.POSTGRES_HOST || 'localhost',
  port: parseInt(process.env.POSTGRES_PORT || '5432'),
  user: process.env.POSTGRES_USER || 'galeri_user',
  password: process.env.POSTGRES_PASSWORD || 'galeri_password',
  database: process.env.POSTGRES_DB || 'galeri_db',
  max: parseInt(process.env.POSTGRES_MAX_CONNECTIONS || '20'),
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000
};

export const pool = new Pool(poolConfig);

pool.on('error', (err) => {
  logger.error('Unexpected error on idle client', { error: err });
});

pool.on('connect', () => {
  logger.info('Database connection established');
});

// Test connection
pool.query('SELECT NOW()')
  .then(() => {
    logger.info('Database connection test successful');
  })
  .catch((err) => {
    logger.error('Database connection test failed', { error: err });
  });

export async function query(text: string, params?: any[]) {
  const start = Date.now();
  try {
    const res = await pool.query(text, params);
    const duration = Date.now() - start;
    logger.debug('Executed query', { duration, rows: res.rowCount });
    return res;
  } catch (error) {
    logger.error('Query error', { error, text });
    throw error;
  }
}

export async function getClient() {
  const client = await pool.connect();
  return client;
}
















