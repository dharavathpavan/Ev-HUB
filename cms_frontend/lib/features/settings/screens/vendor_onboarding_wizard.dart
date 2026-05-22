import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cms_frontend/config.dart';

class VendorOnboardingWizard extends StatefulWidget {
  const VendorOnboardingWizard({super.key});

  @override
  State<VendorOnboardingWizard> createState() => _VendorOnboardingWizardState();
}

class _VendorOnboardingWizardState extends State<VendorOnboardingWizard> {
  int _currentStep = 0;
  bool _isLoading = false;

  // Step 1 Controllers (Application)
  final _businessNameController = TextEditingController(text: 'Phoenix Power Stations');
  final _contactEmailController = TextEditingController(text: 'contact@phoenixpower.com');
  final _taxIdController = TextEditingController(text: 'TAX-PHX-1010');
  final _estimatedChargersController = TextEditingController(text: '12');
  List<dynamic> _applications = [];

  // Step 2 Controllers (Hub Setup)
  final _hubNameController = TextEditingController(text: 'Phoenix Charging Hub Alpha');
  final _hubAddressController = TextEditingController(text: 'Cyber City Phase II, Sector 24, Gurugram');
  final _latController = TextEditingController(text: '28.4901');
  final _lngController = TextEditingController(text: '77.0878');
  String _selectedRateCardId = '';
  List<dynamic> _rateCards = [];

  // Step 3 Controllers (Charger Setup)
  final _chargerIdController = TextEditingController(text: 'CHG-PHX-A1');
  final _modelController = TextEditingController(text: 'VoltSuper 150');
  final _voltageController = TextEditingController(text: '400');
  final _temperatureController = TextEditingController(text: '34');

  // Step 4 Controllers (Guns / Connectors Configuration)
  final List<Map<String, dynamic>> _configuredGuns = [
    {'gun_index': 1, 'connector_type': 'CCS2', 'max_kw_output': 150.0},
    {'gun_index': 2, 'connector_type': 'Type2', 'max_kw_output': 22.0},
  ];
  String _tempConnectorType = 'CCS2';
  final _tempKwController = TextEditingController(text: '50.0');

  // Step 5 Controllers (QR Mappings)
  List<Map<String, dynamic>> _mappedQRs = [];
  bool _qrGenerated = false;

  // Active items initialized during wizard steps
  String _createdVendorId = 'vendor-phoenix';
  String _createdStationId = '';

  @override
  void initState() {
    super.initState();
    _fetchApplications();
    _fetchRateCards();
  }

