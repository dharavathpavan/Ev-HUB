import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config.dart';

class VendorOpsService {
  static Uri _uri(String path) => Uri.parse('${Config.apiBaseUrl}$path');

  static Future<Map<String, dynamic>> fetchOperations() async {
    final response = await http.get(_uri('/api/vendors/operations')).timeout(const Duration(seconds: 8));
    if (response.statusCode >= 400) {
      throw Exception('Vendor operations unavailable');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> addCharger({
    required String stationName,
    required String location,
    required String chargerId,
    required String ocppId,
    required double maxKw,
  }) async {
    final response = await http.post(
      _uri('/api/vendors/chargers'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'station_name': stationName,
        'location': location,
        'charger_id': chargerId,
        'ocpp_charge_point_id': ocppId,
        'max_kw_output': maxKw,
      }),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> configureCharger({
    required String chargerId,
    required String connectorType,
    required int gunIndex,
    required String rateCardId,
    required double maxKw,
    required String razorpayQrId,
  }) async {
    final response = await http.post(
      _uri('/api/vendors/chargers/$chargerId/configure'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'connector_type': connectorType,
        'gun_index': gunIndex,
        'rate_card_id': rateCardId,
        'max_kw_output': maxKw,
        'razorpay_qr_id': razorpayQrId,
      }),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> simulateRazorpayWebhook(String razorpayQrId) async {
    final response = await http.post(
      _uri('/api/payments/razorpay/webhook'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'event': 'qr_code.credited',
        'payload': {
          'payment': {
            'entity': {
              'id': 'pay_demo_${DateTime.now().millisecondsSinceEpoch}',
              'amount': 50000,
              'qr_id': razorpayQrId,
              'notes': {'razorpay_qr_id': razorpayQrId, 'user_id': 'USER-UPI-DEMO', 'gun_index': 1}
            }
          }
        }
      }),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> stopSession(String sessionId) async {
    final response = await http.post(
      _uri('/api/charging/stop'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'session_id': sessionId, 'reason': 'vendor_stop'}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
