import { NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';

// Called when the session stops. Calculates cost based on Rate Card and issues Wallet Refund.
export async function POST(req: Request) {
  try {
    const payload = await req.json();
    const { session_id, kwh_delivered, duration_minutes, rate_card_id } = payload;

    if (!session_id || !rate_card_id) return NextResponse.json({ error: 'Missing parameters' }, { status: 400 });

    // 1. Fetch Rate Card
    const { data: rateCard } = await supabaseAdmin
      .from('rate_cards')
      .select('*')
      .eq('id', rate_card_id)
      .single();

    if (!rateCard) return NextResponse.json({ error: 'Rate Card not found' }, { status: 404 });

    // 2. Fetch Pending Transaction
    const { data: transaction } = await supabaseAdmin
      .from('transactions')
      .select('*')
      .eq('session_id', session_id)
      .eq('status', 'Pending')
      .single();

    if (!transaction) return NextResponse.json({ error: 'No pending transaction found for this session' }, { status: 404 });

    // 3. Calculate Final Cost
    // Cost = Fixed Fee + (kWh * Rate) + (Minutes * Rate)
    const costKwh = (kwh_delivered || 0) * rateCard.per_kwh_fee;
    const costTime = (duration_minutes || 0) * rateCard.per_minute_fee;
    const finalCost = costKwh + costTime + rateCard.session_fixed_fee;

    // 4. Calculate Refund
    const preAuth = transaction.pre_auth_amount;
    let refundedAmount = 0;
    
    if (preAuth > finalCost) {
      refundedAmount = preAuth - finalCost;
    }

    // 5. Update Transaction to Completed/Refunded
    await supabaseAdmin
      .from('transactions')
      .update({
        final_cost: finalCost,
        refunded_amount: refundedAmount,
        status: refundedAmount > 0 ? 'Refunded' : 'Completed',
        completed_at: new Date().toISOString()
      })
      .eq('transaction_id', transaction.transaction_id);

    // 6. Issue Refund to Wallet
    if (refundedAmount > 0) {
      const { data: wallet } = await supabaseAdmin
        .from('wallets')
        .select('balance_available')
        .eq('user_id', transaction.wallet_user_id)
        .single();
        
      if (wallet) {
        await supabaseAdmin
          .from('wallets')
          .update({ balance_available: wallet.balance_available + refundedAmount })
          .eq('user_id', transaction.wallet_user_id);
      }
    }

    return NextResponse.json({ 
      success: true, 
      final_cost: finalCost,
      refunded_amount: refundedAmount,
      message: `Session finalized. $${finalCost.toFixed(2)} charged. $${refundedAmount.toFixed(2)} refunded to Wallet.`
    });

  } catch (err) {
    const error = err as Error;
    console.error('Finalize Session Error:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
