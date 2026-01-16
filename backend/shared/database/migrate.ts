import { readdir, readFile } from 'fs/promises';
import { join } from 'path';
import { query, getClient } from './connection';
import { logger } from '../utils/logger';

const MIGRATIONS_DIR = join(process.cwd(), 'database', 'migrations');

async function ensureMigrationsTable() {
  await query(`
    CREATE TABLE IF NOT EXISTS schema_migrations (
      version VARCHAR(255) PRIMARY KEY,
      applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);
}

async function getAppliedMigrations(): Promise<string[]> {
  const result = await query('SELECT version FROM schema_migrations ORDER BY version');
  return result.rows.map((row) => row.version);
}

async function applyMigration(version: string, sql: string) {
  const client = await getClient();
  try {
    await client.query('BEGIN');
    await client.query(sql);
    await client.query('INSERT INTO schema_migrations (version) VALUES ($1)', [version]);
    await client.query('COMMIT');
    logger.info(`Migration ${version} applied successfully`);
  } catch (error) {
    await client.query('ROLLBACK');
    logger.error(`Migration ${version} failed`, { error });
    throw error;
  } finally {
    client.release();
  }
}

export async function runMigrations() {
  try {
    await ensureMigrationsTable();
    const appliedMigrations = await getAppliedMigrations();
    const files = await readdir(MIGRATIONS_DIR);
    const migrationFiles = files
      .filter((file) => file.endsWith('.sql'))
      .sort();

    for (const file of migrationFiles) {
      const version = file.replace('.sql', '');
      if (appliedMigrations.includes(version)) {
        logger.info(`Migration ${version} already applied, skipping`);
        continue;
      }

      logger.info(`Applying migration ${version}`);
      const sql = await readFile(join(MIGRATIONS_DIR, file), 'utf-8');
      await applyMigration(version, sql);
    }

    logger.info('All migrations completed');
  } catch (error) {
    logger.error('Migration process failed', { error });
    throw error;
  }
}

if (require.main === module) {
  runMigrations()
    .then(() => {
      process.exit(0);
    })
    .catch((error) => {
      logger.error('Migration script failed', { error });
      process.exit(1);
    });
}

