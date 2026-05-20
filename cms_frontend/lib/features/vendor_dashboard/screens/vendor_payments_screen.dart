import 'package:flutter/material.dart';

class VendorPaymentsScreen extends StatelessWidget {
  const VendorPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payments & Revenue', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Track your earnings and payout history', style: TextStyle(color: Color(0xFF8A8A8A))),
          
          const SizedBox(height: 40),
          
          Row(
            children: [
              Expanded(child: _buildSummaryCard(context, 'Available for Payout', '\$1,240.00', const Color(0xFF4ADDA2))),
              const SizedBox(width: 24),
              Expanded(child: _buildSummaryCard(context, 'Pending Commission', '\$85.50', Colors.orange)),
              const SizedBox(width: 24),
              Expanded(child: _buildSummaryCard(context, 'Total Lifetime Earned', '\$12,450.00', Colors.purpleAccent)),
            ],
          ),
          
          const SizedBox(height: 40),
          
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: SingleChildScrollView(
                child: DataTable(
                  headingTextStyle: const TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold),
                  dataTextStyle: const TextStyle(color: Colors.white),
                  columns: const [
                    DataColumn(label: Text('DATE')),
                    DataColumn(label: Text('DESCRIPTION')),
                    DataColumn(label: Text('AMOUNT')),
                    DataColumn(label: Text('STATUS')),
                  ],
                  rows: [
                    _buildRow('2026-05-20', 'Charging Session (ST-001)', '+\$15.00', 'Completed', Colors.green),
                    _buildRow('2026-05-19', 'Charging Session (ST-002)', '+\$22.50', 'Completed', Colors.green),
                    _buildRow('2026-05-18', 'Weekly Payout to Bank', '-\$1,200.00', 'Processed', Colors.blue),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
  
  Widget _buildSummaryCard(BuildContext context, String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(amount, style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  DataRow _buildRow(String date, String desc, String amount, String status, Color statusColor) {
    return DataRow(
      cells: [
        DataCell(Text(date)),
        DataCell(Text(desc, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(amount)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(50)),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
          )
        ),
      ],
    );
  }
}
