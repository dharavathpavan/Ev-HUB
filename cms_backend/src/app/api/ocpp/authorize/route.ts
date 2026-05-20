import { NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';

// Called when a physical RFID Card is tapped on a charger
// Validates the offline RFID against the user's wallet
export async function POST(req: Request) {
  try {
    const payload = await req.json();
    const { idTag, charger_id } = payload; // idTag is the physical RFID UID

    if (!idTag) return NextResponse.json({ error: 'Missing idTag' }, { status: 400 });

    // 1. Check RFID Tag in database
    const { data: rfid, error: rfidError } = await supabaseAdmin
      .from('rfid_tags')
      .select('*')
      .eq('uid', idTag)
      .single();

    if (rfidError || !rfid) {
      return NextResponse.json({ idTagInfo: { status: 'Invalid', parentIdTag: '' } });
    }

    if (rfid.status !== 'Active') {
      return NextResponse.json({ idTagInfo: { status: 'Blocked', parentIdTag: rfid.wallet_id } });
    }

    // 2. Check linked Wallet Balance
    const { data: wallet } = await supabaseAdmin
      .from('wallets')
      .select('balance_available')
      .eq('user_id', rfid.wallet_id)
      .single();

    if (!wallet || wallet.balance_available < 10.00) { // Minimum $10 to authorize
      return NextResponse.json({ idTagInfo: { status: 'Expired', parentIdTag: rfid.wallet_id } });
    }

    // 3. (Optional) Log the Authorized event or initiate a transaction immediately
    await supabaseAdmin
      .from('ocpp_commands_log')
      .insert([{
        charger_id: charger_id || 'UNKNOWN',
        command: `Authorize RFID (${idTag})`,
        status: 'Accepted',
        initiated_by: rfid.user_id
      }]);

    // Return OCPP 1.6 Compliant AuthorizeResponse
    return NextResponse.json({
      idTagInfo: {
        status: 'Accepted',
        parentIdTag: rfid.wallet_id,
        expiryDate: new Date(Date.now() + 86400000).toISOString() // Valid for 24h
      }
    });

  } catch (err) {
    const error = err as Error;
    console.error('OCPP Authorize Error:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
