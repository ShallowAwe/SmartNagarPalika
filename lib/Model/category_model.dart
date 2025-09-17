

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