import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:smart_nagarpalika/Model/complaint_response_model.dart';
import 'package:smart_nagarpalika/Services/complaintService.dart';
import 'package:smart_nagarpalika/Services/logger_service.dart';

/// Widget that displays a single complaint card with status, description, and image
class ComplaintCard extends StatelessWidget {
  final ComplaintResponseModel complaint;
  final VoidCallback onTap;
  final Color statusColor;
  final IconData statusIcon;
  final String normalizedStatus;

  const ComplaintCard({
    super.key,
    required this.complaint,
    required this.onTap,
    required this.statusColor,
    required this.statusIcon,
    required this.normalizedStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image preview section
              ComplaintImagePreview(imageUrls: complaint.imageUrls),
              const SizedBox(width: 12),
              
              // Complaint details section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row with date and status
                    _buildHeaderRow(),
                    const SizedBox(height: 6),
                    
                    // Complaint description
                    _buildDescriptionRow(),
                    const SizedBox(height: 4),
                    
                    // Address row
                    _buildAddressRow(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the header row containing date and status badge
  Widget _buildHeaderRow() {
    return Row(
      children: [
        Text(
          _formatDate(complaint.createdAt),
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const Spacer(),
        StatusBadge(
          statusColor: statusColor,
          statusIcon: statusIcon,
          status: normalizedStatus,
        ),
      ],
    );
  }

  /// Builds the description row with overflow handling
  Widget _buildDescriptionRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            complaint.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Show completion indicator for resolved complaints
        if (complaint.isCompleted) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withAlpha(75)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 12, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  'Completed',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Builds the address row with location icon
  Widget _buildAddressRow() {
    return Row(
      children: [
        Icon(Icons.location_on, size: 12, color: Colors.grey.shade600),
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
    );
  }

  /// Formats the date in DD/MM/YYYY format
  static String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year}';
  }
}

/// Widget that displays the status badge with color and icon
class StatusBadge extends StatelessWidget {
  final Color statusColor;
  final IconData statusIcon;
  final String status;

  const StatusBadge({
    super.key,
    required this.statusColor,
    required this.statusIcon,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            _capitalize(status),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Capitalizes the first letter of the status string
  static String _capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '';
}

/// Widget that displays the complaint image preview
class ComplaintImagePreview extends StatelessWidget {
  final List<String> imageUrls;

  const ComplaintImagePreview({
    super.key,
    required this.imageUrls,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return _buildPlaceholderImage();
    }

    return _buildNetworkImage(imageUrls.first);
  }

  /// Builds a placeholder when no image is available
  Widget _buildPlaceholderImage() {
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

  /// Builds the network image with error handling
  Widget _buildNetworkImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        headers: ComplaintService.instance.getAuthHeaders(),
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 60,
            color: Colors.red.shade100,
            child: const Icon(Icons.broken_image, color: Colors.red),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 60,
            height: 60,
            color: Colors.grey.shade200,
            child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
      ),
    );
  }
}

/// Widget that displays the complaint details popup
class ComplaintDetailsPopup extends StatelessWidget {
  final ComplaintResponseModel complaint;
  final Color statusColor;
  final IconData statusIcon;
  final String normalizedStatus;
  final VoidCallback? onCompleteComplaint;

  const ComplaintDetailsPopup({
    super.key,
    required this.complaint,
    required this.statusColor,
    required this.statusIcon,
    required this.normalizedStatus,
    this.onCompleteComplaint,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header section with status
            _buildHeaderSection(),
            
            // Details section
            _buildDetailsSection(),
          ],
        ),
      ),
    );
  }

