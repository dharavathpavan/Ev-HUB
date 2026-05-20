import { NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';

// This API mocks the OCPP 'ChangeConfiguration' and 'GetConfiguration' routines
export async function POST(req: Request) {
  try {
    const payload = await req.json();
    const { action, charger_id, key_name, value } = payload;

    if (!charger_id || !action) {
      return NextResponse.json({ error: 'Missing required fields' }, { status: 400 });
    }

    if (action === 'CHANGE_CONFIGURATION') {
      if (!key_name || value === undefined) {
        return NextResponse.json({ error: 'Missing key or value' }, { status: 400 });
      }

      // 1. Verify it is not readonly
      const { data: configCheck } = await supabaseAdmin
        .from('charger_configs')
        .select('is_readonly')
        .eq('charger_id', charger_id)
        .eq('key_name', key_name)
        .single();

      if (configCheck?.is_readonly) {
        return NextResponse.json({ success: false, message: 'Key is Read-Only by the manufacturer.' }, { status: 403 });
      }

      // 2. Update the config in DB
      const { error: configError } = await supabaseAdmin
        .from('charger_configs')
        .upsert({ charger_id, key_name, value, updated_at: new Date().toISOString() }, { onConflict: 'charger_id,key_name' });

      if (configError) throw configError;

      // 3. Log the OCPP Command
      await supabaseAdmin
        .from('ocpp_commands_log')
        .insert([{
          charger_id,
          command: `ChangeConfiguration (${key_name}=${value})`,
          status: 'Accepted',
          initiated_by: 'Configurator Wizard'
        }]);

      return NextResponse.json({ success: true, message: `Configuration updated: ${key_name} = ${value}` });
    }

    return NextResponse.json({ error: 'Invalid action' }, { status: 400 });

  } catch (err) {
    const error = err as Error;
    console.error('OCPP Configuration API Error:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
