import 'package:uuid/uuid.dart';

class Course {
  String id;
  String title;
  String description;
  String introVideo;
  String categoryId;
  String instructor;
  double price;
  double rating;
  String imageUrl;
  DateTime createdAt;
  DateTime updatedAt;
  bool isPublished;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.introVideo,
    required this.categoryId,
    required this.instructor,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.isPublished,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "introVideo": introVideo,
      "categoryId": categoryId,
      "instructor": instructor,
      "price": price,
      "rating": rating,
      "imageUrl": imageUrl,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "isPublished": isPublished,
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json["id"],
      title: json["title"],
      description: json["description"],
      introVideo: json["introVideo"],
      categoryId: json["categoryId"],
      instructor: json["instructor"],
      price: (json["price"] as num).toDouble(),
      rating: (json["rating"] as num).toDouble(),
      imageUrl: json["imageUrl"],
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
      isPublished: json["isPublished"],
    );
  }
}