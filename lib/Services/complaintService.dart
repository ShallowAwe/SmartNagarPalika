import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import 'package:smart_nagarpalika/Model/coplaintModel.dart';
// import 'package:cached_network_image/cached_network_image.dart';

class ComplaintService {
  static ComplaintService? _instance;
  static ComplaintService get instance => _instance ??= ComplaintService._();
  ComplaintService._();

  final String _baseUrl =
      'http://192.168.1.34:8080/complaints/register-with-images';
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

  Future<void> submitComplaint(
    ComplaintModel complaint,
    String username,
  ) async {
    List<String> compressedFilePaths =
        []; // Track compressed file paths for cleanup

    try {
      print('Starting complaint submission...');
      print('URL: $_baseUrl');
      print('Username: $username');
      print('Description: ${complaint.description}');
      print('Category: ${complaint.category}');
      print('Location: ${complaint.address}');
      print('Latitude: ${complaint.location?.latitude}');
      print('Longitude: ${complaint.location?.longitude}');
      print('Attachments count: ${complaint.attachments.length}');

      if (complaint.location?.latitude == null ||
          complaint.location?.longitude == null) {
        throw Exception('Location data is required');
      }

      final uri = Uri.parse(_baseUrl);
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(getAuthHeaders());

      request.fields['username'] = username;
      request.fields['description'] = complaint.description;
      request.fields['category'] = complaint.category;
      request.fields['location'] = complaint.address;
      request.fields['latitude'] = complaint.location!.latitude.toString();
      request.fields['longitude'] = complaint.location!.longitude.toString();

      print('Request fields: ${request.fields}');

      int imageCount = 0;

      for (String imagePath in complaint.attachments) {
        if (imagePath.isNotEmpty && File(imagePath).existsSync()) {
          final file = File(imagePath);
          print('Processing image ${imageCount + 1}: ${file.path}');
          print('Original file size: ${await file.length()} bytes');

          try {
            // Create a unique compressed file path
            final fileName = path.basename(imagePath);
            final compressedFileName =
                'compressed_${DateTime.now().millisecondsSinceEpoch}_$fileName';
            final compressedPath = path.join(
              path.dirname(imagePath),
              compressedFileName,
            );

            // Compress the image
            final compressedFile =
                await FlutterImageCompress.compressAndGetFile(
                  file.path,
                  compressedPath,
                  quality: 70, // Better quality balance
                  minWidth: 1024, // Max width
                  minHeight: 1024, // Max height
                );

            if (compressedFile != null) {
              // Verify the compressed file exists and has content
              final compressedFileSize = await compressedFile.length();
              if (compressedFileSize > 0) {
                print('Compressed file size: $compressedFileSize bytes');
                print(
                  'Compression ratio: ${((await file.length() - compressedFileSize) / await file.length() * 100).toStringAsFixed(1)}%',
                );

                // Add to request
                final multipartFile = await http.MultipartFile.fromPath(
                  'images',
                  compressedFile.path,
                );
                request.files.add(multipartFile);
                compressedFilePaths.add(compressedFile.path);
                imageCount++;
              } else {
                print('Compressed file is empty for: $imagePath');
                // Fallback to original file
                final multipartFile = await http.MultipartFile.fromPath(
                  'images',
                  file.path,
                );
                request.files.add(multipartFile);
                imageCount++;
              }
            } else {
              print('Compression failed for: $imagePath');
              // Fallback to original file if compression fails
              final multipartFile = await http.MultipartFile.fromPath(
                'images',
                file.path,
              );
              request.files.add(multipartFile);
              imageCount++;
            }
          } catch (e) {
            print('Error compressing image $imagePath: $e');
            // Fallback to original file
            final multipartFile = await http.MultipartFile.fromPath(
              'images',
              file.path,
            );
            request.files.add(multipartFile);
            imageCount++;
          }
        } else {
          print('Skipping invalid image path: $imagePath');
        }
      }

      print('Total images added: $imageCount');

      if (imageCount == 0) {
        throw Exception('At least one valid image is required');
      }

      // Test connectivity first
      print('Testing connectivity to $_baseUrl...');
      try {
        final testResponse = await http
            .get(
              Uri.parse(
                _baseUrl.replaceAll('/register-with-images', '/health'),
              ),
            )
            .timeout(const Duration(seconds: 10));
        print('Connectivity test status: ${testResponse.statusCode}');
      } catch (e) {
        print('Connectivity test failed: $e');
        // Continue anyway, as the health endpoint might not exist
      }

      print('Sending request...');
      print(
        'Total request size: ${request.fields.length} fields + ${request.files.length} files',
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60), // Increased timeout to 60 seconds
        onTimeout: () {
          throw Exception('Request timeout after 60 seconds');
        },
      );

      print('Response status: ${streamedResponse.statusCode}');
      final response = await http.Response.fromStream(streamedResponse);
      print('Response body: ${response.body}');
      print('Response headers: ${response.headers}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Complaint submitted successfully: ${response.body}');
      } else {
        print('Submission failed: ${response.statusCode} - ${response.body}');
        throw Exception(
          'Failed to submit complaint: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error submitting complaint: $e');
      rethrow;
    } finally {
      // Clean up compressed files
      for (String compressedPath in compressedFilePaths) {
        try {
          final compressedFile = File(compressedPath);
          if (compressedFile.existsSync()) {
            await compressedFile.delete();
            print('Cleaned up compressed file: $compressedPath');
          }
        } catch (e) {
          print('Error cleaning up compressed file $compressedPath: $e');
        }
      }
    }
  }

  // api to get all complaints by username
  Future<List<ComplaintModel>> getComplaintsByUsername(String username) async {
    // Use 10.0.2.2 if running on Android emulator
    final String _getComplaintsURL =
        'http://192.168.1.34:8080/citizen/complaints/by-username?username=$username';
    final url = Uri.parse(_getComplaintsURL);

    try {
      final response = await http.get(url, headers: getAuthHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        print(data);
        List<ComplaintModel> complaints = data
            .map((json) => ComplaintModel.fromJson(json))
            .toList();
        print("complaints: $complaints");
        return complaints;
      } else {
        throw Exception(
          'Failed to fetch complaints (code: ${response.statusCode})',
        );
      }
    } catch (e) {
      log('Error fetching complaints: $e');
      rethrow;
    }
  }
}







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

