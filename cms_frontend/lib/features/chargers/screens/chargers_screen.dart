import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:go_router/go_router.dart';

class ChargersScreen extends StatefulWidget {
  const ChargersScreen({super.key});

  @override
  State<ChargersScreen> createState() => _ChargersScreenState();
}

class _ChargersScreenState extends State<ChargersScreen> {
  late final Stream<List<Map<String, dynamic>>> _chargersStream;

  @override
  void initState() {
    super.initState();
    _chargersStream = Supabase.instance.client
        .from('chargers')
        .stream(primaryKey: ['id'])
        .order('charger_id', ascending: true);
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
                'Live Charger Monitoring',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4ADDA2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: const Color(0xFF4ADDA2).withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(color: Color(0xFF4ADDA2), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        const Text('OCPP WebSocket Live', style: TextStyle(color: Color(0xFF4ADDA2), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Charger', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 40),

          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _chargersStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(color: Color(0xFF4ADDA2)),
                  ),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text(
                      'Connection Error:\nPlease run the Supabase Chargers Migration SQL script.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.redAccent, fontSize: 16),
                    ),
                  ),
                );
              }

              final chargers = snapshot.data ?? [];

              if (chargers.isEmpty) {
                return const Center(child: Text('No chargers found.', style: TextStyle(color: Color(0xFF8A8A8A))));
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 0.85,
                ),
                itemCount: chargers.length,
                itemBuilder: (context, index) {
                  final charger = chargers[index];
                  return AnimatedChargerCard(charger: charger);
                },
              );
            },
          )
        ],
      ),
    );
  }
}

class AnimatedChargerCard extends StatefulWidget {
  final Map<String, dynamic> charger;

  const AnimatedChargerCard({super.key, required this.charger});

  @override
  State<AnimatedChargerCard> createState() => _AnimatedChargerCardState();
}

