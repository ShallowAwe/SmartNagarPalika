import 'package:flutter/material.dart';

/// Utility class for complaint-related helper functions
class ComplaintUtils {
  /// Normalizes the status string by removing prefixes and converting to lowercase
  /// Example: "status.pending" -> "pending"
  /// Also handles variations like "Inprogress" -> "in progress"
  static String normalizeStatus(String? status) {
    if (status == null || status.isEmpty) return '';
    final parts = status.split('.');
    final cleanStatus = parts.isNotEmpty
        ? parts.last.trim().toLowerCase()
        : status.trim().toLowerCase();
    
    // Handle variations in status naming
    switch (cleanStatus) {
      case 'inprogress':
        return 'in progress';
      case 'in_progress':
        return 'in progress';
      default:
        return cleanStatus;
    }
  }

  /// Returns the appropriate color for a given complaint status
  static Color getStatusColor(String? status) {
    final normalized = normalizeStatus(status);
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

  /// Returns the appropriate icon for a given complaint status
  static IconData getStatusIcon(String? status) {
    final normalized = normalizeStatus(status);
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

  /// Formats a DateTime object to DD/MM/YYYY format
  static String formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year}';
  }

  /// Capitalizes the first letter of a string
  static String capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '';
}
