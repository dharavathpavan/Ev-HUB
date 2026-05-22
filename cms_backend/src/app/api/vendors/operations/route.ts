import { NextResponse } from 'next/server';
import { vendorOps } from '@/lib/vendorOps';

export async function GET() {
  return NextResponse.json(vendorOps.overview());
}
