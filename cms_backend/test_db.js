const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://exgoxwxvdgocccrcfmow.supabase.co';
const supabaseKey = 'sb_publishable_yRe6KAiaT1l-mUTX7hmYYw_mXI-g1qo'; // Anon key from .env.local

const supabase = createClient(supabaseUrl, supabaseKey);

async function test() {
  console.log('Testing tables...');
  const tables = ['vendor_applications', 'vendor_profiles', 'charging_guns', 'qr_mappings', 'chargers', 'stations'];
  for (const table of tables) {
    try {
      const { data, error } = await supabase.from(table).select('*').limit(1);
      if (error) {
        console.log(`Table "${table}": Error ->`, error.message);
      } else {
        console.log(`Table "${table}": OK -> found`, data.length, 'rows');
      }
    } catch (e) {
      console.log(`Table "${table}": Exception ->`, e.message);
    }
  }
}

test();
