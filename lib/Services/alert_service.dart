import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_nagarpalika/Model/alert_model.dart';
import 'package:smart_nagarpalika/config/app_config.dart';


class AlertService {
  String get _baseUrl => '${AppConfig.citizenBaseUrl}/get_all_alerts';
  
  Future<List<Alertmodel>> fetchAlerts(String username, String password) async {
    try {
      AppConfig.logApiCall('GET', _baseUrl);
      
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$username:$password'))}',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: AppConfig.timeoutSeconds));

      AppConfig.logApiCall('GET', _baseUrl, statusCode: response.statusCode);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final alerts = data.map((json) => Alertmodel.fromJson(json)).toList();
        
        if (AppConfig.isDebugMode) {
          AppConfig.logger.i('📋 Fetched ${alerts.length} alerts');
        }
        
        return alerts;
      } else {
        throw Exception('Failed to load alerts (status: ${response.statusCode})');
      }
    } catch (e) {
      AppConfig.logger.e('❌ Alert Service Error: $e');
      rethrow;
    }
  }
}