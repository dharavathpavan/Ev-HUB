import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;
  RealtimeChannel? _channel;

  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => n['is_read'] == false).length;
  bool get isLoading => _isLoading;

  NotificationProvider() {
    _init();
  }

  Future<void> _init() async {
    await _fetchAll();
    _subscribeRealtime();
  }

  Future<void> _fetchAll() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await Supabase.instance.client
          .from('notifications')
          .select()
          .order('created_at', ascending: false)
          .limit(100);
      _notifications = List<Map<String, dynamic>>.from(data);
    } catch (_) {
      // Table may not exist yet — use mock data for demo
      _notifications = _mockNotifications();
    }
    _isLoading = false;
    notifyListeners();
  }

  void _subscribeRealtime() {
    _channel = Supabase.instance.client
        .channel('notifications_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          callback: (payload) {
            final newNotif = Map<String, dynamic>.from(payload.newRecord);
            _notifications.insert(0, newNotif);
            notifyListeners();
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'notifications',
          callback: (payload) {
            final updated = Map<String, dynamic>.from(payload.newRecord);
            final idx = _notifications.indexWhere((n) => n['id'] == updated['id']);
            if (idx != -1) {
              _notifications[idx] = updated;
              notifyListeners();
            }
          },
        )
        .subscribe();
  }

  Future<void> markAsRead(String id) async {
    try {
      await Supabase.instance.client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', id);
    } catch (_) {}
    // Optimistic update
    final idx = _notifications.indexWhere((n) => n['id'] == id);
    if (idx != -1) {
      _notifications[idx] = {..._notifications[idx], 'is_read': true};
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await Supabase.instance.client
          .from('notifications')
          .update({'is_read': true})
          .eq('is_read', false);
    } catch (_) {}
    _notifications = _notifications.map((n) => {...n, 'is_read': true}).toList();
    notifyListeners();
  }

  Future<void> deleteNotification(String id) async {
    try {
      await Supabase.instance.client.from('notifications').delete().eq('id', id);
    } catch (_) {}
    _notifications.removeWhere((n) => n['id'] == id);
    notifyListeners();
  }

  Future<void> refresh() => _fetchAll();

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  // Mock data for demo when table doesn't exist
  List<Map<String, dynamic>> _mockNotifications() => [
    {'id': 'notif-001', 'title': 'Critical Hardware Fault', 'body': 'Thermal overload on CHR-002 Gun 1 at HUB-Downtown.', 'type': 'fault', 'priority': 'critical', 'is_read': false, 'action_route': '/stations', 'created_at': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String()},
    {'id': 'notif-002', 'title': 'New Vendor Registration', 'body': 'TechCharge Pvt Ltd has submitted a vendor registration request.', 'type': 'vendor', 'priority': 'high', 'is_read': false, 'action_route': '/users', 'created_at': DateTime.now().subtract(const Duration(minutes: 22)).toIso8601String()},
    {'id': 'notif-003', 'title': 'Payment Captured', 'body': 'Razorpay payment ₹450.00 captured for John Doe — Session SESS-8821.', 'type': 'payment', 'priority': 'normal', 'is_read': false, 'action_route': '/payments', 'created_at': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String()},
    {'id': 'notif-004', 'title': 'Refund Requested', 'body': 'Alice Johnson requested a refund of ₹120.00 for Session SESS-8800.', 'type': 'refund', 'priority': 'high', 'is_read': false, 'action_route': '/users', 'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String()},
    {'id': 'notif-005', 'title': 'Session Started', 'body': 'Ravi Kumar started charging at HUB-Westside Gun 2 (CCS2 — 150kW).', 'type': 'session', 'priority': 'normal', 'is_read': true, 'action_route': '/sessions', 'created_at': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String()},
    {'id': 'notif-006', 'title': 'AI Grid Intervention', 'body': 'Load balancer throttled 3 chargers at HUB-Downtown during peak demand.', 'type': 'system', 'priority': 'normal', 'is_read': true, 'action_route': '/ai_monitoring', 'created_at': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String()},
    {'id': 'notif-007', 'title': 'Booking Confirmed', 'body': 'Slot BK-00441 booked for Priya Sharma at HUB-Uptown-04 tomorrow 10AM.', 'type': 'session', 'priority': 'low', 'is_read': true, 'action_route': '/bookings', 'created_at': DateTime.now().subtract(const Duration(hours: 8)).toIso8601String()},
  ];
}
