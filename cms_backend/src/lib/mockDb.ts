import fs from 'fs';
import path from 'path';

const MOCK_DB_PATH = path.join(process.cwd(), 'src/lib/mock_db_store.json');
const IS_PRODUCTION = process.env.NODE_ENV === 'production';

export interface VendorApplication {
  id: string;
  business_name: string;
  contact_email: string;
  tax_id?: string;
  business_registration_number?: string;
  vat_number?: string;
  company_address?: string;
  phone_number?: string;
  utility_bill_url?: string;
  estimated_chargers: number;
  kyc_status?: 'Pending' | 'Verified' | 'Failed';
  status: 'Pending' | 'Approved' | 'Rejected';
  vendor_id?: string;
  admin_notes?: string;
  created_at: string;
  updated_at: string;
}

export interface VendorProfile {
  id: string;
  vendor_id: string;
  business_name: string;
  contact_phone?: string;
  business_address?: string;
  payout_bank_details?: any;
  brand_logo_url?: string;
  brand_color_primary: string;
  commission_rate: number;
  kyc_status?: 'Pending' | 'Verified' | 'Failed';
  status: 'Active' | 'Suspended';
  created_at: string;
}

export interface ChargingGun {
  id: string;
  charger_id: string;
  gun_index: number;
  connector_type: 'CCS2' | 'Type2' | 'CHAdeMO' | 'GB_T';
  max_kw_output: number;
  status: 'Available' | 'Preparing' | 'Charging' | 'Faulted' | 'Offline';
  updated_at: string;
}

export interface QrMapping {
  qr_id: string;
  charger_id: string;
  gun_index: number;
  short_url?: string;
  created_at: string;
}

export interface VendorOrder {
  id: string;
  booking_id: string;
  vendor_id: string;
  customer_name: string;
  station_location: string;
  scheduled_at: string;
  status: 'Pending' | 'Confirmed' | 'Completed' | 'Cancelled';
  amount: number;
  created_at: string;
}

export interface VendorPayment {
  id: string;
  vendor_id: string;
  description: string;
  amount: number;
  status: 'Pending' | 'Processed' | 'Completed';
  payment_date: string;
  created_at: string;
}

interface MockSchema {
  vendor_applications: VendorApplication[];
  vendor_profiles: VendorProfile[];
  charging_guns: ChargingGun[];
  qr_mappings: QrMapping[];
  vendor_orders: VendorOrder[];
  vendor_payments: VendorPayment[];
}

