import { NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';
import { mockDb } from '@/lib/mockDb';

export async function GET(req: Request) {
  try {
    const url = new URL(req.url);
    const vendorId = url.searchParams.get('vendor_id') || undefined;
    const mockOrders = mockDb.getOrders(vendorId);
    const mockPayments = mockDb.getPayments(vendorId);
    const mockProfiles = mockDb.getProfiles();
    const profile = vendorId ? mockProfiles.find((p) => p.vendor_id === vendorId) : mockProfiles[0] || null;

    const summary = {
      vendor_id: vendorId || profile?.vendor_id,
      business_name: profile?.business_name ?? 'Vendor Partner',
      total_orders: mockOrders.length,
      active_bookings: mockOrders.filter((order) => order.status === 'Pending' || order.status === 'Confirmed').length,
      total_revenue: mockPayments.reduce((sum, payment) => sum + payment.amount, 0),
      current_balance: mockPayments.reduce((sum, payment) => sum + payment.amount, 0),
    };

    try {
      const { data: orders } = await supabaseAdmin
        .from('vendor_orders')
        .select('*')
        .eq('vendor_id', vendorId || profile?.vendor_id || '')
        .order('scheduled_at', { ascending: false });
      const { data: payments } = await supabaseAdmin
        .from('vendor_payments')
        .select('*')
        .eq('vendor_id', vendorId || profile?.vendor_id || '')
        .order('payment_date', { ascending: false });
      const { data: profiles } = await supabaseAdmin
        .from('vendor_profiles')
        .select('*')
        .eq('vendor_id', vendorId || profile?.vendor_id || '')
        .limit(1);

      return NextResponse.json({
        success: true,
        summary,
        profile: profiles?.[0] ?? profile,
        orders: orders ?? mockOrders,
        payments: payments ?? mockPayments,
      });
    } catch (_) {
      return NextResponse.json({
        success: true,
        summary,
        profile,
        orders: mockOrders,
        payments: mockPayments,
      });
    }
  } catch (err) {
    const error = err as Error;
    return NextResponse.json({ success: false, error: error.message }, { status: 500 });
  }
}
