import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:smart_nagarpalika/Model/complaint_response_model.dart';

class EmployeeComplaintService {
  // final String _baseUrl = "http://192.168.1.41:8080/employee";
  final String _baseUrl = "http://192.168.1.34:8080/employee";
  final String _username = "user1"; // replace with your username
  final String _password = "user1"; // replace with your password
  final empName = 'emp3';
  
  /// Fetch assigned complaints for given employee (e.g., "emp")
  Future<List<ComplaintResponseModel>> fetchAssignedComplaints() async {
    final url = Uri.parse("$_baseUrl/assignedComplaints/$empName");

    final basicAuth = 'Basic ${base64Encode(utf8.encode("$_username:$_password"))}';

    final response = await http.get(
      url,
     headers: {
      "Accept": "application/json",
      // "Authorization": basicAuth,
     }
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      // Response structure has: message, count, data
      final List<dynamic> complaintsJson = decoded["data"];

      return complaintsJson
          .map((json) => ComplaintResponseModel.fromJson(json))
          .toList();
    } else {
      throw Exception("Failed to load complaints. Status: ${response.statusCode}");
    }
  }



  /// Complete a complaint with repair description and optional images
  Future<bool> completeComplaint({
    required int complaintId,
    required String repairDescription,
    List<File>? images,
  }) async {
    final url = Uri.parse("$_baseUrl/complaints/$complaintId/complete");
    
    print('🔧 API CALL: Completing complaint ID: $complaintId');
    print('🔧 API CALL: URL: $url');
    print('🔧 API CALL: Description: $repairDescription');
    print('🔧 API CALL: Images: ${images?.length ?? 0}');
    
    // Create multipart request
    final request = http.MultipartRequest('POST', url);
    
    // Add authorization header
    final basicAuth = 'Basic ${base64Encode(utf8.encode("$_username:$_password"))}';
    request.headers['Authorization'] = basicAuth;
    request.headers['Accept'] = '*/*';
    
    // Add repair description
    request.fields['repairDescription'] = repairDescription;
    
    // Track compressed file paths for cleanup
    List<String> compressedFilePaths = [];
    
    // Add images if provided
    if (images != null && images.isNotEmpty) {
      for (int i = 0; i < images.length; i++) {
        final originalFile = images[i];
        
        try {
          // Create a unique compressed file path
          final fileName = path.basename(originalFile.path);
          final compressedFileName = 'compressed_${DateTime.now().millisecondsSinceEpoch}_$fileName';
          final compressedPath = path.join(
            path.dirname(originalFile.path),
            compressedFileName,
          );

          // Compress the image
          final compressedFile = await FlutterImageCompress.compressAndGetFile(
            originalFile.path,
            compressedPath,
            quality: 70, // Better quality balance
            minWidth: 1024, // Max width
            minHeight: 1024, // Max height
          );

          File fileToUpload = originalFile; // Default to original
          
          if (compressedFile != null) {
            // Convert XFile to File
            final compressedFileFile = File(compressedFile.path);
            
            // Verify the compressed file exists and has content
            final compressedFileSize = await compressedFileFile.length();
            if (compressedFileSize > 0) {
              final originalSize = await originalFile.length();
              final compressionRatio = ((originalSize - compressedFileSize) / originalSize * 100).toStringAsFixed(1);

              print('🔧 API CALL: Image $i compressed successfully - Original: ${originalSize} bytes, Compressed: ${compressedFileSize} bytes (${compressionRatio}% reduction)');
              
              fileToUpload = compressedFileFile;
              compressedFilePaths.add(compressedFileFile.path);
            } else {
              print('🔧 API CALL: Compressed file is empty, using original for image $i');
            }
          } else {
            print('🔧 API CALL: Compression failed, using original file for image $i');
          }
          
          final stream = http.ByteStream(fileToUpload.openRead());
          final length = await fileToUpload.length();
          
          print('🔧 API CALL: Adding image $i: ${fileToUpload.path} (${length} bytes)');
          
          final multipartFile = http.MultipartFile(
            'images',
            stream,
            length,
            filename: 'image_$i.jpg',
          );
          
          request.files.add(multipartFile);
          
        } catch (e) {
          print('🔧 API CALL: Error compressing image $i, using original: $e');
          // Fallback to original file
          final stream = http.ByteStream(originalFile.openRead());
          final length = await originalFile.length();
          
          final multipartFile = http.MultipartFile(
            'images',
            stream,
            length,
            filename: 'image_$i.jpg',
          );
          
          request.files.add(multipartFile);
        }
      }
    }
    
    try {
      print('🔧 API CALL: Sending request...');
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      print('🔧 API CALL: Response Status: ${response.statusCode}');
      print('🔧 API CALL: Response Body: $responseBody');
      
      if (response.statusCode == 200) {
        print('✅ API CALL: Complaint completed successfully!');
        
        // Clean up compressed files
        print('🔧 API CALL: Cleaning up compressed files...');
        for (String compressedPath in compressedFilePaths) {
          try {
            final compressedFile = File(compressedPath);
            if (compressedFile.existsSync()) {
              await compressedFile.delete();
              print('🔧 API CALL: Cleaned up compressed file: $compressedPath');
            }
          } catch (e) {
            print('🔧 API CALL: Error cleaning up compressed file $compressedPath: $e');
          }
        }
        
        return true; // Success
      } else {
        print('❌ API CALL: Failed to complete complaint');
        throw Exception("Failed to complete complaint. Status: ${response.statusCode}, Body: $responseBody");
      }
    } catch (e) {
      print('❌ API CALL: Error completing complaint: $e');
      
      // Clean up compressed files even on error
      print('🔧 API CALL: Cleaning up compressed files after error...');
      for (String compressedPath in compressedFilePaths) {
        try {
          final compressedFile = File(compressedPath);
          if (compressedFile.existsSync()) {
            await compressedFile.delete();
            print('🔧 API CALL: Cleaned up compressed file: $compressedPath');
          }
        } catch (cleanupError) {
          print('🔧 API CALL: Error cleaning up compressed file $compressedPath: $cleanupError');
        }
      }
      
      throw Exception("Error completing complaint: $e");
    }
  }
}
