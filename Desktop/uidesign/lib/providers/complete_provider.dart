import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uidesign/models/complete_lesson.dart';

class CompleteLessonProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to mark a lesson as complete or incomplete
  Future<void> markLessonComplete({
    required String id,
    required String userId,
    required String courseId,
    required String sectionId,
    required String lessonId,
    required bool status,
  }) async {
    try {
      // Check if a CompleteLesson document already exists for the given lesson
      final existingDoc = await _firestore
          .collection('CompleteLessons')
          .where('userId', isEqualTo: userId)
          .where('courseId', isEqualTo: courseId)
          .where('sectionId', isEqualTo: sectionId)
          .where('lessonId', isEqualTo: lessonId)
          .get();

      if (existingDoc.docs.isNotEmpty) {
        // If a document exists, update the status and updateDate
        final docRef = _firestore
            .collection('CompleteLessons')
            .doc(existingDoc.docs.first.id);

        await docRef.update({
          'status': status,
          'updateDate': DateTime.now().toIso8601String(),
        });
      } else {
        // If no document exists, create a new CompleteLesson document
        final newCompleteLesson = CompleteLesson(
          id: id,
          userId: userId,
          courseId: courseId,
          sectionId: sectionId,
          lessonId: lessonId,
          status: status,
          date: DateTime.now(),
          updateDate: DateTime.now(),
        );

        await _firestore
            .collection('CompleteLessons')
            .doc(id)
            .set(newCompleteLesson.toJson());
      }

      notifyListeners(); // Notify listeners about the change
    } catch (e) {
      // Handle errors appropriately (e.g., show an error message)
      print('Error marking lesson complete: $e');
      rethrow; // Re-throw the error to be handled by the calling code
    }
  }

  // Stream to listen for completed lessons for a specific user, course, section, and lesson (optional)
  Stream<List<CompleteLesson>> getCompleteLessons(
      {String? userId, String? courseId, String? sectionId, String? lessonId}) {
    Query<Map<String, dynamic>> query =
        _firestore.collection('CompleteLessons');

    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }
    if (courseId != null) {
      query = query.where('courseId', isEqualTo: courseId);
    }
    if (sectionId != null) {
      query = query.where('sectionId', isEqualTo: sectionId);
    }
    if (lessonId != null) {
      query = query.where('lessonId', isEqualTo: lessonId);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CompleteLesson.fromJson(doc.data()))
          .toList();
    });
  }
}