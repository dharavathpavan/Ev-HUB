-- EV CMS backend schema bootstrap for Supabase/Postgres.
-- This file is intentionally idempotent so it can be pushed repeatedly.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS vendor_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_name TEXT NOT NULL,
    contact_email TEXT NOT NULL,
    tax_id TEXT,
    business_registration_number TEXT,
    vat_number TEXT,
    company_address TEXT,
    phone_number TEXT,
    utility_bill_url TEXT,
    estimated_chargers INTEGER DEFAULT 0,
    kyc_status TEXT NOT NULL DEFAULT 'Pending' CHECK (kyc_status IN ('Pending', 'Verified', 'Failed')),
    status TEXT NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending', 'Approved', 'Rejected')),
    vendor_id TEXT,
    admin_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS vendor_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id TEXT UNIQUE,
    business_name TEXT NOT NULL,
    contact_phone TEXT,
    business_address TEXT,
    payout_bank_details JSONB,
    brand_logo_url TEXT,
    brand_color_primary TEXT DEFAULT '#4ADDA2',
    commission_rate NUMERIC DEFAULT 10.0,
    kyc_status TEXT NOT NULL DEFAULT 'Verified' CHECK (kyc_status IN ('Pending', 'Verified', 'Failed')),
    status TEXT NOT NULL DEFAULT 'Active' CHECK (status IN ('Active', 'Suspended')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS vendor_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT UNIQUE NOT NULL,
    vendor_id TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'vendor_staff' CHECK (role IN ('super_admin', 'vendor', 'vendor_staff')),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS vendor_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id TEXT NOT NULL,
    booking_id TEXT NOT NULL,
    customer_name TEXT NOT NULL,
    station_location TEXT NOT NULL,
    scheduled_at TIMESTAMP WITH TIME ZONE,
    status TEXT NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending', 'Confirmed', 'Completed', 'Cancelled')),
    amount NUMERIC NOT NULL DEFAULT 0.0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS vendor_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id TEXT NOT NULL,
    description TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    status TEXT NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending', 'Processed', 'Completed')),
    payment_date TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS charging_guns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    charger_id TEXT NOT NULL,
    gun_index INTEGER NOT NULL,
    connector_type TEXT NOT NULL DEFAULT 'CCS2' CHECK (connector_type IN ('CCS2', 'Type2', 'CHAdeMO', 'GB_T')),
    max_kw_output NUMERIC NOT NULL DEFAULT 150.0,
    status TEXT NOT NULL DEFAULT 'Available' CHECK (status IN ('Available', 'Preparing', 'Charging', 'Faulted', 'Offline')),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(charger_id, gun_index)
);

CREATE TABLE IF NOT EXISTS qr_mappings (
    qr_id TEXT PRIMARY KEY,
    charger_id TEXT NOT NULL,
    gun_index INTEGER NOT NULL,
    short_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    FOREIGN KEY (charger_id, gun_index) REFERENCES charging_guns(charger_id, gun_index) ON DELETE CASCADE
);

ALTER TABLE charging_guns ADD COLUMN IF NOT EXISTS vendor_id TEXT;
ALTER TABLE charging_guns ADD COLUMN IF NOT EXISTS rate_card_id TEXT DEFAULT 'rate-standard';
ALTER TABLE charging_guns ADD COLUMN IF NOT EXISTS ocpp_charge_point_id TEXT;
ALTER TABLE charging_guns ADD COLUMN IF NOT EXISTS razorpay_qr_id TEXT;

