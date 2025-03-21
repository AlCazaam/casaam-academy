
class User {
  String id;
  String fullname;
  String username;
  String email;
  String number;
  String description;
  String imageUrl;
  String password;
  DateTime createdAt;
  DateTime updatedAt;
  bool isLoggedIn;
  bool isStudent;
  DateTime? lastActivated; 

  User({
    required this.id,
    required this.fullname,
    required this.username,
    required this.email,
    required this.number,
    required this.description,
    required this.imageUrl,
    required this.password,
    required this.createdAt,
    required this.updatedAt,
    required this.isLoggedIn,
    required this.isStudent,
    this.lastActivated,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "fullname": fullname,
      "username": username,
      "email": email,
      "number": number,
      "description": description,
      "imageUrl": imageUrl,
      "password": password,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "isLoggedIn": isLoggedIn,
      "isStudent": isStudent,
      "lastActivated": lastActivated?.toIso8601String(), // Handle null case
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      fullname: json["fullname"],
      username: json["username"],
      email: json["email"],
      number: json["number"],
      description: json["description"],
      imageUrl: json["imageUrl"],
      password: json["password"],
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
      isLoggedIn: json["isLoggedIn"],
      isStudent: json["isStudent"],
      lastActivated: json["lastActivated"] != null ? DateTime.parse(json["lastActivated"]) : null, // Handle null case
    );
  }
}