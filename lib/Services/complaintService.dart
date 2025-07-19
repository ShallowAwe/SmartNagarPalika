import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:smart_nagarpalika/Model/coplaintModel.dart';

class ComplaintService {
  static ComplaintService? _instance;
  static ComplaintService get instance => _instance ??= ComplaintService._();
  ComplaintService._();

  final String _baseUrl = 'http://10.0.2.2:8080/complaints/register-with-images';

  Future<void> submitComplaint(ComplaintModel complaint, String username) async {
    try {
      print('🚀 Starting complaint submission...');
      print('📍 URL: $_baseUrl');
      print('👤 Username: $username');
      print('📝 Description: ${complaint.description}');
      print('📂 Category: ${complaint.category}');
      print('🗺️ Location: ${complaint.address}');
      print('🌐 Latitude: ${complaint.location?.latitude}');
      print('🌐 Longitude: ${complaint.location?.longitude}');
      print('📎 Attachments count: ${complaint.attachments.length}');

      // Validate location data
      if (complaint.location?.latitude == null || complaint.location?.longitude == null) {
        throw Exception('Location data is required');
      }

      final uri = Uri.parse(_baseUrl);
      final request = http.MultipartRequest('POST', uri);
      
      // Add fields
      request.fields['username'] = username;
      request.fields['description'] = complaint.description;
      request.fields['category'] = complaint.category;
      request.fields['location'] = complaint.address;
      request.fields['latitude'] = complaint.location!.latitude.toString();
      request.fields['longitude'] = complaint.location!.longitude.toString();

      print('📋 Request fields: ${request.fields}');

      // Add images
      int imageCount = 0;
      for (String imagePath in complaint.attachments) {
        if (imagePath.isNotEmpty && File(imagePath).existsSync()) {
          final file = File(imagePath);
          print('📸 Adding image ${imageCount + 1}: ${file.path}');
          print('📏 File size: ${await file.length()} bytes');
          
          final multipartFile = await http.MultipartFile.fromPath(
            'images', // This should match @RequestPart("images") in controller
            file.path,
          );
          request.files.add(multipartFile);
          imageCount++;
        } else {
          print('⚠️ Skipping invalid image path: $imagePath');
        }
      }

      print('📸 Total images added: $imageCount');

      if (imageCount == 0) {
        throw Exception('At least one valid image is required');
      }

      print('🌐 Sending request...');
      final streamedResponse = await request.send().timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout after 30 seconds');
        },
      );

      print('📡 Response status: ${streamedResponse.statusCode}');
      final response = await http.Response.fromStream(streamedResponse);
      print('📄 Response body: ${response.body}');
      print('🔧 Response headers: ${response.headers}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Complaint submitted successfully: ${response.body}');
      } else {
        print('❌ Submission failed: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to submit complaint: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error submitting complaint: $e');
      rethrow;
    }
  }
}


  // Future<List<ComplaintModel>> getComplaints() async {
  //   try {
  //     final response = await http.get(Uri.parse(_baseUrl));

  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = jsonDecode(response.body);
  //       return data.map((json) => ComplaintModel.fromJson(json)).toList();
  //     } else {
  //       throw Exception('Failed to fetch complaints: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     log('Error fetching complaints: $e');
  //     rethrow;
  //   }
  // }

  // Future<ComplaintModel?> getComplaintById(String id) async {
  //   try {
  //     final response = await http.get(Uri.parse('$_baseUrl/$id'));

  //     if (response.statusCode == 200) {
  //       return ComplaintModel.fromJson(jsonDecode(response.body));
  //     } else if (response.statusCode == 404) {
  //       return null;
  //     } else {
  //       throw Exception('Failed to fetch complaint: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     log('Error getting complaint by ID: $e');
  //     rethrow;
  //   }
  // }

  // Future<void> updateComplaintStatus(String id, String newStatus) async {
  //   try {
  //     final response = await http.put(
  //       Uri.parse('$_baseUrl/$id/status'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode({'status': newStatus}),
  //     );

  //     if (response.statusCode == 200) {
  //       log('Complaint status updated successfully');
  //     } else {
  //       throw Exception('Failed to update status: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     log('Error updating complaint status: $e');
  //     rethrow;
  //   }
  // }

