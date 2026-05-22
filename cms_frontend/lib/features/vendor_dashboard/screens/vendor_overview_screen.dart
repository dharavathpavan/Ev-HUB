import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../vendor_ops_service.dart';
import '../widgets/vendor_ops_widgets.dart';

class VendorOverviewScreen extends StatefulWidget {
  const VendorOverviewScreen({super.key});

  @override
  State<VendorOverviewScreen> createState() => _VendorOverviewScreenState();
}

class _VendorOverviewScreenState extends State<VendorOverviewScreen> {
  late Future<Map<String, dynamic>> _opsFuture;

  @override
  void initState() {
    super.initState();
    _opsFuture = VendorOpsService.fetchOperations();
  }

  void _refresh() {
    setState(() => _opsFuture = VendorOpsService.fetchOperations());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _opsFuture,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final summary = data?['summary'] as Map<String, dynamic>? ?? {};
        final chargers = List<Map<String, dynamic>>.from(data?['chargers'] ?? []);
        final sessions = List<Map<String, dynamic>>.from(data?['sessions'] ?? []);
        final wallet = data?['wallet'] as Map<String, dynamic>? ?? {};
        final activity = List<String>.from(data?['recent_activity'] ?? []);

        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VendorPageHeader(
                  title: 'Vendor Operations',
                  subtitle: 'Charging, payment, settlement, and charger health in one workspace.',
                  action: ElevatedButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh, color: Colors.black, size: 18),
                    label: const Text('Refresh', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(backgroundColor: vendorMint, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(child: VendorKpiCard(title: 'Lifetime Revenue', value: money(summary['total_revenue']), icon: Icons.currency_rupee, color: vendorMint)),
                    const SizedBox(width: 16),
                    Expanded(child: VendorKpiCard(title: 'Active Sessions', value: '${summary['active_sessions'] ?? 0}', icon: Icons.bolt, color: Colors.amber)),
                    const SizedBox(width: 16),
                    Expanded(child: VendorKpiCard(title: 'Charger Uptime', value: '${summary['charger_uptime'] ?? 0}%', icon: Icons.health_and_safety_outlined, color: Colors.blueAccent)),
                    const SizedBox(width: 16),
                    Expanded(child: VendorKpiCard(title: 'Pending Refunds', value: '${summary['pending_refunds'] ?? 0}', icon: Icons.currency_exchange, color: Colors.orangeAccent)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _LiveChargerGrid(chargers: chargers)),
                    const SizedBox(width: 20),
                    Expanded(child: _WalletAndActivity(wallet: wallet, activity: activity)),
                  ],
                ),
                const SizedBox(height: 24),
                _ActiveSessionPreview(sessions: sessions, onOpen: () => context.go('/vendor-dashboard/sessions')),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LiveChargerGrid extends StatelessWidget {
  final List<Map<String, dynamic>> chargers;

  const _LiveChargerGrid({required this.chargers});

  @override
  Widget build(BuildContext context) {
    return VendorSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Live Charger Health', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: chargers.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 2.7),
            itemBuilder: (context, index) {
              final charger = chargers[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF101010), borderRadius: BorderRadius.circular(8), border: Border.all(color: vendorBorder)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(charger['charger_id'] ?? '-', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
                        VendorStatusPill(status: charger['status'] ?? 'Unknown'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(charger['station_name'] ?? '-', style: const TextStyle(color: vendorMuted, fontSize: 12), overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    LinearProgressIndicator(
                      value: ((double.tryParse(charger['current_kw_output']?.toString() ?? '0') ?? 0) / (double.tryParse(charger['max_kw_output']?.toString() ?? '1') ?? 1)).clamp(0, 1).toDouble(),
                      color: vendorMint,
                      backgroundColor: vendorBorder,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WalletAndActivity extends StatelessWidget {
  final Map<String, dynamic> wallet;
  final List<String> activity;

  const _WalletAndActivity({required this.wallet, required this.activity});

  @override
  Widget build(BuildContext context) {
    return VendorSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Vendor Wallet', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          _walletLine('Available', money(wallet['available_balance']), vendorMint),
          _walletLine('Pending settlement', money(wallet['pending_balance']), Colors.amber),
          _walletLine('UPI refunds', money(wallet['refunded_total']), Colors.blueAccent),
          const SizedBox(height: 24),
          const Text('Workflow Feed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...activity.take(4).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  const Icon(Icons.circle, color: vendorMint, size: 8),
                  const SizedBox(width: 10),
                  Expanded(child: Text(item, style: const TextStyle(color: vendorMuted, fontSize: 13))),
                ]),
              )),
        ],
      ),
    );
  }

  Widget _walletLine(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: vendorMuted)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

class _ActiveSessionPreview extends StatelessWidget {
  final List<Map<String, dynamic>> sessions;
  final VoidCallback onOpen;

  const _ActiveSessionPreview({required this.sessions, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final active = sessions.where((session) => session['status'] == 'Active').toList();
    return VendorSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Active Charging Sessions', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              TextButton(onPressed: onOpen, child: const Text('View all sessions', style: TextStyle(color: vendorMint))),
            ],
          ),
          const SizedBox(height: 12),
          if (active.isEmpty)
            const Text('No active sessions right now.', style: TextStyle(color: vendorMuted))
          else
            ...active.take(3).map((session) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.ev_station, color: vendorMint),
                  title: Text('${session['session_id']} / ${session['charger_id']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  subtitle: Text('${session['kwh_delivered']} kWh / SOC ${session['soc_percent']}% / ${money(session['total_cost'])}', style: const TextStyle(color: vendorMuted)),
                  trailing: VendorStatusPill(status: session['status']),
                )),
        ],
      ),
    );
  }
}
