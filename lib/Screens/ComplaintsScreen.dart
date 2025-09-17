import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:smart_nagarpalika/Model/complaint_response_model.dart';
import 'package:smart_nagarpalika/Model/departmentModel.dart';
import 'package:smart_nagarpalika/Model/coplaintModel.dart';
import 'package:smart_nagarpalika/Screens/complaintRegistrationScreen.dart';
import 'package:smart_nagarpalika/Services/complaintService.dart';
import 'package:smart_nagarpalika/Services/department_service.dart';
import 'package:smart_nagarpalika/Services/logger_service.dart';

class Complaintsscreen extends StatefulWidget {
  final List<Department> department;
  // final List<ComplaintModel> complaints;
  const Complaintsscreen({super.key, required this.department});

  @override
  State<Complaintsscreen> createState() => _ComplaintsscreenState();
}

class _ComplaintsscreenState extends State<Complaintsscreen> {
  Future<List<ComplaintResponseModel>>? complaints;
  String username = 'user1';
  List<Department> _departments = [];
  final LoggerService _logger = LoggerService.instance;

  /// Refresh complaints data
  Future<void> _refreshComplaints() async {
    setState(() {
      complaints = ComplaintService.instance.getComplaintsByUsername(username);
    });
  }

  @override
  void initState() {
    super.initState();
    _logger.methodEntry('ComplaintsScreen.initState', {
      'username': username,
      'departments_count': widget.department.length,
    });

    complaints = ComplaintService.instance.getComplaintsByUsername(username);
    _fetchDepartments();

    _logger.methodExit('ComplaintsScreen.initState');
  }

  @override
  void dispose() {
    _logger.methodEntry('ComplaintsScreen.dispose');
    super.dispose();
    _logger.methodExit('ComplaintsScreen.dispose');
  }

  Future<void> _fetchDepartments() async {
    _logger.methodEntry('_fetchDepartments');

    try {
      final departments = await DepartmentService.instance.getDepartments();
      _logger.info('Successfully fetched ${departments.length} departments');

      setState(() {
        _departments = departments;
      });

      _logger.methodExit(
        '_fetchDepartments',
        '${departments.length} departments loaded',
      );
    } catch (e) {
      _logger.error('Failed to fetch departments', e);
      _logger.methodExit('_fetchDepartments', 'Exception occurred');
    }
  }

  String _normalizeStatus(String? status) {
    if (status == null || status.isEmpty) return '';
    // Extract after last dot, if present
    final parts = status.split('.');
    return parts.isNotEmpty
        ? parts.last.trim().toLowerCase()
        : status.trim().toLowerCase();
  }

