import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseAdminKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl) {
  throw new Error('Missing required environment variable NEXT_PUBLIC_SUPABASE_URL.');
}

const supabaseKey = supabaseAdminKey || supabaseAnonKey;
if (!supabaseKey) {
  throw new Error('Missing required Supabase key. Set SUPABASE_SERVICE_ROLE_KEY or NEXT_PUBLIC_SUPABASE_ANON_KEY.');
}

if (!supabaseAdminKey) {
  console.warn(
    'Running with NEXT_PUBLIC_SUPABASE_ANON_KEY instead of SUPABASE_SERVICE_ROLE_KEY. ' +
    'Admin mutations may fail in production. Provide SUPABASE_SERVICE_ROLE_KEY for backend operations.'
  );
}

export const supabaseAdmin = createClient(supabaseUrl, supabaseKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
  },
});
