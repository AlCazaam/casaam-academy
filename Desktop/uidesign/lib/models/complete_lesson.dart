class CompleteLesson {
  String id;
  String userId;
  String courseId;
  String sectionId;
  String lessonId;
  bool status; // true or false
  DateTime date;
  DateTime updateDate;

  CompleteLesson({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.sectionId,
    required this.lessonId,
    required this.status,
    required this.date,
    required this.updateDate,
  });

  // Convert the object to a Map for serialization
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
      "courseId": courseId,
      "sectionId": sectionId,
      "lessonId": lessonId,
      "status": status,
      "date": date.toIso8601String(),
      "updateDate": updateDate.toIso8601String(),
    };
  }

  // Create a CompleteLesson object from a Map (deserialization)
  factory CompleteLesson.fromJson(Map<String, dynamic> json) {
    return CompleteLesson(
      id: json["id"],
      userId: json["userId"],
      courseId: json["courseId"],
      sectionId: json["sectionId"],
      lessonId: json["lessonId"],
      status: json["status"],
      date: DateTime.parse(json["date"]),
      updateDate: DateTime.parse(json["updateDate"]),
    );
  }
}
