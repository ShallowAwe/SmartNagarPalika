import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:smart_nagarpalika/Services/logger_service.dart';
import '../config/app_config.dart';

class AuthService {
  // Use base URL from AppConfig (which reads from .env)
  String get _baseUrl => AppConfig.citizenBaseUrl.replaceAll('/citizen', ''); // Remove /citizen for auth endpoint
  String get _authUrl => '$_baseUrl/auth/login';
  
  Future<LoginResponse?> login(String username, String password) async {
    try {
      LoggerService.instance.info('🔗 Attempting to connect to: $_authUrl');
      LoggerService.instance.debug('📱 Username: $username');
      
      final uri = Uri.parse(_authUrl);
      LoggerService.instance.debug('🌐 Full URI: $uri');
      
      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "username": username,
          "password": password
        }),
      ).timeout(
        Duration(seconds: AppConfig.timeoutSeconds), // Use timeout from config
        onTimeout: () {
          throw TimeoutException('Connection timed out after ${AppConfig.timeoutSeconds} seconds');
        },
      );

      LoggerService.instance.info('📊 Response status: ${response.statusCode}');
      
      if (AppConfig.isDebugMode) {
        LoggerService.instance.debug('📄 Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        LoggerService.instance.info('✅ Login successful for user: $username');
        return LoginResponse.fromJson(data);
      } else {
        LoggerService.instance.warning('❌ Login failed with status: ${response.statusCode}');
        if (AppConfig.isDebugMode) {
          LoggerService.instance.debug('❌ Response body: ${response.body}');
        }
        return null;
      }
      
    } on TimeoutException catch (e) {
      LoggerService.instance.error('⏱️ Timeout error: $e');
      rethrow;
    } on SocketException catch (e) {
      LoggerService.instance.error('🔌 Socket error: $e');
      LoggerService.instance.info('💡 This usually means:');
      LoggerService.instance.info('   - Server is not running on ${_baseUrl}');
      LoggerService.instance.info('   - Wrong IP address in .env file');
      LoggerService.instance.info('   - Firewall blocking connection');
      LoggerService.instance.info('   - Network configuration issue');
      rethrow;
    } on HttpException catch (e) {
      LoggerService.instance.error('🌐 HTTP error: $e');
      rethrow;
    } on FormatException catch (e) {
      LoggerService.instance.error('📝 JSON parsing error: $e');
      rethrow;
    } catch (e) {
      LoggerService.instance.error('❌ Unexpected error: $e');
      rethrow;
    }
  }
  
  // Test connectivity method
  Future<bool> testConnectivity() async {
    try {
      LoggerService.instance.info('🧪 Testing connectivity to: $_baseUrl');
      
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {"Accept": "application/json"},
      ).timeout(Duration(seconds: AppConfig.timeoutSeconds));
      
      LoggerService.instance.info('🧪 Connectivity test result: ${response.statusCode}');
      return response.statusCode < 500; // Accept any response that's not a server error
    } catch (e) {
      LoggerService.instance.error('🧪 Connectivity test failed: $e');
      return false;
    }
  }

  // Method to test specific endpoints
  Future<Map<String, bool>> testAllEndpoints() async {
    final results = <String, bool>{};
    
    // Test base server
    results['server'] = await testConnectivity();
    
    // Test auth endpoint specifically
    try {
      final response = await http.post(
        Uri.parse(_authUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"test": "connectivity"}),
      ).timeout(Duration(seconds: 5));
      
      results['auth'] = response.statusCode != 404; // Endpoint exists
    } catch (e) {
      results['auth'] = false;
    }
    
    // Test citizen endpoint
    try {
      final citizenUrl = AppConfig.citizenBaseUrl;
      final response = await http.get(
        Uri.parse(citizenUrl),
        headers: {"Accept": "application/json"},
      ).timeout(Duration(seconds: 5));
      
      results['citizen'] = response.statusCode < 500;
    } catch (e) {
      results['citizen'] = false;
    }
    
    // Test employee endpoint  
    try {
      final employeeUrl = AppConfig.employeeBaseUrl;
      final response = await http.get(
        Uri.parse(employeeUrl),
        headers: {"Accept": "application/json"},
      ).timeout(Duration(seconds: 5));
      
      results['employee'] = response.statusCode < 500;
    } catch (e) {
      results['employee'] = false;
    }
    
    LoggerService.instance.info('🧪 Endpoint test results: $results');
    return results;
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => 'TimeoutException: $message';
}

class LoginResponse {
  final String username;
  final String role;
  final EmployeeDetails? employeeDetails;

  LoginResponse({
    required this.username,
    required this.role,
    this.employeeDetails,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      username: json["username"] ?? '',
      role: json["role"] ?? '',
      employeeDetails: json["employeeDetails"] != null
          ? EmployeeDetails.fromJson(json["employeeDetails"])
          : null,
    );
  }

  @override
  String toString() {
    return 'LoginResponse(username: $username, role: $role, hasEmployeeDetails: ${employeeDetails != null})';
  }
}

class EmployeeDetails {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String departmentName;
  final List<String> wardNames;

  EmployeeDetails({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.departmentName,
    required this.wardNames,
  });

  factory EmployeeDetails.fromJson(Map<String, dynamic> json) {
    return EmployeeDetails(
      firstName: json["firstName"] ?? '',
      lastName: json["lastName"] ?? '',
      phoneNumber: json["phoneNumber"] ?? '',
      departmentName: json["departmentName"] ?? '',
      wardNames: json["wardNames"] != null 
          ? List<String>.from(json["wardNames"]) 
          : [],
    );
  }

  @override
  String toString() {
    return 'EmployeeDetails(firstName: $firstName, lastName: $lastName, department: $departmentName, wards: ${wardNames.length})';
  }
}