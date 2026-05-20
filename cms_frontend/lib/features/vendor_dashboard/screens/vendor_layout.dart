import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VendorLayout extends StatefulWidget {
  final Widget child;
  const VendorLayout({super.key, required this.child});

  @override
  State<VendorLayout> createState() => _VendorLayoutState();
}

class _VendorLayoutState extends State<VendorLayout> {
  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Overview', 'route': '/vendor-dashboard', 'icon': Icons.dashboard_outlined},
    {'title': 'Stations', 'route': '/vendor-dashboard/stations', 'icon': Icons.ev_station_outlined},
    {'title': 'Bookings', 'route': '/vendor-dashboard/bookings', 'icon': Icons.book_online_outlined},
    {'title': 'Payments', 'route': '/vendor-dashboard/payments', 'icon': Icons.account_balance_wallet_outlined},
    {'title': 'Settings', 'route': '/vendor-dashboard/settings', 'icon': Icons.settings_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return Scaffold(
      body: Row(
        children: [
          // ── Sidebar ───────────────────────────────────────────────────
          Container(
            width: 260,
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Row(children: [
                    Icon(Icons.business, color: Theme.of(context).colorScheme.primary, size: 28),
                    const SizedBox(width: 8),
                    const Text('VENDOR', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
                  ]),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: ListView.builder(
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      final item = _menuItems[index];
                      // Exact match for overview, startsWith for others to highlight correctly
                      final isSelected = item['route'] == '/vendor-dashboard' 
                          ? location == '/vendor-dashboard' 
                          : location.startsWith(item['route']);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: InkWell(
                          onTap: () => context.go(item['route']),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                            ),
                            child: ListTile(
                              leading: Icon(item['icon'],
                                  color: isSelected ? Theme.of(context).colorScheme.primary : const Color(0xFF8A8A8A), size: 22),
                              title: Text(item['title'],
                                  style: TextStyle(
                                    color: isSelected ? Theme.of(context).colorScheme.primary : const Color(0xFF8A8A8A),
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    fontSize: 15,
                                  )),
                              selected: isSelected,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                              dense: true,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Profile section
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(children: [
                    const CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=33')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ChargePoint', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                          const Text('Vendor Admin', style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Color(0xFF8A8A8A), size: 20),
                      onPressed: () {
                        // TODO: Implement logout logic
                        context.go('/login');
                      },
                    )
                  ]),
                ),
              ],
            ),
          ),

          // ── Main Content ──────────────────────────────────────────────
          Expanded(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                children: [
                  // Top bar with notification bell
                  Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: const Border(bottom: BorderSide(color: Color(0xFF2A2A2A))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 16),
                        const CircleAvatar(radius: 18, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=33')),
                      ],
                    ),
                  ),

                  // Page content
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
