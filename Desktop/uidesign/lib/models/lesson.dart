class Lesson {
  String id;
  String sectionId;
  String courseId; 
  String title;
  String videoUrl;
  String textContent;
  int duration;
  DateTime createdAt;
  DateTime updatedAt;

  Lesson({
    required this.id,
    required this.sectionId,
    required this.courseId, // Added courseId
    required this.title,
    required this.videoUrl,
    required this.textContent,
    required this.duration,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "sectionId": sectionId,
      "courseId": courseId, // Added courseId
      "title": title,
      "videoUrl": videoUrl,
      "textContent": textContent,
      "duration": duration,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json["id"],
      sectionId: json["sectionId"],
      courseId: json["courseId"], // Added courseId
      title: json["title"],
      videoUrl: json["videoUrl"],
      textContent: json["textContent"],
      duration: json["duration"],
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
    );
  }
}