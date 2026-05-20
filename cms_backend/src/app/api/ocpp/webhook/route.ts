import { NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';

// This acts as an OCPP 1.6J / 2.0.1 Webhook Listener.
// An external OCPP server (like SteVe or a custom CSMS) would forward requests here.

export async function POST(req: Request) {
  try {
    const payload = await req.json();
    const { action, charger_id, payload: ocppPayload } = payload;

    if (!charger_id || !action) {
      return NextResponse.json({ error: 'Missing charger_id or action' }, { status: 400 });
    }

    // 1. Heartbeat Event
    if (action === 'Heartbeat') {
      const { error } = await supabaseAdmin
        .from('chargers')
        .update({ last_heartbeat: new Date().toISOString() })
        .eq('charger_id', charger_id);
      
      if (error) throw error;
      return NextResponse.json({ status: 'Heartbeat Accepted' });
    }

    // 2. StatusNotification Event
    if (action === 'StatusNotification') {
      const { status, errorCode } = ocppPayload;
      
      let mappedStatus = 'Available';
      if (status === 'Preparing' || status === 'Charging') mappedStatus = 'Charging';
      if (status === 'Faulted' || errorCode !== 'NoError') mappedStatus = 'Faulted';
      if (status === 'Unavailable') mappedStatus = 'Offline';

      const { error } = await supabaseAdmin
        .from('chargers')
        .update({ status: mappedStatus })
        .eq('charger_id', charger_id);

      if (error) throw error;
      return NextResponse.json({ status: 'Status Updated' });
    }

    // 3. MeterValues Event (Real-time telemetry update)
    if (action === 'MeterValues') {
      // In a real scenario, we parse the sampled values.
      // Here we assume standard format for demo.
      const { current_kw, voltage, temperature } = ocppPayload;

      const { error } = await supabaseAdmin
        .from('chargers')
        .update({ 
          current_kw_output: current_kw ?? 0,
          voltage: voltage ?? 0,
          temperature: temperature ?? 25
        })
        .eq('charger_id', charger_id);

      if (error) throw error;
      return NextResponse.json({ status: 'Telemetry Updated' });
    }

    return NextResponse.json({ error: 'Action not handled' }, { status: 400 });

  } catch (err) {
    const error = err as Error;
    console.error('OCPP Webhook Error:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
