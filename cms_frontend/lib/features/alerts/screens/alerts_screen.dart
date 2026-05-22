import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:cms_frontend/config.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late final Stream<List<Map<String, dynamic>>> _alertsStream;
  bool _isResolving = false;

  @override
  void initState() {
    super.initState();
    _alertsStream = Supabase.instance.client
        .from('alerts')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  Future<void> _resolveFault(String alertId, String chargerId) async {
    setState(() => _isResolving = true);
    try {
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/api/ocpp/alerts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'RESOLVE_FAULT',
          'alert_id': alertId,
          'charger_id': chargerId,
        }),
      );
      if (response.statusCode == 200) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fault resolved and charger reset!'), backgroundColor: Color(0xFF4ADDA2)));
      } else {
        throw Exception('Failed to resolve fault');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error resolving fault.'), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isResolving = false);
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Critical': return Colors.redAccent;
      case 'High': return Colors.orangeAccent;
      case 'Medium': return const Color(0xFFFFD700);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Hardware Faults & Alerts', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 8),
                  Text('Real-time OCPP diagnostic trouble codes and error alerts from the charging network.', style: TextStyle(color: Color(0xFF8A8A8A))),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(50), border: Border.all(color: Colors.redAccent.withOpacity(0.5))),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    const Text('OCPP Diagnostics Sync Active', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _alertsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator(color: Colors.redAccent)));
              if (snapshot.hasError) return const Center(child: Padding(padding: EdgeInsets.all(40.0), child: Text('Error loading alerts. Run the SQL migration.', style: TextStyle(color: Colors.redAccent, fontSize: 16))));
              final alerts = snapshot.data ?? [];
              if (alerts.isEmpty) return const Center(child: Text('All systems operational. No active faults.', style: TextStyle(color: Color(0xFF4ADDA2), fontSize: 18, fontWeight: FontWeight.bold)));

              return Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF2A2A2A))),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(const Color(0xFF0F0F0F)),
                    dataRowHeight: 90,
                    horizontalMargin: 32,
                    columnSpacing: 24,
                    columns: const [
                      DataColumn(label: Text('Time & Severity', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Location', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Error Code & Details', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Action / Status', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                    ],
                    rows: alerts.map((alert) {
                      final isResolved = alert['status'] == 'Resolved';
                      final timeFormat = DateFormat('MMM d, h:mm a').format(DateTime.parse(alert['created_at']).toLocal());
                      final severityColor = isResolved ? Colors.grey : _getSeverityColor(alert['severity']);

                      return DataRow(
                        cells: [
                          DataCell(
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(isResolved ? Icons.check_circle : Icons.warning_amber, color: severityColor, size: 16),
                                    const SizedBox(width: 8),
                                    Text(alert['severity'], style: TextStyle(color: severityColor, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(timeFormat, style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                              ],
                            ),
                          ),
                          DataCell(
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(alert['charger_id'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                Text('Station: ${alert['station_id']}', style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                              ],
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 300,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(alert['error_code'], style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                                  const SizedBox(height: 4),
                                  Text(alert['description'], style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ),
                          DataCell(
                            isResolved
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(50), border: Border.all(color: Colors.grey.withOpacity(0.2))),
                                    child: const Text('Resolved', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                                  )
                                : ElevatedButton.icon(
                                    onPressed: _isResolving ? null : () => _resolveFault(alert['id'], alert['charger_id']),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2A2A2A),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.build, size: 16, color: Color(0xFF4ADDA2)),
                                    label: const Text('Resolve Issue'),
                                  ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
