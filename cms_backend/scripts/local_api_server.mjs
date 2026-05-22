import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { fileURLToPath } from 'node:url';

const port = Number(process.env.PORT || 3003);
const vendorId = process.env.VENDOR_ID || 'vendor-production';
const defaultCmsWsUrl = process.env.OCPP_CMS_WS_URL || 'ws://localhost:3003/ocpp';
const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const backendRoot = path.resolve(scriptDir, '..');
const dbPath = path.join(backendRoot, 'src/lib/mock_db_store.json');

const defaultDb = {
  vendor_applications: [],
  vendor_profiles: [],
  charging_guns: [],
  qr_mappings: [],
  vendor_orders: [],
  vendor_payments: [],
  vendor_stations: [],
  vendor_chargers: [],
  charger_qr_payments: [],
  charging_sessions: [],
  vendor_wallets: [],
  vendor_wallet_ledger: [],
  razorpay_events: [],
  refunds: [],
};

function readDb() {
  try {
    if (!fs.existsSync(dbPath)) return { ...defaultDb };
    return { ...defaultDb, ...JSON.parse(fs.readFileSync(dbPath, 'utf8')) };
  } catch {
    return { ...defaultDb };
  }
}

function writeDb(db) {
  fs.writeFileSync(dbPath, JSON.stringify(db, null, 2));
}

function websocketAcceptKey(key) {
  return crypto.createHash('sha1').update(`${key}258EAFA5-E914-47DA-95CA-C5AB0DC85B11`).digest('base64');
}

function websocketTextFrame(text) {
  const payload = Buffer.from(text);
  const header = payload.length < 126 ? Buffer.from([0x81, payload.length]) : Buffer.from([0x81, 126, payload.length >> 8, payload.length & 255]);
  return Buffer.concat([header, payload]);
}

function readWebsocketText(buffer) {
  const opcode = buffer[0] & 0x0f;
  if (opcode === 0x8) return null;
  let offset = 2;
  let length = buffer[1] & 0x7f;
  if (length === 126) {
    length = buffer.readUInt16BE(offset);
    offset += 2;
  } else if (length === 127) {
    length = Number(buffer.readBigUInt64BE(offset));
    offset += 8;
  }
  const masked = (buffer[1] & 0x80) === 0x80;
  const mask = masked ? buffer.subarray(offset, offset + 4) : null;
  if (masked) offset += 4;
  const payload = Buffer.from(buffer.subarray(offset, offset + length));
  if (mask) {
    for (let index = 0; index < payload.length; index += 1) payload[index] ^= mask[index % 4];
  }
  return payload.toString('utf8');
}

function ocppResponse(message) {
  try {
    const payload = JSON.parse(message);
    if (!Array.isArray(payload) || payload.length < 3) return JSON.stringify({ ok: true, received: message });
    const [messageType, uniqueId, action] = payload;
    if (messageType !== 2) return JSON.stringify([3, uniqueId || 'local', {}]);
    const currentTime = new Date().toISOString();
    const responses = {
      BootNotification: { currentTime, interval: 30, status: 'Accepted' },
      Heartbeat: { currentTime },
      StatusNotification: {},
      MeterValues: {},
      Authorize: { idTagInfo: { status: 'Accepted' } },
      StartTransaction: { transactionId: Date.now(), idTagInfo: { status: 'Accepted' } },
      StopTransaction: { idTagInfo: { status: 'Accepted' } },
    };
    return JSON.stringify([3, uniqueId, responses[action] || {}]);
  } catch {
    return JSON.stringify({ ok: true, message: 'Local OCPP WebSocket received text frame.' });
  }
}

