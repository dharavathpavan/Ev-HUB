const { Client } = require('pg');

async function test(host, port) {
  console.log(`Testing ${host}:${port}...`);
  const client = new Client({
    host,
    port,
    database: 'postgres',
    user: 'postgres',
    password: 'lovenest29358',
    ssl: { rejectUnauthorized: false }
  });
  try {
    await client.connect();
    console.log(`SUCCESS connected to ${host}:${port}!`);
    await client.end();
    return true;
  } catch (e) {
    console.log(`FAILED ${host}:${port}:`, e.message);
    return false;
  }
}

async function run() {
  await test('db.exgoxwxvdgocccrcfmow.supabase.co', 5432);
  await test('db.exgoxwxvdgocccrcfmow.supabase.co', 6543);
  await test('aws-0-us-east-1.pooler.supabase.com', 5432);
  await test('aws-0-us-east-1.pooler.supabase.com', 6543);
}

run();
