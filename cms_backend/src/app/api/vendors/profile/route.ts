import { NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';
import { mockDb } from '@/lib/mockDb';

export async function GET() {
  try {
    const mockProfiles = mockDb.getProfiles();
    
    try {
      const { data: dbProfiles } = await supabaseAdmin
        .from('vendor_profiles')
        .select('*');
      if (dbProfiles && dbProfiles.length > 0) {
        return NextResponse.json({ success: true, profiles: dbProfiles });
      }
    } catch (_) {}
    
    return NextResponse.json({ success: true, profiles: mockProfiles });
  } catch (err) {
    const error = err as Error;
    return NextResponse.json({ success: false, error: error.message }, { status: 500 });
  }
}

export async function POST(req: Request) {
  try {
    const body = await req.json();
    const { vendor_id, business_name, payout_bank_details, brand_color_primary, commission_rate } = body;

    if (!vendor_id) {
      return NextResponse.json({ success: false, error: 'Missing vendor_id parameter' }, { status: 400 });
    }

    const updated = mockDb.updateProfile(vendor_id, {
      business_name,
      payout_bank_details,
      brand_color_primary,
      commission_rate: commission_rate !== undefined ? Number(commission_rate) : undefined
    });

    if (!updated) {
      return NextResponse.json({ success: false, error: 'Vendor profile not found' }, { status: 404 });
    }

    try {
      await supabaseAdmin
        .from('vendor_profiles')
        .update({
          business_name,
          payout_bank_details,
          brand_color_primary,
          commission_rate: commission_rate !== undefined ? Number(commission_rate) : undefined
        })
        .eq('vendor_id', vendor_id);
    } catch (_) {}

    return NextResponse.json({ 
      success: true, 
      message: 'Profile updated successfully.', 
      profile: updated 
    });

  } catch (err) {
    const error = err as Error;
    console.error('Vendor Profile Update Error:', error);
    return NextResponse.json({ success: false, error: error.message }, { status: 500 });
  }
}
