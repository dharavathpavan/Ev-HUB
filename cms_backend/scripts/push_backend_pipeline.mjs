import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';
import { Client } from 'pg';

const rootDir = process.cwd();
const envPath = path.join(rootDir, '.env.local');
const schemaPath = path.join(rootDir, 'supabase', 'backend_schema.sql');

function loadEnvFile(filePath) {
  if (!fs.existsSync(filePath)) return;

  const lines = fs.readFileSync(filePath, 'utf8').split(/\r?\n/);
  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;

    const splitAt = trimmed.indexOf('=');
    if (splitAt === -1) continue;

    const key = trimmed.slice(0, splitAt).trim();
    const rawValue = trimmed.slice(splitAt + 1).trim();
    const value = rawValue.replace(/^['"]|['"]$/g, '');

    if (!process.env[key]) {
      process.env[key] = value;
    }
  }
}

function buildPgConfig() {
  if (process.env.SUPABASE_DB_URL) {
    return {
      connectionString: process.env.SUPABASE_DB_URL,
      ssl: { rejectUnauthorized: false },
    };
  }

  const projectRef = process.env.SUPABASE_PROJECT_REF;
  const host = process.env.SUPABASE_DB_HOST || (projectRef ? `db.${projectRef}.supabase.co` : undefined);
  const password = process.env.SUPABASE_DB_PASSWORD;

  if (!host || !password) {
    throw new Error(
      'Missing database connection. Set SUPABASE_DB_URL, or set SUPABASE_PROJECT_REF and SUPABASE_DB_PASSWORD in .env.local.'
    );
  }

  return {
    host,
    port: Number(process.env.SUPABASE_DB_PORT || 5432),
    database: process.env.SUPABASE_DB_NAME || 'postgres',
    user: process.env.SUPABASE_DB_USER || 'postgres',
    password,
    ssl: { rejectUnauthorized: false },
  };
}

async function verifyTables(client) {
  const requiredTables = [
    'vendor_applications',
    'vendor_profiles',
    'vendor_users',
    'vendor_orders',
    'vendor_payments',
    'charging_guns',
    'qr_mappings',
  ];

  const { rows } = await client.query(
    `
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'public'
      AND table_name = ANY($1)
      ORDER BY table_name
    `,
    [requiredTables]
  );

  const found = new Set(rows.map((row) => row.table_name));
  const missing = requiredTables.filter((table) => !found.has(table));

  if (missing.length > 0) {
    throw new Error(`Schema verification failed. Missing tables: ${missing.join(', ')}`);
  }

  console.log(`Verified ${requiredTables.length} backend tables in Supabase.`);
}

async function main() {
  loadEnvFile(envPath);

  if (!fs.existsSync(schemaPath)) {
    throw new Error(`Schema file not found: ${schemaPath}`);
  }

  const sql = fs.readFileSync(schemaPath, 'utf8');
  const client = new Client(buildPgConfig());

  console.log('Connecting to Supabase Postgres...');
  await client.connect();

  try {
    console.log('Pushing backend schema...');
    await client.query(sql);
    await verifyTables(client);
    console.log('Backend pipeline completed successfully.');
  } finally {
    await client.end();
  }
}

main().catch((error) => {
  console.error(`Backend pipeline failed: ${error.message}`);
  process.exit(1);
});
