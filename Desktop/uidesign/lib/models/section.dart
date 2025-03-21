class Section {
  String id;
  String courseId;
  String title;
  String description;
  int order;
  DateTime createdAt;
  DateTime updatedAt;

  Section({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "courseId": courseId,
      "title": title,
      "description": description,
      "order": order,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json["id"],
      courseId: json["courseId"],
      title: json["title"],
      description: json["description"],
      order: json["order"],
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
    );
  }
}