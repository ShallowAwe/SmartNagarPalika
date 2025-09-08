class Alertmodel {
  final int id;
  final String description;
  final String type;
  final String? imageUrl; // single string
  final String title;

  Alertmodel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.type,
  });

  factory Alertmodel.fromJson(Map<String, dynamic> json) {
    return Alertmodel(
      id: json['id'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      type: json['type'],
    );
  }
}
