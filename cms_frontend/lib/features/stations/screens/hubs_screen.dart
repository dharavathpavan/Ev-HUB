import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class HubsScreen extends StatefulWidget {
  const HubsScreen({super.key});

  @override
  State<HubsScreen> createState() => _HubsScreenState();
}

class _HubsScreenState extends State<HubsScreen> {
  late final Stream<List<Map<String, dynamic>>> _hubsStream;

  @override
  void initState() {
    super.initState();
    _hubsStream = Supabase.instance.client
        .from('hubs')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
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
                'Hub & Regional Management',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Create New Hub', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
          const SizedBox(height: 40),

          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _hubsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator(color: Color(0xFF4ADDA2))));
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text('Error loading Hubs. Please run the Hubs SQL script.', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
                  ),
                );
              }

              final hubs = snapshot.data ?? [];

              if (hubs.isEmpty) {
                return const Center(child: Text('No regional hubs found.', style: TextStyle(color: Color(0xFF8A8A8A))));
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 1.1,
                ),
                itemCount: hubs.length,
                itemBuilder: (context, index) {
                  return _HubCard(hub: hubs[index]);
                },
              );
            },
          )
        ],
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  final Map<String, dynamic> hub;

  const _HubCard({required this.hub});

  Widget _buildStatusBadge(String status) {
    Color bgColor = const Color(0xFF4ADDA2).withOpacity(0.1);
    Color textColor = const Color(0xFF4ADDA2);

    if (status == 'Under Maintenance') {
      bgColor = const Color(0xFFFFD700).withOpacity(0.1);
      textColor = const Color(0xFFFFD700);
    } else if (status == 'Offline') {
      bgColor = Colors.redAccent.withOpacity(0.1);
      textColor = Colors.redAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(50), border: Border.all(color: textColor.withOpacity(0.2))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: textColor, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(status, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.hub, color: Colors.white, size: 28),
              ),
              _buildStatusBadge(hub['status'] ?? 'Operational'),
            ],
          ),
          const Spacer(),
          Text(hub['name'] ?? 'Unknown Hub', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF8A8A8A), size: 16),
              const SizedBox(width: 4),
              Text(hub['region'] ?? 'Unknown Region', style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, width: double.infinity, color: const Color(0xFF2A2A2A)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hub Manager', style: TextStyle(color: Color(0xFF5A5A5A), fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const CircleAvatar(radius: 12, backgroundColor: Color(0xFF4ADDA2), child: Icon(Icons.person, size: 16, color: Colors.black)),
                      const SizedBox(width: 8),
                      Text(hub['manager_name'] ?? 'Unassigned', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => context.go('/stations'), // Route to the redesigned Stations dashboard
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A2A2A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('View Stations'),
              )
            ],
          )
        ],
      ),
    );
  }
}
