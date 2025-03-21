import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uidesign/models/section.dart';

import 'package:uuid/uuid.dart';

class SectionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add Section
  Future<void> addSection({
    required String courseId,
    required String title,
    required String description,
    required int order,
  }) async {
    try {
      String sectionId = const Uuid().v4();
      Section section = Section(
        id: sectionId,
        courseId: courseId,
        title: title,
        description: description,
        order: order,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection("sections")
          .doc(sectionId)
          .set(section.toJson());
      notifyListeners();
    } catch (e) {
      print("Error adding section: $e");
      rethrow;
    }
  }

  // Update Section
  Future<void> updateSection(Section section) async {
    try {
      Section updatedSection = Section(
        id: section.id,
        courseId: section.courseId,
        title: section.title,
        description: section.description,
        order: section.order,
        createdAt: section.createdAt,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection("sections")
          .doc(section.id)
          .update(updatedSection.toJson());
      notifyListeners();
    } catch (e) {
      print("Error updating section: $e");
      rethrow;
    }
  }

  // Delete Section
  Future<void> deleteSection(String sectionId) async {
    try {
      await _firestore.collection("sections").doc(sectionId).delete();
      notifyListeners();
    } catch (e) {
      print("Error deleting section: $e");
      rethrow;
    }
  }

  // Get Sections
  Stream<List<Section>> getSections() {
    return _firestore.collection("sections").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Section.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Get Sections for a specific Course
  Stream<List<Section>> getSectionsForCourse(String courseId) {
    return _firestore
        .collection("sections")
        .where("courseId", isEqualTo: courseId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => Section.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList();
        });
  }
}
