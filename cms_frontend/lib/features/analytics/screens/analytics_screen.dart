import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // Mock Data for the charts
  final List<FlSpot> _revenueData = const [
    FlSpot(0, 300),
    FlSpot(1, 450),
    FlSpot(2, 400),
    FlSpot(3, 700),
    FlSpot(4, 850),
    FlSpot(5, 600),
    FlSpot(6, 950),
  ];

  final List<BarChartGroupData> _utilizationData = [
    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 85, color: const Color(0xFF4ADDA2), width: 16, borderRadius: BorderRadius.circular(4))]),
    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 60, color: const Color(0xFF4ADDA2), width: 16, borderRadius: BorderRadius.circular(4))]),
    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 45, color: const Color(0xFF4ADDA2), width: 16, borderRadius: BorderRadius.circular(4))]),
    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 92, color: const Color(0xFF4ADDA2), width: 16, borderRadius: BorderRadius.circular(4))]),
    BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 30, color: const Color(0xFF4ADDA2), width: 16, borderRadius: BorderRadius.circular(4))]),
  ];

  Widget _buildKPICard(String title, String value, String subtitle, IconData icon, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
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
                Text(title, style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: Color(0xFF4ADDA2), fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Revenue Overview (Last 7 Days)', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 200,
                  getDrawingHorizontalLine: (value) => FlLine(color: const Color(0xFF2A2A2A), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(days[value.toInt()], style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text('\$${value.toInt()}', style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 1000,
                lineBarsData: [
                  LineChartBarData(
                    spots: _revenueData,
                    isCurved: true,
                    color: const Color(0xFF4ADDA2),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF4ADDA2).withValues(alpha: 0.3),
                          const Color(0xFF4ADDA2).withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUtilizationChart() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Station Utilization (%)', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Expanded(
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) => FlLine(color: const Color(0xFF2A2A2A), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        const stations = ['ST-001', 'ST-002', 'ST-003', 'ST-004', 'ST-005'];
                        if (value.toInt() >= 0 && value.toInt() < stations.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(stations[value.toInt()], style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toInt()}%', style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                maxY: 100,
                barGroups: _utilizationData,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analytics & Reporting',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 40),
          
          // KPI Cards Row
          Row(
            children: [
              _buildKPICard('Total Revenue', '\$4,250.00', '+12.5% from last week', Icons.attach_money, const Color(0xFF4ADDA2)),
              const SizedBox(width: 24),
              _buildKPICard('Active Sessions', '42', 'Live right now', Icons.ev_station, Colors.blueAccent),
              const SizedBox(width: 24),
              _buildKPICard('Energy Dispensed', '1,840 kWh', '+8.2% from last week', Icons.bolt, Colors.amber),
              const SizedBox(width: 24),
              _buildKPICard('System Uptime', '99.98%', 'No active alerts', Icons.check_circle_outline, Colors.purpleAccent),
            ],
          ),
          const SizedBox(height: 40),

          // Charts Row
          Row(
            children: [
              Expanded(flex: 2, child: _buildRevenueChart()),
              const SizedBox(width: 24),
              Expanded(flex: 1, child: _buildUtilizationChart()),
            ],
          ),
        ],
      ),
    );
  }
}
