import { NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';

export async function POST(req: Request) {
  try {
    const payload = await req.json();
    const { station_id, max_power_capacity_kw, load_balancing_enabled } = payload;

    if (!station_id) {
      return NextResponse.json({ error: 'Missing station_id' }, { status: 400 });
    }

    // 1. Update the Station configuration in the DB
    const { error: stationError } = await supabaseAdmin
      .from('stations')
      .update({
        max_power_capacity_kw,
        load_balancing_enabled
      })
      .eq('station_id', station_id);

    if (stationError) throw stationError;

    // 2. Simulate OCPP SetChargingProfile commands to physical chargers
    // In a real system, if load_balancing_enabled is true, we calculate 
    // the fair share or priority-based limit and send it to chargers.
    if (load_balancing_enabled) {
      // Mock logic: Fetch active chargers for this station
      const { data: chargers } = await supabaseAdmin
        .from('chargers')
        .select('charger_id, current_kw_output')
        .eq('station_id', station_id)
        .eq('status', 'Charging');
        
      if (chargers && chargers.length > 0) {
        const fairShareLimit = max_power_capacity_kw / chargers.length;
        console.log(`Smart Load Balancer: Station ${station_id} fair share limit calculated as ${fairShareLimit} kW`);
        
        // Log this smart charging action
        for (const charger of chargers) {
          await supabaseAdmin
            .from('ocpp_commands_log')
            .insert([
              {
                charger_id: charger.charger_id,
                command: 'SetChargingProfile',
                status: 'Sent',
                initiated_by: 'Smart Load Balancer (Auto)',
              }
            ]);
        }
      }
    }

    return NextResponse.json({ 
      success: true, 
      message: `Load Balancing config applied to ${station_id}. Profile updates dispatched.` 
    });

  } catch (err) {
    const error = err as Error;
    console.error('Load Balancing API Error:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
