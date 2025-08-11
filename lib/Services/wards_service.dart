import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:smart_nagarpalika/Model/ward_model.dart';

class WardsService {
  final Logger _logger = Logger();
  final String _getWardsURL = 'http://192.168.1.35:8080/citizen/get_wards';
  final String _username = 'user1';
  final String _password = 'user1';

  Map<String, String> getAuthHeaders() {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$_username:$_password'))}';
    return {
      'Authorization': basicAuth,
      // ✅ DO NOT include Content-Type here
    };
  }

  static WardsService? _instance;
  static WardsService get instance => _instance ??= WardsService._();
  WardsService._();

  Future<List<WardModel>> getWards() async {
    final url = Uri.parse(_getWardsURL);

    _logger.i('Fetching wards from: $_getWardsURL');
    _logger.d('Request URL: $url');

    try {
      _logger.d('Initiating HTTP GET request...');
      final response = await http.get(url, headers: getAuthHeaders());

      _logger.i('Response received - Status Code: ${response.statusCode}');
      _logger.d('Response Headers: ${response.headers}');
      _logger.d('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        _logger.i('Successfully received wards data');

        final List<dynamic> data = jsonDecode(response.body);
        _logger.d('Parsed JSON data: $data');
        _logger.i('Total wards found: ${data.length}');

        List<WardModel> wards = data
            .map((json) => WardModel.fromJson(json))
            .toList();

        _logger.i(
          'Successfully converted ${wards.length} wards to WardModel objects',
        );
        return wards;
      } else {
        _logger.e('Failed to load wards - Status Code: ${response.statusCode}');
        _logger.e('Error Response Body: ${response.body}');
        throw Exception(
          'Failed to load wards - Status: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      _logger.e('Exception occurred while fetching wards: $e');
      _logger.e('Stack trace: $stackTrace');
      throw Exception('Failed to load wards: $e');
    }
  }
}
