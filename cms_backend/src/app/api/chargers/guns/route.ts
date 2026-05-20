import { NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';
import { mockDb } from '@/lib/mockDb';

export async function GET(req: Request) {
  try {
    const { searchParams } = new URL(req.url);
    const chargerId = searchParams.get('charger_id');

    const mockGuns = mockDb.getGuns(chargerId || undefined);

    try {
      let query = supabaseAdmin.from('charging_guns').select('*');
      if (chargerId) {
        query = query.eq('charger_id', chargerId);
      }
      const { data: dbGuns } = await query;
      if (dbGuns && dbGuns.length > 0) {
        return NextResponse.json({ success: true, guns: dbGuns });
      }
    } catch (_) {}

    return NextResponse.json({ success: true, guns: mockGuns });
  } catch (err) {
    const error = err as Error;
    return NextResponse.json({ success: false, error: error.message }, { status: 500 });
  }
}

export async function POST(req: Request) {
  try {
    const body = await req.json();
    const { charger_id, gun_index, connector_type, max_kw_output } = body;

    if (!charger_id || gun_index === undefined || !connector_type) {
      return NextResponse.json({ success: false, error: 'Missing parameters: charger_id, gun_index, connector_type are required' }, { status: 400 });
    }

    const newGun = mockDb.addGun({
      charger_id,
      gun_index: Number(gun_index),
      connector_type,
      max_kw_output: Number(max_kw_output) || 150.0
    });

    try {
      await supabaseAdmin
        .from('charging_guns')
        .upsert({
          charger_id,
          gun_index: Number(gun_index),
          connector_type,
          max_kw_output: Number(max_kw_output) || 150.0,
          status: 'Available',
          updated_at: new Date().toISOString()
        }, { onConflict: 'charger_id,gun_index' });
    } catch (_) {}

    return NextResponse.json({ 
      success: true, 
      message: `Charging Gun ${gun_index} configured successfully.`, 
      gun: newGun 
    });

  } catch (err) {
    const error = err as Error;
    console.error('Add Charging Gun Error:', error);
    return NextResponse.json({ success: false, error: error.message }, { status: 500 });
  }
}
