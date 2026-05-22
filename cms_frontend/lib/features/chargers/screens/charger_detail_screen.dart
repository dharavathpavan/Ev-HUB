import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/widgets/ev_loader.dart';
import 'package:cms_frontend/config.dart';

class ChargerDetailScreen extends StatefulWidget {
  final String chargerId;
  const ChargerDetailScreen({super.key, required this.chargerId});

  @override
  State<ChargerDetailScreen> createState() => _ChargerDetailScreenState();
}

class _ChargerDetailScreenState extends State<ChargerDetailScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late final Stream<List<Map<String, dynamic>>> _chargerStream;
  late final Stream<List<Map<String, dynamic>>> _logsStream;
  late final Stream<List<Map<String, dynamic>>> _alertsStream;

  bool _isSendingCommand = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  List<dynamic> _guns = [];
  bool _isLoadingGuns = false;

  Future<void> _fetchGuns() async {
    if (!mounted) return;
    setState(() => _isLoadingGuns = true);
    try {
      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/api/chargers/guns?charger_id=${widget.chargerId}'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _guns = data['guns'] ?? [];
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching guns: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingGuns = false);
      }
    }
  }

  Future<void> _simulateGunScan(String qrId) async {
    setState(() => _isSendingCommand = true);
    try {
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/api/payments/qr-initiate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'qr_id': qrId,
          'user_id': 'USER-APP-999' // Hardcoded mock app user for demo
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        await _fetchGuns();
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF141414),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.flash_on, color: Color(0xFF00F0FF)),
                  SizedBox(width: 8),
                  Text('Charging Successfully Started!', style: TextStyle(color: Color(0xFF00F0FF))),
                ],
              ),
              content: Text(
                'Connector Gun ${data['gun_index']} status updated to CHARGING.\n\nPre-Auth Deducted: \$${data['pre_auth_deducted']}\nRemaining Balance: \$${data['remaining_balance']}\nSession ID: ${data['session_id']}',
                style: const TextStyle(color: Colors.white),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ADDA2), foregroundColor: Colors.black),
                  child: const Text('Close'),
                )
              ],
            )
          );
        }
      } else {
        throw Exception(data['error'] ?? 'Payment failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Simulation Error: ${e.toString()}'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingCommand = false);
    }
  }

  void _showPrintableGunQR(Map<String, dynamic> charger, Map<String, dynamic> gun) {
    final gunIndex = gun['gun_index'] ?? 1;
    final qrId = 'QR-${charger['charger_id']}-G$gunIndex';
    final qrData = 'https://app.bleuright.com/charge?qr=$qrId';
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Column(
            children: [
              Text('CONNECTOR GUN $gunIndex', style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(charger['charger_id'], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Scan securely with any consumer wallet to start.', style: TextStyle(color: Colors.grey, fontSize: 13), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              SizedBox(
                width: 230,
                height: 230,
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                  dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                ),
              ),
              const SizedBox(height: 16),
              const Text('SCAN SECURELY TO CHARGE', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.1)),
              Text(qrId, style: const TextStyle(color: Colors.grey, fontSize: 10, fontFamily: 'monospace'), textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('QR Sticker for Gun $gunIndex sent to Printer.'), backgroundColor: const Color(0xFF4ADDA2)));
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ADDA2), foregroundColor: Colors.black),
              icon: const Icon(Icons.print),
              label: const Text('Print Sticker'),
            )
          ],
        );
      }
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _chargerStream = Supabase.instance.client
        .from('chargers')
        .stream(primaryKey: ['id'])
        .eq('charger_id', widget.chargerId);
        
    _logsStream = Supabase.instance.client
        .from('ocpp_commands_log')
        .stream(primaryKey: ['id'])
        .eq('charger_id', widget.chargerId)
        .order('created_at', ascending: false)
        .limit(20);
        
    _alertsStream = Supabase.instance.client
        .from('alerts')
        .stream(primaryKey: ['id'])
        .eq('charger_id', widget.chargerId)
        .order('created_at', ascending: false);

    _fetchGuns();
  }

  Future<void> _sendRemoteCommand(String command) async {
    setState(() => _isSendingCommand = true);
    try {
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/api/ocpp/remote-command'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'charger_id': widget.chargerId,
          'command': command,
        }),
      );
      if (response.statusCode == 200) {
        await _fetchGuns();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Command $command dispatched.'), backgroundColor: const Color(0xFF4ADDA2)));
      } else {
        throw Exception('Failed to send command');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Command failed.'), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isSendingCommand = false);
    }
  }

  void _showPrintableQR(Map<String, dynamic> charger) {
    final qrData = charger['qr_identifier'] ?? 'https://app.bleuright.com/charge?id=${charger['charger_id']}';
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Hardware QR: ${charger['charger_id']}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24), textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Print this securely. Users will scan this exact code.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              SizedBox(
                width: 250,
                height: 250,
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                  dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                ),
              ),
              const SizedBox(height: 16),
              Text(qrData, style: const TextStyle(color: Colors.black54, fontSize: 10, fontFamily: 'monospace'), textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('QR Code sent to Printer.'), backgroundColor: Color(0xFF4ADDA2)));
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ADDA2), foregroundColor: Colors.black),
              icon: const Icon(Icons.print),
              label: const Text('Print Sticker'),
            )
          ],
        );
      }
    );
  }

  Future<void> _generateQRPayment(Map<String, dynamic> charger) async {
    setState(() => _isSendingCommand = true);
    try {
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/api/payments/qr-initiate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'charger_id': charger['charger_id'],
          'user_id': 'USER-APP-999' // Hardcoded mock app user for demo
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF141414),
              title: const Text('Customer Scanned QR', style: TextStyle(color: Color(0xFF4ADDA2), fontWeight: FontWeight.bold)),
              content: Text('Session Started: ${data['session_id']}\n\n\$${data['pre_auth_deducted']} Pre-Auth Deducted from Wallet.\nRemaining Wallet Balance: \$${data['remaining_balance']}', style: const TextStyle(color: Colors.white)),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ADDA2), foregroundColor: Colors.black),
                  child: const Text('Close'),
                )
              ],
            )
          );
        }
      } else {
        throw Exception(data['error'] ?? 'Payment failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment Error: ${e.toString()}'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingCommand = false);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chargerStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0A0A0A),
            body: EVLoader(text: 'INITIALIZING HARDWARE LINK...'),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Charger not found.', style: TextStyle(color: Colors.redAccent)));
        
        final charger = snapshot.data!.first;
        final status = charger['status'] ?? 'Offline';
        final currentKw = double.tryParse(charger['current_kw_output'].toString()) ?? 0.0;
        final maxKw = double.tryParse(charger['max_kw_output'].toString()) ?? 150.0;
        final fillPercentage = (currentKw / maxKw).clamp(0.0, 1.0);

        Color statusColor = Colors.grey;
        if (status == 'Charging') statusColor = const Color(0xFF00F0FF);
        if (status == 'Available') statusColor = const Color(0xFF4ADDA2);
        if (status == 'Faulted') statusColor = Colors.redAccent;
        if (status == 'Maintenance') statusColor = const Color(0xFFFFD700);

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go('/chargers'),
            ),
            title: Row(
              children: [
                Text('Hardware Diagnostics: ${widget.chargerId}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(50), border: Border.all(color: statusColor)),
                  child: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            actions: [
              TextButton.icon(
                onPressed: () => _showPrintableQR(charger),
                icon: const Icon(Icons.print, color: Colors.white),
                label: const Text('Print QR', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _generateQRPayment(charger),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ADDA2), foregroundColor: Colors.black),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Mock Customer Scan', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              if (status == 'Charging')
                ElevatedButton.icon(
                  onPressed: () => _sendRemoteCommand('RemoteStopTransaction'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                  label: const Text('Stop Session', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              const SizedBox(width: 16),
              _isSendingCommand
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      color: const Color(0xFF1E1E1E),
                      tooltip: 'Show More Features',
                      onSelected: (value) {
                        _sendRemoteCommand(value);
                      },
                      itemBuilder: (context) => [
                        if (status != 'Charging')
                          const PopupMenuItem(value: 'RemoteStartTransaction', child: Text('⚡ Start Session', style: TextStyle(color: Colors.white))),
                        const PopupMenuItem(value: 'UnlockConnector', child: Text('🔓 Unlock Connector', style: TextStyle(color: Colors.white))),
                        const PopupMenuItem(value: 'Reboot', child: Text('🔄 Remote Reboot', style: TextStyle(color: Colors.white))),
                        const PopupMenuItem(value: 'ClearCache', child: Text('🧹 Clear Cache', style: TextStyle(color: Colors.white))),
                        const PopupMenuItem(value: 'TriggerMessage', child: Text('📨 Trigger Message', style: TextStyle(color: Colors.white))),
                        const PopupMenuDivider(),
                        const PopupMenuItem(value: 'HardReset', child: Text('⚠️ Hard Reset', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
                      ],
                    ),
              const SizedBox(width: 40),
            ],
          ),
          body: DefaultTabController(
            length: 3,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 60,
                            runSpacing: 40,
                            children: [
                              // Visual Gauge
                              SizedBox(
                                height: 200, width: 200,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    CircularProgressIndicator(value: fillPercentage, strokeWidth: 16, backgroundColor: const Color(0xFF2A2A2A), color: statusColor, strokeCap: StrokeCap.round),
                                    Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(currentKw.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                                          Text('kW Output', style: TextStyle(color: statusColor, fontSize: 16)),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              // Dynamic Right Panel (Active Session or Idle Stats)
                              SizedBox(
                                width: 600,
                                child: status == 'Charging' 
                                    ? _buildActiveSessionDashboard(charger, currentKw, maxKw)
                                    : _buildIdleStatsGrid(charger, maxKw),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          const Divider(color: Color(0xFF2A2A2A)),
                          const SizedBox(height: 40),
                          _buildGunsSection(charger),
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        indicatorColor: const Color(0xFF4ADDA2),
                        labelColor: const Color(0xFF4ADDA2),
                        unselectedLabelColor: const Color(0xFF8A8A8A),
                        isScrollable: true,
                        tabs: const [
                          Tab(icon: Icon(Icons.analytics), text: 'Live Telemetry'),
                          Tab(icon: Icon(Icons.terminal), text: 'OCPP Command Logs'),
                          Tab(icon: Icon(Icons.build), text: 'Troubleshooting & Faults'),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildTelemetryTab(charger),
                  _buildLogsTab(),
                  _buildTroubleshootingTab(),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildGunsSection(Map<String, dynamic> charger) {
    if (_isLoadingGuns) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(color: Color(0xFF4ADDA2)),
        ),
      );
    }

    // Default mock guns if none are configured yet (to ensure the UI is fully operational)
    final gunsList = _guns.isNotEmpty ? _guns : [
      {'gun_index': 1, 'connector_type': 'CCS2', 'max_kw_output': 150.0, 'status': 'Available'},
      {'gun_index': 2, 'connector_type': 'Type2', 'max_kw_output': 22.0, 'status': 'Available'}
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Connector Cables (Physical Charging Guns)',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF4ADDA2)),
              onPressed: _fetchGuns,
              tooltip: 'Refresh Guns',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 24,
          runSpacing: 24,
          children: gunsList.map((gun) {
            final gunIndex = gun['gun_index'] ?? 1;
            final type = gun['connector_type'] ?? 'CCS2';
            final kw = gun['max_kw_output'] ?? 150.0;
            final status = gun['status'] ?? 'Available';
            final qrId = 'QR-${charger['charger_id']}-G$gunIndex';

            Color statusColor = Colors.grey;
            if (status == 'Charging') statusColor = const Color(0xFF00F0FF);
            if (status == 'Available') statusColor = const Color(0xFF4ADDA2);
            if (status == 'Faulted') statusColor = Colors.redAccent;
            if (status == 'Offline') statusColor = Colors.redAccent;

            return Container(
              width: 320,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: status == 'Charging' ? const Color(0xFF00F0FF).withOpacity(0.3) : const Color(0xFF2A2A2A)),
                boxShadow: status == 'Charging' ? [
                  BoxShadow(
                    color: const Color(0xFF00F0FF).withOpacity(0.1),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
                ] : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bolt, color: statusColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Gun #$gunIndex',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: statusColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Connector Standard', style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 13)),
                      Text(
                        type,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Maximum Power', style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 13)),
                      Text(
                        '$kw kW',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFF2A2A2A)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () => _showPrintableGunQR(charger, gun),
                          icon: const Icon(Icons.qr_code, size: 16, color: Colors.white),
                          label: const Text('QR Sticker', style: TextStyle(color: Colors.white, fontSize: 12)),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF2A2A2A),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: status == 'Charging'
                              ? () => _sendRemoteCommand('RemoteStopTransaction')
                              : () => _simulateGunScan(qrId),
                          icon: Icon(
                            status == 'Charging' ? Icons.stop_circle : Icons.play_arrow,
                            size: 16,
                            color: Colors.black,
                          ),
                          label: Text(
                            status == 'Charging' ? 'Stop' : 'Scan & Charge',
                            style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: status == 'Charging' ? Colors.redAccent : const Color(0xFF4ADDA2),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: const Color(0xFF4ADDA2)),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildIdleStatsGrid(Map<String, dynamic> charger, double maxKw) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      childAspectRatio: 2.0,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatBox('Voltage', '${charger['voltage']} V', Icons.electric_bolt),
        _buildStatBox('Temperature', '${charger['temperature']} °C', Icons.thermostat),
        _buildStatBox('Max Capacity', '${maxKw} kW', Icons.battery_charging_full),
        _buildStatBox('Connector', charger['connector_type'] ?? 'CCS2', Icons.cable),
        _buildStatBox('Network', 'Ethernet', Icons.network_check),
        _buildStatBox('Firmware', 'v2.4.1', Icons.system_update),
      ],
    );
  }

  Widget _buildActiveSessionDashboard(Map<String, dynamic> charger, double currentKw, double maxKw) {
    // Mock Data for the active session based on user request
    const String bikeName = "Ather 450X Gen 3";
    const String bikeNumber = "MH 12 AB 1234";
    const String orderId = "ORD-9988776655";
    const int currentSoc = 45;
    const double moneySpent = 4.50;
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final shadowOpacity = 0.2 + (_pulseAnimation.value * 0.4);
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF00F0FF).withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00F0FF).withOpacity(shadowOpacity),
                blurRadius: 30,
                spreadRadius: 2,
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.two_wheeler, color: Color(0xFF00F0FF), size: 32),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(bikeName, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          Text(bikeNumber, style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: const Color(0xFF0F0F0F), borderRadius: BorderRadius.circular(50)),
                    child: Text('Session: $orderId', style: const TextStyle(color: Color(0xFF8A8A8A), fontFamily: 'monospace', fontSize: 12)),
                  )
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Battery SOC', style: TextStyle(color: Color(0xFF8A8A8A))),
                            Text('$currentSoc%', style: TextStyle(color: Color(0xFF00F0FF), fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Stack(
                            children: [
                              LinearProgressIndicator(
                                value: currentSoc / 100,
                                backgroundColor: const Color(0xFF2A2A2A),
                                color: const Color(0xFF00F0FF),
                                minHeight: 12,
                              ),
                              // Animated Highlight across the bar
                              Positioned(
                                left: -50 + (_pulseAnimation.value * 200),
                                child: Container(
                                  width: 50,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.transparent, Colors.white.withOpacity(0.5), Colors.transparent],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('55% needed until full', style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Current Billing', style: TextStyle(color: Color(0xFF8A8A8A))),
                      const SizedBox(height: 4),
                      Text('\$$moneySpent', style: const TextStyle(color: Color(0xFF4ADDA2), fontSize: 32, fontWeight: FontWeight.bold)),
                      const Text('Pay-As-You-Go active', style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                    ],
                  )
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildTelemetryTab(Map<String, dynamic> charger) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Real-Time Power Phase Analysis', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Container(
            height: 300,
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF2A2A2A))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(20, (index) {
                // Generate a pseudo-random curve for demo purposes
                final height = 50 + (150 * (0.5 + 0.5 * _pulseAnimation.value * (index % 3 == 0 ? 1 : 0.8)));
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 20,
                  height: height,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ADDA2).withOpacity(0.8 - (index * 0.02)),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 40),
          const Text('Hardware Sensors', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildSensorCard('Cooling System', 'Active', Colors.green)),
              const SizedBox(width: 16),
              Expanded(child: _buildSensorCard('Connector Lock', 'Engaged', Colors.green)),
              const SizedBox(width: 16),
              Expanded(child: _buildSensorCard('Grid Sync', 'Locked', Colors.green)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSensorCard(String label, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLogsTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _logsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF4ADDA2)));
        
        List<Map<String, dynamic>> logs = snapshot.data ?? [];
        
        // Inject beautiful mock logs if DB is empty to demonstrate the UI
        if (logs.isEmpty) {
          final now = DateTime.now();
          logs = [
            {'command': 'Heartbeat', 'initiated_by': 'Charger', 'status': 'Accepted', 'created_at': now.subtract(const Duration(minutes: 1)).toIso8601String()},
            {'command': 'MeterValues', 'initiated_by': 'Charger', 'status': 'Accepted', 'created_at': now.subtract(const Duration(minutes: 5)).toIso8601String()},
            {'command': 'StartTransaction', 'initiated_by': 'USER-APP-999', 'status': 'Accepted', 'created_at': now.subtract(const Duration(minutes: 45)).toIso8601String()},
            {'command': 'Authorize', 'initiated_by': 'RFID Card (A1B2C3D4)', 'status': 'Accepted', 'created_at': now.subtract(const Duration(minutes: 46)).toIso8601String()},
            {'command': 'BootNotification', 'initiated_by': 'Charger', 'status': 'Accepted', 'created_at': now.subtract(const Duration(hours: 2)).toIso8601String()},
          ];
        }

        return ListView.builder(
          padding: const EdgeInsets.all(40),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            final timeFormat = DateFormat('MMM d, h:mm:ss a').format(DateTime.parse(log['created_at']).toLocal());
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF0F0F0F), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A2A2A))),
              child: Row(
                children: [
                  const Icon(Icons.compare_arrows, color: Color(0xFF8A8A8A)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log['command'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                        Text('Initiator: ${log['initiated_by']}', style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                      ],
                    ),
                  ),
                  Text(timeFormat, style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(log['status'], style: const TextStyle(color: Colors.green, fontSize: 12)),
                  )
                ],
              ),
            );
          },
        );
      }
    );
  }

  Widget _buildTroubleshootingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Remote Operations', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildActionButton('Soft Reset', 'Reboot', Icons.refresh, const Color(0xFF4ADDA2)),
              _buildActionButton('Hard Reset', 'HardReset', Icons.power_settings_new, Colors.redAccent),
              _buildActionButton('Unlock Connector', 'UnlockConnector', Icons.lock_open, Colors.orangeAccent),
              _buildActionButton('Clear Cache', 'ClearCache', Icons.cleaning_services, Colors.blueAccent),
              _buildActionButton('Trigger Message', 'TriggerMessage', Icons.send, Colors.purpleAccent),
            ],
          ),
          const SizedBox(height: 40),
          const Text('Active Hardware Alerts', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _alertsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
              final alerts = snapshot.data ?? [];
              final activeAlerts = alerts.where((a) => a['status'] != 'Resolved').toList();
              
              if (activeAlerts.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.green)),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 16),
                      Text('No active faults. Hardware is healthy.', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }

              return Column(
                children: activeAlerts.map((alert) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.redAccent)),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.redAccent),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(alert['error_code'], style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                              Text(alert['description'], style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {}, // Navigate to AlertsScreen or resolve here
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                          child: const Text('Resolve'),
                        )
                      ],
                    ),
                  );
                }).toList(),
              );
            }
          )
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, String command, IconData icon, Color color) {
    return InkWell(
      onTap: _isSendingCommand ? null : () => _sendRemoteCommand(command),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 16),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor, // Stick to background color
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
