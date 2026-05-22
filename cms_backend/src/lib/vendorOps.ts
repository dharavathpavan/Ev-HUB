import { mockDb } from './mockDb';

export type ChargerStatus = 'Available' | 'Preparing' | 'Charging' | 'Faulted' | 'Offline';
export type PaymentStatus = 'Authorized' | 'Captured' | 'Refunded' | 'Failed';
export type SessionStatus = 'Pending' | 'Active' | 'Completed' | 'Faulted' | 'Stopped';

const vendorId = process.env.VENDOR_ID || 'vendor-production';

type VendorCharger = {
  id: string;
  vendor_id: string;
  station_name: string;
  location: string;
  charger_id: string;
  ocpp_charge_point_id: string;
  rate_card_id: string;
  max_kw_output: number;
  status: ChargerStatus;
  current_kw_output: number;
  last_heartbeat: string;
  razorpay_qr_id: string;
};

type ChargerPayment = {
  id: string;
  vendor_id: string;
  razorpay_payment_id: string;
  razorpay_qr_id: string;
  user_id: string;
  charger_id: string;
  gun_index: number;
  hold_amount: number;
  captured_amount: number;
  refunded_amount: number;
  status: PaymentStatus;
  created_at: string;
};

type ChargingSession = {
  session_id: string;
  vendor_id: string;
  user_id: string;
  charger_id: string;
  gun_index: number;
  status: SessionStatus;
  payment_id: string;
  rate_card_id: string;
  started_at: string;
  ended_at?: string;
  soc_percent: number;
  kwh_delivered: number;
  current_kw: number;
  total_cost: number;
  refund_status: 'None' | 'Pending' | 'Processed';
};

type VendorWallet = {
  vendor_id: string;
  available_balance: number;
  pending_balance: number;
  lifetime_earned: number;
  refunded_total: number;
  currency: string;
};

type WalletLedger = {
  id: string;
  vendor_id: string;
  type: 'Session Earning' | 'Refund' | 'Payout' | 'Adjustment';
  description: string;
  amount: number;
  status: 'Pending' | 'Settled' | 'Processed';
  created_at: string;
};

const state: {
  chargers: VendorCharger[];
  payments: ChargerPayment[];
  sessions: ChargingSession[];
  wallet: VendorWallet;
  ledger: WalletLedger[];
} = {
  chargers: [],
  payments: [],
  sessions: [],
  wallet: {
    vendor_id: vendorId,
    available_balance: 0,
    pending_balance: 0,
    lifetime_earned: 0,
    refunded_total: 0,
    currency: 'INR',
  } satisfies VendorWallet,
  ledger: [],
};

function now() {
  return new Date().toISOString();
}

function calculateCost(kwh: number, minutes: number) {
  const perKwh = 10;
  const perMinute = 0.5;
  const fixed = 20;
  return Number((kwh * perKwh + minutes * perMinute + fixed).toFixed(2));
}

async function sendBridgeCommand(path: string, payload: Record<string, unknown>) {
  const baseUrl = process.env.OCPP_BRIDGE_URL;
  if (!baseUrl) {
    return { dispatched: false, reason: 'OCPP_BRIDGE_URL is not configured for local demo mode.' };
  }

  try {
    const response = await fetch(new URL(path, baseUrl), {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(process.env.OCPP_BRIDGE_API_KEY ? { Authorization: `Bearer ${process.env.OCPP_BRIDGE_API_KEY}` } : {}),
      },
      body: JSON.stringify(payload),
    });

    return { dispatched: response.ok, status: response.status };
  } catch (error) {
    return { dispatched: false, error: error instanceof Error ? error.message : 'OCPP bridge request failed' };
  }
}

