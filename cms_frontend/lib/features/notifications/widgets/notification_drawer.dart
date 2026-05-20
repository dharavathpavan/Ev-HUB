import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../notification_provider.dart';

class NotificationDrawer extends StatefulWidget {
  const NotificationDrawer({super.key});

  @override
  State<NotificationDrawer> createState() => _NotificationDrawerState();
}

class _NotificationDrawerState extends State<NotificationDrawer> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        final all = provider.notifications;
        final unread = all.where((n) => n['is_read'] == false).toList();
        final critical = all.where((n) => n['priority'] == 'critical' || n['priority'] == 'high').toList();

        return Container(
          width: 420,
          decoration: const BoxDecoration(
            color: Color(0xFF141414),
            border: Border(left: BorderSide(color: Color(0xFF2A2A2A))),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      const Icon(Icons.notifications_active, color: Color(0xFF4ADDA2)),
                      const SizedBox(width: 12),
                      const Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      if (provider.unreadCount > 0) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(50)),
                          child: Text('${provider.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ]
                    ]),
                    Row(children: [
                      TextButton(
                        onPressed: provider.markAllAsRead,
                        child: const Text('Mark all read', style: TextStyle(color: Color(0xFF4ADDA2), fontSize: 12)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.open_in_full, color: Color(0xFF8A8A8A), size: 18),
                        tooltip: 'Open full center',
                        onPressed: () {
                          Scaffold.of(context).closeEndDrawer();
                          context.push('/notifications');
                        },
                      ),
                    ]),
                  ],
                ),
              ),

              // Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFF4ADDA2),
                  labelColor: const Color(0xFF4ADDA2),
                  unselectedLabelColor: const Color(0xFF8A8A8A),
                  indicatorWeight: 2,
                  tabs: [
                    Tab(text: 'All (${all.length})'),
                    Tab(text: 'Unread (${unread.length})'),
                    Tab(text: 'Critical (${critical.length})'),
                  ],
                ),
              ),

              const Divider(color: Color(0xFF2A2A2A), height: 1),

              // Notification Lists
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(all, provider),
                    _buildList(unread, provider),
                    _buildList(critical, provider),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items, NotificationProvider provider) {
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, color: Color(0xFF2A2A2A), size: 48),
            SizedBox(height: 12),
            Text('All caught up!', style: TextStyle(color: Color(0xFF8A8A8A))),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(color: Color(0xFF2A2A2A), height: 1),
      itemBuilder: (context, index) => _NotifCard(
        notif: items[index],
        onRead: () => provider.markAsRead(items[index]['id']),
        onDelete: () => provider.deleteNotification(items[index]['id']),
        onAction: () {
          final route = items[index]['action_route'] as String?;
          if (route != null) {
            provider.markAsRead(items[index]['id']);
            Scaffold.of(context).closeEndDrawer();
            context.push(route);
          }
        },
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final Map<String, dynamic> notif;
  final VoidCallback onRead;
  final VoidCallback onDelete;
  final VoidCallback onAction;

  const _NotifCard({required this.notif, required this.onRead, required this.onDelete, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final isRead = notif['is_read'] == true;
    final type = notif['type'] as String? ?? 'system';
    final priority = notif['priority'] as String? ?? 'normal';
    final createdAt = DateTime.tryParse(notif['created_at'] ?? '') ?? DateTime.now();
    final timeAgo = _timeAgo(createdAt);

    final typeConfig = _typeConfig(type);
    final priorityColor = _priorityColor(priority);

    return InkWell(
      onTap: onAction,
      child: Container(
        color: isRead ? Colors.transparent : const Color(0xFF4ADDA2).withValues(alpha: 0.04),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type Icon
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: (typeConfig['color'] as Color).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(typeConfig['icon'] as IconData, color: typeConfig['color'] as Color, size: 20),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Text(notif['title'] ?? '', style: TextStyle(color: Colors.white, fontWeight: isRead ? FontWeight.normal : FontWeight.bold, fontSize: 14))),
                    if (priority == 'critical' || priority == 'high')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: priorityColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                        child: Text(priority.toUpperCase(), style: TextStyle(color: priorityColor, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                  ]),
                  const SizedBox(height: 4),
                  Text(notif['body'] ?? '', style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(children: [
                    Text(timeAgo, style: const TextStyle(color: Color(0xFF5A5A5A), fontSize: 11)),
                    const Spacer(),
                    if (!isRead)
                      GestureDetector(onTap: onRead, child: const Text('Mark read', style: TextStyle(color: Color(0xFF4ADDA2), fontSize: 11))),
                    const SizedBox(width: 12),
                    GestureDetector(onTap: onDelete, child: const Icon(Icons.close, color: Color(0xFF5A5A5A), size: 14)),
                  ]),
                ],
              ),
            ),

            // Unread dot
            if (!isRead)
              Container(width: 8, height: 8, margin: const EdgeInsets.only(left: 8, top: 4), decoration: const BoxDecoration(color: Color(0xFF4ADDA2), shape: BoxShape.circle)),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d').format(dt);
  }

  Map<String, dynamic> _typeConfig(String type) {
    switch (type) {
      case 'fault': return {'icon': Icons.warning_amber, 'color': Colors.redAccent};
      case 'payment': return {'icon': Icons.credit_card, 'color': Colors.purpleAccent};
      case 'refund': return {'icon': Icons.currency_exchange, 'color': Colors.amber};
      case 'vendor': return {'icon': Icons.storefront, 'color': Colors.blueAccent};
      case 'session': return {'icon': Icons.bolt, 'color': const Color(0xFF4ADDA2)};
      default: return {'icon': Icons.settings, 'color': Colors.grey};
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'critical': return Colors.redAccent;
      case 'high': return Colors.orange;
      case 'low': return Colors.grey;
      default: return Colors.blueAccent;
    }
  }
}
