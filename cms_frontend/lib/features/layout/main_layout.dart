import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../notifications/notification_provider.dart';
import '../notifications/widgets/notification_drawer.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Dashboard', 'route': '/dashboard', 'icon': Icons.dashboard_outlined},
    {'title': 'Hubs', 'route': '/hubs', 'icon': Icons.hub_outlined},
    {'title': 'Stations', 'route': '/stations', 'icon': Icons.ev_station_outlined},
    {'title': 'Chargers', 'route': '/chargers', 'icon': Icons.battery_charging_full_outlined},
    {'title': 'Onboarding', 'route': '/onboarding', 'icon': Icons.router_outlined},
    {'title': 'Vendor Portal', 'route': '/vendor-portal', 'icon': Icons.business_outlined},
    {'title': 'Sessions', 'route': '/sessions', 'icon': Icons.timeline_outlined},
    {'title': 'Bookings', 'route': '/bookings', 'icon': Icons.book_online_outlined},
    {'title': 'Users', 'route': '/users', 'icon': Icons.people_outline},
    {'title': 'Fleet', 'route': '/fleet', 'icon': Icons.local_shipping_outlined},
    {'title': 'Payments', 'route': '/payments', 'icon': Icons.payment_outlined},
    {'title': 'Analytics', 'route': '/analytics', 'icon': Icons.analytics_outlined},
    {'title': 'Maps', 'route': '/maps', 'icon': Icons.map_outlined},
    {'title': 'Alerts', 'route': '/alerts', 'icon': Icons.warning_amber_outlined},
    {'title': 'Notifications', 'route': '/notifications', 'icon': Icons.notifications_outlined},
    {'title': 'Support', 'route': '/support', 'icon': Icons.support_agent_outlined},
    {'title': 'AI Monitoring', 'route': '/ai_monitoring', 'icon': Icons.smart_toy_outlined},
    {'title': 'Reports', 'route': '/reports', 'icon': Icons.picture_as_pdf_outlined},
    {'title': 'Settings', 'route': '/settings', 'icon': Icons.settings_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    if (location.startsWith('/vendor-dashboard')) {
      return widget.child;
    }

    return Consumer<NotificationProvider>(
      builder: (context, notifProvider, _) {
        return Scaffold(
          key: _scaffoldKey,
          endDrawer: const NotificationDrawer(),
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
                        Icon(Icons.bolt, color: Theme.of(context).colorScheme.primary, size: 28),
                        const SizedBox(width: 8),
                        const Text('EV HUB', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
                      ]),
                    ),
                    const SizedBox(height: 40),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _menuItems.length,
                        itemBuilder: (context, index) {
                          final item = _menuItems[index];
                          final isSelected = location.startsWith(item['route']);
                          final isNotif = item['route'] == '/notifications';

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
                                  trailing: isNotif && notifProvider.unreadCount > 0
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(50)),
                                          child: Text('${notifProvider.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                        )
                                      : null,
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
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Row(children: [
                        CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11')),
                        SizedBox(width: 12),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Super Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text('EV Hub Global', style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                        ]),
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
                            // Bell icon with animated badge
                            GestureDetector(
                              onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(10)),
                                    child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                                  ),
                                  if (notifProvider.unreadCount > 0)
                                    Positioned(
                                      top: -4, right: -4,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                                        child: Text(
                                          notifProvider.unreadCount > 99 ? '99+' : '${notifProvider.unreadCount}',
                                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            const CircleAvatar(radius: 18, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11')),
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
      },
    );
  }
}
