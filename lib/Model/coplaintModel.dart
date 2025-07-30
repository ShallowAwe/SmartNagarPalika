import 'package:geolocator/geolocator.dart';

class ComplaintModel {
  final String id;
  final String description;
  final int? departmentId;
  final String address;
  final String? landmark;
  final LocationData? location;
  final int? wardId;
  final List<String> attachments;
  final DateTime createdAt;
  final ComplaintStatus status;

  ComplaintModel({
    required this.id,
    required this.description,
    required this.departmentId,
    required this.address,
    this.landmark,
    this.location,
    this.wardId,
    this.attachments = const [],
    required this.createdAt,
    this.status = ComplaintStatus.pending,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'department': departmentId,
      'address': address,
      'landmark': landmark,
      'location': location?.toJson(),
      'ward': wardId,
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name, // ✅ Clean status serialization
    };
  }

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'].toString(),
      description: json['description'],
      departmentId: json['department'],
      address: json['location'] ?? '', // Use 'location' as address
      landmark: '', // No landmark in backend
      location: null, // No location object in backend
      wardId: json['ward'],
      attachments:
          (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
      status: ComplaintStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == (json['status'] as String).toLowerCase(),
        orElse: () => ComplaintStatus.pending,
      ),
    );
  }
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
      latitude: json['latitude'],
      longitude: json['longitude'],
      accuracy: json['accuracy'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}

enum ComplaintStatus {
  pending,
  inProgress,
  resolved,
  // rejected
}
