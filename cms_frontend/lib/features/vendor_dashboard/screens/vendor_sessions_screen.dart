import 'package:flutter/material.dart';

import '../vendor_ops_service.dart';
import '../widgets/vendor_ops_widgets.dart';

class VendorSessionsScreen extends StatefulWidget {
  const VendorSessionsScreen({super.key});

  @override
  State<VendorSessionsScreen> createState() => _VendorSessionsScreenState();
}

class _VendorSessionsScreenState extends State<VendorSessionsScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = VendorOpsService.fetchOperations();
  }

  void _refresh() => setState(() => _future = VendorOpsService.fetchOperations());

  Future<void> _stop(String sessionId) async {
    final result = await VendorOpsService.stopSession(sessionId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['success'] == true ? 'Session stopped. Cost settled and refund processed.' : result['error']?.toString() ?? 'Stop failed'),
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
        final sessions = List<Map<String, dynamic>>.from(snapshot.data?['sessions'] ?? []);

        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VendorPageHeader(title: 'Live Sessions', subtitle: 'Track OCPP sessions from QR payment to settlement and UPI refund.', action: TextButton.icon(onPressed: _refresh, icon: const Icon(Icons.refresh, color: vendorMint), label: const Text('Refresh', style: TextStyle(color: vendorMint)))),
              const SizedBox(height: 24),
              Expanded(
                child: VendorSectionCard(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingTextStyle: const TextStyle(color: vendorMuted, fontWeight: FontWeight.w800),
                      dataTextStyle: const TextStyle(color: Colors.white),
                      columns: const [
                        DataColumn(label: Text('SESSION')),
                        DataColumn(label: Text('CHARGER / GUN')),
                        DataColumn(label: Text('SOC')),
                        DataColumn(label: Text('ENERGY')),
                        DataColumn(label: Text('COST')),
                        DataColumn(label: Text('REFUND')),
                        DataColumn(label: Text('STATUS')),
                        DataColumn(label: Text('ACTION')),
                      ],
                      rows: sessions.map((session) {
                        final active = session['status'] == 'Active';
                        return DataRow(cells: [
                          DataCell(Text(session['session_id'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w800))),
                          DataCell(Text('${session['charger_id']} / Gun ${session['gun_index']}')),
                          DataCell(Text('${session['soc_percent']}%')),
                          DataCell(Text('${session['kwh_delivered']} kWh')),
                          DataCell(Text(money(session['total_cost']))),
                          DataCell(Text(session['refund_status'] ?? 'None')),
                          DataCell(VendorStatusPill(status: session['status'] ?? 'Unknown')),
                          DataCell(active ? TextButton(onPressed: () => _stop(session['session_id']), child: const Text('Stop & Settle', style: TextStyle(color: vendorMint))) : const Text('-', style: TextStyle(color: vendorMuted))),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
