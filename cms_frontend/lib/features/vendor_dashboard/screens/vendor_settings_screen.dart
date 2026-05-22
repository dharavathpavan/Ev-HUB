import 'package:flutter/material.dart';

import '../widgets/vendor_ops_widgets.dart';

class VendorSettingsScreen extends StatelessWidget {
  const VendorSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VendorPageHeader(
            title: 'Vendor Settings',
            subtitle: 'Business profile, payout destination, webhook endpoints, and charger notification preferences.',
            action: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save_outlined, color: Colors.black, size: 18),
              label: const Text('Save', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(backgroundColor: vendorMint, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 980;
              final cards = [
                _settingsCard(
                  title: 'Business Profile',
                  icon: Icons.store_mall_directory_outlined,
                  rows: const [
                    _SettingsRow('Company', 'VoltSpark EV Solutions'),
                    _SettingsRow('Contact email', 'partner@voltspark.com'),
                    _SettingsRow('Phone', '+91 98765 43210'),
                    _SettingsRow('Vendor ID', 'vendor-voltspark'),
                    _SettingsRow('Commission', '8.5% platform fee'),
                  ],
                ),
                _settingsCard(
                  title: 'Payout Destination',
                  icon: Icons.account_balance_outlined,
                  rows: const [
                    _SettingsRow('UPI ID', 'voltspark@upi'),
                    _SettingsRow('Bank', 'State Bank of India'),
                    _SettingsRow('Account', 'XXXX1234'),
                    _SettingsRow('Settlement cycle', 'T + 1 business day'),
                    _SettingsRow('Wallet status', 'Active'),
                  ],
                ),
                _settingsCard(
                  title: 'Webhook Endpoints',
                  icon: Icons.integration_instructions_outlined,
                  rows: const [
                    _SettingsRow('Razorpay', '/api/payments/razorpay/webhook'),
                    _SettingsRow('OCPP telemetry', '/api/ocpp/webhook'),
                    _SettingsRow('Start session', '/api/charging/start'),
                    _SettingsRow('Stop session', '/api/charging/stop'),
                    _SettingsRow('Bridge mode', 'HTTPS OCPP bridge'),
                  ],
                ),
                _settingsCard(
                  title: 'Notifications',
                  icon: Icons.notifications_active_outlined,
                  rows: const [
                    _SettingsRow('Fault alerts', 'SMS + dashboard'),
                    _SettingsRow('Refund alerts', 'Dashboard'),
                    _SettingsRow('Low uptime', 'Email summary'),
                    _SettingsRow('Payouts', 'Daily settlement mail'),
                    _SettingsRow('Offline charger', 'Immediate alert'),
                  ],
                ),
              ];

              if (!isWide) {
                return Column(children: cards.map((card) => Padding(padding: const EdgeInsets.only(bottom: 16), child: card)).toList());
              }

              return Column(
                children: [
                  Row(children: [Expanded(child: cards[0]), const SizedBox(width: 18), Expanded(child: cards[1])]),
                  const SizedBox(height: 18),
                  Row(children: [Expanded(child: cards[2]), const SizedBox(width: 18), Expanded(child: cards[3])]),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _settingsCard({required String title, required IconData icon, required List<_SettingsRow> rows}) {
    return VendorSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: vendorMint, size: 22),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 18),
          ...rows,
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final String value;

  const _SettingsRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: vendorMuted, fontSize: 13))),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
