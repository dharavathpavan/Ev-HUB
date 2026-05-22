import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:cms_frontend/config.dart';

class ChargerConfigScreen extends StatefulWidget {
  const ChargerConfigScreen({super.key});

  @override
  State<ChargerConfigScreen> createState() => _ChargerConfigScreenState();
}

class _ChargerConfigScreenState extends State<ChargerConfigScreen> {
  late final Stream<List<Map<String, dynamic>>> _pendingChargersStream;
  String? _selectedChargerId;

  @override
  void initState() {
    super.initState();
    // Fetch unassigned chargers or pending chargers
    _pendingChargersStream = Supabase.instance.client
        .from('chargers')
        .stream(primaryKey: ['id'])
        .eq('status', 'Pending');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('EV Charger Onboarding & Configuration', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Discover newly connected physical hardware via OCPP. Configure their keys before assigning them to a station.', style: TextStyle(color: Color(0xFF8A8A8A))),
          const SizedBox(height: 24),
          // Vendor Portal shortcut banner
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4ADDA2).withOpacity(0.15),
                  const Color(0xFF00F0FF).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF4ADDA2).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF4ADDA2).withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.business_center, color: Color(0xFF4ADDA2), size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Onboard Partner Vendors & Deploy Complete Hubs',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Use the Vendor Portal to guide new operators through application, hub setup, cabinet provisioning, connector cable configurations, and printable QR sticker mapping.',
                        style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () => context.go('/vendor-portal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ADDA2),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.rocket_launch),
                  label: const Text('Open Vendor Portal', style: TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
          const SizedBox(height: 40),

          // 1. Pending Chargers List
          const Text('Step 1: Select Unassigned Hardware', style: TextStyle(color: Color(0xFF4ADDA2), fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _pendingChargersStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator(color: Color(0xFF4ADDA2));
              final chargers = snapshot.data ?? [];
              if (chargers.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
                  child: const Center(child: Text('No pending hardware detected on the WebSocket.', style: TextStyle(color: Color(0xFF8A8A8A)))),
                );
              }

              return SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: chargers.length,
                  itemBuilder: (context, index) {
                    final charger = chargers[index];
                    final isSelected = _selectedChargerId == charger['charger_id'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedChargerId = charger['charger_id']),
                      child: Container(
                        width: 250,
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF4ADDA2).withOpacity(0.1) : const Color(0xFF141414),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isSelected ? const Color(0xFF4ADDA2) : const Color(0xFF2A2A2A), width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(Icons.router, color: Colors.white),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                                  child: const Text('Pending', style: TextStyle(color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                            const Spacer(),
                            Text(charger['charger_id'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            Text('MAC: xx:xx:xx:xx', style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 40),

          // 2. Realtime OCPP Configuration Editor
          if (_selectedChargerId != null) ...[
            Text('Step 2: Live OCPP Configuration (${_selectedChargerId})', style: const TextStyle(color: Color(0xFF4ADDA2), fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _OCPPConfigEditor(chargerId: _selectedChargerId!),
            
            const SizedBox(height: 40),
            
            // 3. Assignment
            const Text('Step 3: Provision to Station', style: TextStyle(color: Color(0xFF4ADDA2), fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Finalize Onboarding', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('This will lock the config and move the charger to an active station.', style: TextStyle(color: Color(0xFF8A8A8A))),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Logic to pick a station and update DB
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add to Station Modal Triggered'), backgroundColor: Color(0xFF4ADDA2)));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4ADDA2),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Assign to Station', style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            )
          ]
        ],
      ),
    );
  }
}

class _OCPPConfigEditor extends StatefulWidget {
  final String chargerId;
  const _OCPPConfigEditor({required this.chargerId});

  @override
  State<_OCPPConfigEditor> createState() => _OCPPConfigEditorState();
}

class _OCPPConfigEditorState extends State<_OCPPConfigEditor> {
  late Stream<List<Map<String, dynamic>>> _configStream;

  @override
  void initState() {
    super.initState();
    _setupStream();
  }

  @override
  void didUpdateWidget(covariant _OCPPConfigEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chargerId != widget.chargerId) {
      _setupStream();
    }
  }

  void _setupStream() {
    _configStream = Supabase.instance.client
        .from('charger_configs')
        .stream(primaryKey: ['id'])
        .eq('charger_id', widget.chargerId)
        .order('key_name', ascending: true);
  }

  Future<void> _editKey(String keyName, String currentValue) async {
    final controller = TextEditingController(text: currentValue);
    final newValue = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141414),
          title: Text('Edit Configuration: $keyName', style: const TextStyle(color: Colors.white, fontSize: 18)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF2A2A2A),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Color(0xFF8A8A8A)))),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ADDA2), foregroundColor: Colors.black),
              child: const Text('Apply via OCPP'),
            )
          ],
        );
      }
    );

    if (newValue != null && newValue != currentValue) {
      try {
        final response = await http.post(
          Uri.parse('${Config.apiBaseUrl}/api/ocpp/configuration'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'action': 'CHANGE_CONFIGURATION', 'charger_id': widget.chargerId, 'key_name': keyName, 'value': newValue}),
        );
        final data = jsonDecode(response.body);
        if (response.statusCode == 200) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message']), backgroundColor: const Color(0xFF4ADDA2)));
        } else {
          throw Exception(data['message'] ?? 'Failed to apply config');
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.redAccent));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _configStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator(color: Color(0xFF4ADDA2));
        final configs = snapshot.data ?? [];
        
        if (configs.isEmpty) {
          return const Text('No configuration keys found for this charger in the DB. Try running the SQL Migration.', style: TextStyle(color: Colors.redAccent));
        }

        return Container(
          decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(const Color(0xFF0F0F0F)),
              columns: const [
                DataColumn(label: Text('OCPP Key', style: TextStyle(color: Color(0xFF8A8A8A)))),
                DataColumn(label: Text('Current Value', style: TextStyle(color: Color(0xFF8A8A8A)))),
                DataColumn(label: Text('Access', style: TextStyle(color: Color(0xFF8A8A8A)))),
                DataColumn(label: Text('Action', style: TextStyle(color: Color(0xFF8A8A8A)))),
              ],
              rows: configs.map((config) {
                final isReadOnly = config['is_readonly'] == true;
                return DataRow(
                  cells: [
                    DataCell(Text(config['key_name'], style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontWeight: FontWeight.bold))),
                    DataCell(Text(config['value'], style: const TextStyle(color: Color(0xFF4ADDA2), fontFamily: 'monospace'))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: isReadOnly ? Colors.redAccent.withOpacity(0.1) : Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(isReadOnly ? 'Read-Only' : 'Read/Write', style: TextStyle(color: isReadOnly ? Colors.redAccent : Colors.green, fontSize: 10)),
                      )
                    ),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        color: isReadOnly ? Colors.grey : Colors.white,
                        onPressed: isReadOnly ? null : () => _editKey(config['key_name'], config['value']),
                        tooltip: isReadOnly ? 'Manufacturer Locked' : 'ChangeConfiguration',
                      )
                    )
                  ]
                );
              }).toList(),
            ),
          ),
        );
      }
    );
  }
}
