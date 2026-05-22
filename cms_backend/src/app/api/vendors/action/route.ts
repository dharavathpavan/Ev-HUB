import { NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';
import { mockDb } from '@/lib/mockDb';

export async function POST(req: Request) {
  try {
    const body = await req.json();
    const { id, action, admin_notes } = body;

    if (!id || !action || !['Approved', 'Rejected'].includes(action)) {
      return NextResponse.json({ success: false, error: 'Missing or invalid parameters. Action must be "Approved" or "Rejected".' }, { status: 400 });
    }

    const updatedApp = mockDb.updateApplicationStatus(id, action, admin_notes);
    if (!updatedApp) {
      return NextResponse.json({ success: false, error: 'Application not found' }, { status: 404 });
    }

    try {
      const vendorId = updatedApp.vendor_id || `vendor-${Math.random().toString(36).substring(2, 9)}`;

      await supabaseAdmin
        .from('vendor_applications')
        .update({
          status: action,
          kyc_status: action === 'Approved' ? 'Verified' : 'Failed',
          vendor_id: vendorId,
          admin_notes,
          updated_at: new Date().toISOString()
        })
        .eq('id', id);

      if (action === 'Approved') {
        await supabaseAdmin
          .from('vendor_profiles')
          .insert([{
            vendor_id: vendorId,
            business_name: updatedApp.business_name,
            commission_rate: 10.0,
            status: 'Active',
            kyc_status: 'Verified'
          }]);
      }
    } catch (_) {
      // Ignore Supabase errors in dev sandbox mode
    }

    return NextResponse.json({ 
      success: true, 
      message: `Application has been ${action.toLowerCase()}.`, 
      application: updatedApp 
    });

  } catch (err) {
    const error = err as Error;
    console.error('Vendor Action Error:', error);
    return NextResponse.json({ success: false, error: error.message }, { status: 500 });
  }
}
