import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart'; // Import for web
import 'package:image_picker/image_picker.dart';
import 'package:uidesign/models/hero_section.dart';
import 'package:uidesign/services/cloudinary_services.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

class HeroSectionProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  Future<void> addHeroSection({
    required String title,
    required String subtitle,
    required String description,
    Uint8List? webImageBytes, // Only use webImageBytes for web uploads
  }) async {
    try {
      String imageUrl = "";

      if (webImageBytes != null) {
        // Upload image to Cloudinary (for Web)
        try {
          imageUrl = await _cloudinaryService.uploadImageBytes(webImageBytes) ?? "";
        } catch (cloudinaryError) {
          print("Cloudinary Upload Error: $cloudinaryError");
          imageUrl = ""; // Set to empty string if upload fails
          // Optionally, re-throw the error or show a user-friendly message
          // throw cloudinaryError; // Or:
          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error uploading image.")));
        }
      }

      final newHeroSection = HeroSection(
        id: const Uuid().v4(),
        title: title,
        imageUrl: imageUrl, // Store the Cloudinary URL
        subtitle: subtitle,
        description: description,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('HeroSections')
          .doc(newHeroSection.id)
          .set(newHeroSection.toJson());

      notifyListeners(); // Notify listeners about the change
    } catch (e) {
      // Handle general errors appropriately (e.g., show an error message)
      print('Error adding hero section: $e');
      rethrow; // Re-throw to allow the UI to handle the error as well
    }
  }

  // Function to update an existing Hero Section
  Future<void> updateHeroSection({
    required String id,
    required String title,
    Uint8List? webImageBytes, // Only use webImageBytes for web uploads
    required String subtitle,
    required String description,
  }) async {
    try {
      String imageUrl = "";
      final existingHeroSection =
          await _firestore.collection('HeroSections').doc(id).get();
      final heroSectionData = existingHeroSection.data();

      if (heroSectionData != null) {
        imageUrl = HeroSection.fromJson(heroSectionData).imageUrl; // Get existing URL
      }

      if (webImageBytes != null) {
        // Upload the new image (for Web)
        try {
          imageUrl = await _cloudinaryService.uploadImageBytes(webImageBytes) ?? "";
        } catch (cloudinaryError) {
          print("Cloudinary Upload Error: $cloudinaryError");
          imageUrl = ""; // Set to empty string if upload fails
          // Optionally, re-throw the error or show a user-friendly message
          // throw cloudinaryError; // Or:
          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error uploading image.")));
        }
      }

      await _firestore.collection('HeroSections').doc(id).update({
        "title": title,
        "imageUrl": imageUrl,
        "subtitle": subtitle,
        "description": description,
        "updatedAt": DateTime.now().toIso8601String(),
      });

      notifyListeners();
    } catch (e) {
      print('Error updating hero section: $e');
      rethrow;
    }
  }

  // Optional: Stream to listen for Hero Sections
  Stream<List<HeroSection>> getHeroSections() {
    return _firestore.collection('HeroSections').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => HeroSection.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

   // Function to delete a Hero Section
  Future<void> deleteHeroSection(String id) async {
    try {
      await _firestore.collection('HeroSections').doc(id).delete();
      notifyListeners();
    } catch (e) {
      print('Error deleting hero section: $e');
      rethrow;
    }
  }

}