  Future<void> _fetchApplications() async {
    try {
      final response = await http.get(Uri.parse('${Config.apiBaseUrl}/api/vendors/apply'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _applications = data['applications'] ?? [];
            _prefillUserApplication();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching applications: $e');
    }
  }

  void _prefillUserApplication() {
    final currentUserEmail = Supabase.instance.client.auth.currentUser?.email;
    if (currentUserEmail != null && currentUserEmail.isNotEmpty) {
      // Try to find if there is an application for the current user email
      final userApp = _applications.firstWhere(
        (app) => app['contact_email'] == currentUserEmail,
        orElse: () => null,
      );
      if (userApp != null) {
        _businessNameController.text = userApp['business_name'] ?? '';
        _contactEmailController.text = userApp['contact_email'] ?? '';
        _taxIdController.text = userApp['tax_id'] ?? '';
        _estimatedChargersController.text = (userApp['estimated_chargers'] ?? 0).toString();
        _createdVendorId = userApp['vendor_id'] ?? 'vendor-phoenix';

        if (userApp['status'] == 'Approved') {
          _currentStep = 1; // Auto-advance to Hub deployment!
        }
      } else {
        _contactEmailController.text = currentUserEmail;
      }
    }
  }

  Future<void> _fetchRateCards() async {
    try {
      final response = await Supabase.instance.client.from('rate_cards').select();
      if (response != null && mounted) {
        setState(() {
          _rateCards = response;
          if (_rateCards.isNotEmpty) {
            _selectedRateCardId = _rateCards.first['id'].toString();
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching rate cards: $e');
    }
  }

  Future<void> _submitApplication() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/api/vendors/apply'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'business_name': _businessNameController.text,
          'contact_email': _contactEmailController.text,
          'tax_id': _taxIdController.text,
          'estimated_chargers': int.tryParse(_estimatedChargersController.text) ?? 5,
        }),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Application submitted successfully!'), backgroundColor: Color(0xFF4ADDA2)),
          );
        }
        await _fetchApplications();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _approveApplication(String id, String businessName) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/api/vendors/action'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': id,
          'action': 'Approved',
          'admin_notes': 'Auto-approved for wizard demo workflow.',
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _createdVendorId = data['application']['vendor_id'] ?? 'vendor-phoenix';
            _businessNameController.text = businessName;
            _currentStep = 1; // Advance to Step 2
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Application approved! Profile created for $businessName.'), backgroundColor: const Color(0xFF4ADDA2)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Approval failed: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deployHub() async {
    setState(() => _isLoading = true);
    try {
      final stationId = 'STN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      
      // Deploy Hub directly to Supabase!
      await Supabase.instance.client.from('stations').insert({
        'station_id': stationId,
        'name': _hubNameController.text,
        'location': _hubAddressController.text,
        'chargers': 0, // start with 0, will increment when we bind
        'status': 'Online',
        'revenue': '0.00',
        'created_at': DateTime.now().toIso8601String(),
        'rate_card_id': _selectedRateCardId.isNotEmpty ? int.parse(_selectedRateCardId) : null
      });

      if (mounted) {
        setState(() {
          _createdStationId = stationId;
          _currentStep = 2; // Advance to Step 3
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Station Hub Deployed Successfully!'), backgroundColor: Color(0xFF4ADDA2)),
        );
      }
    } catch (e) {
      if (mounted) {
        // Fallback simulate advance if DB RLS fails or key invalid
        setState(() {
          _createdStationId = 'STN-MOCK-999';
          _currentStep = 2;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deployed Hub (Local Fallback Mode): $e'), backgroundColor: Colors.orangeAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _provisionCharger() async {
    setState(() => _isLoading = true);
    try {
      // Connect / Provision Charger to Supabase
      await Supabase.instance.client.from('chargers').insert({
        'charger_id': _chargerIdController.text,
        'station_id': _createdStationId,
        'status': 'Available',
        'current_kw_output': 0.0,
        'max_kw_output': 150.0,
        'voltage': int.tryParse(_voltageController.text) ?? 400,
        'temperature': int.tryParse(_temperatureController.text) ?? 35,
        'model': _modelController.text,
      });

      // Update parent station count
      try {
        final stationRes = await Supabase.instance.client
            .from('stations')
            .select('chargers')
            .eq('station_id', _createdStationId)
            .single();
        if (stationRes != null) {
          int count = stationRes['chargers'] ?? 0;
          await Supabase.instance.client
              .from('stations')
              .update({'chargers': count + 1})
              .eq('station_id', _createdStationId);
        }
      } catch (_) {}

      if (mounted) {
        setState(() {
          _currentStep = 3; // Advance to Step 4
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OCPP Cabinet Registered Successfully!'), backgroundColor: Color(0xFF4ADDA2)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentStep = 3;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registered Cabinet (Local Fallback): $e'), backgroundColor: Colors.orangeAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitChargingGuns() async {
    setState(() => _isLoading = true);
    try {
      final chargerId = _chargerIdController.text;
      
      for (final gun in _configuredGuns) {
        await http.post(
          Uri.parse('${Config.apiBaseUrl}/api/chargers/guns'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'charger_id': chargerId,
            'gun_index': gun['gun_index'],
            'connector_type': gun['connector_type'],
            'max_kw_output': gun['max_kw_output'],
          }),
        );
      }

      if (mounted) {
        setState(() {
          _currentStep = 4; // Advance to Step 5 (QR Mapping)
          _generateAndRegisterQR();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All Charging Guns configured successfully!'), backgroundColor: Color(0xFF4ADDA2)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save guns: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _generateAndRegisterQR() async {
    setState(() => _isLoading = true);
    try {
      final chargerId = _chargerIdController.text;
      final List<Map<String, dynamic>> maps = [];
      
      for (final gun in _configuredGuns) {
        final gunIdx = gun['gun_index'];
        final qrId = 'QR-${chargerId}-G${gunIdx}';
        
        final response = await http.post(
          Uri.parse('${Config.apiBaseUrl}/api/qr/map'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'qr_id': qrId,
            'charger_id': chargerId,
            'gun_index': gunIdx
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          maps.add(data['mapping']);
        }
      }

      if (mounted) {
        setState(() {
          _mappedQRs = maps;
          _qrGenerated = true;
        });
      }
    } catch (e) {
      debugPrint('Error generating mapping: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addGunLocal() {
    final kw = double.tryParse(_tempKwController.text) ?? 50.0;
    setState(() {
      _configuredGuns.add({
        'gun_index': _configuredGuns.length + 1,
        'connector_type': _tempConnectorType,
        'max_kw_output': kw
      });
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vendor Onboarding & Operations Portal', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            const Text('Manage incoming partner requests, configure new hubs, register multi-connector hardware, and print QR mapping codes.', style: TextStyle(color: Color(0xFF8A8A8A))),
            const SizedBox(height: 40),

            // Step Indicator
            _buildStepIndicator(),
            const SizedBox(height: 40),

            // Active Step Content
            _isLoading
                ? const Center(child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator(color: Color(0xFF4ADDA2))))
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildActiveStepContent(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final List<String> stepTitles = ['1. Apply & Review', '2. Station Hub', '3. Charger Cabin', '4. Configure Guns', '5. QR Mapping'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(stepTitles.length, (index) {
          final isCompleted = _currentStep > index;
          final isActive = _currentStep == index;
          Color indicatorColor = const Color(0xFF2A2A2A);
          if (isActive) indicatorColor = const Color(0xFF4ADDA2);
          if (isCompleted) indicatorColor = const Color(0xFF00F0FF);

          return Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: indicatorColor.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: indicatorColor, width: 2)),
                  child: Text('${index + 1}', style: TextStyle(color: isActive || isCompleted ? Colors.white : const Color(0xFF8A8A8A), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(stepTitles[index], style: TextStyle(color: isActive ? const Color(0xFF4ADDA2) : (isCompleted ? Colors.white : const Color(0xFF5A5A5A)), fontSize: 13, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                if (index < stepTitles.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.arrow_forward_ios, size: 14, color: isCompleted ? const Color(0xFF00F0FF) : const Color(0xFF2A2A2A)),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActiveStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Application();
      case 1:
        return _buildStep2Station();
      case 2:
        return _buildStep3Charger();
      case 3:
        return _buildStep4Guns();
      case 4:
        return _buildStep5QR();
      default:
        return const SizedBox.shrink();
    }
  }

  // --- STEP 1: APPLICATION REVIEW ---
  Widget _buildStep1Application() {
    return Wrap(
      spacing: 40,
      runSpacing: 40,
      children: [
        // Form panel
        Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF2A2A2A))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Submit Partner Application', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Apply as a charging point operator (CPO) to host cabinets.', style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 13)),
              const SizedBox(height: 24),
              _buildTextField('Business Name', _businessNameController, Icons.business),
              const SizedBox(height: 16),
              _buildTextField('Contact Email', _contactEmailController, Icons.email),
              const SizedBox(height: 16),
              _buildTextField('Tax ID / Business Reg No.', _taxIdController, Icons.assignment),
              const SizedBox(height: 16),
              _buildTextField('Estimated Charging Cabinets', _estimatedChargersController, Icons.ev_station, isNumber: true),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _submitApplication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ADDA2), foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.send),
                label: const Text('Submit Application', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),

        // Live admin review simulation table
        Container(
          width: 600,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF2A2A2A))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Admin Dashboard: Pending Requests', style: TextStyle(color: Color(0xFF00F0FF), fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.refresh, color: Color(0xFF00F0FF)), onPressed: _fetchApplications),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Review partner applications. Click "Approve" to simulate administrative setup and advance.', style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
              const SizedBox(height: 24),
              if (_applications.isEmpty)
                const Center(child: Text('No applications found.', style: TextStyle(color: Color(0xFF8A8A8A))))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _applications.length,
                  itemBuilder: (context, index) {
                    final app = _applications[index];
                    final isPending = app['status'] == 'Pending';
                    final isApproved = app['status'] == 'Approved';
                    Color statusColor = Colors.orangeAccent;
                    if (isApproved) statusColor = const Color(0xFF4ADDA2);
                    if (app['status'] == 'Rejected') statusColor = Colors.redAccent;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFF0F0F0F), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(app['business_name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                Text('Email: ${app['contact_email']} | Reg: ${app['tax_id']}', style: const TextStyle(color: Color(0xFF5A5A5A), fontSize: 11)),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                  child: Text(app['status'], style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                          ),
                          if (isPending)
                             ElevatedButton(
                              onPressed: () => _approveApplication(app['id'], app['business_name']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4ADDA2),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              child: const Text('Approve', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            )
                          else if (isApproved)
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_outlined, color: Color(0xFF00F0FF)),
                              onPressed: () {
                                setState(() {
                                  _createdVendorId = app['vendor_id'] ?? 'vendor-phoenix';
                                  _businessNameController.text = app['business_name'];
                                  _currentStep = 1;
                                });
                              },
                              tooltip: 'Proceed to Step 2',
                            )
                        ],
                      ),
                    );
                  },
                )
            ],
          ),
        )
      ],
    );
  }

  // --- STEP 2: DEPLOY HUB ---
  Widget _buildStep2Station() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Step 2: Deploy Station Hub', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => setState(() => _currentStep = 0)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Configure a physical location hub under brand workspace of "${_businessNameController.text}".', style: const TextStyle(color: Color(0xFF8A8A8A))),
          const SizedBox(height: 24),
          _buildTextField('Hub / Station Name', _hubNameController, Icons.location_on),
          const SizedBox(height: 16),
          _buildTextField('Geolocation Address', _hubAddressController, Icons.pin_drop),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField('Latitude', _latController, Icons.map)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Longitude', _lngController, Icons.map)),
            ],
          ),
          const SizedBox(height: 16),
          // Rate card dropdown select
          const Text('Select Billable Rate Card', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: const Color(0xFF0F0F0F), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A2A2A))),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedRateCardId.isNotEmpty ? _selectedRateCardId : null,
                dropdownColor: const Color(0xFF141414),
                style: const TextStyle(color: Colors.white),
                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4ADDA2)),
                isExpanded: true,
                items: _rateCards.map((rc) {
                  return DropdownMenuItem<String>(
                    value: rc['id'].toString(),
                    child: Text('${rc['name']} (\$${rc['per_kwh_fee']}/kWh + \$${rc['per_minute_fee']}/min)'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRateCardId = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: () => setState(() => _currentStep = 0), child: const Text('Back', style: TextStyle(color: Color(0xFF8A8A8A)))),
              ElevatedButton.icon(
                onPressed: _deployHub,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ADDA2), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Deploy Hub', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          )
        ],
      ),
    );
  }

