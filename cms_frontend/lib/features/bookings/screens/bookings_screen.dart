import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  late final Stream<List<Map<String, dynamic>>> _bookingsStream;

  @override
  void initState() {
    super.initState();
    _bookingsStream = Supabase.instance.client
        .from('bookings')
        .stream(primaryKey: ['booking_id'])
        .order('start_time', ascending: true);
  }

  Future<void> _showCreateBookingModal() async {
    showDialog(
      context: context,
      builder: (context) => const _CreateBookingModal(),
    );
  }

  Future<void> _updateBookingStatus(String bookingId, String status) async {
    try {
      await Supabase.instance.client
          .from('bookings')
          .update({'status': status, 'updated_at': DateTime.now().toUtc().toIso8601String()})
          .eq('booking_id', bookingId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking marked as $status.'),
            backgroundColor: const Color(0xFF4ADDA2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update booking.'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return const Color(0xFF4ADDA2);
      case 'Upcoming':
        return Colors.amber;
      case 'Completed':
        return Colors.blueAccent;
      case 'Cancelled':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
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
              const Text(
                'Slot Bookings & Reservations',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              ElevatedButton.icon(
                onPressed: _showCreateBookingModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ADDA2),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('New Booking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // StreamBuilder for Real-Time UI
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _bookingsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator(color: Color(0xFF4ADDA2))),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Text('Error loading bookings. Please run the SQL migration.\n${snapshot.error}', style: const TextStyle(color: Colors.redAccent, fontSize: 16)),
                  ),
                );
              }

              final bookings = snapshot.data ?? [];

              if (bookings.isEmpty) {
                return const Center(child: Text('No bookings found.', style: TextStyle(color: Color(0xFF8A8A8A))));
              }

              return Container(
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
                    dataRowMinHeight: 60,
                    dataRowMaxHeight: 80,
                    horizontalMargin: 32,
                    columnSpacing: 24,
                    columns: const [
                      DataColumn(label: Text('Customer', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Station / Charger', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Schedule', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Est. Price', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Status', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Actions', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                    ],
                    rows: bookings.map((booking) {
                      final status = booking['status'] ?? 'Upcoming';
                      final startTime = DateTime.parse(booking['start_time']).toLocal();
                      final endTime = DateTime.parse(booking['end_time']).toLocal();
                      final timeFormat = DateFormat('MMM d, h:mm a').format(startTime);
                      final endFormat = DateFormat('h:mm a').format(endTime);
                      
                      final durationStr = '${endTime.difference(startTime).inHours}h ${endTime.difference(startTime).inMinutes.remainder(60)}m';

                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: const Color(0xFF4ADDA2).withValues(alpha: 0.2),
                                  child: Text(
                                    (booking['user_name'] ?? '?').substring(0, 1).toUpperCase(),
                                    style: const TextStyle(color: Color(0xFF4ADDA2), fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(booking['user_name'] ?? 'Unknown User', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          DataCell(
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(booking['station_id'] ?? '-', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                Text(booking['charger_id'] ?? 'Any Charger', style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                              ],
                            ),
                          ),
                          DataCell(
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$timeFormat - $endFormat', style: const TextStyle(color: Colors.white)),
                                Text(durationStr, style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(booking['total_price'] != null ? '\$${booking['total_price']}' : '-', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(color: _getStatusColor(status).withValues(alpha: 0.3)),
                              ),
                              child: Text(status, style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                if (status == 'Upcoming')
                                  IconButton(
                                    icon: const Icon(Icons.play_circle_fill, color: Color(0xFF4ADDA2)),
                                    tooltip: 'Start Booking',
                                    onPressed: () => _updateBookingStatus(booking['booking_id'], 'Active'),
                                  ),
                                if (status == 'Active')
                                  IconButton(
                                    icon: const Icon(Icons.stop_circle, color: Colors.blueAccent),
                                    tooltip: 'Complete Booking',
                                    onPressed: () => _updateBookingStatus(booking['booking_id'], 'Completed'),
                                  ),
                                if (status == 'Upcoming' || status == 'Active')
                                  IconButton(
                                    icon: const Icon(Icons.cancel, color: Colors.redAccent),
                                    tooltip: 'Cancel Booking',
                                    onPressed: () => _updateBookingStatus(booking['booking_id'], 'Cancelled'),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

class _CreateBookingModal extends StatefulWidget {
  const _CreateBookingModal();

  @override
  State<_CreateBookingModal> createState() => _CreateBookingModalState();
}

class _CreateBookingModalState extends State<_CreateBookingModal> {
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  List<dynamic> _stations = [];
  
  String? _selectedStationId;
  String? _userName;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    _fetchStations();
  }

  Future<void> _fetchStations() async {
    try {
      final data = await Supabase.instance.client.from('stations').select('station_id, name');
      if (mounted) {
        setState(() {
          _stations = data;
          if (_stations.isNotEmpty) {
            _selectedStationId = _stations.first['station_id'] as String;
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching stations: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startTime = picked;
        else _endTime = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select date and time')));
      return;
    }
    
    _formKey.currentState!.save();
    
    setState(() => _isLoading = true);
    
    try {
      final user = Supabase.instance.client.auth.currentUser;
      
      final startDt = DateTime(
        _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
        _startTime!.hour, _startTime!.minute
      );
      final endDt = DateTime(
        _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
        _endTime!.hour, _endTime!.minute
      );
      
      await Supabase.instance.client.from('bookings').insert({
        'user_id': user?.id,
        'user_name': _userName ?? 'Admin Booking',
        'station_id': _selectedStationId,
        'start_time': startDt.toUtc().toIso8601String(),
        'end_time': endDt.toUtc().toIso8601String(),
        'status': 'Upcoming',
        'total_price': 15.00, // Mock price
      });
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking created successfully!'), backgroundColor: Color(0xFF4ADDA2)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return Dialog(
      backgroundColor: const Color(0xFF141414),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Color(0xFF2A2A2A))),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Create New Booking', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 24),
              
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Customer Name',
                  filled: true,
                  fillColor: const Color(0xFF0F0F0F),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  labelStyle: const TextStyle(color: Color(0xFF8A8A8A)),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                onSaved: (val) => _userName = val,
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Station Hub',
                  filled: true,
                  fillColor: const Color(0xFF0F0F0F),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  labelStyle: const TextStyle(color: Color(0xFF8A8A8A)),
                ),
                dropdownColor: const Color(0xFF141414),
                style: const TextStyle(color: Colors.white),
                value: _selectedStationId,
                items: _stations.map((s) => DropdownMenuItem<String>(
                  value: s['station_id'] as String,
                  child: Text('${s['name']} (${s['station_id']})'),
                )).toList(),
                onChanged: (val) => setState(() => _selectedStationId = val),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        decoration: BoxDecoration(color: const Color(0xFF0F0F0F), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_selectedDate == null ? 'Date' : dateFormat.format(_selectedDate!), style: const TextStyle(color: Colors.white)),
                            const Icon(Icons.calendar_today, color: Color(0xFF8A8A8A), size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        decoration: BoxDecoration(color: const Color(0xFF0F0F0F), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_startTime == null ? 'Start Time' : _startTime!.format(context), style: const TextStyle(color: Colors.white)),
                            const Icon(Icons.access_time, color: Color(0xFF8A8A8A), size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        decoration: BoxDecoration(color: const Color(0xFF0F0F0F), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_endTime == null ? 'End Time' : _endTime!.format(context), style: const TextStyle(color: Colors.white)),
                            const Icon(Icons.access_time, color: Color(0xFF8A8A8A), size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF8A8A8A))),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4ADDA2),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                        : const Text('Confirm Booking', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
