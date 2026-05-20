import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class StationsScreen extends StatefulWidget {
  const StationsScreen({super.key});

  @override
  State<StationsScreen> createState() => _StationsScreenState();
}

class _StationsScreenState extends State<StationsScreen> {
  final _stationsFuture = Supabase.instance.client
      .from('stations')
      .select('*, rate_cards(*)')
      .order('created_at', ascending: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'EV Station Hubs',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ADDA2),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.add_location_alt),
                  label: const Text('Deploy New Hub', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Filters / Search Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search by hub name, ID, or geolocation...',
                      hintStyle: const TextStyle(color: Color(0xFF8A8A8A)),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF8A8A8A)),
                      filled: true,
                      fillColor: const Color(0xFF141414),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.tune, color: Colors.white),
                    onPressed: () {},
                  ),
                )
              ],
            ),
            const SizedBox(height: 40),

            // Responsive Grid of Station Cards
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _stationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF4ADDA2)));
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Database Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  );
                }

                final stations = snapshot.data ?? [];

                if (stations.isEmpty) {
                  return const Center(child: Text('No station hubs deployed yet.', style: TextStyle(color: Color(0xFF8A8A8A))));
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 450, // max width of a card
                    mainAxisSpacing: 32,
                    crossAxisSpacing: 32,
                    childAspectRatio: 0.8, // Adjust height
                  ),
                  itemCount: stations.length,
                  itemBuilder: (context, index) {
                    final station = stations[index];
                    return _StationCard(station: station);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StationCard extends StatefulWidget {
  final Map<String, dynamic> station;
  const _StationCard({required this.station});

  @override
  State<_StationCard> createState() => _StationCardState();
}

class _StationCardState extends State<_StationCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final status = widget.station['status'] ?? 'Offline';
    final rateCard = widget.station['rate_cards'];
    final priceStr = rateCard != null ? '\$${rateCard['per_kwh_fee']}/kWh' : 'Free Charging';

    Color statusColor = Colors.grey;
    if (status == 'Online') statusColor = const Color(0xFF4ADDA2);
    if (status == 'Faulted') statusColor = Colors.redAccent;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: () => context.go('/stations/${widget.station['station_id']}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, isHovered ? -8 : 0, 0),
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isHovered ? const Color(0xFF4ADDA2).withOpacity(0.5) : const Color(0xFF2A2A2A)),
            boxShadow: isHovered
                ? [BoxShadow(color: const Color(0xFF4ADDA2).withOpacity(0.1), blurRadius: 20, spreadRadius: 5)]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Mock Map Header
              Expanded(
                flex: 4,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Realistic 3D Station Image
                      Image.asset(
                        'assets/images/demo_station.png',
                        fit: BoxFit.cover,
                      ),
                      // Dark gradient overlay so text remains readable
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.8)],
                          ),
                        ),
                      ),
                      // 3D Location Pin
                      Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.elasticOut,
                          transform: Matrix4.translationValues(0, isHovered ? -10 : 0, 0),
                          child: Icon(
                            Icons.location_on,
                            size: 64,
                            color: statusColor,
                            shadows: [
                              Shadow(color: statusColor.withOpacity(0.6), blurRadius: 15, offset: const Offset(0, 10))
                            ],
                          ),
                        ),
                      ),
                      // Price Badge overlay
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: const Color(0xFF4ADDA2).withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.payments, color: Color(0xFF4ADDA2), size: 14),
                              const SizedBox(width: 6),
                              Text(priceStr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Content details
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.station['name'] ?? 'Unknown Hub',
                                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(color: statusColor),
                                ),
                                child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.pin_drop, color: Color(0xFF8A8A8A), size: 14),
                              const SizedBox(width: 4),
                              Text(widget.station['location'] ?? 'Location N/A', style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      
                      // Metrics
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0A0A),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMiniMetric(Icons.ev_station, '${widget.station['chargers'] ?? 0}', 'Chargers'),
                            _buildMiniMetric(Icons.analytics, '\$${widget.station['revenue'] ?? '0.0'}', 'Daily Rev'),
                            _buildMiniMetric(Icons.cable, 'DC/AC', 'Types'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniMetric(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF4ADDA2), size: 20),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Color(0xFF5A5A5A), fontSize: 10)),
      ],
    );
  }
}

