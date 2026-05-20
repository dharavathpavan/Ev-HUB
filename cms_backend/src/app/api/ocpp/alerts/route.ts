import { NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';

// Handles incoming faults from chargers OR resolution requests from the CMS
export async function POST(req: Request) {
  try {
    const payload = await req.json();
    const { action, alert_id, charger_id, station_id, error_code, description, severity } = payload;

    if (action === 'REPORT_FAULT') {
      // 1. Create the alert
      const { error: alertError } = await supabaseAdmin
        .from('alerts')
        .insert([{ charger_id, station_id, error_code, description, severity, status: 'Open' }]);

      if (alertError) throw alertError;

      // 2. Mark charger as faulted
      const { error: chargerError } = await supabaseAdmin
        .from('chargers')
        .update({ status: 'Faulted', current_kw_output: 0 })
        .eq('charger_id', charger_id);

      if (chargerError) throw chargerError;

      return NextResponse.json({ success: true, message: 'Fault registered.' });
    } 
    else if (action === 'RESOLVE_FAULT') {
      if (!alert_id || !charger_id) return NextResponse.json({ error: 'Missing alert_id or charger_id' }, { status: 400 });

      // 1. Mark alert as resolved
      const { error: alertError } = await supabaseAdmin
        .from('alerts')
        .update({ status: 'Resolved', resolved_at: new Date().toISOString() })
        .eq('id', alert_id);

      if (alertError) throw alertError;

      // 2. Send Reset/Unlock connector command via OCPP, then mark Available
      // (Mocking the success of resetting the charger)
      const { error: chargerError } = await supabaseAdmin
        .from('chargers')
        .update({ status: 'Available' })
        .eq('charger_id', charger_id);

      if (chargerError) throw chargerError;

      return NextResponse.json({ success: true, message: 'Fault resolved. Charger available.' });
    }

    return NextResponse.json({ error: 'Invalid action' }, { status: 400 });

  } catch (err) {
    const error = err as Error;
    console.error('Alert API Error:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
