import 'package:cloud_firestore/cloud_firestore.dart';

class PostVideo {
  String id;
  String adminId;
  String title;
  String description;
  String videoUrl;
  bool isShow;
  DateTime createdAt;
  DateTime updatedAt;
  int likes;

  PostVideo({
    required this.id,
    required this.adminId,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.isShow,
    required this.createdAt,
    required this.updatedAt,
    required this.likes,
  });

  // Convert PostVideo to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "adminId": adminId,
      "title": title,
      "description": description,
      "videoUrl": videoUrl,
      "isShow": isShow,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "likes": likes,
    };
  }

  // Convert Firestore document to PostVideo object
  factory PostVideo.fromJson(Map<String, dynamic> json) {
    return PostVideo(
      id: json["id"],
      adminId: json["adminId"],
      title: json["title"],
      description: json["description"],
      videoUrl: json["videoUrl"],
      isShow: json["isShow"],
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
      likes: json["likes"],
    );
  }
}