CREATE TABLE IF NOT EXISTS vendor_wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id TEXT NOT NULL UNIQUE,
    available_balance NUMERIC NOT NULL DEFAULT 0,
    pending_balance NUMERIC NOT NULL DEFAULT 0,
    refunded_total NUMERIC NOT NULL DEFAULT 0,
    settled_total NUMERIC NOT NULL DEFAULT 0,
    payout_destination JSONB DEFAULT '{}'::jsonb,
    status TEXT NOT NULL DEFAULT 'Active' CHECK (status IN ('Active', 'Hold', 'Suspended')),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS vendor_wallet_ledger (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id TEXT NOT NULL,
    session_id TEXT,
    razorpay_payment_id TEXT,
    type TEXT NOT NULL CHECK (type IN ('earning', 'refund', 'settlement', 'adjustment')),
    description TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    status TEXT NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending', 'Processed', 'Settled', 'Failed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS charger_qr_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id TEXT NOT NULL,
    charger_id TEXT NOT NULL,
    gun_index INTEGER NOT NULL DEFAULT 1,
    razorpay_qr_id TEXT NOT NULL,
    razorpay_payment_id TEXT UNIQUE,
    user_id TEXT,
    hold_amount NUMERIC NOT NULL DEFAULT 0,
    captured_amount NUMERIC NOT NULL DEFAULT 0,
    refunded_amount NUMERIC NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending', 'Authorized', 'Charging', 'Completed', 'Refunded', 'Failed')),
    raw_event JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS charging_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id TEXT UNIQUE NOT NULL,
    vendor_id TEXT NOT NULL,
    charger_id TEXT NOT NULL,
    gun_index INTEGER NOT NULL DEFAULT 1,
    payment_id TEXT,
    ocpp_transaction_id TEXT,
    status TEXT NOT NULL DEFAULT 'Authorized' CHECK (status IN ('Authorized', 'Active', 'Completed', 'Faulted', 'Cancelled')),
    soc_percent NUMERIC DEFAULT 0,
    kwh_delivered NUMERIC NOT NULL DEFAULT 0,
    duration_minutes INTEGER NOT NULL DEFAULT 0,
    hold_amount NUMERIC NOT NULL DEFAULT 0,
    total_cost NUMERIC NOT NULL DEFAULT 0,
    refund_amount NUMERIC NOT NULL DEFAULT 0,
    refund_status TEXT NOT NULL DEFAULT 'None' CHECK (refund_status IN ('None', 'Pending', 'Processed', 'Failed')),
    start_reason TEXT,
    stop_reason TEXT,
    started_at TIMESTAMP WITH TIME ZONE,
    stopped_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS razorpay_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id TEXT UNIQUE,
    event_type TEXT NOT NULL,
    razorpay_payment_id TEXT,
    razorpay_qr_id TEXT,
    received_payload JSONB NOT NULL DEFAULT '{}'::jsonb,
    processed BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS refunds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id TEXT NOT NULL,
    session_id TEXT,
    razorpay_payment_id TEXT,
    razorpay_refund_id TEXT,
    amount NUMERIC NOT NULL,
    destination TEXT DEFAULT 'UPI',
    status TEXT NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending', 'Processed', 'Failed')),
    reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_charging_guns_vendor ON charging_guns(vendor_id);
CREATE INDEX IF NOT EXISTS idx_charger_qr_payments_vendor ON charger_qr_payments(vendor_id, status);
CREATE INDEX IF NOT EXISTS idx_charging_sessions_vendor ON charging_sessions(vendor_id, status);
CREATE INDEX IF NOT EXISTS idx_vendor_wallet_ledger_vendor ON vendor_wallet_ledger(vendor_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_refunds_vendor ON refunds(vendor_id, status);

ALTER TABLE vendor_wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_wallet_ledger ENABLE ROW LEVEL SECURITY;
ALTER TABLE charger_qr_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE charging_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE razorpay_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE refunds ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF to_regclass('public.chargers') IS NOT NULL THEN
    INSERT INTO charging_guns (charger_id, gun_index, connector_type, max_kw_output, status)
    SELECT charger_id, 1, 'CCS2', 150.0, 'Available'
    FROM chargers
    ON CONFLICT (charger_id, gun_index) DO NOTHING;

    INSERT INTO charging_guns (charger_id, gun_index, connector_type, max_kw_output, status)
    SELECT charger_id, 2, 'Type2', 22.0, 'Available'
    FROM chargers
    ON CONFLICT (charger_id, gun_index) DO NOTHING;
  END IF;
END $$;
