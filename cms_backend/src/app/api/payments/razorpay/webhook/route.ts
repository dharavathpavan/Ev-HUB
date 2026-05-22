import { NextResponse } from 'next/server';
import { vendorOps } from '@/lib/vendorOps';

export async function POST(req: Request) {
  const payload = await req.json();
  const result = await vendorOps.razorpayWebhook(payload);
  return NextResponse.json(result, { status: result.success ? 200 : 400 });
}
