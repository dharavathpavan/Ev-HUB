import 'package:flutter/material.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  // Mock Data
  final List<Map<String, dynamic>> _tickets = [
    {
      'id': 'TKT-8921',
      'user': 'Sarah Connor',
      'station': 'HUB-Downtown-01',
      'issue': 'Charger won\'t unlock from vehicle',
      'status': 'Escalated',
      'ai_confidence': 32,
      'messages': [
        {'sender': 'User', 'text': 'Help, the charger is stuck in my car!'},
        {'sender': 'AI', 'text': 'I understand you are having trouble unlocking the charger. Please ensure your vehicle is unlocked from the inside first.'},
        {'sender': 'User', 'text': 'I did that, it\'s still stuck. It\'s flashing red.'},
        {'sender': 'AI', 'text': 'A red flashing light indicates a hard fault. I am escalating this to a human technician immediately.'},
      ]
    },
    {
      'id': 'TKT-8922',
      'user': 'John Smith',
      'station': 'HUB-Uptown-04',
      'issue': 'Payment failed error',
      'status': 'AI Triage',
      'ai_confidence': 94,
      'messages': [
        {'sender': 'User', 'text': 'Why did my card decline?'},
        {'sender': 'AI', 'text': 'Checking your account... It appears there is a temporary \$50 pre-authorization hold required, but your wallet balance is only \$12.'},
        {'sender': 'AI', 'text': 'Would you like me to send a link to top-up your wallet?'},
      ]
    },
    {
      'id': 'TKT-8923',
      'user': 'Alice Johnson',
      'station': 'HUB-Westside-02',
      'issue': 'Slow charging speed',
      'status': 'Escalated',
      'ai_confidence': 45,
      'messages': [
        {'sender': 'User', 'text': 'I am only getting 12kW on a 150kW charger.'},
        {'sender': 'AI', 'text': 'I see you are connected to Charger 2. Your vehicle is currently at 88% State of Charge. Charging speeds naturally decrease above 80% to protect the battery.'},
        {'sender': 'User', 'text': 'No, I just plugged in, it\'s at 20%.'},
        {'sender': 'AI', 'text': 'I apologize for the confusion. I am escalating this to a human operator to investigate the charger telemetry.'},
      ]
    }
  ];

  Map<String, dynamic>? _selectedTicket;
  bool _humanTakeover = false;
  final TextEditingController _chatController = TextEditingController();
  String _filter = 'Escalated'; // 'Escalated' or 'AI Triage'

  @override
  void initState() {
    super.initState();
    _selectedTicket = _tickets.firstWhere((t) => t['status'] == 'Escalated');
  }

  void _sendMessage() {
    if (_chatController.text.trim().isEmpty) return;
    
    setState(() {
      _selectedTicket!['messages'].add({
        'sender': 'Admin',
        'text': _chatController.text.trim(),
      });
      _chatController.clear();
    });
  }

  Widget _buildTicketQueue() {
    final filteredTickets = _tickets.where((t) => t['status'] == _filter).toList();

    return Container(
      width: 350,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() { _filter = 'Escalated'; _selectedTicket = null; _humanTakeover = false; }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: _filter == 'Escalated' ? Colors.redAccent : Colors.transparent, width: 2)),
                      ),
                      child: Center(child: Text('Escalated', style: TextStyle(color: _filter == 'Escalated' ? Colors.redAccent : const Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() { _filter = 'AI Triage'; _selectedTicket = null; _humanTakeover = false; }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: _filter == 'AI Triage' ? const Color(0xFF4ADDA2) : Colors.transparent, width: 2)),
                      ),
                      child: Center(child: Text('AI Triage', style: TextStyle(color: _filter == 'AI Triage' ? const Color(0xFF4ADDA2) : const Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: filteredTickets.length,
              separatorBuilder: (context, index) => const Divider(color: Color(0xFF2A2A2A), height: 1),
              itemBuilder: (context, index) {
                final ticket = filteredTickets[index];
                final isSelected = _selectedTicket?['id'] == ticket['id'];

                return InkWell(
                  onTap: () => setState(() { _selectedTicket = ticket; _humanTakeover = false; }),
                  child: Container(
                    color: isSelected ? const Color(0xFF2A2A2A).withValues(alpha: 0.5) : Colors.transparent,
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(ticket['id'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: ticket['status'] == 'Escalated' ? Colors.redAccent.withValues(alpha: 0.1) : const Color(0xFF4ADDA2).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(ticket['status'], style: TextStyle(color: ticket['status'] == 'Escalated' ? Colors.redAccent : const Color(0xFF4ADDA2), fontSize: 10, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(ticket['issue'], style: const TextStyle(color: Colors.white, fontSize: 14)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(ticket['user'], style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                            Text('AI Conf: ${ticket['ai_confidence']}%', style: TextStyle(color: ticket['ai_confidence'] < 50 ? Colors.redAccent : const Color(0xFF4ADDA2), fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> message) {
    final sender = message['sender'];
    final text = message['text'];
    
    bool isUser = sender == 'User';
    bool isAdmin = sender == 'Admin';
    bool isAI = sender == 'AI';

    Color bubbleColor = const Color(0xFF2A2A2A);
    Color textColor = Colors.white;
    Alignment alignment = Alignment.centerLeft;
    
    if (isAdmin) {
      bubbleColor = Colors.purpleAccent.withValues(alpha: 0.2);
      textColor = Colors.purpleAccent[100]!;
      alignment = Alignment.centerRight;
    } else if (isAI) {
      bubbleColor = const Color(0xFF4ADDA2).withValues(alpha: 0.1);
      textColor = const Color(0xFF4ADDA2);
    }

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomLeft: (isUser || isAI) ? const Radius.circular(0) : const Radius.circular(16),
            bottomRight: isAdmin ? const Radius.circular(0) : const Radius.circular(16),
          ),
          border: Border.all(color: isAdmin ? Colors.purpleAccent.withValues(alpha: 0.5) : (isAI ? const Color(0xFF4ADDA2).withValues(alpha: 0.3) : Colors.transparent)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isUser ? Icons.person : (isAI ? Icons.smart_toy : Icons.support_agent), size: 14, color: textColor),
                const SizedBox(width: 6),
                Text(sender, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(color: Colors.white, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    if (_selectedTicket == null) {
      return const Center(child: Text('Select a ticket to view the transcript.', style: TextStyle(color: Color(0xFF8A8A8A))));
    }

    final messages = _selectedTicket!['messages'] as List;

    return Column(
      children: [
        // Chat Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF2A2A2A)))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_selectedTicket!['id']} - ${_selectedTicket!['issue']}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF8A8A8A), size: 14),
                      const SizedBox(width: 4),
                      Text(_selectedTicket!['station'], style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                    ],
                  )
                ],
              ),
              if (!_humanTakeover)
                ElevatedButton.icon(
                  onPressed: () => setState(() => _humanTakeover = true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent, foregroundColor: Colors.white),
                  icon: const Icon(Icons.back_hand),
                  label: const Text('Takeover from AI', style: TextStyle(fontWeight: FontWeight.bold)),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.purpleAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(50), border: Border.all(color: Colors.purpleAccent)),
                  child: const Row(
                    children: [
                      Icon(Icons.person, color: Colors.purpleAccent, size: 16),
                      SizedBox(width: 8),
                      Text('Human Operator Active', style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
            ],
          ),
        ),
        
        // Transcript
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(32),
            itemCount: messages.length,
            itemBuilder: (context, index) => _buildChatBubble(messages[index]),
          ),
        ),

        // Input Area
        if (_humanTakeover)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF2A2A2A)))),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type your message to the user...',
                      hintStyle: const TextStyle(color: Color(0xFF8A8A8A)),
                      filled: true,
                      fillColor: const Color(0xFF0F0F0F),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.purpleAccent, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF2A2A2A)))),
            child: const Center(
              child: Text('AI Agent is currently handling this conversation.', style: TextStyle(color: Color(0xFF4ADDA2), fontStyle: FontStyle.italic)),
            ),
          )
      ],
    );
  }

  Widget _buildContextPanel() {
    if (_selectedTicket == null) return const SizedBox.shrink();
    
    return Container(
      width: 300,
      decoration: const BoxDecoration(border: Border(left: BorderSide(color: Color(0xFF2A2A2A)))),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('User Telemetry', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          
          _buildContextItem(Icons.person, 'User', _selectedTicket!['user']),
          const SizedBox(height: 16),
          _buildContextItem(Icons.ev_station, 'Station', _selectedTicket!['station']),
          const SizedBox(height: 16),
          _buildContextItem(Icons.battery_charging_full, 'Vehicle SOC', '42% (Charging)'),
          const SizedBox(height: 16),
          _buildContextItem(Icons.account_balance_wallet, 'Wallet Balance', '\$12.50', color: Colors.redAccent),
          
          const Spacer(),
          const Text('AI Diagnostics', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(12)),
            child: const Text('Hardware fault detected on connector B locking pin. Remote unlock command failed 3 times.', style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ADDA2), foregroundColor: Colors.black),
              child: const Text('Send Remote Unlock Command'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildContextItem(IconData icon, String label, String value, {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF8A8A8A), size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
              Text(value, style: TextStyle(color: color ?? Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('AI Support Call Center', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                Row(
                  children: [
                    _buildTopKPI('AI Resolution Rate', '87%', const Color(0xFF4ADDA2)),
                    const SizedBox(width: 24),
                    _buildTopKPI('Active Escalations', '12', Colors.redAccent),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(40, 0, 40, 40),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Row(
                  children: [
                    _buildTicketQueue(),
                    Expanded(child: _buildChatArea()),
                    if (_selectedTicket != null) _buildContextPanel(),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTopKPI(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border.all(color: const Color(0xFF2A2A2A)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(color: Color(0xFF8A8A8A))),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }
}
