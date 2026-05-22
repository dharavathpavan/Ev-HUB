import 'package:flutter/material.dart';

import '../vendor_ops_service.dart';
import '../widgets/vendor_ops_widgets.dart';

class VendorStationsScreen extends StatefulWidget {
  const VendorStationsScreen({super.key});

  @override
  State<VendorStationsScreen> createState() => _VendorStationsScreenState();
}

class _VendorStationsScreenState extends State<VendorStationsScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = VendorOpsService.fetchOperations();
  }

  void _refresh() => setState(() => _future = VendorOpsService.fetchOperations());

  Future<void> _addCharger() async {
    final stamp = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    final result = await VendorOpsService.addCharger(
      stationName: 'New Vendor Hub $stamp',
      location: 'New Location',
      chargerId: 'CHG-$stamp',
      ocppId: 'OCPP-CHG-$stamp',
      maxKw: 60,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['success'] == true ? 'Charger added and QR mapping prepared.' : 'Unable to add charger'), backgroundColor: result['success'] == true ? vendorMint : Colors.redAccent));
    _refresh();
  }

  Future<void> _configure(Map<String, dynamic> charger) async {
    final result = await VendorOpsService.configureCharger(
      chargerId: charger['charger_id'],
      connectorType: 'CCS2',
      gunIndex: 1,
      rateCardId: 'rate-standard',
      maxKw: double.tryParse(charger['max_kw_output']?.toString() ?? '60') ?? 60,
      razorpayQrId: charger['razorpay_qr_id'] ?? 'rzp_qr_${charger['charger_id']}_g1',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['success'] == true ? 'Connector, rate card, OCPP ID and QR saved.' : result['error']?.toString() ?? 'Configure failed'), backgroundColor: result['success'] == true ? vendorMint : Colors.redAccent));
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        final chargers = List<Map<String, dynamic>>.from(snapshot.data?['chargers'] ?? []);

        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VendorPageHeader(
                title: 'Stations & Chargers',
                subtitle: 'Add charger cabinets, configure connector guns, assign rate cards, and generate Razorpay QR IDs.',
                action: ElevatedButton.icon(
                  onPressed: _addCharger,
                  icon: const Icon(Icons.add, color: Colors.black),
                  label: const Text('Add Charger', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(backgroundColor: vendorMint, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: VendorSectionCard(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingTextStyle: const TextStyle(color: vendorMuted, fontWeight: FontWeight.w800),
                      dataTextStyle: const TextStyle(color: Colors.white),
                      columns: const [
                        DataColumn(label: Text('STATION')),
                        DataColumn(label: Text('CHARGER')),
                        DataColumn(label: Text('OCPP ID')),
                        DataColumn(label: Text('RATE CARD')),
                        DataColumn(label: Text('RAZORPAY QR')),
                        DataColumn(label: Text('STATUS')),
                        DataColumn(label: Text('ACTION')),
                      ],
                      rows: chargers.map((charger) {
                        return DataRow(cells: [
                          DataCell(Text(charger['station_name'] ?? '-')),
                          DataCell(Text('${charger['charger_id']} / ${charger['max_kw_output']} kW', style: const TextStyle(fontWeight: FontWeight.w800))),
                          DataCell(Text(charger['ocpp_charge_point_id'] ?? '-')),
                          DataCell(Text(charger['rate_card_id'] ?? '-')),
                          DataCell(Text(charger['razorpay_qr_id'] ?? '-', overflow: TextOverflow.ellipsis)),
                          DataCell(VendorStatusPill(status: charger['status'] ?? 'Unknown')),
                          DataCell(TextButton(onPressed: () => _configure(charger), child: const Text('Configure', style: TextStyle(color: vendorMint)))),
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
