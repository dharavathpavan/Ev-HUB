# EV CMS Backend Pipeline

This backend pipeline pushes the EV CMS backend schema into Supabase/Postgres from one command.

## 1. Configure Supabase

Copy `.env.example` to `.env.local`, then fill either:

- `SUPABASE_DB_URL`

or:

- `SUPABASE_PROJECT_REF`
- `SUPABASE_DB_PASSWORD`
- optional `SUPABASE_DB_PORT`, `SUPABASE_DB_NAME`, `SUPABASE_DB_USER`

Keep `.env.local` private. Do not commit it.

## 2. One-click push

Double-click:

```text
push-backend-to-supabase.bat
```

or run:

```bash
npm run push:supabase
```

## What It Pushes

The pipeline applies `supabase/backend_schema.sql`, then verifies these tables exist:

- `vendor_applications`
- `vendor_profiles`
- `vendor_users`
- `vendor_orders`
- `vendor_payments`
- `charging_guns`
- `qr_mappings`

The SQL is idempotent, so it can be run multiple times safely.

## Important

This pushes database schema/data only. Supabase does not host the Next.js backend files; deploy the Next.js backend separately to a platform such as Vercel, Render, Railway, or a VPS.
