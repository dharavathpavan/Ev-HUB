import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 0;

  final List<String> _tabs = [
    'Platform Preferences',
    'Integrations & APIs',
    'Webhooks & Events',
    'Security & Access',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Global Settings', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            const Text('Configure platform behavior, third-party APIs, and security protocols.', style: TextStyle(color: Color(0xFF8A8A8A))),
            const SizedBox(height: 40),
            
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vertical Tabs Sidebar
                  Container(
                    width: 250,
                    decoration: BoxDecoration(
                      color: const Color(0xFF141414),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF2A2A2A)),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _tabs.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedIndex == index;
                        return InkWell(
                          onTap: () => setState(() => _selectedIndex = index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(color: isSelected ? const Color(0xFF4ADDA2) : Colors.transparent, width: 4),
                                bottom: BorderSide(color: index < _tabs.length - 1 ? const Color(0xFF2A2A2A) : Colors.transparent),
                              ),
                              color: isSelected ? const Color(0xFF2A2A2A).withValues(alpha: 0.5) : Colors.transparent,
                            ),
                            child: Text(
                              _tabs[index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF8A8A8A),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 40),
                  
                  // Content Area
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF2A2A2A)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(40),
                          child: _buildCurrentTab(),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_selectedIndex) {
      case 0: return _buildPlatformPreferences();
      case 1: return _buildIntegrations();
      case 2: return _buildWebhooks();
      case 3: return _buildSecurity();
      default: return const SizedBox.shrink();
    }
  }

  // --- TAB 1: Platform Preferences ---
  Widget _buildPlatformPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Platform Preferences', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        
        _buildSectionTitle('Localization'),
        Row(
          children: [
            Expanded(child: _buildDropdownField('Base Currency', ['USD (\$)', 'EUR (€)', 'GBP (£)', 'INR (₹)'], 'USD (\$)')),
            const SizedBox(width: 24),
            Expanded(child: _buildDropdownField('Global Timezone', ['UTC', 'America/New_York', 'Europe/London', 'Asia/Kolkata'], 'Asia/Kolkata')),
          ],
        ),
        const SizedBox(height: 32),
        
        _buildSectionTitle('Measurement Units'),
        Row(
          children: [
            Expanded(child: _buildDropdownField('Distance Unit', ['Kilometers (km)', 'Miles (mi)'], 'Kilometers (km)')),
            const SizedBox(width: 24),
            Expanded(child: _buildDropdownField('Energy Unit', ['Kilowatt-hours (kWh)'], 'Kilowatt-hours (kWh)')),
          ],
        ),
        const SizedBox(height: 40),
        _buildSaveButton(),
      ],
    );
  }

  // --- TAB 2: Integrations & APIs ---
  Widget _buildIntegrations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Integrations & APIs', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),

        _buildSectionTitle('Payment Gateways'),
        _buildTextField('Stripe Secret Key (Live)', isObscure: true, hint: 'sk_live_...'),
        const SizedBox(height: 16),
        _buildTextField('Razorpay Key Secret', isObscure: true, hint: 'rzp_live_...'),
        const SizedBox(height: 16),
        _buildTextField('PayPal Client ID', hint: 'Client ID from PayPal Developer Portal'),
        
        const SizedBox(height: 40),
        _buildSectionTitle('Messaging & Notifications'),
        _buildTextField('WhatsApp Business API Token', isObscure: true, hint: 'EAA...'),
        const SizedBox(height: 16),
        _buildTextField('Twilio Account SID (SMS)', hint: 'AC...'),
        const SizedBox(height: 16),
        _buildTextField('Twilio Auth Token', isObscure: true, hint: 'Hidden'),

        const SizedBox(height: 40),
        _buildSectionTitle('System APIs'),
        _buildTextField('OCPP Central System Endpoint', hint: 'wss://ocpp.yourdomain.com/steve'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A2A2A))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Generate New Admin API Key', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('Used for external system integrations.', style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2A2A2A), foregroundColor: Colors.white),
                child: const Text('Generate Key'),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 40),
        _buildSaveButton(),
      ],
    );
  }

  // --- TAB 3: Webhooks & Events ---
  Widget _buildWebhooks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Webhooks & Events', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Configure external endpoints that should be notified when specific system events occur.', style: TextStyle(color: Color(0xFF8A8A8A))),
        const SizedBox(height: 32),

        _buildSectionTitle('Charging Session Hooks'),
        _buildTextField('Session Started Webhook URL', hint: 'https://your-api.com/webhooks/session/start'),
        const SizedBox(height: 16),
        _buildTextField('Session Completed Webhook URL', hint: 'https://your-api.com/webhooks/session/end'),
        const SizedBox(height: 16),
        _buildTextField('Session Fault Webhook URL', hint: 'https://your-api.com/webhooks/session/fault'),

        const SizedBox(height: 40),
        _buildSectionTitle('Financial Hooks'),
        _buildTextField('Wallet Top-up Success Webhook URL', hint: 'https://your-api.com/webhooks/wallet/success'),
        const SizedBox(height: 16),
        _buildTextField('Refund Processed Webhook URL', hint: 'https://your-api.com/webhooks/refund'),

        const SizedBox(height: 40),
        _buildSaveButton(),
      ],
    );
  }

  // --- TAB 4: Security & Access ---
  Widget _buildSecurity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Security & Access', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),

        _buildSectionTitle('Admin Security'),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Two-Factor Authentication (2FA)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Switch(value: true, onChanged: (v) {}, activeColor: const Color(0xFF4ADDA2)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Require TOTP (Google Authenticator) for all Super Admin logins.', style: TextStyle(color: Color(0xFF8A8A8A))),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2A2A2A), foregroundColor: Colors.white),
                child: const Text('Change Admin Password'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),
        _buildSectionTitle('Global Password Resets'),
        const Text('Force password resets for entire user cohorts. They will be logged out immediately.', style: TextStyle(color: Color(0xFF8A8A8A))),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Vendor Accounts', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _showResetDialog('Vendors'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                      child: const Text('Force Reset All Vendors'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.orange.withValues(alpha: 0.3))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('End-User Accounts', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _showResetDialog('Users'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                      child: const Text('Force Reset All Users'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  void _showResetDialog(String cohort) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        title: Text('Force Reset $cohort?', style: const TextStyle(color: Colors.white)),
        content: Text('This will invalidate all current sessions for $cohort and send them a password reset link. Are you absolutely sure?', style: const TextStyle(color: Color(0xFF8A8A8A))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password reset triggered for $cohort.'), backgroundColor: const Color(0xFF4ADDA2)));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Yes, Force Reset'),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(title, style: const TextStyle(color: Color(0xFF4ADDA2), fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField(String label, {bool isObscure = false, String? hint}) {
    return TextField(
      obscureText: isObscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF8A8A8A)),
        labelStyle: const TextStyle(color: Color(0xFF8A8A8A)),
        filled: true,
        fillColor: const Color(0xFF0F0F0F),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String selected) {
    return DropdownButtonFormField<String>(
      value: selected,
      dropdownColor: const Color(0xFF141414),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF8A8A8A)),
        filled: true,
        fillColor: const Color(0xFF0F0F0F),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: (val) {},
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: 200,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved successfully.'), backgroundColor: Color(0xFF4ADDA2)));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4ADDA2),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.save),
        label: const Text('Save Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
