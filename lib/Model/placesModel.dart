class PlaceModel {
  final String placeId;
  final String name;
  final double lat;
  final double lng;
  final String? address;
  final List<String>? types;

  PlaceModel({
    required this.placeId,
    required this.name,
    required this.lat,
    required this.lng,
    this.address,
    this.types,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    final location = json['geometry']['location'];
    return PlaceModel(
      placeId: json['place_id'],
      name: json['name'],
      lat: location['lat'],
      lng: location['lng'],
      address: json['vicinity'] ?? json['formatted_address'],
      types: json['types'] != null
          ? List<String>.from(json['types'])
          : null,
    );
  }
}
