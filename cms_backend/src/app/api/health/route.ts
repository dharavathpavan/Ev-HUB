import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

export async function GET() {
  return NextResponse.json({
    success: true,
    service: 'ev-hub-backend',
    environment: process.env.VERCEL_ENV || process.env.NODE_ENV || 'local',
    timestamp: new Date().toISOString(),
  });
}
