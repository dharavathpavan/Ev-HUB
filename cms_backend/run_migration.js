const { execSync } = require('child_process');

// 1. Install pg if it is not installed
try {
  require('pg');
} catch (e) {
  console.log('Installing "pg" library...');
  execSync('npm install pg', { stdio: 'inherit' });
}

const { Client } = require('pg');

const client = new Client({
  host: 'db.exgoxwxvdgocccrcfmow.supabase.co',
  port: 5432,
  database: 'postgres',
  user: 'postgres',
  password: 'lovenest29358',
  ssl: {
    rejectUnauthorized: false
  }
});

const sql = `
-- 1. Create vendor_applications table
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

-- 2. Create vendor_profiles table
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

-- 3. Create vendor_users table
CREATE TABLE IF NOT EXISTS vendor_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT UNIQUE NOT NULL,
    vendor_id TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'vendor_staff' CHECK (role IN ('super_admin', 'vendor', 'vendor_staff')),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. Create vendor_orders table
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

-- 5. Create vendor_payments table
CREATE TABLE IF NOT EXISTS vendor_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id TEXT NOT NULL,
    description TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    status TEXT NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending', 'Processed', 'Completed')),
    payment_date TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Create charging_guns table
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

-- 4. Create qr_mappings table
CREATE TABLE IF NOT EXISTS qr_mappings (
    qr_id TEXT PRIMARY KEY,
    charger_id TEXT NOT NULL,
    gun_index INTEGER NOT NULL,
    short_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    FOREIGN KEY (charger_id, gun_index) REFERENCES charging_guns(charger_id, gun_index) ON DELETE CASCADE
);

-- 5. Seed some initial charging guns for existing chargers
-- First find if there are existing chargers and add guns to them if not present
INSERT INTO charging_guns (charger_id, gun_index, connector_type, max_kw_output, status)
SELECT charger_id, 1, 'CCS2', 150.0, 'Available'
FROM chargers
ON CONFLICT (charger_id, gun_index) DO NOTHING;

INSERT INTO charging_guns (charger_id, gun_index, connector_type, max_kw_output, status)
SELECT charger_id, 2, 'Type2', 22.0, 'Available'
FROM chargers
ON CONFLICT (charger_id, gun_index) DO NOTHING;

-- 6. Seed some default vendor applications
INSERT INTO vendor_applications (business_name, contact_email, tax_id, estimated_chargers, status)
VALUES 
('ChargePoint India', 'info@chargepoint.in', 'TAX-CP-9922', 15, 'Pending'),
('VoltSpark EV Solutions', 'partner@voltspark.com', 'TAX-VS-8811', 8, 'Approved'),
('EcoDrive Hubs', 'deploy@ecodrive.org', 'TAX-ED-7744', 25, 'Pending')
ON CONFLICT DO NOTHING;

-- Seed vendor profile for approved application
INSERT INTO vendor_profiles (vendor_id, business_name, commission_rate, status)
VALUES 
('vendor-voltspark', 'VoltSpark EV Solutions', 8.5, 'Active')
ON CONFLICT (vendor_id) DO NOTHING;
`;

async function run() {
  console.log('Connecting to database...');
  await client.connect();
  console.log('Connected! Executing migration SQL...');
  const res = await client.query(sql);
  console.log('Migration executed successfully!');
  await client.end();
}

run().catch(err => {
  console.error('Migration failed:', err);
  process.exit(1);
});
