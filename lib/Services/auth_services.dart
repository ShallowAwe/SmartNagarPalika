import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:smart_nagarpalika/Services/logger_service.dart';

class AuthService {
  // Configure based on your setup:
  // For Android Emulator: "http://10.0.2.2:8080"
  // For Physical Device: "http://192.168.1.3:8080" (replace with your computer's IP)
  final String _baseUrl = "http://192.168.1.34:8080"; // Change this based on your device
  
  Future<LoginResponse?> login(String username, String password) async {
    try {
      LoggerService.instance.info('🔗 Attempting to connect to: $_baseUrl/auth/login');
      LoggerService.instance.debug('📱 Username: $username');
      
      final uri = Uri.parse("$_baseUrl/auth/login");
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
        Duration(seconds: 10), // 10 second timeout
        onTimeout: () {
          throw TimeoutException('Connection timed out after 10 seconds');
        },
      );

      LoggerService.instance.info('📊 Response status: ${response.statusCode}');
      LoggerService.instance.debug('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LoginResponse.fromJson(data);
      } else {
        LoggerService.instance.warning('❌ Login failed with status: ${response.statusCode}');
        LoggerService.instance.debug('❌ Response body: ${response.body}');
        return null;
      }
      
    } on TimeoutException catch (e) {
      LoggerService.instance.error('⏱️ Timeout error: $e');
      rethrow;
    } on SocketException catch (e) {
      LoggerService.instance.error('🔌 Socket error: $e');
      LoggerService.instance.info('💡 This usually means:');
      LoggerService.instance.info('   - Server is not running');
      LoggerService.instance.info('   - Wrong IP address');
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
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {"Accept": "application/json"},
      ).timeout(Duration(seconds: 5));
      
      LoggerService.instance.info('🧪 Connectivity test result: ${response.statusCode}');
      return true;
    } catch (e) {
      LoggerService.instance.error('🧪 Connectivity test failed: $e');
      return false;
    }
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
      username: json["username"],
      role: json["role"],
      employeeDetails: json["employeeDetails"] != null
          ? EmployeeDetails.fromJson(json["employeeDetails"])
          : null,
    );
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
      firstName: json["firstName"],
      lastName: json["lastName"],
      phoneNumber: json["phoneNumber"],
      departmentName: json["departmentName"],
      wardNames: List<String>.from(json["wardNames"]),
    );
  }
}