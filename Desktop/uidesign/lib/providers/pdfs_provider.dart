import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uidesign/models/pdfs.dart';
import 'package:uidesign/services/cloudinary_services.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';

class PdfProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final CollectionReference _pdfCollection = FirebaseFirestore.instance
      .collection('pdfs');

  // Add PDF
  Future<String?> addPdf({
    // Changed return type to Future<String?>
    required String name,
    required String description,
    required double price,
    required String categoryId,
    required dynamic pdfFile,
    String? imageUrl,
    required bool isPublished,
  }) async {
    try {
      String? pdfUrl;

      if (pdfFile != null) {
        try {
          pdfUrl = await _cloudinaryService.uploadFile(pdfFile);
        } catch (cloudinaryError) {
          print("Cloudinary PDF Upload Error: $cloudinaryError");
          rethrow;
        }
      }

      final pdfId = Uuid().v4();
      final now = DateTime.now();
      final newPdf = PDF(
        id: pdfId,
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        fileUrl: pdfUrl ?? '',
        imageUrl: imageUrl ?? '',
        isPublished: isPublished,
        createdAt: now,
        updatedAt: now,
      );

      await _pdfCollection.doc(pdfId).set(newPdf.toJson());
      notifyListeners();
      return pdfId; // Return the pdfId on success
    } catch (error, stackTrace) {
      print("Error adding PDF: $error, Stacktrace: $stackTrace");
      return null; // Return null on error
    }
  }

  // Update PDF
  Future<void> updatePdf({
    required String id,
    required String name,
    required String description,
    required double price,
    required String categoryId,
    dynamic pdfFile, // Changed to dynamic
    String? imageUrl,
    required bool isPublished,
  }) async {
    try {
      String? pdfUrl;

      // Upload new PDF file if provided
      if (pdfFile != null) {
        pdfUrl = await _cloudinaryService.uploadFile(pdfFile);
      }

      final now = DateTime.now();

      // Retrieve the existing PDF from Firestore
      DocumentSnapshot pdfDoc = await _pdfCollection.doc(id).get();
      PDF existingPdf = PDF.fromJson(pdfDoc.data() as Map<String, dynamic>);

      // Create an updated PDF object using the existing PDF and the new values
      final updatedPdf = PDF(
        id: id,
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        fileUrl: pdfUrl ?? existingPdf.fileUrl,
        imageUrl: imageUrl ?? existingPdf.imageUrl,
        isPublished: isPublished,
        createdAt: existingPdf.createdAt,
        updatedAt: now,
      );

      await _pdfCollection.doc(id).update(updatedPdf.toJson());
      notifyListeners();
    } catch (error) {
      print("Error updating PDF: $error");
      rethrow;
    }
  }

  // Delete PDF
  Future<void> deletePdf(String id) async {
    try {
      await _pdfCollection.doc(id).delete();
      notifyListeners();
    } catch (error) {
      print("Error deleting PDF: $error");
      rethrow;
    }
  }

  // Get PDF by ID
  Future<PDF?> getPdf(String id) async {
    try {
      DocumentSnapshot doc = await _pdfCollection.doc(id).get();
      if (doc.exists) {
        return PDF.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (error) {
      print("Error getting PDF: $error");
      return null;
    }
  }

  // Get all PDFs (You might want to add pagination or filtering)
  Stream<List<PDF>> getPdfs() {
    return _pdfCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => PDF.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<String?> uploadImageBytes(Uint8List imageBytes) async {
    try {
      return await _cloudinaryService.uploadImageBytes(imageBytes);
    } catch (e) {
      print("Error uploading image bytes: $e");
      return null;
    }
  }
}
