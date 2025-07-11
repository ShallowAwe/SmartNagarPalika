import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:smart_nagarpalika/Model/coplaintModel.dart';

class ComplaintService {
  static ComplaintService? _instance;
  static ComplaintService get instance => _instance ??= ComplaintService._();
  ComplaintService._();

  final String _baseUrl = 'https://your-backend.com/api/complaints';

  Future<void> submitComplaint(ComplaintModel complaint) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(complaint.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        log('Complaint submitted successfully');
      } else {
        throw Exception('Failed to submit complaint: ${response.statusCode}');
      }
    } catch (e) {
      log('Error submitting complaint: $e');
      rethrow;
    }
  }

  Future<List<ComplaintModel>> getComplaints() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ComplaintModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch complaints: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching complaints: $e');
      rethrow;
    }
  }

  Future<ComplaintModel?> getComplaintById(String id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$id'));

      if (response.statusCode == 200) {
        return ComplaintModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to fetch complaint: ${response.statusCode}');
      }
    } catch (e) {
      log('Error getting complaint by ID: $e');
      rethrow;
    }
  }

  Future<void> updateComplaintStatus(String id, String newStatus) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id/status'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        log('Complaint status updated successfully');
      } else {
        throw Exception('Failed to update status: ${response.statusCode}');
      }
    } catch (e) {
      log('Error updating complaint status: $e');
      rethrow;
    }
  }
}