function ensureOps(db) {
  if (!db.vendor_stations) db.vendor_stations = [];
  if (!db.vendor_chargers) db.vendor_chargers = [];
  if (!db.charging_sessions) db.charging_sessions = [];
  if (!db.charger_qr_payments) db.charger_qr_payments = [];
  if (!db.vendor_wallets) db.vendor_wallets = [];
  if (!db.vendor_wallet_ledger) db.vendor_wallet_ledger = [];
  if (!db.refunds) db.refunds = [];
  if (!db.razorpay_events) db.razorpay_events = [];
  db.vendor_chargers.forEach((charger) => {
    const station = db.vendor_stations[0];
    charger.vendor_id = charger.vendor_id || vendorId;
    charger.station_id = station?.id || charger.station_id || null;
    charger.station_name = station?.name || charger.station_name || null;
    charger.location = station?.location || charger.location || null;
    charger.guns = Array.isArray(charger.guns) && charger.guns.length ? charger.guns : [
      {
        gun_index: 1,
        connector_type: 'CCS2',
        max_kw_output: Number(charger.max_kw_output || 60),
        status: charger.status === 'Charging' ? 'Charging' : 'Available',
        razorpay_qr_id: charger.razorpay_qr_id || `rzp_qr_${String(charger.charger_id).toLowerCase()}_g1`,
      },
    ];
    charger.ocpp_test_status = charger.ocpp_test_status || (charger.status === 'Faulted' ? 'Faulted' : 'Ready');
    charger.cms_websocket_url = charger.cms_websocket_url || defaultCmsWsUrl;
  });
  return db;
}

function opsPayload(db) {
  ensureOps(db);
  const active = db.charging_sessions.filter((s) => s.status === 'Active');
  const healthy = db.vendor_chargers.filter((c) => c.status !== 'Offline' && c.status !== 'Faulted');
  const wallet = db.vendor_wallets[0] || { vendor_id: vendorId, available_balance: 0, pending_balance: 0, lifetime_earned: 0, refunded_total: 0, currency: 'INR' };
  return {
    success: true,
    summary: {
      vendor_id: vendorId,
      station_count: db.vendor_stations.length,
      charger_count: db.vendor_chargers.length,
      gun_count: db.vendor_chargers.reduce((sum, c) => sum + (c.guns?.length || 0), 0),
      total_revenue: wallet?.lifetime_earned || 0,
      today_energy_kwh: Number(db.charging_sessions.reduce((sum, s) => sum + Number(s.kwh_delivered || 0), 0).toFixed(2)),
      active_sessions: active.length,
      charger_uptime: db.vendor_chargers.length ? Math.round((healthy.length / db.vendor_chargers.length) * 1000) / 10 : 0,
      pending_refunds: db.charger_qr_payments.filter((p) => p.refunded_amount > 0 && p.status !== 'Refunded').length,
    },
    station: db.vendor_stations[0] || null,
    chargers: db.vendor_chargers,
    sessions: db.charging_sessions,
    payments: db.charger_qr_payments,
    wallet,
    ledger: db.vendor_wallet_ledger,
    recent_activity: [],
  };
}

function startSession(db, body) {
  ensureOps(db);
  const charger = db.vendor_chargers.find((c) => c.charger_id === body.charger_id) || db.vendor_chargers[0];
  if (!charger || charger.status === 'Faulted' || charger.status === 'Offline') {
    return { status: 400, body: { success: false, error: 'Faulted/offline charger cannot start a session' } };
  }
  charger.status = 'Charging';
  charger.current_kw_output = Math.min(45, charger.max_kw_output);
  charger.last_heartbeat = new Date().toISOString();
  const payment = body.payment_id ? db.charger_qr_payments.find((p) => p.id === body.payment_id) : db.charger_qr_payments[0];
  const session = {
    session_id: `SES-${Date.now()}`,
    vendor_id: vendorId,
    user_id: body.user_id || payment?.user_id || 'USER-UPI-DEMO',
    charger_id: charger.charger_id,
    gun_index: Number(body.gun_index || 1),
    status: 'Active',
    payment_id: payment?.id || '',
    rate_card_id: charger.rate_card_id,
    started_at: new Date().toISOString(),
    soc_percent: 22,
    kwh_delivered: 0,
    current_kw: charger.current_kw_output,
    total_cost: 0,
    refund_status: 'None',
  };
  db.charging_sessions.unshift(session);
  return { status: 200, body: { success: true, message: 'RemoteStartTransaction dispatched to OCPP bridge.', session, charger } };
}

