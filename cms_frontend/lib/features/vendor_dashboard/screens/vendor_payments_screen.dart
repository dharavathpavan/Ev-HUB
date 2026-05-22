import 'package:flutter/material.dart';

import '../vendor_ops_service.dart';
import '../widgets/vendor_ops_widgets.dart';

class VendorPaymentsScreen extends StatefulWidget {
  const VendorPaymentsScreen({super.key});

  @override
  State<VendorPaymentsScreen> createState() => _VendorPaymentsScreenState();
}

class _VendorPaymentsScreenState extends State<VendorPaymentsScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = VendorOpsService.fetchOperations();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        final payments = List<Map<String, dynamic>>.from(snapshot.data?['payments'] ?? []);
        final ledger = List<Map<String, dynamic>>.from(snapshot.data?['ledger'] ?? []);
        final wallet = snapshot.data?['wallet'] as Map<String, dynamic>? ?? {};

        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const VendorPageHeader(title: 'Billing & Vendor Wallet', subtitle: 'Razorpay UPI holds, final session cost, UPI refunds, and vendor settlement ledger.'),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: VendorKpiCard(title: 'Available Balance', value: money(wallet['available_balance']), icon: Icons.account_balance_wallet, color: vendorMint)),
                  const SizedBox(width: 16),
                  Expanded(child: VendorKpiCard(title: 'Pending Settlement', value: money(wallet['pending_balance']), icon: Icons.pending_actions, color: Colors.amber)),
                  const SizedBox(width: 16),
                  Expanded(child: VendorKpiCard(title: 'Refunded to UPI', value: money(wallet['refunded_total']), icon: Icons.currency_exchange, color: Colors.blueAccent)),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: VendorSectionCard(
                        child: _table('Razorpay Payment Ledger', const ['PAYMENT', 'CHARGER', 'HOLD', 'CAPTURED', 'REFUND', 'STATUS'], payments.map((p) => [
                              p['razorpay_payment_id'],
                              p['charger_id'],
                              money(p['hold_amount']),
                              money(p['captured_amount']),
                              money(p['refunded_amount']),
                              VendorStatusPill(status: p['status'] ?? 'Unknown'),
                            ]).toList()),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: VendorSectionCard(
                        child: _table('Vendor Wallet Ledger', const ['TYPE', 'DESCRIPTION', 'AMOUNT', 'STATUS'], ledger.map((l) => [
                              l['type'],
                              l['description'],
                              money(l['amount']),
                              VendorStatusPill(status: l['status'] ?? 'Unknown'),
                            ]).toList()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _table(String title, List<String> columns, List<List<dynamic>> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: const TextStyle(color: vendorMuted, fontWeight: FontWeight.w800, fontSize: 12),
              dataTextStyle: const TextStyle(color: Colors.white, fontSize: 12),
              columns: columns.map((column) => DataColumn(label: Text(column))).toList(),
              rows: rows.map((row) => DataRow(cells: row.map((cell) => DataCell(cell is Widget ? cell : Text(cell?.toString() ?? '-'))).toList())).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
