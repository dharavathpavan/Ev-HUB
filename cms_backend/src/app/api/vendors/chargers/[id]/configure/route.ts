import { NextResponse } from 'next/server';
import { vendorOps } from '@/lib/vendorOps';

export async function POST(req: Request, { params }: { params: Promise<{ id: string }> }) {
  const body = await req.json();
  const { id } = await params;
  const result = vendorOps.configureCharger(id, body);
  return NextResponse.json(result, { status: result.success ? 200 : 404 });
}
