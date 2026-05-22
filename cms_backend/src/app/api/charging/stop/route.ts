import { NextResponse } from 'next/server';
import { vendorOps } from '@/lib/vendorOps';

export async function POST(req: Request) {
  const body = await req.json();
  const result = await vendorOps.stopSession(body);
  return NextResponse.json(result, { status: result.success ? 200 : 404 });
}
