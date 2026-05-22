import { NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';
import { mockDb } from '@/lib/mockDb';

export async function GET() {
  try {
    // 1. Fetch applications
    const mockApps = mockDb.getApplications();
    
    // 2. Also try Supabase as hybrid source (optional)
    try {
      const { data: dbApps } = await supabaseAdmin
        .from('vendor_applications')
        .select('*')
        .order('created_at', { ascending: false });
        
      if (dbApps && dbApps.length > 0) {
        return NextResponse.json({ success: true, applications: dbApps });
      }
    } catch (_) {
      // Graceful fallback to mock store
    }
    
    return NextResponse.json({ success: true, applications: mockApps });
  } catch (err) {
    const error = err as Error;
    return NextResponse.json({ success: false, error: error.message }, { status: 500 });
  }
}

export async function POST(req: Request) {
  try {
    const body = await req.json();
    const { business_name, contact_email, tax_id, business_registration_number, vat_number, company_address, phone_number, utility_bill_url, estimated_chargers } = body;

    if (!business_name || !contact_email || !company_address) {
      return NextResponse.json({ success: false, error: 'Missing required parameters: business_name, contact_email and company_address' }, { status: 400 });
    }

    const newApp = mockDb.addApplication({
      business_name,
      contact_email,
      tax_id: tax_id || '',
      business_registration_number: business_registration_number || '',
      vat_number: vat_number || '',
      company_address: company_address || '',
      phone_number: phone_number || '',
      utility_bill_url: utility_bill_url || '',
      estimated_chargers: Number(estimated_chargers) || 0
    });

    try {
      await supabaseAdmin
        .from('vendor_applications')
        .insert([{
          business_name,
          contact_email,
          tax_id,
          business_registration_number,
          vat_number,
          company_address,
          phone_number,
          utility_bill_url,
          estimated_chargers: Number(estimated_chargers) || 0,
          kyc_status: 'Pending',
          status: 'Pending'
        }]);
    } catch (_) {
      // Ignore Supabase write failures due to missing tables/keys in dev mode
    }

    return NextResponse.json({ 
      success: true, 
      message: 'Application submitted successfully.', 
      application: newApp 
    });

  } catch (err) {
    const error = err as Error;
    console.error('Vendor Apply Error:', error);
    return NextResponse.json({ success: false, error: error.message }, { status: 500 });
  }
}
