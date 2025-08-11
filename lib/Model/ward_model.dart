class WardModel {
  int id;
  String? wardName;

  WardModel({required this.id, required this.wardName});

  factory WardModel.fromJson(Map<String, dynamic> json) {
    return WardModel(id: json['id'], wardName: json['name']);
  }
}
