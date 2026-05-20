import { NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';

// This endpoint executes the Smart Charging algorithm for a specific station.
// It redistributes the available grid capacity equally among all actively charging vehicles.
export async function POST(req: Request) {
  try {
    const payload = await req.json();
    const { station_id } = payload;

    if (!station_id) {
      return NextResponse.json({ error: 'Missing station_id' }, { status: 400 });
    }

    // 1. Get Station Limits
    const { data: station, error: stationError } = await supabaseAdmin
      .from('stations')
      .select('max_power_capacity_kw, load_balancing_enabled')
      .eq('station_id', station_id)
      .single();

    if (stationError) throw stationError;

    if (!station.load_balancing_enabled) {
      return NextResponse.json({ 
        success: false, 
        message: 'Load balancing is disabled for this station. No action taken.' 
      });
    }

    // 2. Get Active Chargers
    const { data: chargers, error: chargersError } = await supabaseAdmin
      .from('chargers')
      .select('charger_id, max_kw_output, current_kw_output')
      .eq('station_id', station_id)
      .eq('status', 'Charging');

    if (chargersError) throw chargersError;

    if (!chargers || chargers.length === 0) {
      return NextResponse.json({ 
        success: true, 
        message: 'No active chargers to rebalance.' 
      });
    }

    // 3. Smart Charging Algorithm: Fair-Share Distribution
    const gridLimit = station.max_power_capacity_kw;
    
    // Equal division of power
    const fairShare = gridLimit / chargers.length;
    
    let totalAssigned = 0;
    const updates = [];

    for (const charger of chargers) {
      // A charger cannot draw more than its hardware limit
      const assignedKw = Math.min(fairShare, charger.max_kw_output);
      
      updates.push({
        charger_id: charger.charger_id,
        new_kw: parseFloat(assignedKw.toFixed(1))
      });
      totalAssigned += assignedKw;
    }

    // 4. Update the chargers in the database to simulate the hardware obeying the profile
    for (const update of updates) {
      await supabaseAdmin
        .from('chargers')
        .update({ current_kw_output: update.new_kw })
        .eq('charger_id', update.charger_id);
        
      // Log the SetChargingProfile action
      await supabaseAdmin
        .from('ocpp_commands_log')
        .insert([{
            charger_id: update.charger_id,
            command: 'SetChargingProfile (Rebalance)',
            status: 'Accepted',
            initiated_by: 'Smart Charging Engine'
        }]);
    }

    // 5. Update the station's total draw metric
    await supabaseAdmin
      .from('stations')
      .update({ current_total_kw_draw: parseFloat(totalAssigned.toFixed(1)) })
      .eq('station_id', station_id);

    return NextResponse.json({ 
      success: true, 
      message: `Grid Rebalanced. Distributed ${totalAssigned.toFixed(1)}kW across ${chargers.length} chargers.`,
      distribution: updates
    });

  } catch (err) {
    const error = err as Error;
    console.error('Smart Charging Error:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
