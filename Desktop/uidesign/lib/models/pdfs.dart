import 'package:uuid/uuid.dart';

class PDF {
  String id;
  String name;
  String description;
  double price;
  String categoryId;
  String fileUrl;
  String imageUrl;
  bool isPublished;
  DateTime createdAt;
  DateTime updatedAt;

  PDF({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.fileUrl,
    required this.imageUrl,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert PDF to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "price": price,
      "categoryId": categoryId,
      "fileUrl": fileUrl,
      "imageUrl": imageUrl,
      "isPublished": isPublished,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }

  // Convert Firestore document to PDF object
  factory PDF.fromJson(Map<String, dynamic> json) {
    return PDF(
      id: json["id"] ?? '', //Provide default empty string if null
      name: json["name"] ?? '',
      description: json["description"] ?? '',
      price: (json["price"] ?? 0.0).toDouble(), //Provide default 0.0 if null
      categoryId: json["categoryId"] ?? '',
      fileUrl: json["fileUrl"] ?? '',
      imageUrl: json["imageUrl"] ?? '',
      isPublished: json["isPublished"] ?? false, //Provide default false if null
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
    );
  }
}