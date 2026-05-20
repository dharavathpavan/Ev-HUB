import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late ScrollController _scrollController;
  Timer? _tickerTimer;

  // Mock Telemetry Feed
  final List<String> _feedItems = [
    'Session started at HUB-Downtown-01',
    'User Alice topped up wallet (+\$50.00)',
    'Charger 4 at Westside offline',
    'Session ended at HUB-Uptown-04 (12.4 kWh)',
    'New Vendor Registration pending approval',
    'Peak grid load detected, throttling applied',
    'Session started at HUB-Downtown-02',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();

    _scrollController = ScrollController();
    _startTicker();
  }

  void _startTicker() {
    _tickerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.position.pixels;
        double target = currentScroll + 50;
        if (target > maxScroll) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.animateTo(target, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        }
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.dispose();
    _tickerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
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
                      Text('Super Admin Hub', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 8),
                      Text('Network overview and action center', style: TextStyle(color: Color(0xFF8A8A8A))),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => context.go('/vendor-portal'),
                        icon: const Icon(Icons.rocket_launch, color: Colors.black, size: 18),
                        label: const Text(
                          'Vendor Portal',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4ADDA2), // Neon mint green
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          shadowColor: const Color(0xFF4ADDA2).withValues(alpha: 0.4),
                          elevation: 12,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Container(
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(50)),
                        child: IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_active, color: Color(0xFF4ADDA2))),
                      ),
                      const SizedBox(width: 16),
                      const CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11')),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 40),
              
              // Animated KPI Ribbon
              Row(
                children: [
                  Expanded(child: _buildAnimatedKpiCard('Network Uptime', '98.5%', Icons.cloud_done, const Color(0xFF4ADDA2), delay: 0)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildAnimatedKpiCard('Live Sessions', '42', Icons.ev_station, Colors.amber, delay: 200)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildAnimatedKpiCard('Today\'s Revenue', '\$1,204.50', Icons.attach_money, Colors.purpleAccent, delay: 400)),
                ],
              ),
              
              const SizedBox(height: 40),

              // Main Layout: Charts (Left) and Action Center (Right)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Dual Charts
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildChartCard('Revenue (Last 7 Days)', _buildRevenueChart(), Colors.purpleAccent),
                        const SizedBox(height: 40),
                        _buildChartCard('Energy Dispensed (kWh)', _buildEnergyChart(), const Color(0xFF4ADDA2)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  
                  // Right Column: Action Center & Telemetry
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Action Center', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _buildActionItem(context, 'Vendor Onboarding Wizard', 'Launch complete provisioning workflow', Icons.business, const Color(0xFF4ADDA2), '/vendor-portal'),
                        const SizedBox(height: 16),
                        _buildActionItem(context, 'Pending Vendors', '3 awaiting approval', Icons.storefront, Colors.orange, '/users'),
                        const SizedBox(height: 16),
                        _buildActionItem(context, 'Pending Refunds', '4 authorization required', Icons.currency_exchange, Colors.amber, '/users'),
                        const SizedBox(height: 16),
                        _buildActionItem(context, 'Critical Faults', '1 unresolved hardware issue', Icons.warning_amber, Colors.redAccent, '/support'),
                        
                        const SizedBox(height: 40),
                        
                        const Text('Live Telemetry Feed', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Container(
                          height: 300,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFF2A2A2A)),
                          ),
                          child: ListView.separated(
                            controller: _scrollController,
                            itemCount: _feedItems.length,
                            separatorBuilder: (context, index) => const Divider(color: Color(0xFF2A2A2A), height: 32),
                            itemBuilder: (context, index) {
                              return Row(
                                children: [
                                  Container(
                                    width: 8, height: 8,
                                    decoration: const BoxDecoration(color: Color(0xFF4ADDA2), shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(child: Text(_feedItems[index], style: const TextStyle(color: Color(0xFF8A8A8A)))),
                                ],
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedKpiCard(String title, String value, IconData icon, Color color, {required int delay}) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (context, double opacity, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * opacity),
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: -5)
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold)),
                Icon(icon, color: color),
              ],
            ),
            const SizedBox(height: 16),
            Text(value, style: TextStyle(color: color, fontSize: 36, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, String title, String subtitle, IconData icon, Color color, String route) {
    return InkWell(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF8A8A8A)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart, Color color) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(50)),
                child: Text('Last 7 Days', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 32),
          Expanded(child: chart),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: const Color(0xFF2A2A2A), strokeWidth: 1)),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) => Text('\$${value.toInt()}', style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)))),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
            const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
            if (value.toInt() >= 0 && value.toInt() < days.length) {
              return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(days[value.toInt()], style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)));
            }
            return const SizedBox();
          })),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0, maxX: 6, minY: 0, maxY: 2000,
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 800), FlSpot(1, 1200), FlSpot(2, 900),
              FlSpot(3, 1500), FlSpot(4, 1800), FlSpot(5, 1400), FlSpot(6, 1204),
            ],
            isCurved: true,
            color: Colors.purpleAccent,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(colors: [Colors.purpleAccent.withValues(alpha: 0.3), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: const Color(0xFF2A2A2A), strokeWidth: 1)),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) => Text('${value.toInt()}k', style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)))),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
            const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
            if (value.toInt() >= 0 && value.toInt() < days.length) {
              return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(days[value.toInt()], style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)));
            }
            return const SizedBox();
          })),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0, maxX: 6, minY: 0, maxY: 5,
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 2.1), FlSpot(1, 3.4), FlSpot(2, 2.8),
              FlSpot(3, 4.1), FlSpot(4, 4.8), FlSpot(5, 3.9), FlSpot(6, 3.2),
            ],
            isCurved: true,
            color: const Color(0xFF4ADDA2),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(colors: [const Color(0xFF4ADDA2).withValues(alpha: 0.3), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            ),
          ),
        ],
      ),
    );
  }
}
