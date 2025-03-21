import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uidesign/models/user.dart';

import 'package:uuid/uuid.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;

  User? get currentUser => _currentUser;

  // Register User
  Future<void> registerUser({
    required String fullname,
    required String username,
    required String email,
    required String number,
    required String password,
  }) async {
    try {
      String userId = const Uuid().v4();
      User user = User(
        id: userId,
        fullname: fullname,
        username: username,
        email: email,
        number: number,
        description: "",
        imageUrl: "",
        password: password, // Hash this in a real app!
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isLoggedIn: true,
        isStudent: false,
        lastActivated: DateTime.now(),
      );

      await _firestore.collection("users").doc(userId).set(user.toJson());

        // Initialize purchasedCourses subcollection
        await _firestore
            .collection("users")
            .doc(userId)
            .collection("purchasedCourses")
            .doc("init")
            .set({"message": "Purchased Courses initialized"});

      _currentUser = user; // set to the current user
      notifyListeners();
    } catch (e) {
      print("Error registering user: $e");
      rethrow;
    }
  }

  // Login User
  Future<User?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      QuerySnapshot query = await _firestore
          .collection("users")
          .where("email", isEqualTo: email)
          .where("password", isEqualTo: password) // Hash this in a real app!
          .get();

      if (query.docs.isNotEmpty) {
        _currentUser = User.fromJson(query.docs.first.data() as Map<String, dynamic>);
        notifyListeners();
        return _currentUser;
      } else {
        return null; // User not found
      }
    } catch (e) {
      print("Error logging in user: $e");
      return null;
    }
  }

  // Get Current User
  Future<User?> getCurrentUser(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection("users").doc(userId).get();
      if (doc.exists) {
        _currentUser = User.fromJson(doc.data() as Map<String, dynamic>);
        notifyListeners();
        return _currentUser;
      } else {
        return null;
      }
    } catch (e) {
      print("Error getting current user: $e");
      return null;
    }
  }

  // Add Purchased Course
  Future<void> addPurchasedCourse({
    required String userId,
    required String courseId,
  }) async {
    try {
      await _firestore
          .collection("users")
          .doc(userId)
          .collection("purchasedCourses")
          .doc(courseId)
          .set({
        "courseId": courseId,
        "purchasedAt": DateTime.now().toIso8601String(), // Store as String
      });
      notifyListeners();
    } catch (e) {
      print("Error adding purchased course: $e");
      rethrow;
    }
  }

  Future<void> updateUser(User updatedUser) async {
    try {
      await _firestore.collection("users").doc(updatedUser.id).update(updatedUser.toJson());
      notifyListeners();
    } catch (e) {
      print("Error updating user: $e");
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection("users").doc(userId).delete();
      notifyListeners();
    } catch (e) {
      print("Error deleting user: $e");
      rethrow;
    }
  }
}