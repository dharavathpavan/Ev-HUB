import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final MapController _mapController = MapController();
  late final Stream<List<Map<String, dynamic>>> _hubsStream;
  Map<String, dynamic>? _selectedHub;

  @override
  void initState() {
    super.initState();
    _hubsStream = Supabase.instance.client
        .from('hubs')
        .stream(primaryKey: ['id']);
  }

  void _onHubTapped(Map<String, dynamic> hub) {
    setState(() {
      _selectedHub = hub;
    });
    // Optional: pan camera to the selected hub
    // double lat = double.tryParse(hub['latitude']?.toString() ?? '0') ?? 0;
    // double lng = double.tryParse(hub['longitude']?.toString() ?? '0') ?? 0;
    // _mapController.move(LatLng(lat, lng), 13.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // The Map Layer
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _hubsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF4ADDA2)));
              }

              final hubs = snapshot.data ?? [];
              // Default center (San Francisco roughly if no hubs, or center on first hub)
              LatLng initialCenter = const LatLng(37.7749, -122.4194);
              if (hubs.isNotEmpty) {
                final firstLat = double.tryParse(hubs[0]['latitude']?.toString() ?? '37.77') ?? 37.7749;
                final firstLng = double.tryParse(hubs[0]['longitude']?.toString() ?? '-122.41') ?? -122.4194;
                initialCenter = LatLng(firstLat, firstLng);
              }

              final markers = hubs.map((hub) {
                final lat = double.tryParse(hub['latitude']?.toString() ?? '0') ?? 0;
                final lng = double.tryParse(hub['longitude']?.toString() ?? '0') ?? 0;
                final isSelected = _selectedHub != null && _selectedHub!['id'] == hub['id'];
                
                // Color code by status
                Color markerColor = Colors.grey;
                final status = hub['status'] ?? 'Operational';
                if (status == 'Operational') markerColor = const Color(0xFF4ADDA2);
                if (status == 'Under Maintenance') markerColor = Colors.orange;
                if (status == 'Offline') markerColor = Colors.redAccent;

                return Marker(
                  point: LatLng(lat, lng),
                  width: 50,
                  height: 50,
                  child: GestureDetector(
                    onTap: () => _onHubTapped(hub),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: markerColor.withValues(alpha: isSelected ? 0.3 : 0.1),
                        border: Border.all(color: markerColor, width: isSelected ? 3 : 1),
                      ),
                      child: Center(
                        child: Icon(Icons.ev_station, color: markerColor, size: isSelected ? 32 : 24),
                      ),
                    ),
                  ),
                );
              }).toList();

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: 10.0,
                  onTap: (tapPosition, point) {
                    // Deselect if tapping empty space
                    if (_selectedHub != null) {
                      setState(() => _selectedHub = null);
                    }
                  },
                ),
                children: [
                  TileLayer(
                    // Using standard OSM (OpenStreetMap)
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.ev_cms',
                    // Apply a dark mode color filter to standard tiles
                    tileBuilder: (context, tileWidget, tile) {
                      return ColorFiltered(
                        colorFilter: const ColorFilter.matrix([
                          -1,  0,  0, 0, 255,
                           0, -1,  0, 0, 255,
                           0,  0, -1, 0, 255,
                           0,  0,  0, 1,   0,
                        ]),
                        child: tileWidget,
                      );
                    },
                  ),
                  MarkerLayer(markers: markers),
                ],
              );
            },
          ),

          // Header Overlay
          Positioned(
            top: 40,
            left: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2A2A2A)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Live Map Dashboard', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('Select a hub to view live telemetry.', style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 14)),
                ],
              ),
            ),
          ),

          // Hub Detail Side Panel Overlay
          if (_selectedHub != null)
            Positioned(
              right: 40,
              top: 40,
              bottom: 40,
              width: 400,
              child: _buildDetailPanel(),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailPanel() {
    final status = _selectedHub!['status'] ?? 'Unknown';
    Color statusColor = Colors.grey;
    if (status == 'Operational') statusColor = const Color(0xFF4ADDA2);
    if (status == 'Under Maintenance') statusColor = Colors.orange;
    if (status == 'Offline') statusColor = Colors.redAccent;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141414).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2A2A2A)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 15, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          // Image / Header area
          Container(
            height: 200,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1593941707882-a5bba14938c7?auto=format&fit=crop&q=80&w=800'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => setState(() => _selectedHub = null),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF0F0F0F).withValues(alpha: 0.8), borderRadius: BorderRadius.circular(50)),
                    child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                )
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selectedHub!['name'] ?? 'Unnamed Hub', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF8A8A8A), size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_selectedHub!['address'] ?? 'No address provided', style: const TextStyle(color: Color(0xFF8A8A8A)))),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // KPI row
                  Row(
                    children: [
                      Expanded(
                        child: _buildSmallKPI('Total Chargers', '${_selectedHub!['total_chargers'] ?? 0}'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSmallKPI('Max Capacity', '${_selectedHub!['max_capacity_kw'] ?? 0} kW'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  const Text('Coordinates', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Lat: ${_selectedHub!['latitude']}', style: const TextStyle(color: Color(0xFF8A8A8A), fontFamily: 'monospace')),
                  Text('Lng: ${_selectedHub!['longitude']}', style: const TextStyle(color: Color(0xFF8A8A8A), fontFamily: 'monospace')),
                ],
              ),
            ),
          ),
          
          // Action Bottom
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push('/hubs'); // Route to hubs management
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ADDA2),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.settings),
                label: const Text('Manage Hub Details', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSmallKPI(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