function stopSession(db, body) {
  ensureOps(db);
  const session = db.charging_sessions.find((s) => s.session_id === body.session_id);
  if (!session) return { status: 404, body: { success: false, error: 'Session not found' } };
  const charger = db.vendor_chargers.find((c) => c.charger_id === session.charger_id);
  const payment = db.charger_qr_payments.find((p) => p.id === session.payment_id);
  const minutes = Math.max(1, Math.round((Date.now() - new Date(session.started_at).getTime()) / 60000));
  const kwh = session.kwh_delivered || Number(((session.current_kw || 30) * minutes / 60).toFixed(2));
  const finalCost = Number((kwh * 10 + minutes * 0.5 + 20).toFixed(2));
  const refund = Math.max(0, Number(((payment?.hold_amount || 0) - finalCost).toFixed(2)));
  session.status = 'Completed';
  session.ended_at = new Date().toISOString();
  session.kwh_delivered = kwh;
  session.total_cost = finalCost;
  session.current_kw = 0;
  session.refund_status = refund > 0 ? 'Processed' : 'None';
  if (payment) {
    payment.captured_amount = finalCost;
    payment.refunded_amount = refund;
    payment.status = refund > 0 ? 'Refunded' : 'Captured';
  }
  if (charger) {
    charger.status = 'Available';
    charger.current_kw_output = 0;
  }
  const wallet = db.vendor_wallets[0];
  wallet.available_balance = Number((wallet.available_balance + finalCost).toFixed(2));
  wallet.pending_balance = Math.max(0, Number((wallet.pending_balance - finalCost).toFixed(2)));
  wallet.lifetime_earned = Number((wallet.lifetime_earned + finalCost).toFixed(2));
  wallet.refunded_total = Number((wallet.refunded_total + refund).toFixed(2));
  db.vendor_wallet_ledger.unshift({ id: `ledger-${Date.now()}`, vendor_id: vendorId, type: 'Session Earning', description: `Final settlement for ${session.session_id}`, amount: finalCost, status: 'Settled', created_at: new Date().toISOString() });
  if (refund > 0) db.vendor_wallet_ledger.unshift({ id: `ledger-refund-${Date.now()}`, vendor_id: vendorId, type: 'Refund', description: `UPI refund to ${session.user_id}`, amount: -refund, status: 'Processed', created_at: new Date().toISOString() });
  return { status: 200, body: { success: true, final_cost: finalCost, refunded_amount: refund, session, payment, wallet } };
}

async function readJson(req) {
  const chunks = [];
  for await (const chunk of req) chunks.push(chunk);
  const raw = Buffer.concat(chunks).toString('utf8');
  return raw ? JSON.parse(raw) : {};
}

function send(res, status, data) {
  res.writeHead(status, {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET,POST,PUT,PATCH,DELETE,OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  });
  res.end(JSON.stringify(data));
}

