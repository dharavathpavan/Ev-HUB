import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import '../../chargers/screens/chargers_screen.dart';

class StationDetailScreen extends StatefulWidget {
  final String stationId;
  const StationDetailScreen({super.key, required this.stationId});

  @override
  State<StationDetailScreen> createState() => _StationDetailScreenState();
}

class _StationDetailScreenState extends State<StationDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _stationData;
  bool _isLoading = true;

  // Admin Feature Flags
  bool _publicAccess = true;
  bool _payAsYouGo = true;
  bool _smartLoadBalancing = false;
  bool _dynamicPricing = false;

  // Amenities
  bool _hasWater = true;
  bool _hasFood = true;
  bool _hasRestroom = true;
  bool _hasWifi = false;
  bool _hasLounge = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 10, vsync: this);
    _fetchStationData();
  }

  Future<void> _fetchStationData() async {
    try {
      final response = await Supabase.instance.client
          .from('stations')
          .select()
          .eq('station_id', widget.stationId)
          .single();
      setState(() {
        _stationData = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _stopSession(String chargerId, String sessionId) async {
    try {
      await http.post(
        Uri.parse('http://localhost:3003/api/ocpp/remote-command'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'charger_id': chargerId, 'command': 'RemoteStopTransaction'}),
      );
      await Supabase.instance.client
          .from('sessions')
          .update({'status': 'Completed', 'end_time': DateTime.now().toUtc().toIso8601String()})
          .eq('session_id', sessionId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Session $sessionId stopped.'), backgroundColor: const Color(0xFF4ADDA2)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to stop session.'), backgroundColor: Colors.redAccent));
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFF4ADDA2)));

    if (_stationData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Station Not Found', style: TextStyle(color: Colors.white, fontSize: 24)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => context.go('/stations'), child: const Text('Back to Stations')),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
            color: const Color(0xFF141414),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => context.go('/stations'),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, color: Color(0xFF8A8A8A)),
                      SizedBox(width: 8),
                      Text('Back to Stations', style: TextStyle(color: Color(0xFF8A8A8A))),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_stationData!['name'] ?? 'Unknown Station',
                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.location_on, color: Color(0xFF8A8A8A), size: 16),
                          const SizedBox(width: 4),
                          Text(_stationData!['location'] ?? 'Unknown Location',
                              style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 16)),
                          const SizedBox(width: 16),
                          _buildStatusBadge(_stationData!['status'] ?? 'Offline'),
                        ]),
                      ],
                    ),
                    Row(children: [
                      _buildQuickKpi('Chargers', '${_stationData!['chargers'] ?? 0}', Icons.ev_station, const Color(0xFF4ADDA2)),
                      const SizedBox(width: 16),
                      _buildQuickKpi('Revenue', '\$${_stationData!['revenue'] ?? 0}', Icons.attach_money, Colors.amber),
                    ]),
                  ],
                ),
                const SizedBox(height: 24),
                TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFF4ADDA2),
                  indicatorWeight: 3,
                  labelColor: const Color(0xFF4ADDA2),
                  unselectedLabelColor: const Color(0xFF8A8A8A),
                  isScrollable: true,
                  tabs: const [
                    Tab(icon: Icon(Icons.dashboard, size: 18), text: 'Overview'),
                    Tab(icon: Icon(Icons.bolt, size: 18), text: 'Live Orders'),
                    Tab(icon: Icon(Icons.cable, size: 18), text: 'Chargers & Guns'),
                    Tab(icon: Icon(Icons.qr_code_2, size: 18), text: 'QR & Razorpay'),
                    Tab(icon: Icon(Icons.timeline, size: 18), text: 'Sessions'),
                    Tab(icon: Icon(Icons.speed, size: 18), text: 'Load Balancing'),
                    Tab(icon: Icon(Icons.bar_chart, size: 18), text: 'Revenue Analytics'),
                    Tab(icon: Icon(Icons.price_change, size: 18), text: 'Rate Cards'),
                    Tab(icon: Icon(Icons.build, size: 18), text: 'Maintenance'),
                    Tab(icon: Icon(Icons.settings, size: 18), text: 'Admin Settings'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildLiveOrdersTab(),
                _buildGunManagementTab(),
                _buildQrRazorpayTab(),
                _buildSessionsTab(),
                LoadBalancingTab(stationId: widget.stationId, initialData: _stationData!),
                _buildRevenueAnalyticsTab(),
                _buildRateCardsTab(),
                _buildMaintenanceLogTab(),
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // TAB 1: OVERVIEW
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: _StatCard(title: 'Total Chargers', value: '${_stationData!['chargers']}', icon: Icons.ev_station)),
            const SizedBox(width: 24),
            Expanded(child: _StatCard(title: 'Active Sessions', value: '3', icon: Icons.bolt, color: const Color(0xFF4ADDA2))),
            const SizedBox(width: 24),
            Expanded(child: _StatCard(title: 'Daily Revenue', value: '\$${_stationData!['revenue']}', icon: Icons.attach_money, color: const Color(0xFFFFD700))),
            const SizedBox(width: 24),
            Expanded(child: _StatCard(title: 'Uptime', value: '98.5%', icon: Icons.cloud_done, color: Colors.purpleAccent)),
          ]),
          const SizedBox(height: 40),
          const Text('24H Revenue Trend', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Container(
            height: 300,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF2A2A2A))),
            child: LineChart(LineChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFF2A2A2A), strokeWidth: 1)),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, _) => Text('\$${v.toInt()}', style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 11)))),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                  const hours = ['6AM', '9AM', '12PM', '3PM', '6PM', '9PM'];
                  if (v.toInt() >= 0 && v.toInt() < hours.length) return Text(hours[v.toInt()], style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 11));
                  return const SizedBox();
                })),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minX: 0, maxX: 5, minY: 0, maxY: 500,
              lineBarsData: [
                LineChartBarData(
                  spots: const [FlSpot(0, 80), FlSpot(1, 200), FlSpot(2, 350), FlSpot(3, 280), FlSpot(4, 420), FlSpot(5, 310)],
                  isCurved: true,
                  color: const Color(0xFF4ADDA2),
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [const Color(0xFF4ADDA2).withValues(alpha: 0.3), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // TAB 2: LIVE ORDERS
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildLiveOrdersTab() {
    final stream = Supabase.instance.client
        .from('sessions')
        .stream(primaryKey: ['session_id'])
        .eq('station_id', widget.stationId)
        .order('start_time', ascending: false);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        final allSessions = snapshot.data ?? [];
        final sessions = allSessions.where((s) => s['status'] == 'Active').toList();
        // If no real sessions, show mock data for demo
        final displaySessions = sessions.isEmpty
            ? [
                {'session_id': 'SESS-DEMO-01', 'charger_id': 'CHR-001', 'gun_number': 1, 'user_name': 'Ravi Kumar', 'kwh_delivered': 18.4, 'total_cost': 92.00, 'start_time': DateTime.now().subtract(const Duration(minutes: 42)).toIso8601String(), 'soc_percent': 72},
                {'session_id': 'SESS-DEMO-02', 'charger_id': 'CHR-002', 'gun_number': 2, 'user_name': 'Priya Sharma', 'kwh_delivered': 6.2, 'total_cost': 31.00, 'start_time': DateTime.now().subtract(const Duration(minutes: 14)).toIso8601String(), 'soc_percent': 38},
              ]
            : sessions;

        if (displaySessions.isEmpty) {
          return const Center(child: Text('No active sessions right now.', style: TextStyle(color: Color(0xFF8A8A8A))));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF4ADDA2), shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Text('${displaySessions.length} Active Charging Session${displaySessions.length > 1 ? 's' : ''}',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 32),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 24, mainAxisSpacing: 24, childAspectRatio: 1.4),
                itemCount: displaySessions.length,
                itemBuilder: (context, index) => _LiveOrderCard(session: displaySessions[index], onStop: () => _stopSession(displaySessions[index]['charger_id'], displaySessions[index]['session_id'])),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // TAB 3: CHARGER & GUN MANAGEMENT
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildGunManagementTab() {
    final stream = Supabase.instance.client.from('chargers').stream(primaryKey: ['id']).eq('station_id', widget.stationId);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        final chargers = snapshot.data ?? [];
        final displayChargers = chargers.isEmpty
            ? [
                {'id': 'CHR-DEMO-01', 'charger_id': 'CHR-001', 'model': 'ABB Terra 184', 'type': 'DC Fast', 'status': 'Available', 'guns': [
                  {'gun_number': 1, 'connector_type': 'CCS2', 'max_power_kw': 150, 'status': 'Occupied'},
                  {'gun_number': 2, 'connector_type': 'CHAdeMO', 'max_power_kw': 50, 'status': 'Available'},
                ]},
                {'id': 'CHR-DEMO-02', 'charger_id': 'CHR-002', 'model': 'Delta 50kW', 'type': 'DC', 'status': 'Faulted', 'guns': [
                  {'gun_number': 1, 'connector_type': 'CCS2', 'max_power_kw': 50, 'status': 'Faulted'},
                ]},
              ]
            : chargers;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Chargers & Connectors (Guns)', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () => _showAddChargerModal(),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ADDA2), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Charger', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ]),
              const SizedBox(height: 32),
              ...displayChargers.map((charger) => _ChargerExpandableCard(charger: charger, stationId: widget.stationId)).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showAddChargerModal() {
    final idCtrl = TextEditingController();
    final modelCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        title: const Text('Add New Charger', style: TextStyle(color: Colors.white)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _buildDialogField('Charger ID', idCtrl),
          const SizedBox(height: 16),
          _buildDialogField('Model / Manufacturer', modelCtrl),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Charger provisioned!'), backgroundColor: Color(0xFF4ADDA2)));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ADDA2), foregroundColor: Colors.black),
            child: const Text('Provision'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // TAB 4: QR CODE & RAZORPAY MAPPING
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildQrRazorpayTab() {
    // Mock guns for QR mapping
    final guns = <Map<String, dynamic>>[
      {'charger_id': 'CHR-001', 'gun_number': 1, 'razorpay_link_id': 'plink_Abc123XYZ', 'status': 'Active', 'qr_data': 'https://rzp.io/l/ev-chr001-gun1'},
      {'charger_id': 'CHR-001', 'gun_number': 2, 'razorpay_link_id': 'plink_Def456UVW', 'status': 'Active', 'qr_data': 'https://rzp.io/l/ev-chr001-gun2'},
      {'charger_id': 'CHR-002', 'gun_number': 1, 'razorpay_link_id': 'plink_Ghi789RST', 'status': 'Inactive', 'qr_data': 'https://rzp.io/l/ev-chr002-gun1'},
    ];

    final webhookEvents = [
      {'event': 'payment.authorized', 'amount': '₹250.00', 'link_id': 'plink_Abc123XYZ', 'time': '2 mins ago'},
      {'event': 'payment.captured', 'amount': '₹250.00', 'link_id': 'plink_Abc123XYZ', 'time': '2 mins ago'},
      {'event': 'payment.authorized', 'amount': '₹180.00', 'link_id': 'plink_Def456UVW', 'time': '18 mins ago'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('QR Code & Razorpay Mapping', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('QR codes regenerated for all guns!'), backgroundColor: Color(0xFF4ADDA2))),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2A2A2A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              icon: const Icon(Icons.refresh),
              label: const Text('Regenerate All'),
            ),
          ]),
          const SizedBox(height: 32),

          // QR Code Gallery
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 24, mainAxisSpacing: 24, childAspectRatio: 0.75),
            itemCount: guns.length,
            itemBuilder: (context, index) {
              final gun = guns[index];
              final isActive = gun['status'] == 'Active';
              final qrData = gun['qr_data'] as String;
              final razorpayLinkId = gun['razorpay_link_id'] as String;
              final gunStatus = gun['status'] as String;
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isActive ? const Color(0xFF4ADDA2).withValues(alpha: 0.4) : const Color(0xFF2A2A2A)),
                ),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('${gun['charger_id']} — Gun ${gun['gun_number']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: isActive ? const Color(0xFF4ADDA2).withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(gun['status']!, style: TextStyle(color: isActive ? const Color(0xFF4ADDA2) : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: QrImageView(data: qrData, version: QrVersions.auto, size: 120),
                    ),
                    const SizedBox(height: 12),
                    Text(razorpayLinkId, style: const TextStyle(color: Color(0xFF4ADDA2), fontSize: 11, fontFamily: 'monospace')),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: qrData));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied!'), backgroundColor: Color(0xFF4ADDA2)));
                        },
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Color(0xFF2A2A2A)), padding: const EdgeInsets.symmetric(vertical: 8)),
                        icon: const Icon(Icons.copy, size: 14),
                        label: const Text('Copy', style: TextStyle(fontSize: 12)),
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: OutlinedButton.icon(
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Printing QR...'), backgroundColor: Colors.amber)),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Color(0xFF2A2A2A)), padding: const EdgeInsets.symmetric(vertical: 8)),
                        icon: const Icon(Icons.print, size: 14),
                        label: const Text('Print', style: TextStyle(fontSize: 12)),
                      )),
                    ]),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 48),

          // Razorpay Webhook Events
          const Text('Razorpay Webhook Events', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFF4ADDA2).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF4ADDA2).withValues(alpha: 0.3))),
            child: const Row(children: [
              Icon(Icons.webhook, color: Color(0xFF4ADDA2), size: 14),
              SizedBox(width: 8),
              Text('Webhook endpoint: POST https://your-api.com/api/webhooks/razorpay', style: TextStyle(color: Color(0xFF4ADDA2), fontSize: 12, fontFamily: 'monospace')),
            ]),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFF0F0F0F)),
                columns: const [
                  DataColumn(label: Text('Event', style: TextStyle(color: Color(0xFF8A8A8A)))),
                  DataColumn(label: Text('Razorpay Link', style: TextStyle(color: Color(0xFF8A8A8A)))),
                  DataColumn(label: Text('Amount', style: TextStyle(color: Color(0xFF8A8A8A)))),
                  DataColumn(label: Text('Time', style: TextStyle(color: Color(0xFF8A8A8A)))),
                ],
                rows: webhookEvents.map((e) => DataRow(cells: [
                  DataCell(Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF4ADDA2).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: Text(e['event']!, style: const TextStyle(color: Color(0xFF4ADDA2), fontSize: 12)))),
                  DataCell(Text(e['link_id']!, style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 12))),
                  DataCell(Text(e['amount']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  DataCell(Text(e['time']!, style: const TextStyle(color: Color(0xFF8A8A8A)))),
                ])).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // TAB 5: CHARGING SESSIONS
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildSessionsTab() {
    final stream = Supabase.instance.client
        .from('sessions')
        .stream(primaryKey: ['session_id'])
        .eq('station_id', widget.stationId)
        .order('start_time', ascending: false);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF4ADDA2)));
        final sessions = snapshot.data ?? [];
        if (sessions.isEmpty) return const Center(child: Text('No sessions recorded for this station.', style: TextStyle(color: Color(0xFF8A8A8A))));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF2A2A2A))),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFF0F0F0F)),
                dataRowMinHeight: 70,
                dataRowMaxHeight: 80,
                columns: const [
                  DataColumn(label: Text('Session ID', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Charger', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Identifier', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Duration', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Energy / Cost', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Control', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                ],
                rows: sessions.map((session) {
                  final isActive = session['status'] == 'Active';
                  final startTime = DateTime.parse(session['start_time']).toLocal();
                  final timeFormat = DateFormat('MMM d, h:mm a').format(startTime);
                  final duration = isActive ? DateTime.now().difference(startTime) : (session['end_time'] != null ? DateTime.parse(session['end_time']).difference(startTime) : Duration.zero);
                  return DataRow(cells: [
                    DataCell(Text(session['session_id'].toString().substring(0, 8), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace'))),
                    DataCell(Text(session['charger_id'].toString().substring(0, 8), style: const TextStyle(color: Colors.white))),
                    DataCell(Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(4)), child: Text(session['rfid_tag'] ?? 'App', style: const TextStyle(color: Colors.white, fontSize: 12)))),
                    DataCell(Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(timeFormat, style: const TextStyle(color: Colors.white)),
                      Text('${duration.inHours}h ${duration.inMinutes.remainder(60)}m', style: TextStyle(color: isActive ? const Color(0xFF4ADDA2) : const Color(0xFF8A8A8A), fontSize: 12)),
                    ])),
                    DataCell(Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${session['kwh_delivered'] ?? 0} kWh', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text('\$${session['total_cost'] ?? 0}', style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                    ])),
                    DataCell(isActive
                        ? ElevatedButton.icon(
                            onPressed: () => _stopSession(session['charger_id'], session['session_id']),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withValues(alpha: 0.1), foregroundColor: Colors.redAccent, elevation: 0, side: const BorderSide(color: Colors.redAccent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                            icon: const Icon(Icons.stop_circle_outlined, size: 16),
                            label: const Text('Force Stop'),
                          )
                        : Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(50), border: Border.all(color: Colors.grey.withValues(alpha: 0.2))), child: const Text('Completed', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)))),
                  ]);
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // TAB 7: REVENUE ANALYTICS
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildRevenueAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: _StatCard(title: 'Total Revenue (All Time)', value: '\$48,200', icon: Icons.account_balance, color: const Color(0xFF4ADDA2))),
            const SizedBox(width: 24),
            Expanded(child: _StatCard(title: 'Avg Session Value', value: '\$14.20', icon: Icons.show_chart, color: Colors.amber)),
            const SizedBox(width: 24),
            Expanded(child: _StatCard(title: 'Top User Revenue', value: '\$820', icon: Icons.emoji_events, color: Colors.purpleAccent)),
          ]),
          const SizedBox(height: 40),

          const Text('Revenue — Last 30 Days', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Container(
            height: 280,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF2A2A2A))),
            child: LineChart(LineChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFF2A2A2A), strokeWidth: 1)),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 44, getTitlesWidget: (v, _) => Text('\$${v.toInt()}', style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 11)))),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text('D${v.toInt() + 1}', style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 10)))),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minX: 0, maxX: 6, minY: 0, maxY: 2500,
              lineBarsData: [
                LineChartBarData(
                  spots: const [FlSpot(0, 800), FlSpot(1, 1200), FlSpot(2, 900), FlSpot(3, 1800), FlSpot(4, 2100), FlSpot(5, 1600), FlSpot(6, 2400)],
                  isCurved: true, color: Colors.purpleAccent, barWidth: 3, dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [Colors.purpleAccent.withValues(alpha: 0.3), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                ),
              ],
            )),
          ),
          const SizedBox(height: 40),

          const Text('Sessions Per Hour (Peak Heatmap)', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Container(
            height: 220,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF2A2A2A))),
            child: BarChart(BarChartData(
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text('${v.toInt()}h', style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 10)))),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barGroups: List.generate(24, (i) {
                final vals = [1.0, 0.5, 0.3, 0.2, 0.1, 0.3, 1.5, 3.0, 5.0, 6.5, 7.0, 6.0, 5.5, 6.0, 7.5, 8.0, 7.0, 6.5, 5.0, 4.0, 3.5, 3.0, 2.0, 1.5];
                return BarChartGroupData(x: i, barRods: [
                  BarChartRodData(toY: vals[i], color: vals[i] > 6 ? Colors.amber : const Color(0xFF4ADDA2), width: 10, borderRadius: BorderRadius.circular(4)),
                ]);
              }),
            )),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // TAB 8: RATE CARDS & PRICING
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildRateCardsTab() {
    double surgeMultiplier = 1.0;
    String selectedCard = 'EV Hub Basic';

    return StatefulBuilder(
      builder: (context, setLocalState) => SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rate Card & Pricing Configuration', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),

            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Active Rate Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF4ADDA2).withValues(alpha: 0.4))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Row(children: [Icon(Icons.price_change, color: Color(0xFF4ADDA2)), SizedBox(width: 8), Text('Active Rate Card', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      value: selectedCard,
                      dropdownColor: const Color(0xFF141414),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(filled: true, fillColor: const Color(0xFF0F0F0F), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), labelText: 'Assign Rate Card', labelStyle: const TextStyle(color: Color(0xFF8A8A8A))),
                      items: ['Pay As You Go', 'EV Hub Basic', 'EV Hub Premium', 'Fleet Rate'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setLocalState(() => selectedCard = v!),
                    ),
                    const SizedBox(height: 24),
                    _buildRateRow('12 AM – 8 AM (Off-Peak)', '₹12.00 / kWh', const Color(0xFF00F0FF)),
                    const SizedBox(height: 12),
                    _buildRateRow('8 AM – 12 PM (Mid)', '₹16.00 / kWh', const Color(0xFF4ADDA2)),
                    const SizedBox(height: 12),
                    _buildRateRow('12 PM – 6 PM (Peak)', '₹22.00 / kWh', Colors.amber),
                    const SizedBox(height: 24),
                    SizedBox(width: double.infinity, child: ElevatedButton.icon(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rate card updated!'), backgroundColor: Color(0xFF4ADDA2))),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ADDA2), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      icon: const Icon(Icons.save),
                      label: const Text('Apply Rate Card', style: TextStyle(fontWeight: FontWeight.bold)),
                    )),
                  ]),
                ),
              ),
              const SizedBox(width: 32),

              // Surge Multiplier
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF2A2A2A))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Row(children: [Icon(Icons.electric_bolt, color: Colors.amber), SizedBox(width: 8), Text('Live Surge Multiplier', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]),
                    const SizedBox(height: 8),
                    const Text('Manually apply a surge price for events / peak demand. Applies on top of active rate card.', style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                    const SizedBox(height: 32),
                    Center(child: Text('${surgeMultiplier.toStringAsFixed(1)}x', style: TextStyle(color: surgeMultiplier > 1.5 ? Colors.redAccent : Colors.amber, fontSize: 56, fontWeight: FontWeight.bold))),
                    const SizedBox(height: 16),
                    SliderTheme(
                      data: SliderThemeData(activeTrackColor: Colors.amber, inactiveTrackColor: const Color(0xFF2A2A2A), thumbColor: Colors.white, overlayColor: Colors.amber.withValues(alpha: 0.2), trackHeight: 8),
                      child: Slider(min: 1.0, max: 3.0, divisions: 20, value: surgeMultiplier, onChanged: (v) => setLocalState(() => surgeMultiplier = v)),
                    ),
                    const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('1.0x (Normal)', style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 11)), Text('3.0x (Max Surge)', style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 11))]),
                    const SizedBox(height: 24),
                    SizedBox(width: double.infinity, child: ElevatedButton.icon(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Surge ${surgeMultiplier.toStringAsFixed(1)}x applied!'), backgroundColor: Colors.amber)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      icon: const Icon(Icons.bolt),
                      label: const Text('Apply Surge Now', style: TextStyle(fontWeight: FontWeight.bold)),
                    )),
                  ]),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // TAB 9: MAINTENANCE LOG
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildMaintenanceLogTab() {
    final incidents = [
      {'id': 'INC-221', 'title': 'Thermal fault on Gun 1', 'priority': 'Critical', 'status': 'Resolved', 'technician': 'Ramesh S.', 'date': '2026-05-18', 'notes': 'Cooling fan replaced.'},
      {'id': 'INC-215', 'title': 'RFID reader non-responsive', 'priority': 'High', 'status': 'Resolved', 'technician': 'Vijay K.', 'date': '2026-05-12', 'notes': 'Module firmware updated.'},
      {'id': 'INC-208', 'title': 'Scheduled quarterly inspection', 'priority': 'Low', 'status': 'Completed', 'technician': 'Anand R.', 'date': '2026-05-01', 'notes': 'All connectors checked. No issues.'},
    ];

    final titleCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Maintenance Log', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: const Color(0xFF141414),
                  title: const Text('Log New Incident', style: TextStyle(color: Colors.white)),
                  content: Column(mainAxisSize: MainAxisSize.min, children: [
                    _buildDialogField('Incident Title', titleCtrl),
                    const SizedBox(height: 16),
                    _buildDialogField('Notes / Description', notesCtrl),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: 'High',
                      dropdownColor: const Color(0xFF141414),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(labelText: 'Priority', labelStyle: const TextStyle(color: Color(0xFF8A8A8A)), filled: true, fillColor: const Color(0xFF0F0F0F), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                      items: ['Critical', 'High', 'Low'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (_) {},
                    ),
                  ]),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incident logged!'), backgroundColor: Color(0xFF4ADDA2))); },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ADDA2), foregroundColor: Colors.black),
                      child: const Text('Log Incident'),
                    ),
                  ],
                ),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              icon: const Icon(Icons.add_alert),
              label: const Text('Log Incident', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 32),

          // Timeline
          ...incidents.asMap().entries.map((entry) {
            final i = entry.key;
            final inc = entry.value;
            Color priColor = inc['priority'] == 'Critical' ? Colors.redAccent : (inc['priority'] == 'High' ? Colors.orange : Colors.grey);
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: priColor, shape: BoxShape.circle)),
                  if (i < incidents.length - 1) Container(width: 2, height: 120, color: const Color(0xFF2A2A2A)),
                ]),
                const SizedBox(width: 24),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('${inc['id']} — ${inc['title']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: priColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: Text(inc['priority']!, style: TextStyle(color: priColor, fontSize: 11, fontWeight: FontWeight.bold))),
                      ]),
                      const SizedBox(height: 8),
                      Text('${inc['date']} • Technician: ${inc['technician']}', style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                      const SizedBox(height: 8),
                      Text(inc['notes']!, style: const TextStyle(color: Color(0xFF8A8A8A))),
                      const SizedBox(height: 8),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF4ADDA2).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: Text(inc['status']!, style: const TextStyle(color: Color(0xFF4ADDA2), fontSize: 11))),
                    ]),
                  ),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // TAB 10: ADMIN SETTINGS
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(flex: 4, child: _buildStationProfileForm()),
        const SizedBox(width: 40),
        Expanded(flex: 5, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _buildFeaturePanel(),
          const SizedBox(height: 32),
          _buildAmenitiesPanel(),
        ])),
      ]),
    );
  }

  Widget _buildStationProfileForm() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.edit_document, color: Color(0xFF8A8A8A)), SizedBox(width: 12), Text('Station Profile Details', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 32),
        _buildTextField('Station Name', _stationData!['name'] ?? ''),
        const SizedBox(height: 24),
        _buildTextField('Physical Location', _stationData!['location'] ?? ''),
        const SizedBox(height: 24),
        _buildTextField('Geolocation (Lat, Lng)', '34.0522, -118.2437'),
        const SizedBox(height: 24),
        const Text('Vendor Assignment', style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: 'Vendor A',
          dropdownColor: const Color(0xFF141414),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(filled: true, fillColor: const Color(0xFF0F0F0F), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
          items: ['Vendor A', 'Vendor B', 'Vendor C (Self-Owned)'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (_) {},
        ),
        const SizedBox(height: 24),
        const Text('Operational Status', style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: const Color(0xFF0F0F0F), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A2A2A))),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _stationData!['status'] ?? 'Offline',
              dropdownColor: const Color(0xFF1E1E1E),
              isExpanded: true,
              items: ['Online', 'Offline', 'Faulted', 'Maintenance'].map((v) => DropdownMenuItem<String>(value: v, child: Text(v, style: const TextStyle(color: Colors.white)))).toList(),
              onChanged: (_) {},
            ),
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings Saved!'), backgroundColor: Color(0xFF4ADDA2))),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ADDA2), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          icon: const Icon(Icons.save),
          label: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        )),
      ]),
    );
  }

  Widget _buildTextField(String label, String initialValue) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
      const SizedBox(height: 8),
      TextFormField(
        initialValue: initialValue,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(filled: true, fillColor: const Color(0xFF0F0F0F), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4ADDA2)))),
      ),
    ]);
  }

  Widget _buildFeaturePanel() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.admin_panel_settings, color: Color(0xFF4ADDA2)), SizedBox(width: 12), Text('Hub Capabilities & Feature Flags', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 24),
        _buildToggleSwitch('Public Access', 'Make station visible to all users on the app map.', _publicAccess, (v) => setState(() => _publicAccess = v)),
        _buildToggleSwitch('Pay-As-You-Go Billing', 'Allow QR scanning and direct wallet deduction.', _payAsYouGo, (v) => setState(() => _payAsYouGo = v)),
        _buildToggleSwitch('Smart Load Balancing', 'Dynamically throttle chargers to prevent grid overload.', _smartLoadBalancing, (v) => setState(() => _smartLoadBalancing = v)),
        _buildToggleSwitch('Dynamic Surge Pricing', 'Automatically increase rate cards during peak hours.', _dynamicPricing, (v) => setState(() => _dynamicPricing = v)),
      ]),
    );
  }

  Widget _buildAmenitiesPanel() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.coffee, color: Colors.orangeAccent), SizedBox(width: 12), Text('Amenities & Infrastructure', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 24),
        _buildToggleSwitch('Free Drinking Water', 'Provide purified RO water dispenser.', _hasWater, (v) => setState(() => _hasWater = v)),
        _buildToggleSwitch('Restrooms', 'Maintained public washrooms available.', _hasRestroom, (v) => setState(() => _hasRestroom = v)),
        _buildToggleSwitch('Food & Cafe', 'On-site cafe or food vending machines.', _hasFood, (v) => setState(() => _hasFood = v)),
        _buildToggleSwitch('Premium Lounge', 'Air-conditioned waiting area for customers.', _hasLounge, (v) => setState(() => _hasLounge = v)),
        _buildToggleSwitch('High-Speed WiFi', 'Free internet access while charging.', _hasWifi, (v) => setState(() => _hasWifi = v)),
      ]),
    );
  }

  Widget _buildToggleSwitch(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
        ])),
        Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF4ADDA2), inactiveTrackColor: const Color(0xFF2A2A2A)),
      ]),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor = const Color(0xFF4ADDA2).withValues(alpha: 0.1);
    Color textColor = const Color(0xFF4ADDA2);
    if (status == 'Offline') { bgColor = Colors.grey.withValues(alpha: 0.1); textColor = Colors.grey; }
    else if (status == 'Faulted') { bgColor = Colors.redAccent.withValues(alpha: 0.1); textColor = Colors.redAccent; }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(50), border: Border.all(color: textColor.withValues(alpha: 0.2))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: textColor, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(status, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12)),
      ]),
    );
  }

  Widget _buildQuickKpi(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 11)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        ]),
      ]),
    );
  }

  Widget _buildRateRow(String label, String price, Color color) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 10), Text(label, style: const TextStyle(color: Colors.white))]),
      Text(price, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    ]);
  }

  TextField _buildDialogField(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Color(0xFF8A8A8A)), filled: true, fillColor: const Color(0xFF0F0F0F), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LIVE ORDER CARD WIDGET (with live timer)
