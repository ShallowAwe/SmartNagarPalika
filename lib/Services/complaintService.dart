import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import 'package:smart_nagarpalika/Model/coplaintModel.dart';
import 'logger_service.dart';
// import 'package:cached_network_image/cached_network_image.dart';

class ComplaintService {
  static ComplaintService? _instance;
  static ComplaintService get instance => _instance ??= ComplaintService._();
  ComplaintService._();

  final String _baseUrl =
      'http://192.168.1.34:8080/complaints/register-with-images';
  final String _username = 'user1';
  final String _password = 'user1';
  final _logger = LoggerService.instance;

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
    _logger.methodEntry('submitComplaint', {
      'username': username,
      'description': complaint.description,
      'departmentId': complaint.departmentId,
      'attachmentsCount': complaint.attachments.length,
    });

    List<String> compressedFilePaths =
        []; // Track compressed file paths for cleanup

    try {
      _logger.info('Starting complaint submission to $_baseUrl');
      _logger.debug('Complaint details', {
        'username': username,
        'description': complaint.description,
        'category': complaint.departmentId,
        'location': complaint.address,
        'latitude': complaint.location?.latitude,
        'longitude': complaint.location?.longitude,
        'attachmentsCount': complaint.attachments.length,
      });

      if (complaint.location?.latitude == null ||
          complaint.location?.longitude == null) {
        _logger.error('Location data is missing');
        throw Exception('Location data is required');
      }

      final uri = Uri.parse(_baseUrl);
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(getAuthHeaders());

      request.fields['username'] = username;
      request.fields['description'] = complaint.description;
      request.fields['department'] = complaint.departmentId.toString();
      request.fields['location'] = complaint.address;
      request.fields['latitude'] = complaint.location!.latitude.toString();
      request.fields['longitude'] = complaint.location!.longitude.toString();

      _logger.debug('Request fields prepared', request.fields);

      int imageCount = 0;

      for (String imagePath in complaint.attachments) {
        if (imagePath.isNotEmpty && File(imagePath).existsSync()) {
          final file = File(imagePath);
          _logger.imageProcessing('processing', file.path, {
            'imageNumber': imageCount + 1,
            'originalSize': await file.length(),
          });

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
                final originalSize = await file.length();
                final compressionRatio =
                    ((originalSize - compressedFileSize) / originalSize * 100)
                        .toStringAsFixed(1);

                _logger.imageProcessing(
                  'compressed successfully',
                  compressedFile.path,
                  {
                    'originalSize': originalSize,
                    'compressedSize': compressedFileSize,
                    'compressionRatio': '$compressionRatio%',
                  },
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
                _logger.warning(
                  'Compressed file is empty, using original',
                  null,
                  null,
                );
                // Fallback to original file
                final multipartFile = await http.MultipartFile.fromPath(
                  'images',
                  file.path,
                );
                request.files.add(multipartFile);
                imageCount++;
              }
            } else {
              _logger.warning(
                'Compression failed, using original file',
                null,
                null,
              );
              // Fallback to original file if compression fails
              final multipartFile = await http.MultipartFile.fromPath(
                'images',
                file.path,
              );
              request.files.add(multipartFile);
              imageCount++;
            }
          } catch (e) {
            _logger.error('Error compressing image $imagePath', e);
            // Fallback to original file
            final multipartFile = await http.MultipartFile.fromPath(
              'images',
              file.path,
            );
            request.files.add(multipartFile);
            imageCount++;
          }
        } else {
          _logger.warning('Skipping invalid image path: $imagePath');
        }
      }

      _logger.info('Total images processed: $imageCount');

      if (imageCount == 0) {
        _logger.error('No valid images found');
        throw Exception('At least one valid image is required');
      }

      // Test connectivity first
      _logger.info('Testing connectivity to $_baseUrl...');
      try {
        final testResponse = await http
            .get(
              Uri.parse(
                _baseUrl.replaceAll('/register-with-images', '/health'),
              ),
            )
            .timeout(const Duration(seconds: 10));
        _logger.debug('Connectivity test status: ${testResponse.statusCode}');
      } catch (e) {
        _logger.warning('Connectivity test failed: $e');
        // Continue anyway, as the health endpoint might not exist
      }

      _logger.info('Sending complaint submission request...');
      _logger.debug('Request details', {
        'fieldsCount': request.fields.length,
        'filesCount': request.files.length,
      });

      _logger.apiRequest('POST', _baseUrl, getAuthHeaders(), request.fields);

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60), // Increased timeout to 60 seconds
        onTimeout: () {
          _logger.error('Request timeout after 60 seconds');
          throw Exception('Request timeout after 60 seconds');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      _logger.apiResponse('POST', _baseUrl, response.statusCode, response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.info('Complaint submitted successfully');
        _logger.methodExit('submitComplaint', 'Success');
      } else {
        _logger.error(
          'Complaint submission failed',
          'HTTP ${response.statusCode}: ${response.body}',
        );
        _logger.methodExit('submitComplaint', 'Failed');
        throw Exception(
          'Failed to submit complaint: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      _logger.error('Error submitting complaint', e);
      _logger.methodExit('submitComplaint', 'Exception occurred');
      rethrow;
    } finally {
      // Clean up compressed files
      _logger.info('Cleaning up compressed files...');
      for (String compressedPath in compressedFilePaths) {
        try {
          final compressedFile = File(compressedPath);
          if (compressedFile.existsSync()) {
            await compressedFile.delete();
            _logger.debug('Cleaned up compressed file: $compressedPath');
          }
        } catch (e) {
          _logger.error('Error cleaning up compressed file $compressedPath', e);
        }
      }
    }
  }

  // api to get all complaints by username
  Future<List<ComplaintModel>> getComplaintsByUsername(String username) async {
    _logger.methodEntry('getComplaintsByUsername', {'username': username});

    // Use 10.0.2.2 if running on Android emulator
    final String _getComplaintsURL =
        'http://192.168.1.34:8080/citizen/complaints/by-username?username=$username';
    final url = Uri.parse(_getComplaintsURL);

    try {
      _logger.apiRequest('GET', _getComplaintsURL, getAuthHeaders());

      final response = await http.get(url, headers: getAuthHeaders());

      _logger.apiResponse(
        'GET',
        _getComplaintsURL,
        response.statusCode,
        response.body,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        List<ComplaintModel> complaints = data
            .map((json) => ComplaintModel.fromJson(json))
            .toList();

        _logger.info(
          'Successfully fetched ${complaints.length} complaints for user: $username',
        );
        _logger.methodExit(
          'getComplaintsByUsername',
          '${complaints.length} complaints loaded',
        );
        return complaints;
      } else {
        _logger.error(
          'Failed to fetch complaints',
          'HTTP ${response.statusCode}: ${response.body}',
        );
        _logger.methodExit(
          'getComplaintsByUsername',
          'HTTP Error ${response.statusCode}',
        );
        throw Exception(
          'Failed to fetch complaints (code: ${response.statusCode})',
        );
      }
    } catch (e) {
      _logger.error('Error fetching complaints', e);
      _logger.methodExit('getComplaintsByUsername', 'Exception occurred');
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