const server = http.createServer(async (req, res) => {
  if (req.method === 'OPTIONS') return send(res, 200, { ok: true });

  const url = new URL(req.url || '/', `http://localhost:${port}`);
  const db = readDb();
  ensureOps(db);

  try {
    if (url.pathname === '/api/vendors/apply' && req.method === 'GET') {
      return send(res, 200, { success: true, applications: db.vendor_applications });
    }

    if (url.pathname === '/api/vendors/apply' && req.method === 'POST') {
      const body = await readJson(req);
      const app = {
        id: `app-${Date.now()}`,
        business_name: body.business_name || body.businessName || 'Vendor Business',
        contact_email: body.contact_email || body.email || 'vendor@example.com',
        tax_id: body.tax_id || '',
        business_registration_number: body.business_registration_number || '',
        vat_number: body.vat_number || '',
        company_address: body.company_address || body.address || '',
        phone_number: body.phone_number || body.phone || '',
        utility_bill_url: body.utility_bill_url || '',
        estimated_chargers: Number(body.estimated_chargers || 0),
        kyc_status: 'Pending',
        status: 'Pending',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      };
      db.vendor_applications.unshift(app);
      writeDb(db);
      return send(res, 200, { success: true, message: 'Application submitted successfully.', application: app });
    }

    if (url.pathname === '/api/vendors/action' && req.method === 'POST') {
      const body = await readJson(req);
      const app = db.vendor_applications.find((item) => item.id === body.id);
      if (!app) return send(res, 404, { success: false, error: 'Application not found' });
      app.status = body.action;
      app.kyc_status = body.action === 'Approved' ? 'Verified' : 'Failed';
      app.vendor_id = app.vendor_id || `vendor-${Date.now()}`;
      app.admin_notes = body.admin_notes || '';
      app.updated_at = new Date().toISOString();
      if (body.action === 'Approved') {
        db.vendor_profiles.unshift({
          id: `profile-${Date.now()}`,
          vendor_id: app.vendor_id,
          business_name: app.business_name,
          brand_color_primary: '#4ADDA2',
          commission_rate: 10,
          kyc_status: 'Verified',
          status: 'Active',
          created_at: new Date().toISOString(),
        });
      }
      writeDb(db);
      return send(res, 200, { success: true, application: app });
    }

    if (url.pathname === '/api/vendors/dashboard') {
      return send(res, 200, {
        success: true,
        summary: { total_orders: db.vendor_orders.length, active_bookings: 0, total_revenue: 0, current_balance: 0 },
        profile: db.vendor_profiles[0] || null,
        orders: db.vendor_orders,
        payments: db.vendor_payments,
      });
    }

    if (url.pathname === '/api/vendors/operations') {
      writeDb(db);
      return send(res, 200, opsPayload(db));
    }

    if (url.pathname === '/api/vendors/chargers' && req.method === 'GET') {
      return send(res, 200, opsPayload(db));
    }

    if (url.pathname === '/api/vendors/chargers' && req.method === 'POST') {
      const body = await readJson(req);
      const chargerId = body.charger_id || `CHG-${Date.now().toString().slice(-5)}`;
      if (!db.vendor_stations.length) {
        db.vendor_stations.push({
          id: `station-${Date.now()}`,
          vendor_id: vendorId,
          name: body.station_name || 'Vendor EV Station',
          location: body.location || 'Station location pending',
          address: body.address || '',
          status: 'Active',
        });
      }
      const station = db.vendor_stations[0];
      const charger = {
        id: `vc-${Date.now()}`,
        vendor_id: vendorId,
        station_id: station.id,
        station_name: station.name,
        location: station.location,
        charger_id: chargerId,
        ocpp_charge_point_id: body.ocpp_charge_point_id || `OCPP-${chargerId}`,
        cms_websocket_url: body.cms_websocket_url || defaultCmsWsUrl,
        rate_card_id: body.rate_card_id || 'rate-standard',
        max_kw_output: Number(body.max_kw_output || 60),
        status: 'Available',
        current_kw_output: 0,
        last_heartbeat: new Date().toISOString(),
        razorpay_qr_id: body.razorpay_qr_id || `rzp_qr_${chargerId.toLowerCase()}_g1`,
        guns: Array.from({ length: Math.max(1, Number(body.gun_count || 1)) }, (_, index) => ({
          gun_index: index + 1,
          connector_type: body.connector_type || 'CCS2',
          max_kw_output: Number(body.max_kw_output || 60),
          status: 'Available',
          razorpay_qr_id: `rzp_qr_${chargerId.toLowerCase()}_g${index + 1}`,
        })),
        ocpp_test_status: 'Ready',
        ocpp_last_test_at: null,
      };
      db.vendor_chargers.unshift(charger);
      writeDb(db);
      return send(res, 200, { success: true, charger });
    }

    if (url.pathname.match(/^\/api\/vendors\/chargers\/[^/]+\/configure$/) && req.method === 'POST') {
      const id = url.pathname.split('/')[4];
      const body = await readJson(req);
      const charger = db.vendor_chargers.find((c) => c.charger_id === id || c.id === id);
      if (!charger) return send(res, 404, { success: false, error: 'Charger not found' });
      Object.assign(charger, {
        station_name: db.vendor_stations[0]?.name || charger.station_name,
        location: db.vendor_stations[0]?.location || charger.location,
        ocpp_charge_point_id: body.ocpp_charge_point_id || charger.ocpp_charge_point_id,
        cms_websocket_url: body.cms_websocket_url || charger.cms_websocket_url || defaultCmsWsUrl,
        rate_card_id: body.rate_card_id || charger.rate_card_id,
        max_kw_output: Number(body.max_kw_output || charger.max_kw_output),
        razorpay_qr_id: body.razorpay_qr_id || charger.razorpay_qr_id,
        last_heartbeat: new Date().toISOString(),
      });
      const gunIndex = Number(body.gun_index || 1);
      const gun = charger.guns.find((item) => Number(item.gun_index) === gunIndex);
      if (gun) {
        Object.assign(gun, {
          connector_type: body.connector_type || gun.connector_type,
          max_kw_output: Number(body.gun_max_kw || body.max_kw_output || gun.max_kw_output),
          razorpay_qr_id: body.razorpay_qr_id || gun.razorpay_qr_id,
          status: body.gun_status || gun.status,
        });
      } else {
        charger.guns.push({
          gun_index: gunIndex,
          connector_type: body.connector_type || 'CCS2',
          max_kw_output: Number(body.gun_max_kw || body.max_kw_output || charger.max_kw_output),
          status: body.gun_status || 'Available',
          razorpay_qr_id: body.razorpay_qr_id || `rzp_qr_${String(charger.charger_id).toLowerCase()}_g${gunIndex}`,
        });
      }
      writeDb(db);
      return send(res, 200, { success: true, charger });
    }

    if (url.pathname.match(/^\/api\/vendors\/chargers\/[^/]+\/ocpp-test$/) && req.method === 'POST') {
      const id = url.pathname.split('/')[4];
      const body = await readJson(req);
      const charger = db.vendor_chargers.find((c) => c.charger_id === id || c.id === id);
      if (!charger) return send(res, 404, { success: false, error: 'Charger not found' });
      charger.ocpp_charge_point_id = body.ocpp_charge_point_id || charger.ocpp_charge_point_id;
      charger.cms_websocket_url = body.cms_websocket_url || charger.cms_websocket_url || defaultCmsWsUrl;
      charger.ocpp_test_status = body.force_fault ? 'Failed' : 'Connected';
      charger.ocpp_last_test_at = new Date().toISOString();
      charger.last_heartbeat = new Date().toISOString();
      if (charger.status === 'Offline') charger.status = 'Available';
      writeDb(db);
      return send(res, 200, {
        success: true,
        charger,
        test: {
          heartbeat: charger.ocpp_test_status === 'Connected',
          boot_notification: charger.ocpp_test_status === 'Connected',
          status_notification: charger.status,
          meter_values: charger.current_kw_output || 0,
          message: charger.ocpp_test_status === 'Connected' ? 'OCPP realtime test passed.' : 'OCPP realtime test failed.',
          cms_websocket_url: charger.cms_websocket_url,
        },
      });
    }

    if (url.pathname === '/api/vendors/orders') return send(res, 200, { success: true, orders: db.vendor_orders });
    if (url.pathname === '/api/vendors/payments') return send(res, 200, { success: true, payments: db.vendor_payments });
    if (url.pathname === '/api/vendors/profile') return send(res, 200, { success: true, profile: db.vendor_profiles[0] || null });

    if (url.pathname === '/api/chargers/guns' && req.method === 'GET') {
      const chargerId = url.searchParams.get('charger_id');
      const guns = chargerId ? db.charging_guns.filter((gun) => gun.charger_id === chargerId) : db.charging_guns;
      return send(res, 200, { success: true, guns });
    }

    if (url.pathname === '/api/chargers/guns' && req.method === 'POST') {
      const body = await readJson(req);
      const gun = {
        id: `gun-${Date.now()}`,
        charger_id: body.charger_id,
        gun_index: Number(body.gun_index || 1),
        connector_type: body.connector_type || 'CCS2',
        max_kw_output: Number(body.max_kw_output || 150),
        status: 'Available',
        updated_at: new Date().toISOString(),
      };
      db.charging_guns.push(gun);
      writeDb(db);
      return send(res, 200, { success: true, gun });
    }

    if (url.pathname === '/api/qr/map' && req.method === 'GET') return send(res, 200, { success: true, mappings: db.qr_mappings });
    if (url.pathname === '/api/qr/map' && req.method === 'POST') {
      const body = await readJson(req);
      const mapping = {
        qr_id: body.qr_id,
        charger_id: body.charger_id,
        gun_index: Number(body.gun_index || 1),
        short_url: `https://app.bleuright.com/charge?qr=${body.qr_id}`,
        created_at: new Date().toISOString(),
      };
      db.qr_mappings = db.qr_mappings.filter((item) => item.qr_id !== mapping.qr_id);
      db.qr_mappings.push(mapping);
      writeDb(db);
      return send(res, 200, { success: true, mapping });
    }

    if (url.pathname === '/api/payments/qr-initiate' && req.method === 'POST') {
      const body = await readJson(req);
      return send(res, 200, {
        success: true,
        message: 'Payment Authorized. Charging Started.',
        session_id: `SES-QR-${Date.now()}`,
        charger_id: body.charger_id || 'CHG-DEMO',
        gun_index: 1,
        pre_auth_deducted: 30,
        remaining_balance: 120,
      });
    }

    if (url.pathname === '/api/payments/razorpay/webhook' && req.method === 'POST') {
      const body = await readJson(req);
      const entity = body.payload?.payment?.entity || body.payment || body;
      const qrId = entity.notes?.razorpay_qr_id || entity.qr_id || entity.razorpay_qr_id || 'rzp_qr_chg_b2_g1';
      const charger = db.vendor_chargers.find((c) => c.razorpay_qr_id === qrId) || db.vendor_chargers[1] || db.vendor_chargers[0];
      if (!charger || charger.status === 'Faulted' || charger.status === 'Offline') return send(res, 400, { success: false, error: 'Charger is not available for session start' });
      const payment = {
        id: `pay-local-${Date.now()}`,
        vendor_id: vendorId,
        razorpay_payment_id: entity.id || `pay_${Date.now()}`,
        razorpay_qr_id: qrId,
        user_id: entity.notes?.user_id || 'USER-UPI-DEMO',
        charger_id: charger.charger_id,
        gun_index: Number(entity.notes?.gun_index || 1),
        hold_amount: Number(entity.amount || 50000) / 100,
        captured_amount: 0,
        refunded_amount: 0,
        status: 'Authorized',
        created_at: new Date().toISOString(),
      };
      db.charger_qr_payments.unshift(payment);
      const result = startSession(db, { payment_id: payment.id, charger_id: charger.charger_id, user_id: payment.user_id, gun_index: payment.gun_index });
      writeDb(db);
      return send(res, result.status, result.body);
    }

    if (url.pathname === '/api/charging/start' && req.method === 'POST') {
      const result = startSession(db, await readJson(req));
      writeDb(db);
      return send(res, result.status, result.body);
    }

    if (url.pathname === '/api/charging/stop' && req.method === 'POST') {
      const result = stopSession(db, await readJson(req));
      writeDb(db);
      return send(res, result.status, result.body);
    }

    if (url.pathname.startsWith('/api/ocpp/')) {
      return send(res, 200, { success: true, message: 'Local OCPP command accepted.' });
    }

    return send(res, 404, { success: false, error: `No local handler for ${url.pathname}` });
  } catch (error) {
    return send(res, 500, { success: false, error: error.message });
  }
});