// ─────────────────────────────────────────────────────────────────────────────
class _LiveOrderCard extends StatefulWidget {
  final Map<String, dynamic> session;
  final VoidCallback onStop;
  const _LiveOrderCard({required this.session, required this.onStop});

  @override
  State<_LiveOrderCard> createState() => _LiveOrderCardState();
}

class _LiveOrderCardState extends State<_LiveOrderCard> {
  late Timer _timer;
  late Duration _elapsed;

  @override
  void initState() {
    super.initState();
    final start = DateTime.parse(widget.session['start_time']);
    _elapsed = DateTime.now().difference(start);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed = DateTime.now().difference(start));
    });
  }

  @override
  void dispose() { _timer.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final soc = (widget.session['soc_percent'] as int? ?? 50).toDouble();
    final kWh = widget.session['kwh_delivered'] ?? 0.0;
    final cost = widget.session['total_cost'] ?? 0.0;
    final gun = widget.session['gun_number'] ?? 1;
    final user = widget.session['user_name'] ?? 'Unknown User';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF4ADDA2).withValues(alpha: 0.4), width: 2),
        boxShadow: [BoxShadow(color: const Color(0xFF4ADDA2).withValues(alpha: 0.08), blurRadius: 20, spreadRadius: -5)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF4ADDA2), shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text('Gun $gun — ${widget.session['charger_id'] ?? 'CHR'}', style: const TextStyle(color: Color(0xFF4ADDA2), fontWeight: FontWeight.bold, fontSize: 13)),
          ]),
          Text('${_elapsed.inHours.toString().padLeft(2, '0')}:${_elapsed.inMinutes.remainder(60).toString().padLeft(2, '0')}:${_elapsed.inSeconds.remainder(60).toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          const CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://i.pravatar.cc/50')),
          const SizedBox(width: 12),
          Text(user, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('SoC', style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
          Text('${soc.toInt()}%', style: const TextStyle(color: Color(0xFF4ADDA2), fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: soc / 100, backgroundColor: const Color(0xFF2A2A2A), color: const Color(0xFF4ADDA2), minHeight: 8),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Energy', style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 11)),
            Text('${kWh} kWh', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ])),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Amount', style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 11)),
            Text('₹${cost}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          ])),
        ]),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          onPressed: widget.onStop,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withValues(alpha: 0.1), foregroundColor: Colors.redAccent, elevation: 0, side: const BorderSide(color: Colors.redAccent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
          icon: const Icon(Icons.stop_circle_outlined, size: 16),
          label: const Text('Force Stop'),
        )),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHARGER EXPANDABLE CARD
