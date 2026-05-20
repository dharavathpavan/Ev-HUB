import 'package:flutter/material.dart';

class AIMonitoringScreen extends StatefulWidget {
  const AIMonitoringScreen({super.key});

  @override
  State<AIMonitoringScreen> createState() => _AIMonitoringScreenState();
}

class _AIMonitoringScreenState extends State<AIMonitoringScreen> {
  // Master Controls
  bool _predictiveEnabled = true;
  bool _gridBalancingEnabled = true;
  bool _dynamicPricingEnabled = false;

  // Vendor Alert Controls
  bool _alertSms = true;
  bool _alertWhatsapp = true;
  bool _alertCall = false;

  final List<Map<String, dynamic>> _anomalies = [
    {
      'id': 'ANM-091',
      'station': 'HUB-Downtown-02',
      'severity': 'Critical',
      'message': 'High thermal resistance detected on Connector B cooling loop.',
      'prediction': '85% probability of failure within 72 hours.',
      'action': 'Dispatched technician & notified Vendor via SMS.',
      'time': '10 mins ago'
    },
    {
      'id': 'ANM-090',
      'station': 'HUB-Westside-01',
      'severity': 'Warning',
      'message': 'Voltage sag detected during initial handshake.',
      'prediction': 'Grid transformer fluctuation. Monitor only.',
      'action': 'Logged to AI memory.',
      'time': '1 hour ago'
    },
    {
      'id': 'ANM-089',
      'station': 'HUB-Uptown-04',
      'severity': 'Critical',
      'message': 'RFID Reader latency spiked to 4000ms.',
      'prediction': 'Hardware module failing.',
      'action': 'Notified Vendor via WhatsApp. Rebooted module remotely.',
      'time': '3 hours ago'
    }
  ];

  final List<Map<String, dynamic>> _interventions = [
    {
      'session_id': 'SESS-8812',
      'station': 'HUB-Downtown-01',
      'trigger': 'Grid Load Peak',
      'action': 'Throttled from 150kW to 50kW',
      'savings': '\$4.20'
    },
    {
      'session_id': 'SESS-8815',
      'station': 'HUB-Downtown-03',
      'trigger': 'Thermal Limit',
      'action': 'Throttled from 350kW to 150kW',
      'savings': 'N/A'
    },
  ];

  Widget _buildMasterControl(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF4ADDA2),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCheckbox(String title, IconData icon, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Icon(icon, color: value ? const Color(0xFF4ADDA2) : const Color(0xFF8A8A8A), size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: Colors.white)),
        const Spacer(),
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF4ADDA2),
          checkColor: Colors.black,
        ),
      ],
    );
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Core & Telemetry', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 8),
                  Text('Nerve center for predictive maintenance, grid balancing, and automated dispatch.', style: TextStyle(color: Color(0xFF8A8A8A))),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ADDA2).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: const Color(0xFF4ADDA2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.memory, color: Color(0xFF4ADDA2)),
                    SizedBox(width: 8),
                    Text('Core Online & Active', style: TextStyle(color: Color(0xFF4ADDA2), fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 40),

          // Top Metrics
          Row(
            children: [
              Expanded(child: _buildMetricCard('Total AI Decisions (24h)', '1,492', Icons.psychology, Colors.purpleAccent)),
              const SizedBox(width: 24),
              Expanded(child: _buildMetricCard('Grid Throttles Active', '2', Icons.bolt, Colors.amber)),
              const SizedBox(width: 24),
              Expanded(child: _buildMetricCard('Hardware Anomalies', '3', Icons.warning_amber, Colors.redAccent)),
              const SizedBox(width: 24),
              Expanded(child: _buildMetricCard('Vendor Alerts Sent', '18', Icons.send_to_mobile, Colors.blueAccent)),
            ],
          ),
          const SizedBox(height: 40),

          // Main Layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Feeds
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Live Predictive Maintenance Feed', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF2A2A2A)),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _anomalies.length,
                        separatorBuilder: (_, __) => const Divider(color: Color(0xFF2A2A2A), height: 1),
                        itemBuilder: (context, index) {
                          final a = _anomalies[index];
                          final isCritical = a['severity'] == 'Critical';
                          return Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(isCritical ? Icons.error : Icons.warning, color: isCritical ? Colors.redAccent : Colors.orange, size: 28),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('${a['id']} - ${a['station']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          Text(a['time'], style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(a['message'], style: const TextStyle(color: Color(0xFF8A8A8A))),
                                      const SizedBox(height: 4),
                                      Text('Prediction: ${a['prediction']}', style: const TextStyle(color: Color(0xFF4ADDA2), fontSize: 12, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(4)),
                                        child: Text('AI Action: ${a['action']}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text('Active Grid Balancing Interventions', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF2A2A2A)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(const Color(0xFF0F0F0F)),
                          columns: const [
                            DataColumn(label: Text('Session', style: TextStyle(color: Color(0xFF8A8A8A)))),
                            DataColumn(label: Text('Station', style: TextStyle(color: Color(0xFF8A8A8A)))),
                            DataColumn(label: Text('Trigger', style: TextStyle(color: Color(0xFF8A8A8A)))),
                            DataColumn(label: Text('Action Taken', style: TextStyle(color: Color(0xFF8A8A8A)))),
                          ],
                          rows: _interventions.map((i) => DataRow(
                            cells: [
                              DataCell(Text(i['session_id'], style: const TextStyle(color: Colors.white, fontFamily: 'monospace'))),
                              DataCell(Text(i['station'], style: const TextStyle(color: Colors.white))),
                              DataCell(Text(i['trigger'], style: const TextStyle(color: Colors.orange))),
                              DataCell(Text(i['action'], style: const TextStyle(color: Color(0xFF4ADDA2), fontWeight: FontWeight.bold))),
                            ]
                          )).toList(),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 40),
              
              // Right Column: Controls & Alerting
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Vendor Alerting Engine', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF2A2A2A)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('When a critical anomaly is detected, automatically dispatch alerts to the assigned Station Vendor:', style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 14)),
                          const SizedBox(height: 24),
                          _buildAlertCheckbox('SMS / Text Message', Icons.sms, _alertSms, (v) => setState(() => _alertSms = v ?? false)),
                          const SizedBox(height: 16),
                          _buildAlertCheckbox('WhatsApp Message', Icons.chat, _alertWhatsapp, (v) => setState(() => _alertWhatsapp = v ?? false)),
                          const SizedBox(height: 16),
                          _buildAlertCheckbox('Automated Voice Call (Robocall)', Icons.phone_in_talk, _alertCall, (v) => setState(() => _alertCall = v ?? false)),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alert routing rules saved!'), backgroundColor: Color(0xFF4ADDA2)));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4ADDA2),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.save),
                              label: const Text('Save Alert Rules', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text('Master Overrides', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildMasterControl('Predictive Maintenance Engine', 'Detect hardware anomalies', _predictiveEnabled, (v) => setState(() => _predictiveEnabled = v)),
                    const SizedBox(height: 16),
                    _buildMasterControl('Grid Load Balancer', 'Auto-throttle during peak load', _gridBalancingEnabled, (v) => setState(() => _gridBalancingEnabled = v)),
                    const SizedBox(height: 16),
                    _buildMasterControl('Dynamic Pricing Engine', 'Adjust tariffs based on demand', _dynamicPricingEnabled, (v) => setState(() => _dynamicPricingEnabled = v)),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Color(0xFF8A8A8A))),
              Icon(icon, color: color),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
