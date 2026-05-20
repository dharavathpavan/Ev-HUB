import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class UserDetailScreen extends StatefulWidget {
  final String userId;
  const UserDetailScreen({super.key, required this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final Stream<List<Map<String, dynamic>>> _userStream;
  late final Stream<List<Map<String, dynamic>>> _sessionsStream;
  late final Stream<List<Map<String, dynamic>>> _transactionsStream;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    _userStream = Supabase.instance.client
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', widget.userId);

    _sessionsStream = Supabase.instance.client
        .from('sessions')
        .stream(primaryKey: ['session_id'])
        .eq('user_id', widget.userId)
        .order('start_time', ascending: false);

    _transactionsStream = Supabase.instance.client
        .from('transactions')
        .stream(primaryKey: ['transaction_id'])
        .eq('wallet_user_id', widget.userId)
        .order('created_at', ascending: false);
  }

  Future<void> _updateRole(String currentRole) async {
    final roles = ['Customer', 'Fleet Operator', 'Vendor', 'Admin'];
    final newRole = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: const Color(0xFF141414),
        title: const Text('Assign Role', style: TextStyle(color: Colors.white)),
        children: roles.map((r) => SimpleDialogOption(
          onPressed: () => Navigator.pop(context, r),
          child: Text(r, style: TextStyle(color: r == currentRole ? const Color(0xFF4ADDA2) : Colors.white)),
        )).toList(),
      ),
    );

    if (newRole != null && newRole != currentRole) {
      await Supabase.instance.client.from('users').update({'role': newRole}).eq('id', widget.userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Role updated to $newRole'), backgroundColor: const Color(0xFF4ADDA2)));
      }
    }
  }

  Future<void> _processRefund(Map<String, dynamic> transaction) async {
    final maxRefund = double.tryParse(transaction['final_cost']?.toString() ?? '0') ?? 0;
    if (maxRefund <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot refund a zero-cost transaction.')));
      return;
    }

    final refundCtrl = TextEditingController(text: maxRefund.toString());
    
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        title: const Text('Process Refund', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transaction: ${transaction['transaction_id'].toString().substring(0,8)}', style: const TextStyle(color: Color(0xFF8A8A8A))),
            const SizedBox(height: 16),
            TextField(
              controller: refundCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Refund Amount (\$)',
                filled: true,
                fillColor: const Color(0xFF0F0F0F),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                labelStyle: const TextStyle(color: Color(0xFF8A8A8A)),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
            child: const Text('Refund to Wallet'),
          ),
        ],
      ),
    );

    if (proceed == true) {
      final refundAmount = double.tryParse(refundCtrl.text) ?? 0;
      if (refundAmount <= 0 || refundAmount > maxRefund) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid refund amount.'), backgroundColor: Colors.red));
        return;
      }

      try {
        // 1. Update Transaction status
        await Supabase.instance.client.from('transactions').update({
          'status': 'Refunded',
          'refunded_amount': refundAmount
        }).eq('transaction_id', transaction['transaction_id']);

        // 2. Fetch User and update wallet balance
        final userRes = await Supabase.instance.client.from('users').select('wallet_balance').eq('id', widget.userId).single();
        final currentBalance = double.tryParse(userRes['wallet_balance']?.toString() ?? '0') ?? 0;
        
        await Supabase.instance.client.from('users').update({
          'wallet_balance': currentBalance + refundAmount,
          'updated_at': DateTime.now().toUtc().toIso8601String()
        }).eq('id', widget.userId);

        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Refund processed.'), backgroundColor: Color(0xFF4ADDA2)));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF4ADDA2)));
          if (snapshot.hasError || (snapshot.data?.isEmpty ?? true)) return const Center(child: Text('User not found.'));
          
          final user = snapshot.data!.first;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(40.0),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFF2A2A2A))),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context), // Wait, go_router context.pop() is better, but this is simple
                    ),
                    const SizedBox(width: 24),
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xFF4ADDA2).withValues(alpha: 0.2),
                      child: Text((user['full_name'] ?? '?').substring(0, 1).toUpperCase(), style: const TextStyle(color: Color(0xFF4ADDA2), fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(user['full_name'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFF4ADDA2).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(50)),
                                child: Text(user['role'] ?? 'Customer', style: const TextStyle(color: Color(0xFF4ADDA2), fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ],
                          ),
                          Text(user['email'] ?? 'No Email', style: const TextStyle(color: Color(0xFF8A8A8A))),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Wallet Balance', style: TextStyle(color: Color(0xFF8A8A8A))),
                        Text('\$${user['wallet_balance'] ?? '0.00'}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ),
              
              // Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 16),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFF4ADDA2),
                  indicatorWeight: 3,
                  labelColor: const Color(0xFF4ADDA2),
                  unselectedLabelColor: const Color(0xFF8A8A8A),
                  tabs: const [
                    Tab(icon: Icon(Icons.shield), text: 'Access & Profile'),
                    Tab(icon: Icon(Icons.ev_station), text: 'Charging History'),
                    Tab(icon: Icon(Icons.account_balance_wallet), text: 'Payment Ledger'),
                  ],
                ),
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProfileTab(user),
                    _buildChargingHistoryTab(),
                    _buildLedgerTab(),
                  ],
                ),
              )
            ],
          );
        }
      ),
    );
  }

  Widget _buildProfileTab(Map<String, dynamic> user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Access Control', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('System Role', style: TextStyle(color: Color(0xFF8A8A8A))),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(user['role'] ?? 'Customer', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          ElevatedButton(
                            onPressed: () => _updateRole(user['role'] ?? 'Customer'),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2A2A2A), foregroundColor: Colors.white),
                            child: const Text('Change Role'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Changing a user to a Vendor grants them access to view and manage stations they own.', style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Subscription Status', style: TextStyle(color: Color(0xFF8A8A8A))),
                      const SizedBox(height: 8),
                      Text(user['subscription_tier'] ?? 'Basic', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      const Text('Determines access to premium charging speeds and rate cards.', style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Text('Vendor Settings (Visible if Role = Vendor)', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          if (user['role'] == 'Vendor')
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
              child: const Text('Vendor ownership configurations will be displayed here (e.g., Station Assignments, Revenue Split percentages).', style: TextStyle(color: Color(0xFF8A8A8A))),
            )
          else 
            const Text('User is not a Vendor. Change their role above to configure vendor settings.', style: TextStyle(color: Color(0xFF8A8A8A))),
        ],
      ),
    );
  }

  Widget _buildChargingHistoryTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _sessionsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF4ADDA2)));
        final sessions = snapshot.data ?? [];

        if (sessions.isEmpty) return const Center(child: Text('No charging history.', style: TextStyle(color: Color(0xFF8A8A8A))));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF2A2A2A))),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFF0F0F0F)),
                dataRowMinHeight: 70,
                dataRowMaxHeight: 80,
                columns: const [
                  DataColumn(label: Text('Session / Date', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Charger', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Duration', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Energy (kWh)', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Status', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                ],
                rows: sessions.map((s) {
                  final start = DateTime.parse(s['start_time']).toLocal();
                  final end = s['end_time'] != null ? DateTime.parse(s['end_time']).toLocal() : null;
                  final duration = end != null ? end.difference(start).inMinutes : 0;

                  return DataRow(
                    cells: [
                      DataCell(Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s['session_id'].toString().substring(0, 8).toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                          Text(DateFormat('MMM d, h:mm a').format(start), style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                        ],
                      )),
                      DataCell(Text(s['charger_id'].toString().substring(0,8), style: const TextStyle(color: Colors.white))),
                      DataCell(Text(end != null ? '$duration mins' : 'Ongoing...', style: const TextStyle(color: Colors.white))),
                      DataCell(Text('${s['kwh_dispensed'] ?? 0} kWh', style: const TextStyle(color: Color(0xFF4ADDA2), fontWeight: FontWeight.bold))),
                      DataCell(Text(s['status'], style: TextStyle(color: s['status'] == 'Active' ? const Color(0xFF4ADDA2) : Colors.white))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLedgerTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _transactionsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF4ADDA2)));
        final transactions = snapshot.data ?? [];

        if (transactions.isEmpty) return const Center(child: Text('No payment history.', style: TextStyle(color: Color(0xFF8A8A8A))));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF2A2A2A))),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFF0F0F0F)),
                dataRowMinHeight: 70,
                dataRowMaxHeight: 90,
                columns: const [
                  DataColumn(label: Text('Transaction / Date', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Type', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Amount / Cost', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Status', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Action', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                ],
                rows: transactions.map((t) {
                  final timeFormat = DateFormat('MMM d, h:mm a').format(DateTime.parse(t['created_at']).toLocal());
                  final isRefunded = t['status'] == 'Refunded';
                  
                  return DataRow(
                    cells: [
                      DataCell(Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t['transaction_id'].toString().substring(0, 8).toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                          Text(timeFormat, style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                        ],
                      )),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(4)),
                        child: Text(t['payment_type'], style: const TextStyle(color: Color(0xFF4ADDA2), fontSize: 12)),
                      )),
                      DataCell(Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Auth: \$${t['pre_auth_amount']}', style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                          if (t['final_cost'] != null) Text('Final: \$${t['final_cost']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      )),
                      DataCell(Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (t['refunded_amount'] != null && t['refunded_amount'] > 0)
                            Text('+\$${t['refunded_amount']} to Wallet', style: const TextStyle(color: Color(0xFF4ADDA2), fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(t['status'], style: TextStyle(color: isRefunded ? Colors.green : Colors.orange)),
                        ],
                      )),
                      DataCell(
                        isRefunded || (t['final_cost'] == null)
                            ? const Text('N/A', style: TextStyle(color: Color(0xFF8A8A8A)))
                            : ElevatedButton.icon(
                                onPressed: () => _processRefund(t),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                                icon: const Icon(Icons.currency_exchange, size: 16),
                                label: const Text('Refund'),
                              ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
