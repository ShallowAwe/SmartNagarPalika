import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:smart_nagarpalika/Model/complaint_response_model.dart';
import 'package:smart_nagarpalika/Services/Employee/employee_complaint_service.dart';
import 'package:smart_nagarpalika/Services/logger_service.dart';

/// Screen for employees to complete a complaint with repair details
class EmployeeCompleteComplaintScreen extends ConsumerStatefulWidget {
  final ComplaintResponseModel complaint;

  const EmployeeCompleteComplaintScreen({
    super.key,
    required this.complaint,
  });

  @override
  ConsumerState<EmployeeCompleteComplaintScreen> createState() => _EmployeeCompleteComplaintScreenState();
}

class _EmployeeCompleteComplaintScreenState extends ConsumerState<EmployeeCompleteComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repairDescriptionController = TextEditingController();
  final _employeeComplaintService = EmployeeComplaintService();
  final _logger = LoggerService.instance;
  
  List<File> _selectedImages = [];
  bool _isLoading = false;
  static const int _maxImages = 2; // Limit to 2 images

  @override
  void dispose() {
    _repairDescriptionController.dispose();
    super.dispose();
  }

  /// Compress image using flutter_image_compress
  Future<File?> _compressImage(File originalFile) async {
    try {
      _logger.debug('Starting image compression', {
        'originalPath': originalFile.path,
        'originalSize': await originalFile.length(),
      });

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

      if (compressedFile != null) {
        // Convert XFile to File
        final compressedFileFile = File(compressedFile.path);
        
        // Verify the compressed file exists and has content
        final compressedFileSize = await compressedFileFile.length();
        if (compressedFileSize > 0) {
          final originalSize = await originalFile.length();
          final compressionRatio = ((originalSize - compressedFileSize) / originalSize * 100).toStringAsFixed(1);

          _logger.debug('Image compressed successfully', {
            'originalSize': originalSize,
            'compressedSize': compressedFileSize,
            'compressionRatio': '$compressionRatio%',
            'compressedPath': compressedFileFile.path,
          });

          return compressedFileFile;
        } else {
          _logger.warning('Compressed file is empty, using original');
          return originalFile;
        }
      } else {
        _logger.warning('Compression failed, using original file');
        return originalFile;
      }
    } catch (e) {
      _logger.error('Error compressing image', e);
      return originalFile; // Fallback to original file
    }
  }

  /// Take photo with camera
  Future<void> _takePhoto() async {
    try {
      // Check if we've reached the image limit
      if (_selectedImages.length >= _maxImages) {
        _showSnackBar('Maximum ${_maxImages} images allowed');
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
      );

      if (photo != null) {
        final originalFile = File(photo.path);
        
        // Compress the image
        final compressedFile = await _compressImage(originalFile);
        
        if (compressedFile != null) {
          setState(() {
            _selectedImages.add(compressedFile);
          });
          
          _logger.info('Photo added successfully', {
            'originalSize': await originalFile.length(),
            'compressedSize': await compressedFile.length(),
            'totalImages': _selectedImages.length,
          });
        }
      }
    } catch (e) {
      _logger.error('Error taking photo', e);
      _showSnackBar('Error taking photo: $e');
    }
  }

  /// Remove image from selection
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  /// Complete the complaint
  Future<void> _completeComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _employeeComplaintService.completeComplaint(
        complaintId: widget.complaint.id!,
        repairDescription: _repairDescriptionController.text.trim(),
        images: _selectedImages.isNotEmpty ? _selectedImages : null,
      );

      if (success) {
        _showSnackBar('Complaint completed successfully!', isSuccess: true);
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      _logger.error('Error completing complaint', e);
      _showSnackBar('Error completing complaint: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Show snackbar message
  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Complaint'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Complaint details card
              _buildComplaintDetailsCard(),
              const SizedBox(height: 24),
              
              // Repair description field
              _buildRepairDescriptionField(),
              const SizedBox(height: 24),
              
              // Image selection section
              _buildImageSelectionSection(),
              const SizedBox(height: 32),
              
              // Complete button
              _buildCompleteButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build complaint details card
  Widget _buildComplaintDetailsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Complaint Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('ID:', '#${widget.complaint.id}'),
            _buildDetailRow('Description:', widget.complaint.description),
            _buildDetailRow('Address:', widget.complaint.address),
            _buildDetailRow('Date:', _formatDate(widget.complaint.createdAt)),
            _buildDetailRow('Status:', _capitalize(_normalizeStatus(widget.complaint.status?.toString()))),
          ],
        ),
      ),
    );
  }

  /// Build repair description field
  Widget _buildRepairDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repair Description *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _repairDescriptionController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Describe what you did to resolve this complaint...',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Color(0xFFFAFAFA),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a repair description';
            }
            if (value.trim().length < 10) {
              return 'Description must be at least 10 characters long';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Build image selection section
  Widget _buildImageSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Photos (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        // Image button (camera only)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _selectedImages.length >= _maxImages ? null : _takePhoto,
            icon: const Icon(Icons.camera_alt),
            label: Text(_selectedImages.length >= _maxImages 
              ? 'Maximum images reached ($_maxImages)' 
              : 'Take Photo (${_selectedImages.length}/$_maxImages)'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        
        // Selected images
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Selected Images (${_selectedImages.length})',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImages[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  /// Build complete button
  Widget _buildCompleteButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _completeComplaint,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Complete Complaint',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  /// Build detail row
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  /// Format date
  String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year}';
  }

  /// Normalize status
  String _normalizeStatus(String? status) {
    if (status == null || status.isEmpty) return '';
    final parts = status.split('.');
    return parts.isNotEmpty
        ? parts.last.trim().toLowerCase()
        : status.trim().toLowerCase();
  }

  /// Capitalize string
  String _capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '';
} 