import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_nagarpalika/Model/alert_model.dart';


class AlertService {
  final String _baseUrl = 'http://192.168.1.34:8080/citizen/get_all_alerts';

  Future<List<Alertmodel>> fetchAlerts(String username, String password) async {
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Basic ${base64Encode(utf8.encode('$username:$password'))}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Alertmodel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load alerts');
    }
  }
}
