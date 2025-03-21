import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uidesign/models/course.dart';
import 'package:uidesign/models/section.dart';
import 'package:uidesign/services/cloudinary_services.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

class CourseProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  // Add Course
  Future<void> addCourse({
    required String title,
    required String description,
    required String introVideo,
    required String categoryId,
    required String instructor,
    required double price,
    required double rating,
    XFile? imageFile, // Changed to XFile?
    Uint8List? webImageBytes, // Added web image bytes
    required bool isPublished,
  }) async {
    try {
      String imageUrl = "";
      if (imageFile != null || webImageBytes != null) {
        try {
          if (kIsWeb) {
            if (webImageBytes != null) {
              String? temp = await _cloudinaryService.uploadImageBytes(webImageBytes);
              if (temp != null) {
                imageUrl = temp;
                print("Cloudinary URL (addCourse - Web): $imageUrl");
              } else {
                print("Cloudinary upload failed (addCourse - Web): temp is null");
              }
            } else {
              print("No image selected (addCourse - Web). webImageBytes is null");
            }
          } else {
            if (imageFile != null) {
              String? temp = await _cloudinaryService.uploadImage(imageFile);
              if (temp != null) {
                imageUrl = temp;
                print("Cloudinary URL (addCourse - Mobile): $imageUrl");
              } else {
                print("Cloudinary upload failed (addCourse - Mobile): temp is null");
              }
            } else {
              print("No image selected (addCourse - Mobile). imageFile is null");
            }
          }
        } catch (cloudinaryError) {
          print("Cloudinary upload failed: $cloudinaryError");
          rethrow; // Re-throw so the caller knows there was an error
        }
      }
      print("Final Image URL before Firestore (addCourse): $imageUrl");

      String courseId = const Uuid().v4();
      Course course = Course(
        id: courseId,
        title: title,
        description: description,
        introVideo: introVideo,
        categoryId: categoryId,
        instructor: instructor,
        price: price,
        rating: rating,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPublished: isPublished,
      );

      await _firestore.collection("courses").doc(courseId).set(course.toJson());
      notifyListeners();
    } catch (e) {
      print("Error adding course: $e");
      rethrow;
    }
  }

  // Update Course
  Future<void> updateCourse({
    required Course course,
    XFile? imageFile, // Changed to XFile?
    Uint8List? webImageBytes, // Added web image bytes
  }) async {
    try {
      String imageUrl = course.imageUrl; // Start with the existing URL

      if (imageFile != null || webImageBytes != null) {
        try {
          if (kIsWeb) {
            if (webImageBytes != null) {
              String? temp = await _cloudinaryService.uploadImageBytes(webImageBytes);
              if (temp != null) {
                imageUrl = temp;
                print("Cloudinary URL (updateCourse - Web): $imageUrl");
              } else {
                print("Cloudinary upload failed (updateCourse - Web): temp is null");
              }
            } else {
              print("No image selected (updateCourse - Web): webImageBytes is null");
            }
          } else {
            if (imageFile != null) {
              String? temp = await _cloudinaryService.uploadImage(imageFile);
              if (temp != null) {
                imageUrl = temp;
                print("Cloudinary URL (updateCourse - Mobile): $imageUrl");
              } else {
                print("Cloudinary upload failed (updateCourse - Mobile): temp is null");
              }
            } else {
              print("No image selected (updateCourse - Mobile): imageFile is null");
            }
          }
        } catch (cloudinaryError) {
          print("Cloudinary upload failed: $cloudinaryError");
          rethrow; // Re-throw so the caller knows there was an error.
        }
      }
      print("Final Image URL before Firestore (updateCourse): $imageUrl");

      Course updatedCourse = Course(
        id: course.id,
        title: course.title,
        description: course.description,
        introVideo: course.description,
        categoryId: course.categoryId,
        instructor: course.instructor,
        price: course.price,
        rating: course.rating,
        imageUrl: imageUrl, // Use the potentially updated imageUrl
        createdAt: course.createdAt,
        updatedAt: DateTime.now(),
        isPublished: course.isPublished,
      );

      await _firestore
          .collection("courses")
          .doc(course.id)
          .update(updatedCourse.toJson());
      notifyListeners();
    } catch (e) {
      print("Error updating course: $e");
      rethrow;
    }
  }

  // Delete Course
  Future<void> deleteCourse(String courseId) async {
    try {
      await _firestore.collection("courses").doc(courseId).delete();
      notifyListeners();
    } catch (e) {
      print("Error deleting course: $e");
      rethrow;
    }
  }

  // Get Courses (Stream)
  Stream<List<Course>> getCourses() {
    return _firestore.collection("courses").snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Course.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Get a single course by ID (Stream)
  Stream<Course?> getCourseById(String courseId) {
    return _firestore.collection("courses").doc(courseId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return Course.fromJson(snapshot.data() as Map<String, dynamic>);
      } else {
        return null; // Or handle the case where the course doesn't exist
      }
    });
  }

}