server.on('upgrade', (req, socket) => {
  const url = new URL(req.url || '/', `http://${req.headers.host || `localhost:${port}`}`);
  if (!url.pathname.startsWith('/ocpp')) {
    socket.write('HTTP/1.1 404 Not Found\r\n\r\n');
    socket.destroy();
    return;
  }

  const key = req.headers['sec-websocket-key'];
  if (!key) {
    socket.write('HTTP/1.1 400 Bad Request\r\n\r\n');
    socket.destroy();
    return;
  }

  socket.write([
    'HTTP/1.1 101 Switching Protocols',
    'Upgrade: websocket',
    'Connection: Upgrade',
    `Sec-WebSocket-Accept: ${websocketAcceptKey(key)}`,
    'Sec-WebSocket-Protocol: ocpp1.6',
    '\r\n',
  ].join('\r\n'));

  const chargePointId = decodeURIComponent(url.pathname.split('/').filter(Boolean)[1] || 'LOCAL-CHARGER');
  socket.write(websocketTextFrame(JSON.stringify({ type: 'cms_connected', charge_point_id: chargePointId, status: 'Accepted' })));
  const pingTimer = setInterval(() => {
    if (!socket.destroyed) socket.write(websocketTextFrame(JSON.stringify({ type: 'cms_heartbeat', currentTime: new Date().toISOString() })));
  }, 30000);

  socket.on('data', (chunk) => {
    const message = readWebsocketText(chunk);
    if (message === null) {
      socket.end();
      return;
    }
    socket.write(websocketTextFrame(ocppResponse(message)));
  });
  socket.on('close', () => clearInterval(pingTimer));
  socket.on('error', () => clearInterval(pingTimer));
});

server.listen(port, '0.0.0.0', () => {
  console.log(`EV CMS local API running at http://localhost:${port}`);
  console.log(`Vendor API: http://localhost:${port}/api/vendors/apply`);
  console.log(`OCPP WebSocket: ${defaultCmsWsUrl}/{chargePointId}`);
});
