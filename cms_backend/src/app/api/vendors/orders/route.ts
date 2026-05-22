import { NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';
import { mockDb } from '@/lib/mockDb';

export async function GET(req: Request) {
  try {
    const url = new URL(req.url);
    const vendorId = url.searchParams.get('vendor_id') || undefined;
    const mockOrders = mockDb.getOrders(vendorId);

    try {
      const { data: dbOrders } = await supabaseAdmin
        .from('vendor_orders')
        .select('*')
        .match(vendorId ? { vendor_id: vendorId } : {})
        .order('scheduled_at', { ascending: false });

      return NextResponse.json({ success: true, orders: dbOrders ?? mockOrders });
    } catch (_) {
      return NextResponse.json({ success: true, orders: mockOrders });
    }
  } catch (err) {
    const error = err as Error;
    return NextResponse.json({ success: false, error: error.message }, { status: 500 });
  }
}