class _AnimatedChargerCardState extends State<AnimatedChargerCard> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool isHovered = false;
  bool _isSendingCommand = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _updatePulse();
  }

  @override
  void didUpdateWidget(covariant AnimatedChargerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updatePulse();
  }

  void _updatePulse() {
    if (widget.charger['status'] == 'Charging') {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Charging': return const Color(0xFF00F0FF); // Cyan
      case 'Available': return const Color(0xFF4ADDA2); // Mint Green
      case 'Faulted': return Colors.redAccent;
      case 'Maintenance': return const Color(0xFFFFD700); // Gold
      default: return Colors.grey;
    }
  }

  Future<void> _sendRemoteCommand(String command, {String? newStatus}) async {
    setState(() => _isSendingCommand = true);
    try {
      final bodyData = {
        'charger_id': widget.charger['charger_id'],
        'command': command,
      };
      if (newStatus != null) {
        bodyData['new_status'] = newStatus;
      }

      final response = await http.post(
        Uri.parse('http://localhost:3003/api/ocpp/remote-command'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bodyData),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to send command');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Command $command sent to ${widget.charger['charger_id']}'),
            backgroundColor: const Color(0xFF4ADDA2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error communicating with Next.js Backend.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingCommand = false);
      }
    }
  }

  void _showStatusManagementModal() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141414),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Manage Status: ${widget.charger['charger_id']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusOption('Available', const Color(0xFF4ADDA2)),
              _buildStatusOption('Maintenance', const Color(0xFFFFD700)),
              _buildStatusOption('Faulted', Colors.redAccent),
              _buildStatusOption('Offline', Colors.grey),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF8A8A8A))),
            )
          ],
        );
      }
    );
  }

  Widget _buildStatusOption(String status, Color color) {
    return ListTile(
      leading: Icon(Icons.circle, color: color, size: 16),
      title: Text(status, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context); // Close dialog
        _sendRemoteCommand('ChangeAvailability', newStatus: status);
      },
    );
  }

  void _showPrintableQR() {
    final qrData = widget.charger['qr_identifier'] ?? 'https://app.bleuright.com/charge?id=${widget.charger['charger_id']}';
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Hardware QR: ${widget.charger['charger_id']}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24), textAlign: TextAlign.center),
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

  Future<void> _generateQRPayment() async {
    setState(() => _isSendingCommand = true);
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3003/api/payments/qr-initiate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'charger_id': widget.charger['charger_id'],
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
  Widget build(BuildContext context) {
    final status = widget.charger['status'] ?? 'Offline';
    final statusColor = _getStatusColor(status);
    final isCharging = status == 'Charging';
    
    final currentKw = double.tryParse(widget.charger['current_kw_output'].toString()) ?? 0.0;
    final maxKw = double.tryParse(widget.charger['max_kw_output'].toString()) ?? 150.0;
    final voltage = widget.charger['voltage'].toString();
    final temp = widget.charger['temperature'].toString();
    
    final fillPercentage = (currentKw / maxKw).clamp(0.0, 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: () => context.go('/chargers/${widget.charger['charger_id']}'),
        child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final pulseValue = _pulseAnimation.value;
          final shadowColor = isCharging 
              ? statusColor.withOpacity(0.2 + (pulseValue * 0.4)) 
              : Colors.transparent;
              
          final elevation = isHovered ? 8.0 : 0.0;
          final scale = isHovered ? 1.02 : 1.0;

          return Transform.scale(
            scale: scale,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isCharging ? statusColor.withOpacity(0.5 + (pulseValue * 0.5)) : const Color(0xFF2A2A2A),
                  width: isCharging ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(color: shadowColor, blurRadius: 20, spreadRadius: 2),
                  if (isHovered) BoxShadow(color: statusColor.withOpacity(0.1), blurRadius: 30, spreadRadius: 5),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.charger['charger_id'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Station: ${widget.charger['station_id']}', style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          const SizedBox(width: 8),
                          // Remote Commands Popup Menu
                          _isSendingCommand
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                              : PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, color: Colors.white),
                                  color: const Color(0xFF1E1E1E),
                                  onSelected: (value) {
                                    if (value == 'ManageStatus') {
                                      _showStatusManagementModal();
                                    } else if (value == 'GenerateQR') {
                                      _generateQRPayment();
                                    } else if (value == 'PrintQR') {
                                      _showPrintableQR();
                                    } else {
                                      _sendRemoteCommand(value);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(value: 'ManageStatus', child: Text('🛠️ Manage Status', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold))),
                                    const PopupMenuDivider(),
                                    const PopupMenuItem(value: 'PrintQR', child: Text('🖨️ View Printable QR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                    const PopupMenuItem(value: 'GenerateQR', child: Text('📱 Generate QR (Pay-As-You-Go)', style: TextStyle(color: Color(0xFF4ADDA2), fontWeight: FontWeight.bold))),
                                    const PopupMenuDivider(),
                                    const PopupMenuItem(value: 'RemoteStartTransaction', child: Text('⚡ Start Session', style: TextStyle(color: Colors.white))),
                                    const PopupMenuItem(value: 'RemoteStopTransaction', child: Text('🛑 Stop Session', style: TextStyle(color: Colors.white))),
                                    const PopupMenuItem(value: 'UnlockConnector', child: Text('🔓 Unlock Connector', style: TextStyle(color: Colors.white))),
                                    const PopupMenuItem(value: 'Reboot', child: Text('🔄 Remote Reboot', style: TextStyle(color: Colors.white))),
                                  ],
                                ),
                        ],
                      )
                    ],
                  ),
                  
                  const Spacer(),
                  
                  Center(
                    child: SizedBox(
                      height: 140,
                      width: 140,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: fillPercentage),
                            duration: const Duration(milliseconds: 1500),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return CircularProgressIndicator(
                                value: value,
                                strokeWidth: 12,
                                backgroundColor: const Color(0xFF2A2A2A),
                                color: statusColor,
                                strokeCap: StrokeCap.round,
                              );
                            },
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isCharging ? currentKw.toStringAsFixed(1) : '0.0',
                                  style: TextStyle(color: isCharging ? Colors.white : const Color(0xFF8A8A8A), fontSize: 32, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'kW',
                                  style: TextStyle(color: statusColor.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0F0F),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTelemetryItem(Icons.electric_bolt, '$voltage V', 'Voltage', isCharging),
                        Container(width: 1, height: 30, color: const Color(0xFF2A2A2A)),
                        _buildTelemetryItem(Icons.thermostat, '$temp °C', 'Temp', isCharging),
                        Container(width: 1, height: 30, color: const Color(0xFF2A2A2A)),
                        _buildTelemetryItem(Icons.cable, widget.charger['connector_type'] ?? 'CCS2', 'Type', true),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        }
      ),
      ),
    );
  }

  Widget _buildTelemetryItem(IconData icon, String value, String label, bool active) {
    final color = active ? Colors.white : const Color(0xFF8A8A8A);
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Color(0xFF5A5A5A), fontSize: 10)),
      ],
    );
  }
}
