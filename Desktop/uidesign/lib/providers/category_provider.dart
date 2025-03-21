import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uidesign/models/category.dart';
import 'package:uidesign/services/cloudinary_services.dart';
import 'package:uuid/uuid.dart';

class CategoryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  // Add Category
  Future<void> addCategory(
    String name,
    String description,
    XFile? imageFile, // For Mobile
    Uint8List? webImageBytes, // For Web
  ) async {
    try {
      String imageUrl = "";
      if (imageFile != null || webImageBytes != null) {
        try {
          String? temp = kIsWeb
              ? await _cloudinaryService.uploadImageBytes(webImageBytes!)
              : await _cloudinaryService.uploadImage(imageFile!);

          if (temp != null) {
            imageUrl = temp;
          }
          print("Cloudinary URL: $imageUrl");
        } catch (cloudinaryError) {
          print("Cloudinary Upload Error: $cloudinaryError");
          throw Exception("Failed to upload image to Cloudinary");
        }
      }

      String categoryId = const Uuid().v4();
      Category category = Category(
        id: categoryId,
        name: name,
        description: description,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isShow: true,
      );

      await _firestore
          .collection("categories")
          .doc(categoryId)
          .set(category.toJson());
      print("Category added to Firestore successfully.");

      notifyListeners();
    } catch (e) {
      print("Error adding category: $e");
      rethrow;
    }
  }

  // Update Category
  Future<void> updateCategory(
    Category category,
    XFile? imageFile,
    Uint8List? webImageBytes,
  ) async {
    try {
      String imageUrl = category.imageUrl;
      if (imageFile != null || webImageBytes != null) {
        try {
          String? temp = kIsWeb
              ? await _cloudinaryService.uploadImageBytes(webImageBytes!)
              : await _cloudinaryService.uploadImage(imageFile!);

          if (temp != null) {
            imageUrl = temp;
          }
          print("Updated Cloudinary URL: $imageUrl");
        } catch (cloudinaryError) {
          print("Cloudinary Upload Error (Update): $cloudinaryError");
          rethrow;
        }
      }

      Category updatedCategory = Category(
        id: category.id,
        name: category.name,
        description: category.description,
        imageUrl: imageUrl,
        createdAt: category.createdAt,
        updatedAt: DateTime.now(),
        isShow: category.isShow,
      );

      await _firestore
          .collection("categories")
          .doc(category.id)
          .update(updatedCategory.toJson());
      print("Category updated in Firestore successfully.");

      notifyListeners();
    } catch (e) {
      print("Error updating category: $e");
      rethrow;
    }
  }

  // Delete Category
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection("categories").doc(categoryId).delete();
      notifyListeners();
    } catch (e) {
      print("Error deleting category: $e");
      rethrow;
    }
  }

  // Get All Categories
  Stream<List<Category>> getCategories() {
    return _firestore.collection("categories").snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Category.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}
