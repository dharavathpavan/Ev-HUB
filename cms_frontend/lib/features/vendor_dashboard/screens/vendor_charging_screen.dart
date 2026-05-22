import 'package:flutter/material.dart';

import '../vendor_ops_service.dart';
import '../widgets/vendor_ops_widgets.dart';

class VendorChargingScreen extends StatefulWidget {
  const VendorChargingScreen({super.key});

  @override
  State<VendorChargingScreen> createState() => _VendorChargingScreenState();
}

class _VendorChargingScreenState extends State<VendorChargingScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = VendorOpsService.fetchOperations();
  }

  void _refresh() => setState(() => _future = VendorOpsService.fetchOperations());

  Future<void> _simulateQr(String qrId) async {
    final result = await VendorOpsService.simulateRazorpayWebhook(qrId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['success'] == true ? 'Razorpay webhook received. OCPP start dispatched.' : result['error']?.toString() ?? 'Start failed'),
        backgroundColor: result['success'] == true ? vendorMint : Colors.redAccent,
      ),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        final chargers = List<Map<String, dynamic>>.from(snapshot.data?['chargers'] ?? []);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VendorPageHeader(
                title: 'Charging Management',
                subtitle: 'Monitor connector guns, Razorpay QR flow, and OCPP charger commands.',
                action: ElevatedButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh, color: Colors.black),
                  label: const Text('Refresh', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(backgroundColor: vendorMint, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                ),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: chargers.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 18, mainAxisSpacing: 18, childAspectRatio: 1.18),
                itemBuilder: (context, index) {
                  final charger = chargers[index];
                  final currentKw = double.tryParse(charger['current_kw_output']?.toString() ?? '0') ?? 0;
                  final maxKw = double.tryParse(charger['max_kw_output']?.toString() ?? '1') ?? 1;
                  final qrId = charger['razorpay_qr_id']?.toString() ?? '';

                  return VendorSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(charger['charger_id'] ?? '-', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800))),
                            VendorStatusPill(status: charger['status'] ?? 'Unknown'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(charger['station_name'] ?? '-', style: const TextStyle(color: vendorMuted)),
                        Text(charger['ocpp_charge_point_id'] ?? '-', style: const TextStyle(color: vendorMuted, fontSize: 12)),
                        const SizedBox(height: 18),
                        LinearProgressIndicator(value: (currentKw / maxKw).clamp(0, 1).toDouble(), color: vendorMint, backgroundColor: vendorBorder),
                        const SizedBox(height: 8),
                        Text('${currentKw.toStringAsFixed(1)} kW / ${maxKw.toStringAsFixed(0)} kW', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        Text('Razorpay QR: $qrId', style: const TextStyle(color: vendorMuted, fontSize: 11), overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: charger['status'] == 'Faulted' || charger['status'] == 'Offline' ? null : () => _simulateQr(qrId),
                                icon: const Icon(Icons.qr_code, color: Colors.black, size: 16),
                                label: const Text('Simulate QR Pay', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                                style: ElevatedButton.styleFrom(backgroundColor: vendorMint, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: 'Reset / unlock via OCPP bridge',
                              onPressed: () {},
                              icon: const Icon(Icons.settings_remote, color: vendorMint),
                              style: IconButton.styleFrom(backgroundColor: const Color(0xFF242424), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                            )
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
