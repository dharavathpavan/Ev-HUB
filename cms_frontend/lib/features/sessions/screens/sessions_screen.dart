import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:cms_frontend/config.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  late final Stream<List<Map<String, dynamic>>> _sessionsStream;

  @override
  void initState() {
    super.initState();
    _sessionsStream = Supabase.instance.client
        .from('sessions')
        .stream(primaryKey: ['id'])
        .order('start_time', ascending: false);
  }

  Future<void> _stopSession(String chargerId, String sessionId) async {
    try {
      await http.post(
        Uri.parse('${Config.apiBaseUrl}/api/ocpp/remote-command'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'charger_id': chargerId,
          'command': 'RemoteStopTransaction',
        }),
      );
      
      // Also update the session in the DB immediately for UX
      await Supabase.instance.client
          .from('sessions')
          .update({'status': 'Completed', 'end_time': DateTime.now().toUtc().toIso8601String()})
          .eq('session_id', sessionId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Session $sessionId has been remotely stopped.'),
            backgroundColor: const Color(0xFF4ADDA2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to stop session.'), backgroundColor: Colors.redAccent),
        );
      }
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
              const Text(
                'Live Session Control',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ADDA2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: const Color(0xFF4ADDA2).withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF4ADDA2), shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    const Text('OCPP Sync Active', style: TextStyle(color: Color(0xFF4ADDA2), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // StreamBuilder for Real-Time UI
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _sessionsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator(color: Color(0xFF4ADDA2))),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text('Error loading sessions. Please run the SQL migration.', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
                  ),
                );
              }

              final sessions = snapshot.data ?? [];

              if (sessions.isEmpty) {
                return const Center(child: Text('No sessions found.', style: TextStyle(color: Color(0xFF8A8A8A))));
              }

              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(const Color(0xFF0F0F0F)),
                    dataRowHeight: 80,
                    horizontalMargin: 32,
                    columnSpacing: 24,
                    columns: const [
                      DataColumn(label: Text('Session ID', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Charger & Station', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Identifier', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Time & Duration', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Energy & Cost', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Status / Control', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                    ],
                    rows: sessions.map((session) {
                      final isActive = session['status'] == 'Active';
                      final startTime = DateTime.parse(session['start_time']).toLocal();
                      final timeFormat = DateFormat('MMM d, h:mm a').format(startTime);
                      
                      Duration duration;
                      if (isActive) {
                        duration = DateTime.now().difference(startTime);
                      } else if (session['end_time'] != null) {
                        duration = DateTime.parse(session['end_time']).difference(startTime);
                      } else {
                        duration = Duration.zero;
                      }

                      final durationStr = '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';

                      return DataRow(
                        cells: [
                          DataCell(Text(session['session_id'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          DataCell(
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(session['charger_id'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                Text(session['station_id'], style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                              ],
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(4)),
                              child: Text(session['rfid_tag'] ?? 'App', style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                          ),
                          DataCell(
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(timeFormat, style: const TextStyle(color: Colors.white)),
                                Text(durationStr, style: TextStyle(color: isActive ? const Color(0xFF4ADDA2) : const Color(0xFF8A8A8A), fontSize: 12)),
                              ],
                            ),
                          ),
                          DataCell(
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${session['kwh_delivered']} kWh', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                Text('\$${session['total_cost']}', style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                              ],
                            ),
                          ),
                          DataCell(
                            isActive
                                ? ElevatedButton.icon(
                                    onPressed: () => _stopSession(session['charger_id'], session['session_id']),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent.withOpacity(0.1),
                                      foregroundColor: Colors.redAccent,
                                      elevation: 0,
                                      side: const BorderSide(color: Colors.redAccent),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                                    ),
                                    icon: const Icon(Icons.stop_circle_outlined, size: 16),
                                    label: const Text('Force Stop'),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                    ),
                                    child: const Text('Completed', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
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
