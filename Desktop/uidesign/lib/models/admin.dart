class Admin {
  String id;
  String fullname;
  String username;
  String email;
  String description;
  String imageUrl;
  String password;
  DateTime createdAt;
  DateTime updatedAt;
  List<String> dayAvailable;
  bool isShowInfo;

  Admin({
    required this.id,
    required this.fullname,
    required this.username,
    required this.email,
    required this.description,
    required this.imageUrl,
    required this.password,
    required this.createdAt,
    required this.updatedAt,
    required this.dayAvailable,
    required this.isShowInfo,
  });

  // Convert Admin to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "fullname": fullname,
      "username": username,
      "email": email,
      "description": description,
      "imageUrl": imageUrl,
      "password": password,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "dayAvailable": dayAvailable,
      "isShowInfo": isShowInfo,
    };
  }

  // Convert Firestore document to Admin object
  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json["id"],
      fullname: json["fullname"],
      username: json["username"],
      email: json["email"],
      description: json["description"],
      imageUrl: json["imageUrl"],
      password: json["password"],
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
      dayAvailable: List<String>.from(json["dayAvailable"]),
      isShowInfo: json["isShowInfo"],
    );
  }
}