// ─────────────────────────────────────────────────────────────────────────────
class _ChargerExpandableCard extends StatefulWidget {
  final Map<String, dynamic> charger;
  final String stationId;
  const _ChargerExpandableCard({required this.charger, required this.stationId});

  @override
  State<_ChargerExpandableCard> createState() => _ChargerExpandableCardState();
}

class _ChargerExpandableCardState extends State<_ChargerExpandableCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final charger = widget.charger;
    final guns = charger['guns'] as List? ?? [];
    final status = charger['status'] ?? 'Available';
    Color statusColor = status == 'Available' ? const Color(0xFF4ADDA2) : (status == 'Faulted' ? Colors.redAccent : Colors.amber);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Column(children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.ev_station, color: statusColor)),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(charger['charger_id'] ?? 'CHR-???', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${charger['type'] ?? 'DC'} • ${charger['model'] ?? 'Unknown'} • ${guns.length} gun(s)', style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
              ])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: const Color(0xFF8A8A8A)),
            ]),
          ),
        ),
        if (_expanded) ...[
          const Divider(color: Color(0xFF2A2A2A), height: 1),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Connectors / Guns', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...guns.map<Widget>((gun) {
                Color gColor = gun['status'] == 'Occupied' ? Colors.amber : (gun['status'] == 'Faulted' ? Colors.redAccent : const Color(0xFF4ADDA2));
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF0F0F0F), borderRadius: BorderRadius.circular(12), border: Border.all(color: gColor.withValues(alpha: 0.3))),
                  child: Row(children: [
                    Container(width: 32, height: 32, decoration: BoxDecoration(color: gColor.withValues(alpha: 0.1), shape: BoxShape.circle), child: Center(child: Text('G${gun['gun_number']}', style: TextStyle(color: gColor, fontWeight: FontWeight.bold, fontSize: 11)))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${gun['connector_type']} — ${gun['max_power_kw']} kW', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text(gun['status'], style: TextStyle(color: gColor, fontSize: 12)),
                    ])),
                    IconButton(
                      icon: const Icon(Icons.qr_code, color: Color(0xFF8A8A8A)),
                      tooltip: 'View QR',
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: const Color(0xFF141414),
                          title: Text('QR — ${charger['charger_id']} Gun ${gun['gun_number']}', style: const TextStyle(color: Colors.white)),
                          content: Container(padding: const EdgeInsets.all(16), color: Colors.white, child: QrImageView(data: 'https://rzp.io/l/ev-${charger['charger_id']}-gun${gun['gun_number']}', version: QrVersions.auto, size: 200)),
                          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                        ),
                      ),
                    ),
                  ]),
                );
              }).toList(),
            ]),
          ),
        ],
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOAD BALANCING TAB (preserved from original)
// ─────────────────────────────────────────────────────────────────────────────
class LoadBalancingTab extends StatefulWidget {
  final String stationId;
  final Map<String, dynamic> initialData;
  const LoadBalancingTab({super.key, required this.stationId, required this.initialData});