  Color _getStatusColor(String? status) {
    final normalized = _normalizeStatus(status);
    switch (normalized) {
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    final normalized = _normalizeStatus(status);
    switch (normalized) {
      case 'pending':
        return Icons.schedule;
      case 'in progress':
        return Icons.hourglass_empty;
      case 'resolved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  // Image viewer dialog
  void _showImageViewer(List<String> imageUrls, int initialIndex) {
    _logger.info('Opening image viewer', {
      'totalImages': imageUrls.length,
      'initialIndex': initialIndex,
    });

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: imageUrls.length,
              controller: PageController(initialPage: initialIndex),
              itemBuilder: (context, index) {
                return Center(
                  child: InteractiveViewer(
                    child: CachedNetworkImage(
                      httpHeaders: ComplaintService.instance.getAuthHeaders(),
                      cacheManager: CacheManager(
                        Config(
                          'smart_nagarpalika',
                          stalePeriod: const Duration(days: 1),
                        ),
                      ),
                      imageUrl: imageUrls[index],
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, color: Colors.white, size: 64),
                            SizedBox(height: 16),
                            Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
            if (imageUrls.length > 1)
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${initialIndex + 1} of ${imageUrls.length}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _logger.methodEntry('ComplaintsScreen.build');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Complaints'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: complaints,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            _logger.debug('Complaints loading - showing progress indicator');
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            _logger.error('Error loading complaints', snapshot.error);
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final complaints = snapshot.data ?? [];
          _logger.debug('Complaints loaded: ${complaints.length} items');

          return complaints.isEmpty
              ? RefreshIndicator(
                  onRefresh: _refreshComplaints,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.report_problem_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No complaints yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Submit your first complaint to get started',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Add Complaint'),
                              onPressed: () {
                                _logger.info(
                                  'User tapped "Add Complaint" button from empty state',
                                );
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ComplaintRegistrationScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshComplaints,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: complaints.length,
                    itemBuilder: (context, index) {
                      return buildComplaintCard(complaints[index]);
                    },
                  ),
                );
        },
      ),
      floatingActionButton: complaints.toString().isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                _logger.info(
                  'User tapped floating action button to add complaint',
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ComplaintRegistrationScreen(),
                  ),
                );
              },
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('New Complaint'),
            )
          : null,
    );
  }

  Widget buildComplaintCard(ComplaintResponseModel complaint) {
    _logger.debug('Building complaint card for ID: ${complaint.id}');

    final status = complaint.status?.toString();
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          _logger.info('User tapped complaint card for ID: ${complaint.id}');
          _showComplaintDetailsPopup(
            complaint, // Pass the correct object here
            status,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image preview with error handling
              _buildImagePreview(complaint.imageUrls),
              const SizedBox(width: 12),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _formatDate(complaint.createdAt),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: statusColor.withAlpha(75),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 12, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                _capitalize(_normalizeStatus(status)),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      complaint.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            complaint.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.category,
                          size: 12,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          complaint.departmentName ?? 'null',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComplaintDetailsPopup(
    ComplaintResponseModel complaint,
    String? status,
  ) {
    _logger.methodEntry('_showComplaintDetailsPopup', {
      'complaint_id': complaint.id,
      'status': status,
      'department': complaint.departmentName,
      'imageUrl': complaint.imageUrls,
    });

    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Complaint Status: ${_capitalize(_normalizeStatus(status))}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        _logger.info('User closed complaint details dialog');
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Date:', _formatDate(complaint.createdAt)),
                    _buildDetailRow(
                      'Department:',
                      complaint.departmentName ?? 'N/A',
                    ),
                    _buildDetailRow(
                      'Address:',
                      complaint.address.isNotEmpty ? complaint.address : 'N/A',
                    ),
                    _buildDetailRow(
                      'Coordinates:',
                      complaint.landmark != null
                          ? '${complaint.landmark!.latitude}, ${complaint.landmark!.longitude}'
                          : 'N/A',
                    ),
                    _buildDetailRow('Ward:', complaint.wardName ?? 'N/A'),
                    
                    // Show resolved complaint specific data
                    if (_normalizeStatus(status) == 'resolved') ...[
                      _buildDetailRow(
                        'Assigned Employee:',
                        complaint.assignedEmployeeName ?? 'N/A',
                      ),
                      if (complaint.completedAt != null)
                        _buildDetailRow(
                          'Completed At:',
                          _formatDate(complaint.completedAt!),
                        ),
                      if (complaint.employeeRemark != null && complaint.employeeRemark!.isNotEmpty)
                        _buildDetailRow(
                          'Employee Remark:',
                          complaint.employeeRemark!,
                        ),
                    ],
                    
                    const SizedBox(height: 12),
                    const Text(
                      'Description:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        complaint.description,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Attached Images:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (complaint.imageUrls.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: complaint.imageUrls.asMap().entries.map((entry) {
                            final index = entry.key;
                            final path = entry.value;
                            return GestureDetector(
                              onTap: () => _showImageViewer(complaint.imageUrls, index),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  httpHeaders: ComplaintService.instance
                                      .getAuthHeaders(),
                                  cacheManager: CacheManager(
                                    Config(
                                      'smart_nagarpalika',
                                      stalePeriod: const Duration(days: 1),
                                    ),
                                  ),
                                  imageUrl: path,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey.shade200,
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) {
                                    _logger.error(
                                      'Error loading image in complaint details',
                                      {
                                        'url': url,
                                        'error': error,
                                        'complaint_id': complaint.id,
                                      },
                                    );
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.red.shade100,
                                      ),
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.red,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Text(
                          'No images attached.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),

                    // Show employee images for resolved complaints
                    if (_normalizeStatus(status) == 'resolved' && 
                        complaint.employeeImages != null && 
                        complaint.employeeImages!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Employee Work Images:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: complaint.employeeImages!.asMap().entries.map((entry) {
                            final index = entry.key;
                            final path = entry.value;
                            return GestureDetector(
                              onTap: () => _showImageViewer(complaint.employeeImages!, index),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  httpHeaders: ComplaintService.instance
                                      .getAuthHeaders(),
                                  cacheManager: CacheManager(
                                    Config(
                                      'smart_nagarpalika',
                                      stalePeriod: const Duration(days: 1),
                                    ),
                                  ),
                                  imageUrl: path,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.green.shade100,
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.red.shade100,
                                      ),
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.red,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    // Action buttons based on status
                    if (status?.toLowerCase() == 'pending')
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('Edit'),
                              onPressed: () {
                                _logger.info(
                                  'User tapped Edit button for complaint ID: ${complaint.id}',
                                );
                                Navigator.pop(context);
                                // Add edit functionality here
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Edit functionality coming soon!',
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.delete, size: 16),
                              label: const Text('Cancel'),
                              onPressed: () {
                                _logger.info(
                                  'User tapped Cancel button for complaint ID: ${complaint.id}',
                                );
                                Navigator.pop(context);
                                // Add cancel functionality here
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Cancel functionality coming soon!',
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )
                    else if (status?.toLowerCase() == 'resolved')
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.rate_review, size: 16),
                          label: const Text('Rate & Review'),
                          onPressed: () {
                            _logger.info(
                              'User tapped Rate & Review button for complaint ID: ${complaint.id}',
                            );
                            Navigator.pop(context);
                            // Add rating functionality here
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Rating functionality coming soon!',
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        // child: ElevatedButton.icon(
                        //   icon: const Icon(Icons.info, size: 16),
                        //   label: const Text('Track Progress'),
                        //   onPressed: () {
                        //     _logger.info(
                        //       'User tapped Track Progress button for complaint ID: ${complaint.id}',
                        //     );
                        //     Navigator.pop(context);
                        //     // Add tracking functionality here
                        //     ScaffoldMessenger.of(context).showSnackBar(
                        //       const SnackBar(
                        //         content: Text(
                        //           'Tracking functionality coming soon!',
                        //         ),
                        //       ),
                        //     );
                        //   },
                        //   style: ElevatedButton.styleFrom(
                        //     backgroundColor: Colors.blue,
                        //     foregroundColor: Colors.white,
                        //   ),
                        // ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}'
        '/${dateTime.year}';
  }

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
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildImagePreview(List<String> attachments) {
  final LoggerService _logger = LoggerService.instance;
  String username = 'user1';
  String password = 'user1';

  _logger.debug('Building image preview for ${attachments.length} attachments');

  if (attachments.isEmpty) {
    _logger.debug('No attachments found - showing placeholder');
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade300,
      ),
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }

  final firstImagePath = attachments.first;
  final imageUrl = firstImagePath;

  // Check if URL is valid
  if (imageUrl.isEmpty) {
    _logger.warning('Image URL is empty', {'firstImagePath': firstImagePath});
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.red.shade100,
      ),
      child: const Icon(Icons.broken_image, color: Colors.red),
    );
  }

  // Create proper Basic Auth credentials
  String basicAuth =
      'Basic ${base64Encode(utf8.encode('$username:$password'))}';

  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.network(
      imageUrl,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      headers: {'Authorization': basicAuth},
      errorBuilder: (context, error, stackTrace) {
        _logger.error('Error loading image in preview', {
          'url': imageUrl.toString().trim(),
          'error': error,
        });
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.red.shade100,
          ),
          child: const Icon(Icons.broken_image, color: Colors.red),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade200,
          ),
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
    ),
  );
}

String _capitalize(String s) =>
    s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '';