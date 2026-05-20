import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

class VendorOverviewScreen extends StatefulWidget {
  const VendorOverviewScreen({super.key});

  @override
  State<VendorOverviewScreen> createState() => _VendorOverviewScreenState();
}

class _VendorOverviewScreenState extends State<VendorOverviewScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late ScrollController _scrollController;
  Timer? _tickerTimer;

  final List<String> _feedItems = [
    'User Alice topped up wallet (+\$50.00)',
    'Session started at ChargePoint Downtown #01',
    'Session ended at ChargePoint Downtown #02 (12.4 kWh)',
    'Payout of \$1,200.50 deposited to your bank',
    'New Booking: 14:00 at Station #4',
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
    _tickerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
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
              const Text('Vendor Dashboard', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              const Text('Welcome back! Here is what is happening with your stations.', style: TextStyle(color: Color(0xFF8A8A8A))),
              
              const SizedBox(height: 40),
              
              // Animated KPI Ribbon
              Row(
                children: [
                  Expanded(child: _buildAnimatedKpiCard('Total Revenue', '\$4,204.50', Icons.attach_money, const Color(0xFF4ADDA2), delay: 0)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildAnimatedKpiCard('Active Sessions', '12', Icons.ev_station, Colors.amber, delay: 200)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildAnimatedKpiCard('Network Uptime', '99.9%', Icons.cloud_done, Colors.purpleAccent, delay: 400)),
                ],
              ),
              
              const SizedBox(height: 40),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Chart
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildChartCard('Revenue (Last 7 Days)', _buildRevenueChart(), const Color(0xFF4ADDA2)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  
                  // Right Column: Recent Activity Feed
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Recent Activity', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Container(
                          height: 350,
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
        minX: 0, maxX: 6, minY: 0, maxY: 1000,
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 300), FlSpot(1, 450), FlSpot(2, 380),
              FlSpot(3, 550), FlSpot(4, 700), FlSpot(5, 600), FlSpot(6, 820),
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
