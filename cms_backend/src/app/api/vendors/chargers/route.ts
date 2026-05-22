import { NextResponse } from 'next/server';
import { vendorOps } from '@/lib/vendorOps';

export async function GET() {
  return NextResponse.json(vendorOps.overview());
}

export async function POST(req: Request) {
  const body = await req.json();
  return NextResponse.json(vendorOps.createCharger(body));
}