const DEFAULT_DATA: MockSchema = {
  vendor_applications: [
    {
      id: 'app-chargepoint-1',
      business_name: 'ChargePoint India Inc.',
      contact_email: 'info@chargepoint.in',
      tax_id: 'TAX-CP-9922',
      estimated_chargers: 15,
      status: 'Pending',
      created_at: new Date(Date.now() - 3600000 * 2).toISOString(),
      updated_at: new Date(Date.now() - 3600000 * 2).toISOString(),
    },
    {
      id: 'app-voltspark-2',
      business_name: 'VoltSpark EV Solutions',
      contact_email: 'partner@voltspark.com',
      tax_id: 'TAX-VS-8811',
      estimated_chargers: 8,
      status: 'Approved',
      created_at: new Date(Date.now() - 3600000 * 24 * 3).toISOString(),
      updated_at: new Date(Date.now() - 3600000 * 24 * 2).toISOString(),
    },
    {
      id: 'app-ecodrive-3',
      business_name: 'EcoDrive Hubs',
      contact_email: 'deploy@ecodrive.org',
      tax_id: 'TAX-ED-7744',
      estimated_chargers: 25,
      status: 'Pending',
      created_at: new Date(Date.now() - 3600000).toISOString(),
      updated_at: new Date(Date.now()).toISOString(),
    }
  ],
  vendor_profiles: [
    {
      id: 'profile-voltspark',
      vendor_id: 'vendor-voltspark',
      business_name: 'VoltSpark EV Solutions',
      payout_bank_details: { bank_name: 'State Bank of India', account_no: 'XXXXXXXX1234', ifsc: 'SBIN0001234' },
      brand_color_primary: '#4ADDA2',
      commission_rate: 8.5,
      status: 'Active',
      created_at: new Date(Date.now() - 3600000 * 24 * 2).toISOString()
    }
  ],
  charging_guns: [
    // Pre-populate some guns for CHG-A1
    {
      id: 'gun-chga1-1',
      charger_id: 'CHG-A1',
      gun_index: 1,
      connector_type: 'CCS2',
      max_kw_output: 150.0,
      status: 'Available',
      updated_at: new Date().toISOString()
    },
    {
      id: 'gun-chga1-2',
      charger_id: 'CHG-A1',
      gun_index: 2,
      connector_type: 'Type2',
      max_kw_output: 22.0,
      status: 'Available',
      updated_at: new Date().toISOString()
    }
  ],
  qr_mappings: [
    {
      qr_id: 'QR-CHG-A1-G1',
      charger_id: 'CHG-A1',
      gun_index: 1,
      short_url: 'https://app.bleuright.com/charge?qr=QR-CHG-A1-G1',
      created_at: new Date().toISOString()
    },
    {
      qr_id: 'QR-CHG-A1-G2',
      charger_id: 'CHG-A1',
      gun_index: 2,
      short_url: 'https://app.bleuright.com/charge?qr=QR-CHG-A1-G2',
      created_at: new Date().toISOString()
    }
  ],
  vendor_orders: [
    {
      id: 'order-001',
      booking_id: 'BK-9912',
      vendor_id: 'vendor-voltspark',
      customer_name: 'Alice Smith',
      station_location: 'Downtown Mall, NY',
      scheduled_at: new Date(Date.now() + 3600000).toISOString(),
      status: 'Confirmed',
      amount: 15.00,
      created_at: new Date().toISOString()
    },
    {
      id: 'order-002',
      booking_id: 'BK-9914',
      vendor_id: 'vendor-voltspark',
      customer_name: 'Charlie Davis',
      station_location: 'Highway 51 Stop',
      scheduled_at: new Date(Date.now() + 7200000).toISOString(),
      status: 'Pending',
      amount: 10.50,
      created_at: new Date().toISOString()
    }
  ],
  vendor_payments: [
    {
      id: 'payment-001',
      vendor_id: 'vendor-voltspark',
      description: 'Charging Session (ST-001)',
      amount: 15.00,
      status: 'Completed',
      payment_date: new Date(Date.now() - 86400000).toISOString(),
      created_at: new Date().toISOString()
    },
    {
      id: 'payment-002',
      vendor_id: 'vendor-voltspark',
      description: 'Weekly Payout to Bank',
      amount: -1200.00,
      status: 'Processed',
      payment_date: new Date(Date.now() - 43200000).toISOString(),
      created_at: new Date().toISOString()
    }
  ]
};

function readDb(): MockSchema {
  try {
    if (!fs.existsSync(MOCK_DB_PATH)) {
      writeDb(DEFAULT_DATA);
      return DEFAULT_DATA;
    }
    const raw = fs.readFileSync(MOCK_DB_PATH, 'utf-8');
    return JSON.parse(raw);
  } catch (e) {
    console.error('Error reading mock DB, returning default:', e);
    return DEFAULT_DATA;
  }
}

function writeDb(data: MockSchema) {
  if (IS_PRODUCTION) {
    console.warn('Mock DB write skipped in production mode. Switch to Supabase for persistent data.');
    return;
  }

  try {
    const dir = path.dirname(MOCK_DB_PATH);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    fs.writeFileSync(MOCK_DB_PATH, JSON.stringify(data, null, 2), 'utf-8');
  } catch (e) {
    console.error('Error writing mock DB:', e);
  }
}

