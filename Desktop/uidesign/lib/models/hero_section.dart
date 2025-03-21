class HeroSection {
  String id;
  String title;
  String imageUrl;
  String subtitle;
  String description;
  DateTime createdAt;
  DateTime updatedAt;

  HeroSection({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.subtitle,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "imageUrl": imageUrl,
      "subtitle": subtitle,
      "description": description,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }

  factory HeroSection.fromJson(Map<String, dynamic> json) {
    return HeroSection(
      id: json["id"],
      title: json["title"],
      imageUrl: json["imageUrl"],
      subtitle: json["subtitle"],
      description: json["description"],
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
    );
  }
}
