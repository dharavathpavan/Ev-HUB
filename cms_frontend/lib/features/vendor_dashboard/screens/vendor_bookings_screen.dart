import 'package:flutter/material.dart';

class VendorBookingsScreen extends StatelessWidget {
  const VendorBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bookings Management', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('View and manage upcoming customer reservations', style: TextStyle(color: Color(0xFF8A8A8A))),
          
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
                    DataColumn(label: Text('BOOKING ID')),
                    DataColumn(label: Text('USER')),
                    DataColumn(label: Text('STATION')),
                    DataColumn(label: Text('TIME')),
                    DataColumn(label: Text('STATUS')),
                  ],
                  rows: [
                    _buildRow('BK-9912', 'Alice Smith', 'Downtown Mall, NY (Gun 1)', 'Today, 14:00', 'Confirmed', Colors.green),
                    _buildRow('BK-9913', 'Bob Johnson', 'Airport Parking, NY (Gun 2)', 'Today, 15:30', 'Completed', Colors.blue),
                    _buildRow('BK-9914', 'Charlie Davis', 'Highway 51 Stop', 'Tomorrow, 09:00', 'Pending', Colors.orange),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  DataRow _buildRow(String id, String user, String station, String time, String status, Color statusColor) {
    return DataRow(
      cells: [
        DataCell(Text(id, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(user)),
        DataCell(Text(station)),
        DataCell(Text(time)),
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