export const vendorOps = {
  overview() {
    const activeSessions = state.sessions.filter((session) => session.status === 'Active');
    const onlineChargers = state.chargers.filter((charger) => charger.status !== 'Offline' && charger.status !== 'Faulted');
    const payments = mockDb.getPayments(vendorId);
    const totalRevenue = payments.reduce((sum, payment) => sum + payment.amount, 0) + state.wallet.lifetime_earned;

    return {
      success: true,
      summary: {
        vendor_id: vendorId,
        total_revenue: Number(totalRevenue.toFixed(2)),
        today_energy_kwh: Number(state.sessions.reduce((sum, session) => sum + session.kwh_delivered, 0).toFixed(2)),
        active_sessions: activeSessions.length,
        charger_uptime: state.chargers.length ? Math.round((onlineChargers.length / state.chargers.length) * 1000) / 10 : 0,
        pending_refunds: state.payments.filter((payment) => payment.refunded_amount > 0 && payment.status !== 'Refunded').length,
      },
      chargers: state.chargers,
      sessions: state.sessions,
      payments: state.payments,
      wallet: state.wallet,
      ledger: state.ledger,
      recent_activity: [],
    };
  },

  createCharger(input: Partial<VendorCharger>) {
    const id = `vc-${Date.now()}`;
    const chargerId = input.charger_id || `CHG-${Date.now().toString().slice(-5)}`;
    const charger: VendorCharger = {
      id,
      vendor_id: vendorId,
      station_name: input.station_name || 'New Vendor Station',
      location: input.location || 'Unassigned Location',
      charger_id: chargerId,
      ocpp_charge_point_id: input.ocpp_charge_point_id || `OCPP-${chargerId}`,
      rate_card_id: input.rate_card_id || 'rate-standard',
      max_kw_output: Number(input.max_kw_output || 60),
      status: 'Available',
      current_kw_output: 0,
      last_heartbeat: now(),
      razorpay_qr_id: input.razorpay_qr_id || `rzp_qr_${chargerId.toLowerCase()}_g1`,
    };
    state.chargers.unshift(charger);
    mockDb.addGun({ charger_id: charger.charger_id, gun_index: 1, connector_type: 'CCS2', max_kw_output: charger.max_kw_output });
    mockDb.mapQr({ qr_id: `QR-${charger.charger_id}-G1`, charger_id: charger.charger_id, gun_index: 1 });
    return { success: true, charger };
  },

  configureCharger(chargerId: string, input: Partial<VendorCharger> & { gun_index?: number; connector_type?: 'CCS2' | 'Type2' | 'CHAdeMO' | 'GB_T' }) {
    const charger = state.chargers.find((item) => item.charger_id === chargerId || item.id === chargerId);
    if (!charger) return { success: false, error: 'Charger not found' };
    Object.assign(charger, {
      station_name: input.station_name ?? charger.station_name,
      location: input.location ?? charger.location,
      ocpp_charge_point_id: input.ocpp_charge_point_id ?? charger.ocpp_charge_point_id,
      rate_card_id: input.rate_card_id ?? charger.rate_card_id,
      max_kw_output: input.max_kw_output ? Number(input.max_kw_output) : charger.max_kw_output,
      razorpay_qr_id: input.razorpay_qr_id ?? charger.razorpay_qr_id,
      last_heartbeat: now(),
    });
    mockDb.addGun({
      charger_id: charger.charger_id,
      gun_index: Number(input.gun_index || 1),
      connector_type: input.connector_type || 'CCS2',
      max_kw_output: charger.max_kw_output,
    });
    return { success: true, charger };
  },

  async razorpayWebhook(payload: any) {
    const event = payload.event || 'qr_code.credited';
    const entity = payload.payload?.payment?.entity || payload.payment || payload;
    const qrId = entity.notes?.razorpay_qr_id || entity.qr_id || entity.razorpay_qr_id || 'rzp_qr_chg_b2_g1';
    const charger = state.chargers.find((item) => item.razorpay_qr_id === qrId) || state.chargers[1] || state.chargers[0];
    if (!charger) return { success: false, error: 'No charger mapped to Razorpay QR' };
    if (charger.status === 'Faulted' || charger.status === 'Offline') {
      return { success: false, error: 'Charger is not available for session start' };
    }
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
      status: event.includes('failed') ? 'Failed' : 'Authorized',
      created_at: now(),
    } satisfies ChargerPayment;
    state.payments.unshift(payment);
    if (payment.status === 'Authorized') {
      return this.startSession({ payment_id: payment.id, charger_id: charger.charger_id, user_id: payment.user_id, gun_index: payment.gun_index });
    }
    return { success: true, payment };
  },

  async startSession(input: { payment_id?: string; charger_id: string; user_id?: string; gun_index?: number }) {
    const charger = state.chargers.find((item) => item.charger_id === input.charger_id);
    if (!charger) return { success: false, error: 'Charger not found' };
    if (charger.status === 'Faulted' || charger.status === 'Offline') {
      return { success: false, error: 'Faulted/offline charger cannot start a session' };
    }
    charger.status = 'Charging';
    charger.current_kw_output = Math.min(45, charger.max_kw_output);
    charger.last_heartbeat = now();
    const payment = state.payments.find((item) => item.id === input.payment_id) || state.payments[0];
    const session = {
      session_id: `SES-${Date.now()}`,
      vendor_id: vendorId,
      user_id: input.user_id || payment?.user_id || 'USER-UPI-DEMO',
      charger_id: charger.charger_id,
      gun_index: Number(input.gun_index || 1),
      status: 'Active',
      payment_id: payment?.id || '',
      rate_card_id: charger.rate_card_id,
      started_at: now(),
      soc_percent: 22,
      kwh_delivered: 0,
      current_kw: charger.current_kw_output,
      total_cost: 0,
      refund_status: 'None',
    } satisfies ChargingSession;
    state.sessions.unshift(session);
    mockDb.updateGunStatus(charger.charger_id, session.gun_index, 'Charging');
    const bridge = await sendBridgeCommand('/remote-start', {
      command: 'RemoteStartTransaction',
      charge_point_id: charger.ocpp_charge_point_id,
      charger_id: charger.charger_id,
      connector_id: session.gun_index,
      session_id: session.session_id,
      payment_id: session.payment_id,
    });
    return { success: true, message: 'RemoteStartTransaction dispatched to OCPP bridge.', session, charger, bridge };
  },

  async stopSession(input: { session_id: string; reason?: string }) {
    const session: ChargingSession | undefined = state.sessions.find((item) => item.session_id === input.session_id);
    if (!session) return { success: false, error: 'Session not found' };
    const charger = state.chargers.find((item) => item.charger_id === session.charger_id);
    const payment = state.payments.find((item) => item.id === session.payment_id);
    const started = new Date(session.started_at).getTime();
    const minutes = Math.max(1, Math.round((Date.now() - started) / 60000));
    const kwh = session.kwh_delivered || Number(((session.current_kw || 30) * minutes / 60).toFixed(2));
    const finalCost = calculateCost(kwh, minutes);
    const refund = Math.max(0, Number(((payment?.hold_amount || 0) - finalCost).toFixed(2)));

    session.status = input.reason === 'fault' ? 'Faulted' : 'Completed';
    session.ended_at = now();
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
      charger.status = session.status === 'Faulted' ? 'Faulted' : 'Available';
      charger.current_kw_output = 0;
      charger.last_heartbeat = now();
      mockDb.updateGunStatus(charger.charger_id, session.gun_index, charger.status === 'Faulted' ? 'Faulted' : 'Available');
    }

    state.wallet.pending_balance = Math.max(0, Number((state.wallet.pending_balance - finalCost).toFixed(2)));
    state.wallet.available_balance = Number((state.wallet.available_balance + finalCost).toFixed(2));
    state.wallet.lifetime_earned = Number((state.wallet.lifetime_earned + finalCost).toFixed(2));
    state.wallet.refunded_total = Number((state.wallet.refunded_total + refund).toFixed(2));
    state.ledger.unshift({
      id: `ledger-${Date.now()}`,
      vendor_id: vendorId,
      type: 'Session Earning',
      description: `Final settlement for ${session.session_id}`,
      amount: finalCost,
      status: 'Settled',
      created_at: now(),
    });
    if (refund > 0) {
      state.ledger.unshift({
        id: `ledger-refund-${Date.now()}`,
        vendor_id: vendorId,
        type: 'Refund',
        description: `UPI refund to ${session.user_id}`,
        amount: -refund,
        status: 'Processed',
        created_at: now(),
      });
    }

    const bridge = await sendBridgeCommand('/remote-stop', {
      command: 'RemoteStopTransaction',
      charge_point_id: charger?.ocpp_charge_point_id,
      charger_id: session.charger_id,
      connector_id: session.gun_index,
      session_id: session.session_id,
      reason: input.reason || 'vendor_stop',
    });

    return { success: true, final_cost: finalCost, refunded_amount: refund, session, payment, wallet: state.wallet, bridge };
  },

  updateTelemetry(input: { charger_id: string; status?: ChargerStatus; current_kw?: number; kwh_delivered?: number; soc_percent?: number }) {
    const charger = state.chargers.find((item) => item.charger_id === input.charger_id);
    if (charger) {
      charger.status = input.status || charger.status;
      charger.current_kw_output = input.current_kw ?? charger.current_kw_output;
      charger.last_heartbeat = now();
    }
    const session = state.sessions.find((item) => item.charger_id === input.charger_id && item.status === 'Active');
    if (session) {
      session.current_kw = input.current_kw ?? session.current_kw;
      session.kwh_delivered = input.kwh_delivered ?? session.kwh_delivered;
      session.soc_percent = input.soc_percent ?? session.soc_percent;
      session.total_cost = calculateCost(session.kwh_delivered, Math.max(1, Math.round((Date.now() - new Date(session.started_at).getTime()) / 60000)));
    }
    return { success: true, charger, session };
  },
};
