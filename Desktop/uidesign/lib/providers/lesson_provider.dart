import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uidesign/models/lesson.dart';

import 'package:uuid/uuid.dart';

class LessonProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add Lesson
  Future<void> addLesson({
    required String sectionId,
    required String courseId, // Added courseId
    required String title,
    required String videoUrl,
    required String textContent,
    required int duration,
  }) async {
    try {
      String lessonId = const Uuid().v4();
      Lesson lesson = Lesson(
        id: lessonId,
        sectionId: sectionId,
        courseId: courseId, // Added courseId
        title: title,
        videoUrl: videoUrl,
        textContent: textContent,
        duration: duration,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection("lessons").doc(lessonId).set(lesson.toJson());
      notifyListeners();
    } catch (e) {
      print("Error adding lesson: $e");
      rethrow;
    }
  }

  // Update Lesson
  Future<void> updateLesson(Lesson lesson) async {
    try {
      Lesson updatedLesson = Lesson(
        id: lesson.id,
        sectionId: lesson.sectionId,
        courseId: lesson.courseId, // Added courseId
        title: lesson.title,
        videoUrl: lesson.videoUrl,
        textContent: lesson.textContent,
        duration: lesson.duration,
        createdAt: lesson.createdAt,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection("lessons")
          .doc(lesson.id)
          .update(updatedLesson.toJson());
      notifyListeners();
    } catch (e) {
      print("Error updating lesson: $e");
      rethrow;
    }
  }

  // Delete Lesson
  Future<void> deleteLesson(String lessonId) async {
    try {
      await _firestore.collection("lessons").doc(lessonId).delete();
      notifyListeners();
    } catch (e) {
      print("Error deleting lesson: $e");
      rethrow;
    }
  }
  Stream<List<Lesson>> getLessonsForSection(String sectionId) {
  return _firestore
      .collection("lessons")
      .where("sectionId", isEqualTo: sectionId)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => Lesson.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  });
}

}
