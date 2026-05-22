# EV HUB Vercel Deployment

## What Goes To Vercel

Deploy the Next.js backend API from `cms_backend`.

The Flutter web app can be hosted separately as a static site after `flutter build web`, or pointed to this Vercel backend through `API_BASE_URL`.

OCPP WebSocket traffic should run through your production OCPP bridge service. Vercel is good for HTTPS API routes and webhooks, but not for long-running charger WebSocket connections.

## Vercel Project Settings

Import this GitHub repo into Vercel. The safest setup is:

```text
Root Directory: cms_backend
Framework Preset: Next.js
Install Command: npm ci
Build Command: npm run build
Output Directory: .next
```

The repo also includes root-level `package.json` and `vercel.json` fallbacks. If Vercel is accidentally pointed at the repository root, it delegates the build to `cms_backend` and outputs `cms_backend/.next`.

If `/api/health` returns `404: NOT_FOUND`, check the Vercel deployment settings first. The most common cause is that Vercel built the repo root without using the backend app.

## Required Environment Variables

Set these in Vercel Project Settings -> Environment Variables:

```text
NEXT_PUBLIC_SUPABASE_URL=https://your-supabase-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-public-anon-or-publishable-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

RAZORPAY_KEY_ID=your-razorpay-key-id
RAZORPAY_KEY_SECRET=your-razorpay-key-secret
RAZORPAY_WEBHOOK_SECRET=your-razorpay-webhook-secret

OCPP_BRIDGE_URL=https://your-ocpp-bridge-api.example.com
OCPP_BRIDGE_API_KEY=your-ocpp-bridge-api-key
OCPP_CMS_WS_URL=wss://your-ocpp-bridge.example.com/ocpp

VENDOR_ID=your-production-vendor-id
```

Do not expose secret keys with `NEXT_PUBLIC_`.

## Production URLs

After deployment, use these URLs:

```text
Health Check:
https://your-vercel-domain.vercel.app/api/health

Razorpay Webhook:
https://your-vercel-domain.vercel.app/api/payments/razorpay/webhook

OCPP HTTP Telemetry:
https://your-vercel-domain.vercel.app/api/ocpp/webhook

Charging Start:
https://your-vercel-domain.vercel.app/api/charging/start

Charging Stop:
https://your-vercel-domain.vercel.app/api/charging/stop
```

For charger WebSocket configuration, use your OCPP bridge URL:

```text
wss://your-ocpp-bridge.example.com/ocpp/{chargePointId}
```

## Supabase Setup

Before production traffic, apply the schema in:

```text
cms_backend/supabase/backend_schema.sql
```

You can use the existing one-click pipeline:

```text
cms_backend/push-backend-to-supabase.bat
```

## Verify

After Vercel deploy finishes:

```text
https://your-vercel-domain.vercel.app/api/health
```

Expected response:

```json
{
  "success": true,
  "service": "ev-hub-backend"
}
```
