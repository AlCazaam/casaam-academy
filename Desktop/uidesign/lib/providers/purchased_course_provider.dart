import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:uidesign/models/course.dart';
import 'package:uidesign/models/discount.dart';
import 'package:uidesign/models/pdfs.dart';

import 'package:uidesign/models/purchased_course.dart';
import 'package:uuid/uuid.dart';

class PurchasedCourseProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cart management
  List<String> _cartCourseIds = [];
  List<String> _cartPdfIds = [];

  // Discount
  Discount? _appliedDiscount;

  // Getters
  List<String> get cartCourseIds => _cartCourseIds;
  List<String> get cartPdfIds => _cartPdfIds;
  Discount? get appliedDiscount => _appliedDiscount;

  // Get total cart items count
  int get cartItemsCount => _cartCourseIds.length + _cartPdfIds.length;

  // Cart operations (Course and PDF)
  void addToCart(String itemId, bool isCourse) {
    if (isCourse) {
      if (!_cartCourseIds.contains(itemId)) {
        _cartCourseIds.add(itemId);
      }
    } else {
      if (!_cartPdfIds.contains(itemId)) {
        _cartPdfIds.add(itemId);
      }
    }
    notifyListeners();
  }

  void removeFromCart(String itemId, bool isCourse) {
    if (isCourse) {
      _cartCourseIds.remove(itemId);
    } else {
      _cartPdfIds.remove(itemId);
    }
    notifyListeners();
  }

  bool containsCart(String itemId, bool isCourse) {
    if (isCourse) {
      return _cartCourseIds.contains(itemId);
    } else {
      return _cartPdfIds.contains(itemId);
    }
  }

  void removeAllFromCart() {
    _cartCourseIds.clear();
    _cartPdfIds.clear();
    _appliedDiscount = null;
    notifyListeners();
  }

  // Calculate total price (Courses with discount, PDFs full price)
  double calculateTotalPrice(
    List<Course> courses,
    List<PDF> pdfs,
    Discount? appliedDiscount,
  ) {
    double courseTotalPrice = 0;
    double pdfTotalPrice = 0;

    // Calculate total for courses
    for (String courseId in _cartCourseIds) {
      Course course = courses.firstWhere((c) => c.id == courseId);
      courseTotalPrice += course.price;
    }

    // Apply discount on courses
    if (appliedDiscount != null) {
      courseTotalPrice =
          courseTotalPrice -
          (courseTotalPrice * appliedDiscount.percentage / 100);
    }

    // Calculate total for PDFs
    for (String pdfId in _cartPdfIds) {
      PDF pdf = pdfs.firstWhere((p) => p.id == pdfId);
      pdfTotalPrice += pdf.price;
    }

    return courseTotalPrice + pdfTotalPrice;
  }

  // Checkout Process
  Future<String?> checkout({
    required String userId,
    required String number,
    required String message,
    required List<Course> courses,
    required List<PDF> pdfs,
  }) async {
    try {
      EasyLoading.show(status: 'Processing...');

      // Calculate total price (important to do this *before* creating the PurchasedCourse object)
      double totalPrice = calculateTotalPrice(courses, pdfs, _appliedDiscount);

      // Generate a unique purchase ID
      String purchaseId = const Uuid().v4();

      // Create a new PurchasedCourse object
      PurchasedCourse purchasedCourse = PurchasedCourse(
        id: purchaseId,
        number: number,
        userId: userId,
        courseIds: _cartCourseIds,
        purchasedAt: DateTime.now(),
        pending: false, // Set to false as purchase is now complete
        show: true,
        message: message,
        totalPrice: totalPrice, // Store the calculated total price
        pdfIds: _cartPdfIds,
      );

      // Save the purchased course to Firestore
      await _firestore
          .collection("purchasedCourses")
          .doc(purchaseId)
          .set(purchasedCourse.toJson());

      // Clear the cart after successful checkout
      removeAllFromCart();

      EasyLoading.dismiss();
      return purchaseId;
    } catch (e) {
      EasyLoading.dismiss();
      print("Error during checkout: $e");
      rethrow;
    }
  }

  // Firestore operations (CRUD for PurchasedCourse)
  Future<void> addPurchasedCourse({
    required String userId,
    required List<String> courseIds,
    required String message,
    required String number,
    required double totalPrice, // Add totalPrice
    List<String>? pdfIds, // Optional PDF IDs
  }) async {
    try {
      String purchaseId = const Uuid().v4();
      PurchasedCourse purchasedCourse = PurchasedCourse(
        id: purchaseId,
        number: number,
        userId: userId,
        courseIds: courseIds,
        purchasedAt: DateTime.now(),
        pending: true,
        show: true,
        message: message,
        totalPrice: totalPrice, // Use the passed totalPrice
        pdfIds: pdfIds ?? [], // Use passed pdfIds, default to empty list
      );

      await _firestore
          .collection("purchasedCourses")
          .doc(purchaseId)
          .set(purchasedCourse.toJson());
      notifyListeners();
    } catch (e) {
      print("Error adding purchased course: $e");
      rethrow;
    }
  }

  Future<void> updatePurchasedCourse(PurchasedCourse purchasedCourse) async {
    try {
      await _firestore
          .collection("purchasedCourses")
          .doc(purchasedCourse.id)
          .update(purchasedCourse.toJson());
      notifyListeners();
    } catch (e) {
      print("Error updating purchased course: $e");
      rethrow;
    }
  }

  Future<void> deletePurchasedCourse(String purchaseId) async {
    try {
      await _firestore.collection("purchasedCourses").doc(purchaseId).delete();
      notifyListeners();
    } catch (e) {
      print("Error deleting purchased course: $e");
      rethrow;
    }
  }

  Stream<List<PurchasedCourse>> getPurchasedCourses() {
    return _firestore.collection("purchasedCourses").snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map(
            (doc) =>
                PurchasedCourse.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    });
  }

  // Discount-related functions
  void applyDiscount(Discount discount) {
    _appliedDiscount = discount;
    notifyListeners();
  }

  void removeDiscount() {
    _appliedDiscount = null;
    notifyListeners();
  }

   // Method to fetch all purchased courses as a List<PurchasedCourse>
  Future<List<PurchasedCourse>> getPurchasedCoursesList() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection("purchasedCourses").get();
      return snapshot.docs.map((doc) {
        return PurchasedCourse.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Error fetching purchased courses: $e");
      return []; // Or handle the error appropriately
    }
  }

}
