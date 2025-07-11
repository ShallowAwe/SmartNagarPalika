
import 'package:geolocator/geolocator.dart';

class ComplaintModel {
  final String id;
  final String description;
  final String category;
  final String address;
  final String? landmark;
  final LocationData? location;
  final List<String> attachments;
  final DateTime createdAt;
  final ComplaintStatus status;

  ComplaintModel({
    required this.id,
    required this.description,
    required this.category,
    required this.address,
    this.landmark,
    this.location,
    this.attachments = const [],
    required this.createdAt,
    this.status = ComplaintStatus.pending,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'category': category,
      'address': address,
      'landmark': landmark,
      'location': location?.toJson(),
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
      'status': status.toString(),
    };
  }

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'],
      description: json['description'],
      category: json['category'],
      address: json['address'],
      landmark: json['landmark'],
      location: json['location'] != null ? LocationData.fromJson(json['location']) : null,
      attachments: List<String>.from(json['attachments'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      status: ComplaintStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ComplaintStatus.pending,
      ),
    );
  }

  ComplaintModel copyWith({
    String? id,
    String? description,
    String? category,
    String? address,
    String? landmark,
    LocationData? location,
    List<String>? attachments,
    DateTime? createdAt,
    ComplaintStatus? status,
  }) {
    return ComplaintModel(
      id: id ?? this.id,
      description: description ?? this.description,
      category: category ?? this.category,
      address: address ?? this.address,
      landmark: landmark ?? this.landmark,
      location: location ?? this.location,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
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
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

enum ComplaintStatus {
  pending,
  inProgress,
  resolved,
  rejected,
}

class ComplaintCategory {
  static const String streetLight = 'Street light issue (रस्त्यावरील दिवे)';
  static const String garbageCollection = 'Garbage Collection (कचरा गोळा करणे)';
  static const String drainage = 'Drainage problems (नाल्याची समस्या)';
  static const String waterSupply = 'Water Supply (पाणी पुरवठा)';
  static const String roadMaintenance = 'Road Maintenance (रस्त्याची देखभाल)';

  static List<String> get allCategories => [
    streetLight,
    garbageCollection,
    drainage,
    waterSupply,
    roadMaintenance,
  ];
}