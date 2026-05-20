import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final Stream<List<Map<String, dynamic>>> _rateCardsStream;
  late final Stream<List<Map<String, dynamic>>> _transactionsStream;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    _rateCardsStream = Supabase.instance.client
        .from('rate_cards')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
        
    _transactionsStream = Supabase.instance.client
        .from('transactions')
        .stream(primaryKey: ['transaction_id'])
        .order('created_at', ascending: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Payments & Tariffs', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                const Text('Manage rate cards, view QR pay-as-you-go ledgers, and track wallet refunds.', style: TextStyle(color: Color(0xFF8A8A8A))),
                const SizedBox(height: 32),
                TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFF4ADDA2),
                  indicatorWeight: 3,
                  labelColor: const Color(0xFF4ADDA2),
                  unselectedLabelColor: const Color(0xFF8A8A8A),
                  tabs: const [
                    Tab(icon: Icon(Icons.account_balance_wallet), text: 'Financial Ledger'),
                    Tab(icon: Icon(Icons.price_change), text: 'Rate Cards (Tariffs)'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLedgerTab(),
                _buildRateCardsTab(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLedgerTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _transactionsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF4ADDA2)));
        if (snapshot.hasError) return const Center(child: Text('Error loading ledger. Please run SQL migration.', style: TextStyle(color: Colors.redAccent)));
        final transactions = snapshot.data ?? [];

        if (transactions.isEmpty) return const Center(child: Text('No transactions recorded yet.', style: TextStyle(color: Color(0xFF8A8A8A))));

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF2A2A2A))),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(const Color(0xFF0F0F0F)),
                dataRowHeight: 80,
                horizontalMargin: 32,
                columnSpacing: 24,
                columns: const [
                  DataColumn(label: Text('Transaction / Time', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Wallet ID', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Type', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Pre-Auth / Final', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Refund / Status', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                ],
                rows: transactions.map((t) {
                  final timeFormat = DateFormat('MMM d, h:mm a').format(DateTime.parse(t['created_at']).toLocal());
                  final isRefunded = t['status'] == 'Refunded';
                  
                  return DataRow(
                    cells: [
                      DataCell(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t['transaction_id'].toString().substring(0, 8).toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                            Text(timeFormat, style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                          ],
                        ),
                      ),
                      DataCell(Text(t['wallet_user_id'], style: const TextStyle(color: Colors.white))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(4)),
                          child: Text(t['payment_type'], style: const TextStyle(color: Color(0xFF4ADDA2), fontSize: 12)),
                        ),
                      ),
                      DataCell(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Auth: \$${t['pre_auth_amount']}', style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                            if (t['final_cost'] != null) Text('Final: \$${t['final_cost']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      DataCell(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (t['refunded_amount'] != null && t['refunded_amount'] > 0)
                              Text('+\$${t['refunded_amount']} to Wallet', style: const TextStyle(color: Color(0xFF4ADDA2), fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: isRefunded ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(50)),
                              child: Text(t['status'], style: TextStyle(color: isRefunded ? Colors.green : Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                            )
                          ],
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

  Widget _buildRateCardsTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _rateCardsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF4ADDA2)));
        if (snapshot.hasError) return const Center(child: Text('Error loading rate cards. Please run SQL migration.', style: TextStyle(color: Colors.redAccent)));
        final rateCards = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ADDA2), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Rate Card', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 24, mainAxisSpacing: 24, childAspectRatio: 1.5),
                itemCount: rateCards.length,
                itemBuilder: (context, index) {
                  final card = rateCards[index];
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(card['name'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const Icon(Icons.local_offer, color: Color(0xFF4ADDA2)),
                          ],
                        ),
                        const Spacer(),
                        _buildRateRow('Per kWh', '\$${card['per_kwh_fee']}'),
                        const SizedBox(height: 8),
                        _buildRateRow('Per Minute', '\$${card['per_minute_fee']}'),
                        const SizedBox(height: 8),
                        _buildRateRow('Fixed Session Fee', '\$${card['session_fixed_fee']}'),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Active', style: TextStyle(color: Color(0xFF4ADDA2), fontSize: 12)),
                            Text('Currency: ${card['currency']}', style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                          ],
                        )
                      ],
                    ),
                  );
                },
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildRateRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF8A8A8A))),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
