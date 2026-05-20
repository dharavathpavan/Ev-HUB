import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FleetScreen extends StatefulWidget {
  const FleetScreen({super.key});

  @override
  State<FleetScreen> createState() => _FleetScreenState();
}

class _FleetScreenState extends State<FleetScreen> {
  late final Stream<List<Map<String, dynamic>>> _fleetStream;

  @override
  void initState() {
    super.initState();
    _fleetStream = Supabase.instance.client
        .from('fleet_vehicles')
        .stream(primaryKey: ['id'])
        .order('make_model', ascending: true);
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(title, style: const TextStyle(color: Color(0xFF8A8A8A))), Icon(icon, color: color)],
          ),
          const SizedBox(height: 16),
          Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _fleetStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF4ADDA2)));
        if (snapshot.hasError) return const Center(child: Text('Failed to load fleet data. Run the SQL Migration.', style: TextStyle(color: Colors.redAccent)));
        
        final vehicles = snapshot.data ?? [];
        final totalVehicles = vehicles.length;
        final chargingVehicles = vehicles.where((v) => v['status'] == 'Charging').length;
        final activeVehicles = vehicles.where((v) => v['status'] == 'Active').length;
        final maintenanceVehicles = vehicles.where((v) => v['status'] == 'Maintenance').length;

        return SingleChildScrollView(
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
                      Text('Commercial EV Fleet', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 8),
                      Text('Manage enterprise vehicles, track real-time telemetry, and monitor state-of-charge.', style: TextStyle(color: Color(0xFF8A8A8A))),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ADDA2), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                    icon: const Icon(Icons.add),
                    label: const Text('Provision Vehicle', style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              const SizedBox(height: 40),

              // KPI Dashboard
              Row(
                children: [
                  Expanded(child: _buildStatCard('Total Fleet', '$totalVehicles', Icons.local_shipping, Colors.white)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildStatCard('On the Road', '$activeVehicles', Icons.route, const Color(0xFF4ADDA2))),
                  const SizedBox(width: 24),
                  Expanded(child: _buildStatCard('Charging', '$chargingVehicles', Icons.battery_charging_full, const Color(0xFFFFD700))),
                  const SizedBox(width: 24),
                  Expanded(child: _buildStatCard('Maintenance', '$maintenanceVehicles', Icons.build, Colors.redAccent)),
                ],
              ),
              const SizedBox(height: 40),

              // Data Table
              Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF2A2A2A))),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(const Color(0xFF0F0F0F)),
                    dataRowHeight: 80,
                    horizontalMargin: 32,
                    columnSpacing: 24,
                    columns: const [
                      DataColumn(label: Text('Vehicle / VIN', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('License / Driver', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Status', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('State of Charge (SOC)', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Actions', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                    ],
                    rows: vehicles.map((v) {
                      final soc = v['current_soc_percentage'] as int;
                      Color socColor = const Color(0xFF4ADDA2);
                      if (soc < 20) socColor = Colors.redAccent;
                      else if (soc < 50) socColor = Colors.orangeAccent;

                      return DataRow(
                        cells: [
                          DataCell(
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(v['make_model'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                Text(v['vin'], style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12, fontFamily: 'monospace')),
                              ],
                            ),
                          ),
                          DataCell(
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.orangeAccent)),
                                  child: Text(v['license_plate'], style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(height: 4),
                                Text(v['assigned_driver'] ?? 'Unassigned', style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                              ],
                            ),
                          ),
                          DataCell(
                            _StatusBadge(status: v['status']),
                          ),
                          DataCell(
                            SizedBox(
                              width: 200,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('$soc%', style: TextStyle(color: socColor, fontWeight: FontWeight.bold)),
                                      Text('${v['battery_capacity_kwh']} kWh', style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 10)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: soc / 100,
                                    backgroundColor: const Color(0xFF2A2A2A),
                                    color: socColor,
                                    borderRadius: BorderRadius.circular(8),
                                  )
                                ],
                              ),
                            )
                          ),
                          DataCell(
                            IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              )
            ],
          ),
        );
      }
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    if (status == 'Active') color = const Color(0xFF4ADDA2);
    if (status == 'Charging') color = const Color(0xFFFFD700);
    if (status == 'Maintenance') color = Colors.redAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(50), border: Border.all(color: color.withOpacity(0.5))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
