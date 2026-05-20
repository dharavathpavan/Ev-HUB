import { NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';
import { mockDb } from '@/lib/mockDb';

export async function GET() {
  try {
    const mockMappings = mockDb.getQrMappings();
    
    try {
      const { data: dbMappings } = await supabaseAdmin
        .from('qr_mappings')
        .select('*');
      if (dbMappings && dbMappings.length > 0) {
        return NextResponse.json({ success: true, mappings: dbMappings });
      }
    } catch (_) {}
    
    return NextResponse.json({ success: true, mappings: mockMappings });
  } catch (err) {
    const error = err as Error;
    return NextResponse.json({ success: false, error: error.message }, { status: 500 });
  }
}

export async function POST(req: Request) {
  try {
    const body = await req.json();
    const { qr_id, charger_id, gun_index } = body;

    if (!qr_id || !charger_id || gun_index === undefined) {
      return NextResponse.json({ success: false, error: 'Missing parameters: qr_id, charger_id, gun_index are required' }, { status: 400 });
    }

    const newMapping = mockDb.mapQr({
      qr_id,
      charger_id,
      gun_index: Number(gun_index)
    });

    try {
      await supabaseAdmin
        .from('qr_mappings')
        .upsert({
          qr_id,
          charger_id,
          gun_index: Number(gun_index),
          short_url: `https://app.bleuright.com/charge?qr=${qr_id}`,
          created_at: new Date().toISOString()
        }, { onConflict: 'qr_id' });
    } catch (_) {}

    return NextResponse.json({ 
      success: true, 
      message: `QR ${qr_id} mapped to Charger ${charger_id} Connector ${gun_index} successfully.`, 
      mapping: newMapping 
    });

  } catch (err) {
    const error = err as Error;
    console.error('QR Mapping Error:', error);
    return NextResponse.json({ success: false, error: error.message }, { status: 500 });
  }
}
