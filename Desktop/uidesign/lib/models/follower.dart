class Follower {
  String id;
  String adminId;
  List<String> follower;

  Follower({
    required this.id,
    required this.adminId,
    required this.follower,
  });

  // Convert Follower to JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "adminId": adminId,
      "follower": follower,
    };
  }

  // Convert JSON to Follower object
  factory Follower.fromJson(Map<String, dynamic> json) {
    return Follower(
      id: json["id"],
      adminId: json["adminId"],
      follower: List<String>.from(json["follower"]),
    );
  }
}