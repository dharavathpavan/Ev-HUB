import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedReportType = 'Financial Revenue';
  String _selectedDateRange = 'Last 30 Days';
  bool _isGenerating = false;
  bool _reportReady = false;

  final List<String> _reportTypes = ['Financial Revenue', 'Station Utilization', 'Hardware Faults', 'User Activity'];
  final List<String> _dateRanges = ['Today', 'Last 7 Days', 'Last 30 Days', 'Year to Date', 'Custom Range'];

  // Mock Data
  final List<Map<String, dynamic>> _mockData = [
    {'date': '2026-05-18', 'station': 'HUB-Downtown-01', 'sessions': 42, 'energy': 1250.5, 'revenue': 350.25},
    {'date': '2026-05-18', 'station': 'HUB-Uptown-04', 'sessions': 28, 'energy': 840.2, 'revenue': 240.10},
    {'date': '2026-05-19', 'station': 'HUB-Downtown-01', 'sessions': 45, 'energy': 1300.0, 'revenue': 380.00},
    {'date': '2026-05-19', 'station': 'HUB-Westside-02', 'sessions': 15, 'energy': 420.8, 'revenue': 110.50},
    {'date': '2026-05-20', 'station': 'HUB-Downtown-01', 'sessions': 12, 'energy': 310.4, 'revenue': 95.00},
  ];

  void _generateReport() async {
    setState(() {
      _isGenerating = true;
      _reportReady = false;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isGenerating = false;
      _reportReady = true;
    });
  }

  void _handleExport(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading report as $format...'), backgroundColor: const Color(0xFF4ADDA2)),
    );
  }

  void _handlePrint() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening browser print dialog...'), backgroundColor: Colors.amber),
    );
  }

  void _handleShare() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        title: const Text('Share Report', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Generate a secure, read-only link to share this report.', style: TextStyle(color: Color(0xFF8A8A8A))),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF0F0F0F), borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Icon(Icons.link, color: Color(0xFF4ADDA2)),
                  SizedBox(width: 12),
                  Expanded(child: Text('https://evcms.com/shared/rpt_89x2z', style: TextStyle(color: Colors.white, fontFamily: 'monospace'))),
                ],
              ),
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied to clipboard!'), backgroundColor: Color(0xFF4ADDA2)));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ADDA2), foregroundColor: Colors.black),
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reports Engine', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            const Text('Generate, view, and export data across your entire network.', style: TextStyle(color: Color(0xFF8A8A8A))),
            const SizedBox(height: 40),
            
            // Configuration Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _buildDropdownField('Report Type', _reportTypes, _selectedReportType, (v) => setState(() => _selectedReportType = v!)),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildDropdownField('Date Range', _dateRanges, _selectedDateRange, (v) => setState(() => _selectedDateRange = v!)),
                  ),
                  const SizedBox(width: 24),
                  SizedBox(
                    height: 56, // Match height of text fields roughly
                    child: ElevatedButton.icon(
                      onPressed: _isGenerating ? null : _generateReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4ADDA2),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: _isGenerating 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : const Icon(Icons.analytics),
                      label: Text(_isGenerating ? 'Generating...' : 'Generate Report', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 40),

            // Main Content Area (Either Empty State or Report View)
            Expanded(
              child: _reportReady ? _buildReportView() : _buildEmptyState(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_chart_outlined, size: 80, color: const Color(0xFF8A8A8A).withValues(alpha: 0.3)),
          const SizedBox(height: 24),
          const Text('No Report Generated', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Select your parameters above and click Generate.', style: TextStyle(color: Color(0xFF8A8A8A))),
        ],
      ),
    );
  }

  Widget _buildReportView() {
    // Calculate simple totals from mock data
    final totalSessions = _mockData.fold<int>(0, (sum, item) => sum + (item['sessions'] as int));
    final totalRevenue = _mockData.fold<double>(0, (sum, item) => sum + (item['revenue'] as double));

    return Column(
      children: [
        // Action Bar & Summary
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildSummaryPill('Total Sessions: $totalSessions'),
                const SizedBox(width: 16),
                _buildSummaryPill('Total Revenue: \$${totalRevenue.toStringAsFixed(2)}', color: const Color(0xFF4ADDA2)),
              ],
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _handleShare,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2A2A2A), foregroundColor: Colors.white),
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Share'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _handlePrint,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2A2A2A), foregroundColor: Colors.white),
                  icon: const Icon(Icons.print, size: 18),
                  label: const Text('Print'),
                ),
                const SizedBox(width: 12),
                PopupMenuButton<String>(
                  onSelected: _handleExport,
                  color: const Color(0xFF141414),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(color: Colors.purpleAccent, borderRadius: BorderRadius.circular(50)),
                    child: const Row(
                      children: [
                        Icon(Icons.download, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('Export', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Icon(Icons.arrow_drop_down, color: Colors.white),
                      ],
                    ),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'CSV', child: Text('Download as CSV', style: TextStyle(color: Colors.white))),
                    const PopupMenuItem(value: 'Excel', child: Text('Download as Excel', style: TextStyle(color: Colors.white))),
                    const PopupMenuItem(value: 'PDF', child: Text('Download as PDF', style: TextStyle(color: Colors.white))),
                  ],
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 24),

        // Data Grid
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFF0F0F0F)),
                  columns: const [
                    DataColumn(label: Text('Date', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Station', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Sessions', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Energy (kWh)', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Revenue', style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.bold))),
                  ],
                  rows: _mockData.map((row) {
                    final date = DateFormat('MMM d, yyyy').format(DateTime.parse(row['date']));
                    return DataRow(
                      cells: [
                        DataCell(Text(date, style: const TextStyle(color: Colors.white))),
                        DataCell(Text(row['station'], style: const TextStyle(color: Colors.white))),
                        DataCell(Text(row['sessions'].toString(), style: const TextStyle(color: Colors.white))),
                        DataCell(Text(row['energy'].toString(), style: const TextStyle(color: Colors.white))),
                        DataCell(Text('\$${row['revenue'].toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF4ADDA2), fontWeight: FontWeight.bold))),
                      ]
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryPill(String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border.all(color: const Color(0xFF2A2A2A)),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(text, style: TextStyle(color: color ?? Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String selected, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selected,
          dropdownColor: const Color(0xFF141414),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0F0F0F),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
