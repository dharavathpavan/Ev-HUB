import { NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';
import { mockDb } from '@/lib/mockDb';


// Called when a User scans the physical QR code on the charger or gun
export async function POST(req: Request) {
  try {
    const payload = await req.json();
    const { charger_id, qr_id, user_id } = payload; // user_id is from the Consumer App Wallet

    if (!user_id) return NextResponse.json({ error: 'Missing user_id' }, { status: 400 });

    let finalChargerId = charger_id;
    let finalGunIndex = 1;

    // 1. Resolve QR ID mapping if passed
    if (qr_id) {
      const mapping = mockDb.resolveQr(qr_id);
      if (mapping) {
        finalChargerId = mapping.charger_id;
        finalGunIndex = mapping.gun_index;
      } else {
        // Fallback or error
        return NextResponse.json({ error: `QR Code ${qr_id} is not mapped to any physical connector.` }, { status: 404 });
      }
    }

    if (!finalChargerId) {
      return NextResponse.json({ error: 'Missing charger_id or qr_id' }, { status: 400 });
    }

    // 2. Get Wallet Balance
    let balanceAvailable = 150.00;
    let usingMockWallet = false;

    try {
      const { data: wallet, error: walletError } = await supabaseAdmin
        .from('wallets')
        .select('balance_available')
        .eq('user_id', user_id)
        .single();

      if (walletError || !wallet) {
        usingMockWallet = true;
        balanceAvailable = 150.00; // Default demo balance
      } else {
        balanceAvailable = wallet.balance_available;
      }
    } catch (_) {
      usingMockWallet = true;
      balanceAvailable = 150.00;
    }

    // Define a standard Pre-Auth amount (e.g., $30 to start a session)
    const PRE_AUTH_AMOUNT = 30.00;

    if (balanceAvailable < PRE_AUTH_AMOUNT) {
      return NextResponse.json({ error: 'Insufficient wallet balance. Minimum $30 required to start charging.' }, { status: 402 });
    }

    // 3. Generate a Mock Session ID
    const session_id = `SES-QR-${Date.now()}`;

    // 4. Deduct Pre-Auth from Wallet
    if (!usingMockWallet) {
      try {
        await supabaseAdmin
          .from('wallets')
          .update({ balance_available: balanceAvailable - PRE_AUTH_AMOUNT })
          .eq('user_id', user_id);
      } catch (_) {}
    }

    // 5. Create Pending Transaction
    try {
      await supabaseAdmin
        .from('transactions')
        .insert([{
          session_id,
          wallet_user_id: user_id,
          payment_type: 'QR_Scan',
          pre_auth_amount: PRE_AUTH_AMOUNT,
          status: 'Pending'
        }]);
    } catch (_) {}

    // 6. Mock the OCPP RemoteStartTransaction (Updates cabinet status)
    try {
      await supabaseAdmin
        .from('chargers')
        .update({ 
          status: 'Charging',
          current_kw_output: 45.0
        })
        .eq('charger_id', finalChargerId);
    } catch (_) {}

    // 7. Also update the specific physical gun status to Charging
    mockDb.updateGunStatus(finalChargerId, finalGunIndex, 'Charging');

    return NextResponse.json({ 
      success: true, 
      message: `Payment Authorized. Charging Started on Gun ${finalGunIndex}.`,
      session_id,
      charger_id: finalChargerId,
      gun_index: finalGunIndex,
      pre_auth_deducted: PRE_AUTH_AMOUNT,
      remaining_balance: balanceAvailable - PRE_AUTH_AMOUNT
    });

  } catch (err) {
    const error = err as Error;
    console.error('QR Initiate Error:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

