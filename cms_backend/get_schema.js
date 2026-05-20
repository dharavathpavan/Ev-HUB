const { Client } = require('pg');

const client = new Client({
  host: 'db.exgoxwxvdgocccrcfmow.supabase.co',
  port: 5432,
  database: 'postgres',
  user: 'postgres',
  password: 'lovenest29358',
  ssl: {
    rejectUnauthorized: false
  }
});

async function run() {
  await client.connect();
  const res = await client.query(`
    SELECT table_name, column_name, data_type 
    FROM information_schema.columns 
    WHERE table_schema = 'public'
    ORDER BY table_name;
  `);
  
  const schema = {};
  for (const row of res.rows) {
    if (!schema[row.table_name]) {
      schema[row.table_name] = [];
    }
    schema[row.table_name].push(`${row.column_name} (${row.data_type})`);
  }
  
  console.log(JSON.stringify(schema, null, 2));
  await client.end();
}

run().catch(err => {
  console.error(err);
  process.exit(1);
});
