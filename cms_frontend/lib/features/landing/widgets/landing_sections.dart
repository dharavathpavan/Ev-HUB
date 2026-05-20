import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../painters/neural_node_painter.dart';

// ==========================================
// 3️⃣ LIVE NETWORK SECTION
// ==========================================
class NetworkSection extends StatefulWidget {
  const NetworkSection({super.key});

  @override
  State<NetworkSection> createState() => _NetworkSectionState();
}

class _NetworkSectionState extends State<NetworkSection> {
  double _chargers = 0;
  double _sessions = 0;
  double _cities = 0;
  double _uptime = 90.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Simulate real-time incrementing stats tickers
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        if (_chargers < 12450) _chargers += 187;
        if (_sessions < 120000) _sessions += 1800;
        if (_cities < 58) _cities += 1;
        if (_uptime < 98.4) _uptime += 0.15;
        
        if (_chargers >= 12450 && _sessions >= 120000 && _cities >= 58 && _uptime >= 98.4) {
          _chargers = 12450;
          _sessions = 1200000;
          _cities = 58;
          _uptime = 98.4;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Container(
      width: double.infinity,
      color: const Color(0xFF050816),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
      child: Column(
        children: [
          // Section Heading
          Text(
            'LIVE NETWORK METRICS',
            style: GoogleFonts.orbitron(
              color: const Color(0xFF00D1FF),
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Infrastructure Scale & Power',
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
              fontSize: isMobile ? 26 : 38,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 80),

          // Cards Row/Grid
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: [
              _buildStatCard('12,450+', 'Active Charger Nodes', '${_chargers.toInt()}', const Color(0xFF00D1FF)),
              _buildStatCard('1.2M+', 'Total Sessions', '${(_sessions / 1000000).toStringAsFixed(1)}M', const Color(0xFF00FFB2)),
              _buildStatCard('58', 'Connected Cities', '${_cities.toInt()}', const Color(0xFF7B61FF)),
              _buildStatCard('98.4%', 'Network Uptime SLA', '${_uptime.toStringAsFixed(1)}%', const Color(0xFFFF4D6D)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String sub, String val, Color glowColor) {
    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1120).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: glowColor.withOpacity(0.15),
        ),
      ),
      child: Column(
        children: [
          Text(
            val,
            style: GoogleFonts.orbitron(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: glowColor,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            sub,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4️⃣ INTERACTIVE CHARGING FLOW
// ==========================================
class ChargingFlowSection extends StatefulWidget {
  const ChargingFlowSection({super.key});

  @override
  State<ChargingFlowSection> createState() => _ChargingFlowSectionState();
}

class _ChargingFlowSectionState extends State<ChargingFlowSection> {
  int _activeStep = 0;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Plug In',
      'desc': 'Connect the premium CCS2/Type2 plug to your vehicle. Telemetry syncs in <150ms.',
      'icon': Icons.power,
    },
    {
      'title': 'Pay UPI',
      'desc': 'Scan the holographic QR on cabinet display. Authorize via secure instant merchant gateway.',
      'icon': Icons.qr_code_2,
    },
    {
      'title': 'Charging Starts',
      'desc': 'Volumetric energy channels initiate. Smart relay adjusts power draw instantly.',
      'icon': Icons.bolt,
    },
    {
      'title': 'Telemetry HUD',
      'desc': 'Track real-time power draw graphs, cost counters, and voltage curves on client app.',
      'icon': Icons.monitor,
    },
    {
      'title': 'Refund Complete',
      'desc': 'Unused wallet pre-authorization deposits are automatically settled and refunded immediately.',
      'icon': Icons.account_balance_wallet,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Container(
      width: double.infinity,
      color: const Color(0xFF050816),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
      child: Column(
        children: [
          Text(
            'USER JOURNEY MAP',
            style: GoogleFonts.orbitron(
              color: const Color(0xFF00D1FF),
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Interactive Charging Flow',
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
              fontSize: isMobile ? 26 : 38,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 60),

          // Horizontal/Vertical timeline list
          isMobile
              ? Column(
                  children: _steps.asMap().entries.map((entry) => _buildStepRow(entry.key, entry.value)).toList(),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _steps.asMap().entries.map((entry) => _buildStepCol(entry.key, entry.value)).toList(),
                ),

          const SizedBox(height: 60),
          // Active Detail Panel
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: math.min(size.width * 0.8, 600),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1120).withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF00FFB2).withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFB2).withOpacity(0.04),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  _steps[_activeStep]['icon'],
                  color: const Color(0xFF00FFB2),
                  size: 40,
                ),
                const SizedBox(height: 16),
                Text(
                  'STEP ${_activeStep + 1}: ${_steps[_activeStep]['title']}',
                  style: GoogleFonts.orbitron(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _steps[_activeStep]['desc'],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: const Color(0xFF9CA3AF),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCol(int idx, Map<String, dynamic> step) {
    final isActive = _activeStep == idx;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _activeStep = idx),
        child: Row(
          children: [
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF00FFB2) : const Color(0xFF0B1120),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive ? const Color(0xFF00FFB2) : const Color(0xFF00D1FF).withOpacity(0.3),
                      width: 2.0,
                    ),
                  ),
                  child: Icon(
                    step['icon'],
                    color: isActive ? Colors.black : const Color(0xFF00D1FF),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  step['title'],
                  style: GoogleFonts.orbitron(
                    color: isActive ? Colors.white : const Color(0xFF9CA3AF),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (idx < _steps.length - 1)
              Container(
                width: 60,
                height: 2,
                color: isActive ? const Color(0xFF00FFB2) : const Color(0xFF00D1FF).withOpacity(0.15),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow(int idx, Map<String, dynamic> step) {
    final isActive = _activeStep == idx;
    return GestureDetector(
      onTap: () => setState(() => _activeStep = idx),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF00FFB2).withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? const Color(0xFF00FFB2).withOpacity(0.3) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isActive ? const Color(0xFF00FFB2) : const Color(0xFF0B1120),
              child: Icon(
                step['icon'],
                color: isActive ? Colors.black : const Color(0xFF00D1FF),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step['title'],
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Tap to explore details',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 5️⃣ 3D CHARGER SHOWCASE
// ==========================================
class ChargerShowcaseSection extends StatefulWidget {
  const ChargerShowcaseSection({super.key});

  @override
  State<ChargerShowcaseSection> createState() => _ChargerShowcaseSectionState();
}

class _ChargerShowcaseSectionState extends State<ChargerShowcaseSection> {
  int _activeModel = 0;

  final List<Map<String, dynamic>> _models = [
    {
      'name': 'AC Charger',
      'power': '22 kW',
      'tags': ['OCPP Enabled', 'Smart Billing', 'Type 2 Plugs'],
      'desc': 'Ideal for corporate parking and home charging. Seamless load balancing minimizes peak costs.',
    },
    {
      'name': 'DC Fast Charger',
      'power': '350 kW',
      'tags': ['Liquid Cooled', 'AI Load Balancing', 'CCS2 Dual Cables'],
      'desc': 'Ultimate highway charging corridor powerhouse. Direct telemetry pumps energy at record rates.',
    },
    {
      'name': 'Battery Storage Unit',
      'power': '1.2 MWh',
      'tags': ['Peak Shaving', 'Dynamic Pricing', 'Battery Backup'],
      'desc': 'Integrated clean energy backup buffers high capacity nodes during peak smart city grid loads.',
    },
    {
      'name': 'Smart Energy Grid',
      'power': 'Multi-MW',
      'tags': ['Realtime Analytics', 'OCPP 2.0.1', 'Carbon Neutral'],
      'desc': 'Centralized virtual grid balancer routing clean solar/wind resources to localized chargers.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Container(
      width: double.infinity,
      color: const Color(0xFF050816),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
      child: Column(
        children: [
          Text(
            'HARDWARE SYSTEM',
            style: GoogleFonts.orbitron(
              color: const Color(0xFF00D1FF),
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ecosystem Showcase',
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
              fontSize: isMobile ? 26 : 38,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 60),

          // Toggles
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _models.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final isActive = _activeModel == idx;
              return ElevatedButton(
                onPressed: () => setState(() => _activeModel = idx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isActive ? const Color(0xFF00D1FF) : const Color(0xFF0B1120),
                  foregroundColor: isActive ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                    side: BorderSide(
                      color: isActive ? Colors.transparent : const Color(0xFF00D1FF).withOpacity(0.2),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                child: Text(
                  item['name'],
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 60),

          // Model visualizer block (simulate a sleek specs HUD)
          Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1120).withOpacity(0.6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF00D1FF).withOpacity(0.15),
              ),
            ),
            child: Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              children: [
                // Visual Indicator
                Expanded(
                  flex: isMobile ? 0 : 1,
                  child: Container(
                    height: 250,
                    margin: EdgeInsets.only(bottom: isMobile ? 24 : 0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF050816).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF00D1FF).withOpacity(0.2),
                      ),
                    ),
                    child: Center(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: NeuralNodePainter(animationValue: 0.1),
                            ),
                          ),
                          Center(
                            child: Icon(
                              _activeModel == 0 
                                  ? Icons.electrical_services 
                                  : _activeModel == 1 
                                      ? Icons.electric_car
                                      : _activeModel == 2
                                          ? Icons.battery_charging_full
                                          : Icons.grid_view_sharp,
                              color: const Color(0xFF00D1FF),
                              size: 80,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!isMobile) const SizedBox(width: 40),

                // Specs Block
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _models[_activeModel]['name'],
                            style: GoogleFonts.orbitron(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00FFB2).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF00FFB2).withOpacity(0.3)),
                            ),
                            child: Text(
                              _models[_activeModel]['power'],
                              style: GoogleFonts.orbitron(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF00FFB2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _models[_activeModel]['desc'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: const Color(0xFF9CA3AF),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Feature Tags Row
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (_models[_activeModel]['tags'] as List<String>).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00D1FF).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF00D1FF).withOpacity(0.15)),
                            ),
                            child: Text(
                              tag,
                              style: GoogleFonts.orbitron(
                                fontSize: 10,
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 6️⃣ REALTIME DASHBOARD SECTION
// ==========================================
class RealtimeDashboardSection extends StatefulWidget {
  const RealtimeDashboardSection({super.key});

  @override
  State<RealtimeDashboardSection> createState() => _RealtimeDashboardSectionState();
}

class _RealtimeDashboardSectionState extends State<RealtimeDashboardSection> {
  int _batteryPercent = 45;
  double _cost = 12.50;
  double _currentDraw = 320.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Simulate real-time charging metrics tick
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_batteryPercent < 80) {
            _batteryPercent += 1;
            _cost += 0.45;
            _currentDraw = 320.0 + math.sin(timer.tick * 0.5) * 15.0;
          } else {
            _batteryPercent = 45; // Reset cycle
            _cost = 12.50;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Container(
      width: double.infinity,
      color: const Color(0xFF050816),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
      child: Column(
        children: [
          Text(
            'HUD MONITOR CONSOLE',
            style: GoogleFonts.orbitron(
              color: const Color(0xFF00D1FF),
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Realtime Dashboard',
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
              fontSize: isMobile ? 26 : 38,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 60),

          // Main Cockpit Panel
          Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1120).withOpacity(0.7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF00FFB2).withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFB2).withOpacity(0.05),
                  blurRadius: 30,
                ),
              ],
            ),
            child: GridView.count(
              crossAxisCount: isMobile ? 1 : 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: isMobile ? 1.5 : 1.2,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              children: [
                // Gauge: Battery Progress
                _buildCockpitPanel(
                  'Power Battery Level',
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(
                              value: _batteryPercent / 100.0,
                              backgroundColor: Colors.white12,
                              color: const Color(0xFF00FFB2),
                              strokeWidth: 8.0,
                            ),
                          ),
                          Text(
                            '$_batteryPercent%',
                            style: GoogleFonts.orbitron(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('CHARGING (FAST CHARGING CORRIDOR)'),
                    ],
                  ),
                ),

                // Gauge: Cost Accumulations
                _buildCockpitPanel(
                  'Accumulated billing',
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '\$${_cost.toStringAsFixed(2)}',
                        style: GoogleFonts.orbitron(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF00D1FF),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'RATE: \$0.35 / kWh',
                        style: GoogleFonts.orbitron(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),

                // Gauge: Live Power Draw
                _buildCockpitPanel(
                  'Active Cabinet Draw',
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_currentDraw.toStringAsFixed(1)} kW',
                        style: GoogleFonts.orbitron(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF7B61FF),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'VOLTAGE: 800V V-AMP',
                        style: GoogleFonts.orbitron(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCockpitPanel(String label, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF050816).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.orbitron(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white38,
            ),
          ),
          Expanded(child: Center(child: child)),
        ],
      ),
    );
  }
}

// ==========================================
// 7️⃣ MOBILE APP SHOWCASE
// ==========================================
class MobileAppSection extends StatefulWidget {
  const MobileAppSection({super.key});

  @override
  State<MobileAppSection> createState() => _MobileAppSectionState();
}

class _MobileAppSectionState extends State<MobileAppSection> {
  int _activeScreen = 0;
  final List<String> _screens = [
    'CHARGER MAP LOCATOR',
    'REMOTE TELEMETRY',
    'SCAN & PAY SCANNER',
    'UPI DIGITAL WALLET',
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Container(
      width: double.infinity,
      color: const Color(0xFF050816),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
      child: Column(
        children: [
          Text(
            'MOBILE INTERFACES',
            style: GoogleFonts.orbitron(
              color: const Color(0xFF00D1FF),
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Hyperion Mobile App',
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
              fontSize: isMobile ? 26 : 38,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 60),

          // Main Layout split (Phone on left, tags list on right)
          Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rotating simulated phone
              Container(
                width: 250,
                height: 480,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1120),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: const Color(0xFF00D1FF).withOpacity(0.3),
                    width: 3.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D1FF).withOpacity(0.08),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF050816),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Camera Notch
                      Container(
                        width: 80,
                        height: 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1120),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      const Spacer(),
                      // Display content
                      Icon(
                        _activeScreen == 0 
                            ? Icons.map_outlined 
                            : _activeScreen == 1 
                                ? Icons.analytics_outlined
                                : _activeScreen == 2
                                    ? Icons.qr_code_scanner_sharp
                                    : Icons.account_balance_wallet_outlined,
                        color: const Color(0xFF00FFB2),
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _screens[_activeScreen],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Secure Sandbox Telemetry Active',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, color: Colors.white30),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
              if (!isMobile) const SizedBox(width: 80),
              if (isMobile) const SizedBox(height: 40),

              // Interactive Labels list
              Column(
                crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                children: _screens.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final label = entry.value;
                  final isActive = _activeScreen == idx;
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => setState(() => _activeScreen = idx),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        width: 250,
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFF00D1FF).withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isActive ? const Color(0xFF00D1FF) : Colors.white10,
                          ),
                        ),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.orbitron(
                            color: isActive ? Colors.white : Colors.white38,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 8️⃣ VENDOR & FLEET SECTION
// ==========================================
class VendorFleetSection extends StatelessWidget {
  const VendorFleetSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Container(
      width: double.infinity,
      color: const Color(0xFF050816),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
      child: Column(
        children: [
          Text(
            'BUSINESS CORRIDOR',
            style: GoogleFonts.orbitron(
              color: const Color(0xFF00D1FF),
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Vendor & Corporate Fleet Portal',
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
              fontSize: isMobile ? 26 : 38,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 60),

          Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left: Operator applications card
              _buildPartnerCard(
                'CPO PARTNER WORKSPACE',
                '90% operator payout splits. Integrate billing grids dynamically.',
                Icons.business_center,
                const Color(0xFF00D1FF),
                context,
              ),
              if (!isMobile) const SizedBox(width: 40),
              if (isMobile) const SizedBox(height: 40),

              // Right: Corporate Fleet applications card
              _buildPartnerCard(
                'FLEET CONSOLE WORKSPACE',
                'Track real-time asset coordinates and active route billing indexes.',
                Icons.local_shipping,
                const Color(0xFF00FFB2),
                context,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerCard(String label, String desc, IconData icon, Color color, BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1120).withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 20),
          Text(
            label,
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF9CA3AF),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.go('/dashboard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            child: Text(
              'LAUNCH CONSOLE',
              style: GoogleFonts.orbitron(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 9️⃣ AI ENERGY INTELLIGENCE SECTION
// ==========================================
class EnergyIntelligenceSection extends StatefulWidget {
  const EnergyIntelligenceSection({super.key});

  @override
  State<EnergyIntelligenceSection> createState() => _EnergyIntelligenceSectionState();
}

class _EnergyIntelligenceSectionState extends State<EnergyIntelligenceSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Container(
      width: double.infinity,
      height: 500,
      color: const Color(0xFF050816),
      child: Stack(
        children: [
          // Background custom painter neural networks
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: NeuralNodePainter(animationValue: _controller.value),
                );
              },
            ),
          ),

          // Central HUD layout overlay
          Positioned.fill(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1120).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00FFB2).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'AI INFRASTRUCTURE SHED',
                      style: GoogleFonts.orbitron(
                        color: const Color(0xFF00FFB2),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'AI Energy Grid load-shedding balancer',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Monitors thousands of connected charging stations, adjusting cabinet capacities dynamically on grid fluctuations.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF9CA3AF),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 🔟 DEVELOPER API SECTION
// ==========================================
class DeveloperApiSection extends StatefulWidget {
  const DeveloperApiSection({super.key});

  @override
  State<DeveloperApiSection> createState() => _DeveloperApiSectionState();
}

class _DeveloperApiSectionState extends State<DeveloperApiSection> {
  final List<String> _terminalLogs = [];
  Timer? _timer;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _terminalLogs.add('Ready: Listening to websocket feeds...');
    
    // Simulate real-time streams
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _counter++;
          if (_terminalLogs.length > 8) _terminalLogs.removeAt(1); // Keep clean
          
          final String log = '{"event": "charging_started", "charger": "EV-102${_counter % 5}", "power": "${32 + (_counter % 8) * 8}kW"}';
          _terminalLogs.add('LOG: $log');
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Container(
      width: double.infinity,
      color: const Color(0xFF050816),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
      child: Column(
        children: [
          Text(
            'DEVELOPER PORTAL',
            style: GoogleFonts.orbitron(
              color: const Color(0xFF00D1FF),
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Websocket Command Line UI',
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
              fontSize: isMobile ? 26 : 38,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 60),

          // Terminal console visual
          Container(
            constraints: const BoxConstraints(maxWidth: 800),
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1120),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00D1FF).withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D1FF).withOpacity(0.04),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top control indicators
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.amberAccent, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
                    const Spacer(),
                    Text('hyperion_bash', style: GoogleFonts.orbitron(fontSize: 10, color: Colors.white30)),
                  ],
                ),
                const SizedBox(height: 24),
                // Terminal logs display
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _terminalLogs.map((log) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        log,
                        style: GoogleFonts.orbitron(
                          color: const Color(0xFF00D1FF),
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 1️⃣1️⃣ FINAL CTA SECTION
// ==========================================
class FinalCtaSection extends StatelessWidget {
  const FinalCtaSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Container(
      width: double.infinity,
      color: const Color(0xFF050816),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1120).withOpacity(0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF00FFB2).withOpacity(0.15),
            ),
          ),
          child: Column(
            children: [
              Text(
                'BUILD THE FUTURE OF SMART MOBILITY',
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  fontSize: isMobile ? 24 : 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Integrate and scale charging infrastructures using the most intelligent clean energy network.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: const Color(0xFF9CA3AF),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.go('/dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D1FF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 22),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: Text(
                  'LAUNCH PLATFORM NOW',
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 1️⃣2️⃣ LANDING FOOTER
// ==========================================
class LandingFooter extends StatelessWidget {
  const LandingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Container(
      width: double.infinity,
      color: const Color(0xFF050816),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Column(
        children: [
          Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo vision
              Column(
                crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                children: [
                  Text(
                    'HYPERION',
                    style: GoogleFonts.orbitron(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Smart clean energy grid operators system.', style: TextStyle(fontSize: 12, color: Colors.white38)),
                ],
              ),
              if (isMobile) const SizedBox(height: 40),

              // Links directory
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFooterLink('Ecosystem'),
                  const SizedBox(width: 24),
                  _buildFooterLink('OCPP Docs'),
                  const SizedBox(width: 24),
                  _buildFooterLink('Privacy'),
                  const SizedBox(width: 24),
                  _buildFooterLink('Careers'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Divider(color: Colors.white10),
          const SizedBox(height: 20),
          Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© ${DateTime.now().year} Hyperion Energy Inc.',
                style: const TextStyle(fontSize: 11, color: Colors.white30),
              ),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Icon(Icons.energy_savings_leaf, color: Color(0xFF00FFB2), size: 14),
                  SizedBox(width: 6),
                  Text('100% Carbon Neutral Fleet & Servers', style: TextStyle(fontSize: 11, color: Color(0xFF00FFB2))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String label) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: const Color(0xFF9CA3AF),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
