import 'package:geolocator/geolocator.dart';

class ComplaintResponseModel {
  final int id; // API returns int
  final String description;
  final String? departmentName; // API field name
  final String? wardName; // Can be null in API
  final String location; // API field name (used as address)
  final List<String> imageUrls;
  final String submittedBy;
  final ComplaintStatus status;
  final String? assignedEmployeeName; // Can be null in API
  final DateTime createdAt;
  final String? employeeRemark; // Employee's description of work done
  final List<String> employeeImages; // Images uploaded by employee
  final DateTime? completedAt; // When complaint was completed

  ComplaintResponseModel({
    required this.id,
    required this.description,
    this.departmentName,
    this.wardName,
    required this.location,
    required this.imageUrls,
    required this.submittedBy,
    required this.status,
    this.assignedEmployeeName,
    required this.createdAt,
    this.employeeRemark,
    this.employeeImages = const [],
    this.completedAt,
  });

  factory ComplaintResponseModel.fromJson(Map<String, dynamic> json) {
    return ComplaintResponseModel(
      id: json['id'] as int,
      description: json['description'] as String? ?? '',
      departmentName: json['departmentName'] as String?,
      wardName: json['wardName'] as String?,
      location: json['location'] as String? ?? '',
      imageUrls:
          (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      submittedBy: json['submittedBy'] as String? ?? '',
      status: ComplaintStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == (json['status'] as String).toLowerCase(),
        orElse: () => ComplaintStatus.pending,
      ),
      assignedEmployeeName: json['assignedEmployeeName'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      employeeRemark: json['employeeRemark'] as String?,
      employeeImages:
          (json['employeeImages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'departmentName': departmentName,
      'wardName': wardName,
      'location': location,
      'imageUrls': imageUrls,
      'submittedBy': submittedBy,
      'status': status,
      'assignedEmployeeName': assignedEmployeeName,
      'createdAt': createdAt.toIso8601String(),
      'employeeRemark': employeeRemark,
      'employeeImages': employeeImages,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  // Getter for backward compatibility with your existing UI code
  String get address => location;

  // Getter for landmark (since API doesn't provide it but your UI expects it)
  LocationData? get landmark => null;

  // Helper method to check if complaint is completed
  bool get isCompleted => status == ComplaintStatus.resolved && completedAt != null;
}

class LocationData {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });

  factory LocationData.fromPosition(Position position) {
    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      timestamp: position.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      accuracy: json['accuracy'] as double,
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

enum ComplaintStatus {
  pending,
  inProgress,
  resolved,
  // rejected
}