  /// Builds the header section with status information
  Widget _buildHeaderSection() {
    return Builder(
      builder: (context) => Container(
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
              'Complaint Status: ${_capitalize(normalizedStatus)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the details section with complaint information
  Widget _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Date:', _formatDate(complaint.createdAt)),
          _buildDetailRow('Complaint:', complaint.description),
          _buildDetailRow('Address:', complaint.address),
          const SizedBox(height: 12),
          
          // Images section
          _buildImagesSection(),
          
          // Employee completion section (for resolved complaints)
          if (complaint.isCompleted) ...[
            const SizedBox(height: 16),
            _buildEmployeeCompletionSection(),
          ],
          
          // Complete button (only show for in progress complaints)
          if (onCompleteComplaint != null && 
              normalizedStatus == 'in progress') ...[
            const SizedBox(height: 16),
            _buildCompleteButton(),
          ],
        ],
      ),
    );
  }

  /// Builds the images section with grid layout
  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Attached Images:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        
        if (complaint.imageUrls.isNotEmpty)
          _buildImagesGrid()
        else
          const Text('No images attached.',
              style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  /// Builds the images grid
  Widget _buildImagesGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: complaint.imageUrls.map((path) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            httpHeaders: ComplaintService.instance.getAuthHeaders(),
            cacheManager: CacheManager(
              Config('smart_nagarpalika',
                  stalePeriod: const Duration(days: 1)),
            ),
            imageUrl: path,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            placeholder: (context, url) => const SizedBox(
              width: 60,
              height: 60,
              child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            errorWidget: (context, url, error) =>
                const Icon(Icons.broken_image, color: Colors.red),
          ),
        );
      }).toList(),
    );
  }

  /// Builds a detail row with label and value
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
            child: Text(value,
                style: const TextStyle(fontSize: 13, color: Colors.black54)),
          ),
        ],
      ),
    );
  }

  /// Formats the date in DD/MM/YYYY format
  static String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year}';
  }

  /// Builds the employee completion section for resolved complaints
  Widget _buildEmployeeCompletionSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withAlpha(75)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Work Completed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Completion date
          if (complaint.completedAt != null)
            _buildDetailRow('Completed:', _formatDate(complaint.completedAt!)),
          
          // Employee remark
          if (complaint.employeeRemark != null && complaint.employeeRemark!.isNotEmpty)
            _buildDetailRow('Work Done:', complaint.employeeRemark!),
          
          // Employee images
          if (complaint.employeeImages.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('Work Photos:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            _buildEmployeeImagesGrid(),
          ],
        ],
      ),
    );
  }

  /// Builds the employee images grid
  Widget _buildEmployeeImagesGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: complaint.employeeImages.map((path) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            httpHeaders: ComplaintService.instance.getAuthHeaders(),
            cacheManager: CacheManager(
              Config('smart_nagarpalika',
                  stalePeriod: const Duration(days: 1)),
            ),
            imageUrl: path,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            placeholder: (context, url) => const SizedBox(
              width: 80,
              height: 80,
              child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            errorWidget: (context, url, error) =>
                const Icon(Icons.broken_image, color: Colors.red),
          ),
        );
      }).toList(),
    );
  }

  /// Builds the complete complaint button
  Widget _buildCompleteButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onCompleteComplaint,
        icon: const Icon(Icons.check_circle),
        label: const Text('Complete Complaint'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  /// Capitalizes the first letter of the string
  static String _capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '';
}

/// Widget that displays the empty state when no complaints are available
class EmptyComplaintsState extends StatelessWidget {
  final String selectedStatus;
  final VoidCallback onAddComplaint;

  const EmptyComplaintsState({
    super.key,
    required this.selectedStatus,
    required this.onAddComplaint,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.report_problem_outlined,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          
          // Title text
          Text(
            _getTitleText(),
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          
          // Subtitle text
          Text(
            _getSubtitleText(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          
          // Add complaint button (only for 'all' status)
          if (selectedStatus == 'all') ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Complaint'),
              onPressed: onAddComplaint,
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
        ],
      ),
    );
  }

  /// Returns the appropriate title text based on selected status
  String _getTitleText() {
    switch (selectedStatus) {
      case 'all':
        return 'No complaints yet';
      case 'in progress':
        return 'No in-progress complaints';
      case 'resolved':
        return 'No resolved complaints';
      default:
        return 'No complaints found';
    }
  }

  /// Returns the appropriate subtitle text based on selected status
  String _getSubtitleText() {
    switch (selectedStatus) {
      case 'all':
        return 'Submit your first complaint to get started';
      default:
        return 'All complaints are in other categories';
    }
  }
}
