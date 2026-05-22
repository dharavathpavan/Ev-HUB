import { NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';
import { mockDb } from '@/lib/mockDb';

export async function GET(req: Request) {
  try {
    const url = new URL(req.url);
    const vendorId = url.searchParams.get('vendor_id') || undefined;
    const mockPayments = mockDb.getPayments(vendorId);

    try {
      const { data: dbPayments } = await supabaseAdmin
        .from('vendor_payments')
        .select('*')
        .match(vendorId ? { vendor_id: vendorId } : {})
        .order('payment_date', { ascending: false });

      return NextResponse.json({ success: true, payments: dbPayments ?? mockPayments });
    } catch (_) {
      return NextResponse.json({ success: true, payments: mockPayments });
    }
  } catch (err) {
    const error = err as Error;
    return NextResponse.json({ success: false, error: error.message }, { status: 500 });
  }
}
