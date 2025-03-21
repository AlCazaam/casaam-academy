import 'package:uuid/uuid.dart';

class Category {
  String id;
  String name;
  String description;
  String imageUrl;
  DateTime createdAt;
  DateTime updatedAt;
  bool isShow;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.isShow,
  });

  // Convert Category to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "imageUrl": imageUrl,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "isShow": isShow,
    };
  }

  // Convert Firestore document to Category object
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json["id"],
      name: json["name"],
      description: json["description"],
      imageUrl: json["imageUrl"],
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
      isShow: json["isShow"],
    );
  }
}