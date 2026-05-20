import { NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';
import { mockDb } from '@/lib/mockDb';

// This endpoint receives Remote Commands from the CMS frontend and
// forwards them to the OCPP server (or handles them directly in this demo).

export async function POST(req: Request) {
  try {
    const payload = await req.json();
    const { charger_id, command } = payload;

    if (!charger_id || !command) {
      return NextResponse.json({ error: 'Missing charger_id or command' }, { status: 400 });
    }

    // 1. Log the command in the audit trail
    try {
      await supabaseAdmin
        .from('ocpp_commands_log')
        .insert([
          {
            charger_id,
            command,
            status: 'Accepted', // Mocking immediate CSMS acceptance
            initiated_by: 'Super Admin',
          }
        ]);
    } catch (err) {
      console.error('Audit Log Error (ignored in fallback):', err);
    }

    // 2. Simulate the physical charger responding to the command
    let newStatus = '';
    let newKw = 0.0;

    switch (command) {
      case 'RemoteStartTransaction':
        newStatus = 'Charging';
        newKw = 45.0; // Simulated ramp-up
        mockDb.updateGunStatus(charger_id, 1, 'Charging');
        break;
      case 'RemoteStopTransaction':
        newStatus = 'Available';
        newKw = 0.0;
        mockDb.updateGunStatus(charger_id, 1, 'Available');
        mockDb.updateGunStatus(charger_id, 2, 'Available');
        break;
      case 'Reset':
      case 'Reboot':
        newStatus = 'Offline'; // Temporarily offline during reboot
        newKw = 0.0;
        mockDb.updateGunStatus(charger_id, 1, 'Offline');
        mockDb.updateGunStatus(charger_id, 2, 'Offline');
        break;
      case 'UnlockConnector':
        newStatus = 'Available';
        newKw = 0.0;
        mockDb.updateGunStatus(charger_id, 1, 'Available');
        break;
      case 'ChangeAvailability':
        newStatus = payload.new_status ?? 'Unavailable';
        newKw = 0.0;
        break;
      default:
        return NextResponse.json({ error: 'Unknown Command' }, { status: 400 });
    }

    // 3. Update the charger status in Supabase (which triggers real-time UI)
    try {
      await supabaseAdmin
        .from('chargers')
        .update({
          status: newStatus,
          current_kw_output: newKw,
        })
        .eq('charger_id', charger_id);
    } catch (err) {
      console.error('Charger update error (ignored in fallback):', err);
    }

    // In a real system, we'd wait for an OCPP 'CallResult' from the station
    // before returning Success, but for the CMS, we return 'Sent'.
    return NextResponse.json({ 
      success: true, 
      message: `Command ${command} sent and accepted by ${charger_id}.` 
    });

  } catch (err) {
    const error = err as Error;
    console.error('Remote Command Error:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

