// places_model.dart

class PlaceModel {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String categoryName;
  final List<String> types;

  PlaceModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.categoryName,
    required this.types,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    // Defensive parsing for lat/lng
    final double lat = (json['latitude'] as num).toDouble();
    final double lng = (json['longitude'] as num).toDouble();

    if (lat.abs() > 90 || lng.abs() > 180) {
      throw ArgumentError(
        "Invalid coordinates for PlaceModel: lat=$lat, lng=$lng",
      );
    }

    return PlaceModel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      latitude: lat,
      longitude: lng,
      categoryName: json['categoryName'],
      types: [json['categoryName'].toLowerCase()],
    );
  }
}

class CategoryModel {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> locations;

  CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.locations,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      locations: List<String>.from(json['locations']),
    );
  }
}
