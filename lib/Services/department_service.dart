import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:smart_nagarpalika/Model/departmentModel.dart';
import 'logger_service.dart';

class DepartmentService {
  static DepartmentService? _instance;
  static DepartmentService get instance => _instance ??= DepartmentService._();
  DepartmentService._();

  final String _baseUrl =
      'http://192.168.1.35:8080/citizen/get_departments_user';
  final String username = 'user1';
  final String password = 'user1';
  final _logger = LoggerService.instance;

  Future<List<Department>> getDepartments() async {
    _logger.methodEntry('getDepartments');

    try {
      final headers = {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$username:$password'))}',
      };

      _logger.apiRequest('GET', _baseUrl, headers);

      final response = await http.get(Uri.parse(_baseUrl), headers: headers);

      _logger.apiResponse('GET', _baseUrl, response.statusCode, response.body);

      if (response.statusCode == 200) {
        final departments = (jsonDecode(response.body) as List)
            .map((e) => Department.fromJson(e))
            .toList();

        _logger.info('Successfully loaded ${departments.length} departments');
        _logger.methodExit(
          'getDepartments',
          '${departments.length} departments loaded',
        );
        return departments;
      } else {
        _logger.error(
          'Failed to load departments',
          'HTTP ${response.statusCode}: ${response.body}',
        );
        _logger.methodExit(
          'getDepartments',
          'HTTP Error ${response.statusCode}',
        );
        throw Exception('Failed to load departments ${response.statusCode}');
      }
    } catch (e) {
      _logger.error('Exception while loading departments', e);
      _logger.methodExit('getDepartments', 'Exception occurred');
      rethrow;
    }
  }
}
