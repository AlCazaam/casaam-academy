import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uidesign/models/discount.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';

class DiscountProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Discount? _appliedDiscount;

  Discount? get appliedDiscount => _appliedDiscount; //Getter

  // Add Discount
  Future<void> addDiscount({
    required List<String> courseIds,
    required double percentage,
    required String couponCode,
    required DateTime startDate,
    required DateTime endDate,
    required bool isActive,
  }) async {
    try {
      String discountId = const Uuid().v4();
      Discount discount = Discount(
        id: discountId,
        courseIds: courseIds,
        percentage: percentage,
        couponCode: couponCode,
        startDate: startDate,
        endDate: endDate,
        isActive: isActive,

      );

      await _firestore
          .collection("discounts")
          .doc(discountId)
          .set(discount.toJson());
      notifyListeners();
    } catch (e) {
      print("Error adding discount: $e");
      rethrow;
    }
  }

  // Update Discount
  Future<void> updateDiscount(Discount discount) async {
    try {
      Discount updatedDiscount = Discount(
        id: discount.id,
        courseIds: discount.courseIds,
        percentage: discount.percentage,
        couponCode: discount.couponCode,
        startDate: discount.startDate,
        endDate: discount.endDate,
        isActive: discount.isActive,
      );

      await _firestore
          .collection("discounts")
          .doc(discount.id)
          .update(updatedDiscount.toJson());
      notifyListeners();
    } catch (e) {
      print("Error updating discount: $e");
      rethrow;
    }
  }

  // Delete Discount
  Future<void> deleteDiscount(String discountId) async {
    try {
      await _firestore.collection("discounts").doc(discountId).delete();
      notifyListeners();
    } catch (e) {
      print("Error deleting discount: $e");
      rethrow;
    }
  }

  // Get Discounts (Stream)
  Stream<List<Discount>> getDiscounts() {
    return _firestore.collection("discounts").snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Discount.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Toggle IsActive
  Future<void> toggleIsActive(String discountId, bool currentIsActive) async {
    try {
      await _firestore.collection("discounts").doc(discountId).update({
        "isActive": !currentIsActive,
      });
      notifyListeners();
    } catch (e) {
      print("Error toggling isActive: $e");
      rethrow;
    }
  }

  // Apply Coupon Code
  void applyCouponCode(
    List<String> cartCourseIds,
    String couponCode,
    List<Discount> discounts,
  ) {
    _appliedDiscount = null;

    // If coupon code is empty do not process any code and clear listener
    if (couponCode.isEmpty) {
      notifyListeners();
      return;
    }

    Discount? foundDiscount;
    for (final discount in discounts) {
      if (discount.couponCode == couponCode &&
          discount.isActive &&
          discount.courseIds.any(
            (courseId) => cartCourseIds.contains(courseId),
          )) {
        foundDiscount = discount;
        break;
      }
    }
    _appliedDiscount = foundDiscount;
    notifyListeners();
  }

  // Clear Applied Discount
  void clearAppliedDiscount() {
    _appliedDiscount = null;
    notifyListeners();
  }
}