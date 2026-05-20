import 'package:flutter/material.dart';

class VendorStationsScreen extends StatelessWidget {
  const VendorStationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Stations & Chargers', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 8),
                  Text('Manage your charging locations and individual guns', style: TextStyle(color: Color(0xFF8A8A8A))),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, color: Colors.black, size: 18),
                label: const Text('Add Station', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ADDA2),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
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
                    DataColumn(label: Text('STATION ID')),
                    DataColumn(label: Text('LOCATION')),
                    DataColumn(label: Text('GUNS')),
                    DataColumn(label: Text('STATUS')),
                    DataColumn(label: Text('ACTIONS')),
                  ],
                  rows: [
                    _buildRow('ST-001', 'Downtown Mall, NY', '2 (CCS2, CHAdeMO)', 'Online', Colors.green),
                    _buildRow('ST-002', 'Airport Parking, NY', '4 (CCS2)', 'Online', Colors.green),
                    _buildRow('ST-003', 'Highway 51 Stop', '1 (CCS2)', 'Offline', Colors.redAccent),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  DataRow _buildRow(String id, String loc, String guns, String status, Color statusColor) {
    return DataRow(
      cells: [
        DataCell(Text(id, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(loc)),
        DataCell(Text(guns)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(50)),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
          )
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF4ADDA2)),
            onPressed: () {},
          )
        ),
      ],
    );
  }
}
