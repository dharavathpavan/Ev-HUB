import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VendorLayout extends StatelessWidget {
  final Widget child;
  const VendorLayout({super.key, required this.child});

  static const _tabs = [
    {'title': 'Overview', 'route': '/vendor-dashboard', 'icon': Icons.dashboard_outlined},
    {'title': 'Charging', 'route': '/vendor-dashboard/charging', 'icon': Icons.bolt},
    {'title': 'Chargers', 'route': '/vendor-dashboard/stations', 'icon': Icons.ev_station_outlined},
    {'title': 'Sessions', 'route': '/vendor-dashboard/sessions', 'icon': Icons.timeline},
    {'title': 'Billing', 'route': '/vendor-dashboard/payments', 'icon': Icons.account_balance_wallet_outlined},
    {'title': 'Settings', 'route': '/vendor-dashboard/settings', 'icon': Icons.settings_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 76,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              decoration: const BoxDecoration(
                color: Color(0xFF141414),
                border: Border(bottom: BorderSide(color: Color(0xFF2A2A2A))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4ADDA2).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.business, color: Color(0xFF4ADDA2)),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vendor Console', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                      Text('ChargePoint Vendor Admin', style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  _VendorTopAction(
                    icon: Icons.notifications_outlined,
                    onTap: () {},
                  ),
                  const SizedBox(width: 12),
                  _VendorTopAction(
                    icon: Icons.logout,
                    onTap: () => context.go('/login'),
                  ),
                ],
              ),
            ),
            Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              color: const Color(0xFF101010),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = _tabs[index];
                  final route = item['route'] as String;
                  final selected = route == '/vendor-dashboard' ? location == route : location.startsWith(route);

                  return Center(
                    child: InkWell(
                      onTap: () => context.go(route),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFF4ADDA2).withOpacity(0.14) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: selected ? const Color(0xFF4ADDA2).withOpacity(0.35) : Colors.transparent),
                        ),
                        child: Row(
                          children: [
                            Icon(item['icon'] as IconData, size: 18, color: selected ? const Color(0xFF4ADDA2) : const Color(0xFF8A8A8A)),
                            const SizedBox(width: 8),
                            Text(
                              item['title'] as String,
                              style: TextStyle(
                                color: selected ? const Color(0xFF4ADDA2) : const Color(0xFFB0B0B0),
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _VendorTopAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _VendorTopAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF242424),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