  // --- STEP 3: REGISTER CHARGER CABINET ---
  Widget _buildStep3Charger() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Step 3: Register OCPP Cabinet', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => setState(() => _currentStep = 1)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Provision a new physical cabinet inside Station ID: $_createdStationId.', style: const TextStyle(color: Color(0xFF8A8A8A))),
          const SizedBox(height: 24),
          _buildTextField('Hardware Charger ID (OCPP Identity)', _chargerIdController, Icons.vpn_key),
          const SizedBox(height: 16),
          _buildTextField('Model Number / Manufacturer', _modelController, Icons.router),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField('Diagnostic Voltage (V)', _voltageController, Icons.bolt)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Temp Limit (°C)', _temperatureController, Icons.thermostat)),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: () => setState(() => _currentStep = 1), child: const Text('Back', style: TextStyle(color: Color(0xFF8A8A8A)))),
              ElevatedButton.icon(
                onPressed: _provisionCharger,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ADDA2), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                icon: const Icon(Icons.settings_input_hdmi),
                label: const Text('Provision Cabinet', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          )
        ],
      ),
    );
  }

  // --- STEP 4: CONFIGURE CHARGING GUNS ---
  Widget _buildStep4Guns() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 650),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Step 4: Configure Charging Guns (${_chargerIdController.text})', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => setState(() => _currentStep = 2)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Configure distinct charging connectors/cables under this physical cabinet.', style: TextStyle(color: Color(0xFF8A8A8A))),
          const SizedBox(height: 24),

          // Configured Guns Table List
          Container(
            decoration: BoxDecoration(color: const Color(0xFF0F0F0F), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(const Color(0xFF050505)),
                columns: const [
                  DataColumn(label: Text('Gun #', style: TextStyle(color: Color(0xFF8A8A8A)))),
                  DataColumn(label: Text('Type', style: TextStyle(color: Color(0xFF8A8A8A)))),
                  DataColumn(label: Text('Max Power', style: TextStyle(color: Color(0xFF8A8A8A)))),
                  DataColumn(label: Text('Action', style: TextStyle(color: Color(0xFF8A8A8A)))),
                ],
                rows: _configuredGuns.map((gun) {
                  return DataRow(cells: [
                    DataCell(Text('Gun ${gun['gun_index']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    DataCell(Text('${gun['connector_type']}', style: const TextStyle(color: Color(0xFF4ADDA2), fontFamily: 'monospace'))),
                    DataCell(Text('${gun['max_kw_output']} kW', style: const TextStyle(color: Colors.white))),
                    DataCell(IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                      onPressed: () {
                        setState(() {
                          _configuredGuns.remove(gun);
                          // re-index
                          for (int i = 0; i < _configuredGuns.length; i++) {
                            _configuredGuns[i]['gun_index'] = i + 1;
                          }
                        });
                      },
                    ))
                  ]);
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Add gun button
          OutlinedButton.icon(
            onPressed: _showAddGunDialog,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF00F0FF), side: const BorderSide(color: Color(0xFF00F0FF)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.add_link),
            label: const Text('Add Connector Cable'),
          ),

          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: () => setState(() => _currentStep = 2), child: const Text('Back', style: TextStyle(color: Color(0xFF8A8A8A)))),
              ElevatedButton.icon(
                onPressed: _submitChargingGuns,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ADDA2), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                icon: const Icon(Icons.save),
                label: const Text('Save Connectors & Advance', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          )
        ],
      ),
    );
  }

  void _showAddGunDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF141414),
              title: const Text('Add Connector Gun', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Connector Type', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _tempConnectorType,
                    dropdownColor: const Color(0xFF141414),
                    style: const TextStyle(color: Colors.white),
                    isExpanded: true,
                    items: ['CCS2', 'Type2', 'CHAdeMO', 'GB_T'].map((t) {
                      return DropdownMenuItem(value: t, child: Text(t));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => _tempConnectorType = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField('Max Capacity (kW)', _tempKwController, Icons.battery_saver, isNumber: true),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Color(0xFF8A8A8A)))),
                ElevatedButton(
                  onPressed: _addGunLocal,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ADDA2), foregroundColor: Colors.black),
                  child: const Text('Add'),
                )
              ],
            );
          }
        );
      }
    );
  }

  // --- STEP 5: QR CODE MAPPINGS ---
  Widget _buildStep5QR() {
    return Wrap(
      spacing: 40,
      runSpacing: 40,
      children: [
        // QR display sticker printable list
        Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF2A2A2A))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Step 5: Generate & Map QR Stickers', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Stickers printed below have unique IDs mapped directly to individual connectors.', style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 13)),
              const SizedBox(height: 24),
              if (!_qrGenerated)
                const Center(child: Text('Generating QR codes...'))
              else
                Column(
                  children: _mappedQRs.map((map) {
                    final shortUrl = map['short_url'] ?? 'https://app.bleuright.com/charge?qr=${map['qr_id']}';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)]
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.bolt, color: Colors.green, size: 24),
                                  const SizedBox(width: 8),
                                  Text(map['charger_id'], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                child: Text('GUN ${map['gun_index']}', style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
                          QrImageView(
                            data: shortUrl,
                            version: QrVersions.auto,
                            size: 180.0,
                            eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                            dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                          ),
                          const SizedBox(height: 16),
                          const Text('SCAN SECURELY TO CHARGE', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.1)),
                          Text(map['qr_id'], style: const TextStyle(color: Colors.grey, fontSize: 10, fontFamily: 'monospace')),
                        ],
                      ),
                    );
                  }).toList(),
                )
            ],
          ),
        ),

        // End-to-end simulated workflow panel
        Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF00F0FF).withOpacity(0.02),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.2)),
            boxShadow: [BoxShadow(color: const Color(0xFF00F0FF).withOpacity(0.01), blurRadius: 30)]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Verify End-to-End Workflow', style: TextStyle(color: Color(0xFF00F0FF), fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Simulate a consumer scanning a gun sticker and initiating charging.', style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 13)),
              const SizedBox(height: 32),
              if (_mappedQRs.isEmpty)
                const Center(child: Text('Setup QR mappings to enable simulation.', style: TextStyle(color: Color(0xFF8A8A8A))))
              else
                ..._mappedQRs.map((map) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mock User App Scan', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text('Simulate scan of ${map['qr_id']}', style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _simulateScan(map['qr_id']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00F0FF),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          icon: const Icon(Icons.qr_code_scanner, size: 16),
                          label: const Text('Scan & Charge', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  );
                }).toList(),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentStep = 0;
                    _qrGenerated = false;
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ADDA2), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                icon: const Icon(Icons.done_all),
                label: const Text('Complete Onboarding Flow', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        )
      ],
    );
  }

  Future<void> _simulateScan(String qrId) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/api/payments/qr-initiate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'qr_id': qrId,
          'user_id': 'USER-APP-999' // Hardcoded demo consumer
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF141414),
              title: const Row(
                children: [
                  Icon(Icons.flash_on, color: Color(0xFF00F0FF)),
                  SizedBox(width: 8),
                  Text('Charging Successfully Started!', style: TextStyle(color: Color(0xFF00F0FF))),
                ],
              ),
              content: Text(
                'Connector Gun ${data['gun_index']} status updated to CHARGING.\n\nPre-Auth Deducted: \$${data['pre_auth_deducted']}\nRemaining Balance: \$${data['remaining_balance']}\nSession ID: ${data['session_id']}',
                style: const TextStyle(color: Colors.white),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ADDA2), foregroundColor: Colors.black),
                  child: const Text('Close'),
                )
              ],
            ),
          );
        }
      } else {
        throw Exception(data['error'] ?? 'Payment failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Simulation Error: ${e.toString()}'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- REUSABLE INPUT HELPER ---
  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF8A8A8A)),
            filled: true,
            fillColor: const Color(0xFF0F0F0F),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
