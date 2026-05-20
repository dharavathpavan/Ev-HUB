import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _search = '';
  String _filterType = 'All';
  final List<String> _types = ['All', 'fault', 'payment', 'refund', 'vendor', 'session', 'system'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          // Filter + search
          var items = provider.notifications.where((n) {
            final matchSearch = _search.isEmpty ||
                (n['title'] as String? ?? '').toLowerCase().contains(_search.toLowerCase()) ||
                (n['body'] as String? ?? '').toLowerCase().contains(_search.toLowerCase());
            final matchType = _filterType == 'All' || n['type'] == _filterType;
            return matchSearch && matchType;
          }).toList();

          // Group by date
          final Map<String, List<Map<String, dynamic>>> grouped = {};
          for (final n in items) {
            final dt = DateTime.tryParse(n['created_at'] ?? '') ?? DateTime.now();
            final key = _dateLabel(dt);
            grouped.putIfAbsent(key, () => []).add(n);
          }

          return Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Notification Center', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${provider.unreadCount} unread · ${provider.notifications.length} total', style: const TextStyle(color: Color(0xFF8A8A8A))),
                  ]),
                  Row(children: [
                    OutlinedButton.icon(
                      onPressed: provider.markAllAsRead,
                      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF4ADDA2), side: const BorderSide(color: Color(0xFF4ADDA2)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      icon: const Icon(Icons.done_all, size: 16),
                      label: const Text('Mark All Read'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: provider.refresh,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2A2A2A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Refresh'),
                    ),
                  ]),
                ]),
                const SizedBox(height: 32),

                // KPI Row
                Row(children: [
                  _buildKpi('Total', '${provider.notifications.length}', Icons.notifications, Colors.white),
                  const SizedBox(width: 16),
                  _buildKpi('Unread', '${provider.unreadCount}', Icons.mark_email_unread, const Color(0xFF4ADDA2)),
                  const SizedBox(width: 16),
                  _buildKpi('Critical', '${provider.notifications.where((n) => n['priority'] == 'critical').length}', Icons.warning_amber, Colors.redAccent),
                  const SizedBox(width: 16),
                  _buildKpi('Pending Actions', '${provider.notifications.where((n) => n['is_read'] == false && (n['type'] == 'refund' || n['type'] == 'vendor')).length}', Icons.pending_actions, Colors.orange),
                ]),
                const SizedBox(height: 32),

                // Search + Filter
                Row(children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search notifications...',
                        hintStyle: const TextStyle(color: Color(0xFF8A8A8A)),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF8A8A8A)),
                        filled: true,
                        fillColor: const Color(0xFF141414),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      onChanged: (v) => setState(() => _search = v),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Type filter chips
                  Wrap(
                    spacing: 8,
                    children: _types.map((t) {
                      final isSelected = _filterType == t;
                      return ChoiceChip(
                        label: Text(t == 'All' ? 'All' : t, style: TextStyle(color: isSelected ? Colors.black : const Color(0xFF8A8A8A), fontSize: 12)),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _filterType = t),
                        selectedColor: const Color(0xFF4ADDA2),
                        backgroundColor: const Color(0xFF141414),
                        side: const BorderSide(color: Color(0xFF2A2A2A)),
                      );
                    }).toList(),
                  ),
                ]),
                const SizedBox(height: 24),

                // Notification list grouped by date
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF4ADDA2)))
                      : grouped.isEmpty
                          ? const Center(child: Text('No notifications found.', style: TextStyle(color: Color(0xFF8A8A8A))))
                          : ListView(
                              children: grouped.entries.map((entry) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      child: Text(entry.key, style: const TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold, fontSize: 13)),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF141414),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: const Color(0xFF2A2A2A)),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Column(
                                          children: entry.value.asMap().entries.map((e) {
                                            final isLast = e.key == entry.value.length - 1;
                                            return Column(children: [
                                              _BigNotifTile(
                                                notif: e.value,
                                                onRead: () => provider.markAsRead(e.value['id']),
                                                onDelete: () => provider.deleteNotification(e.value['id']),
                                                onAction: () {
                                                  final route = e.value['action_route'] as String?;
                                                  if (route != null) {
                                                    provider.markAsRead(e.value['id']);
                                                    context.push(route);
                                                  }
                                                },
                                              ),
                                              if (!isLast) const Divider(color: Color(0xFF2A2A2A), height: 1),
                                            ]);
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                );
                              }).toList(),
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildKpi(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 11)),
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        ]),
      ]),
    );
  }

  String _dateLabel(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) return 'Today';
    final yesterday = now.subtract(const Duration(days: 1));
    if (dt.year == yesterday.year && dt.month == yesterday.month && dt.day == yesterday.day) return 'Yesterday';
    return DateFormat('MMMM d, yyyy').format(dt);
  }
}

class _BigNotifTile extends StatelessWidget {
  final Map<String, dynamic> notif;
  final VoidCallback onRead;
  final VoidCallback onDelete;
  final VoidCallback onAction;

  const _BigNotifTile({required this.notif, required this.onRead, required this.onDelete, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final isRead = notif['is_read'] == true;
    final type = notif['type'] as String? ?? 'system';
    final priority = notif['priority'] as String? ?? 'normal';
    final typeConfig = _typeConfig(type);

    return InkWell(
      onTap: onAction,
      child: Container(
        color: isRead ? Colors.transparent : const Color(0xFF4ADDA2).withValues(alpha: 0.03),
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: (typeConfig['color'] as Color).withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Icon(typeConfig['icon'] as IconData, color: typeConfig['color'] as Color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(notif['title'] ?? '', style: TextStyle(color: Colors.white, fontWeight: isRead ? FontWeight.w500 : FontWeight.bold, fontSize: 15))),
                  _PriorityBadge(priority),
                  const SizedBox(width: 8),
                  IconButton(icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFF5A5A5A)), onPressed: onDelete, constraints: const BoxConstraints(), padding: EdgeInsets.zero),
                ]),
                const SizedBox(height: 4),
                Text(notif['body'] ?? '', style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 13)),
                const SizedBox(height: 12),
                Row(children: [
                  Icon(Icons.access_time, color: const Color(0xFF5A5A5A), size: 13),
                  const SizedBox(width: 4),
                  Text(_formatTime(notif['created_at']), style: const TextStyle(color: Color(0xFF5A5A5A), fontSize: 12)),
                  const Spacer(),
                  if (!isRead)
                    TextButton(onPressed: onRead, child: const Text('Mark as Read', style: TextStyle(color: Color(0xFF4ADDA2), fontSize: 12))),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: onAction,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2A2A2A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), textStyle: const TextStyle(fontSize: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    icon: const Icon(Icons.open_in_new, size: 13),
                    label: const Text('View'),
                  ),
                ]),
              ]),
            ),
            if (!isRead) Container(width: 8, height: 8, margin: const EdgeInsets.only(left: 12, top: 8), decoration: const BoxDecoration(color: Color(0xFF4ADDA2), shape: BoxShape.circle)),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? raw) {
    if (raw == null) return '';
    final dt = DateTime.tryParse(raw)?.toLocal();
    if (dt == null) return '';
    return DateFormat('MMM d, h:mm a').format(dt);
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
}

class _PriorityBadge extends StatelessWidget {
  final String priority;
  const _PriorityBadge(this.priority);

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (priority) {
      case 'critical': color = Colors.redAccent; break;
      case 'high': color = Colors.orange; break;
      case 'low': color = Colors.grey; break;
      default: return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
      child: Text(priority.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