  @override
  State<LoadBalancingTab> createState() => _LoadBalancingTabState();
}

class _LoadBalancingTabState extends State<LoadBalancingTab> {
  late double _maxPowerKw;
  late bool _isLoadBalancingEnabled;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _maxPowerKw = double.tryParse(widget.initialData['max_power_capacity_kw']?.toString() ?? '500.0') ?? 500.0;
    _isLoadBalancingEnabled = widget.initialData['load_balancing_enabled'] == true;
  }

  Future<void> _saveConfig() async {
    setState(() => _isSaving = true);
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3003/api/ocpp/load-balancing'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'station_id': widget.stationId, 'max_power_capacity_kw': _maxPowerKw, 'load_balancing_enabled': _isLoadBalancingEnabled}),
      );
      if (response.statusCode == 200) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Load Balancing Profile Updated!'), backgroundColor: Color(0xFF4ADDA2)));
      } else throw Exception('API failed');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update config.'), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _forceRebalance() async {
    if (!_isLoadBalancingEnabled) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enable Load Balancing first.'), backgroundColor: Colors.orange)); return; }
    setState(() => _isSaving = true);
    try {
      final response = await http.post(Uri.parse('http://localhost:3003/api/ocpp/smart-charging/rebalance'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'station_id': widget.stationId}));
      if (response.statusCode == 200) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Grid successfully rebalanced!'), backgroundColor: Color(0xFF4ADDA2))); }
      else throw Exception('Rebalance failed');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to rebalance.'), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentDraw = double.tryParse(widget.initialData['current_total_kw_draw']?.toString() ?? '0') ?? 0.0;
    final usagePercent = _maxPowerKw > 0 ? (currentDraw / _maxPowerKw).clamp(0.0, 1.0) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Smart Load Balancing (OCPP)', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Automatically throttle chargers to prevent tripping the local grid.', style: TextStyle(color: Color(0xFF8A8A8A))),
          ]),
          Switch(value: _isLoadBalancingEnabled, activeColor: const Color(0xFF4ADDA2), onChanged: (v) => setState(() => _isLoadBalancingEnabled = v)),
        ]),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(24), border: Border.all(color: _isLoadBalancingEnabled ? const Color(0xFF4ADDA2).withValues(alpha: 0.5) : const Color(0xFF2A2A2A))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Maximum Allowed Station Power Draw', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(8)), child: Text('${_maxPowerKw.toStringAsFixed(0)} kW', style: const TextStyle(color: Color(0xFF4ADDA2), fontSize: 24, fontWeight: FontWeight.bold))),
            ]),
            const SizedBox(height: 24),
            SliderTheme(
              data: SliderThemeData(activeTrackColor: const Color(0xFF4ADDA2), inactiveTrackColor: const Color(0xFF2A2A2A), thumbColor: Colors.white, overlayColor: const Color(0xFF4ADDA2).withValues(alpha: 0.2), trackHeight: 8),
              child: Slider(min: 50, max: 2000, divisions: 39, value: _maxPowerKw, onChanged: _isLoadBalancingEnabled ? (v) => setState(() => _maxPowerKw = v) : null),
            ),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('50 kW', style: TextStyle(color: Color(0xFF5A5A5A))), Text('2000 kW', style: TextStyle(color: Color(0xFF5A5A5A)))]),
          ]),
        ),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF2A2A2A))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Live Station Energy Usage vs Limit', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            LinearProgressIndicator(value: usagePercent, backgroundColor: const Color(0xFF2A2A2A), color: usagePercent > 0.85 ? Colors.redAccent : const Color(0xFF4ADDA2), minHeight: 16, borderRadius: BorderRadius.circular(8)),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Current: $currentDraw kW', style: const TextStyle(color: Color(0xFF8A8A8A))),
              Text('Limit: ${_maxPowerKw.toStringAsFixed(0)} kW', style: const TextStyle(color: Color(0xFF8A8A8A))),
            ]),
          ]),
        ),
        const SizedBox(height: 40),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          OutlinedButton.icon(
            onPressed: _isSaving ? null : _forceRebalance,
            style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF00F0FF), side: const BorderSide(color: Color(0xFF00F0FF)), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            icon: const Icon(Icons.sync),
            label: const Text('Force Grid Rebalance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveConfig,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ADDA2), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            icon: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) : const Icon(Icons.save),
            label: const Text('Save & Apply Smart Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ]),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAT CARD (reusable)
// ─────────────────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 14)), Icon(icon, color: color)]),
        const SizedBox(height: 16),
        Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
      ]),
    );
  }
}