export const mockDb = {
  // --- Vendor Applications ---
  getApplications: (): VendorApplication[] => {
    return readDb().vendor_applications;
  },
  
  addApplication: (app: Omit<VendorApplication, 'id' | 'status' | 'created_at' | 'updated_at'>): VendorApplication => {
    const db = readDb();
    const newApp: VendorApplication = {
      ...app,
      id: `app-${Math.random().toString(36).substring(2, 9)}`,
      status: 'Pending',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };
    db.vendor_applications.unshift(newApp);
    writeDb(db);
    return newApp;
  },

  updateApplicationStatus: (id: string, status: 'Approved' | 'Rejected', adminNotes?: string): VendorApplication | null => {
    const db = readDb();
    const index = db.vendor_applications.findIndex(a => a.id === id);
    if (index === -1) return null;

    const vendorId = db.vendor_applications[index].vendor_id || `vendor-${Math.random().toString(36).substring(2, 9)}`;
    db.vendor_applications[index].status = status;
    db.vendor_applications[index].kyc_status = status === 'Approved' ? 'Verified' : 'Failed';
    db.vendor_applications[index].vendor_id = vendorId;
    db.vendor_applications[index].admin_notes = adminNotes;
    db.vendor_applications[index].updated_at = new Date().toISOString();

    const app = db.vendor_applications[index];

    if (status === 'Approved') {
      const newProfile: VendorProfile = {
        id: `profile-${Math.random().toString(36).substring(2, 9)}`,
        vendor_id: vendorId,
        business_name: app.business_name,
        brand_color_primary: '#4ADDA2',
        commission_rate: 10.0,
        status: 'Active',
        kyc_status: 'Verified',
        created_at: new Date().toISOString()
      };
      db.vendor_profiles.unshift(newProfile);
    }

    writeDb(db);
    return app;
  },

  // --- Vendor Profiles ---
  getProfiles: (): VendorProfile[] => {
    return readDb().vendor_profiles;
  },

  updateProfile: (vendorId: string, updates: Partial<VendorProfile>): VendorProfile | null => {
    const db = readDb();
    const index = db.vendor_profiles.findIndex(p => p.vendor_id === vendorId);
    if (index === -1) return null;

    db.vendor_profiles[index] = {
      ...db.vendor_profiles[index],
      ...updates
    };
    writeDb(db);
    return db.vendor_profiles[index];
  },

  // --- Charging Guns ---
  getGuns: (chargerId?: string): ChargingGun[] => {
    const guns = readDb().charging_guns;
    if (chargerId) {
      return guns.filter(g => g.charger_id === chargerId);
    }
    return guns;
  },

  addGun: (gun: Omit<ChargingGun, 'id' | 'status' | 'updated_at'>): ChargingGun => {
    const db = readDb();
    
    // Check if duplicate index
    const exists = db.charging_guns.findIndex(g => g.charger_id === gun.charger_id && g.gun_index === gun.gun_index);
    if (exists !== -1) {
      db.charging_guns[exists].connector_type = gun.connector_type;
      db.charging_guns[exists].max_kw_output = gun.max_kw_output;
      db.charging_guns[exists].updated_at = new Date().toISOString();
      writeDb(db);
      return db.charging_guns[exists];
    }

    const newGun: ChargingGun = {
      ...gun,
      id: `gun-${Math.random().toString(36).substring(2, 9)}`,
      status: 'Available',
      updated_at: new Date().toISOString()
    };
    db.charging_guns.push(newGun);
    writeDb(db);
    return newGun;
  },

  updateGunStatus: (chargerId: string, gunIndex: number, status: ChargingGun['status']): ChargingGun | null => {
    const db = readDb();
    const index = db.charging_guns.findIndex(g => g.charger_id === chargerId && g.gun_index === gunIndex);
    if (index === -1) return null;

    db.charging_guns[index].status = status;
    db.charging_guns[index].updated_at = new Date().toISOString();
    writeDb(db);
    return db.charging_guns[index];
  },

  // --- QR Mappings ---
  getQrMappings: (): QrMapping[] => {
    return readDb().qr_mappings;
  },

  getOrders: (vendorId?: string): VendorOrder[] => {
    const orders = readDb().vendor_orders;
    return vendorId ? orders.filter(o => o.vendor_id === vendorId) : orders;
  },

  getPayments: (vendorId?: string): VendorPayment[] => {
    const payments = readDb().vendor_payments;
    return vendorId ? payments.filter(p => p.vendor_id === vendorId) : payments;
  },

  mapQr: (mapping: Omit<QrMapping, 'created_at'>): QrMapping => {
    const db = readDb();
    const existingIndex = db.qr_mappings.findIndex(m => m.qr_id === mapping.qr_id);
    
    const newMapping: QrMapping = {
      ...mapping,
      short_url: `https://app.bleuright.com/charge?qr=${mapping.qr_id}`,
      created_at: new Date().toISOString()
    };

    if (existingIndex !== -1) {
      db.qr_mappings[existingIndex] = newMapping;
    } else {
      db.qr_mappings.push(newMapping);
    }
    
    // Auto-create gun if it doesn't exist
    const gunExists = db.charging_guns.some(g => g.charger_id === mapping.charger_id && g.gun_index === mapping.gun_index);
    if (!gunExists) {
      db.charging_guns.push({
        id: `gun-${Math.random().toString(36).substring(2, 9)}`,
        charger_id: mapping.charger_id,
        gun_index: mapping.gun_index,
        connector_type: 'CCS2',
        max_kw_output: 150.0,
        status: 'Available',
        updated_at: new Date().toISOString()
      });
    }

    writeDb(db);
    return newMapping;
  },

  resolveQr: (qrId: string): QrMapping | null => {
    const db = readDb();
    return db.qr_mappings.find(m => m.qr_id === qrId) || null;
  }
};
