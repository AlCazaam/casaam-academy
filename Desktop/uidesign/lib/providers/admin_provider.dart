import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:uidesign/models/admin.dart';

class AdminProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Admin? _currentAdmin;

  // Register Admin with followers subcollection
  Future<void> registerAdmin(Admin admin) async {
    try {
      await _firestore.collection("admins").doc(admin.id).set(admin.toJson());

      // Create followers subcollection (empty)
      await _firestore
          .collection("admins")
          .doc(admin.id)
          .collection("followers")
          .doc("init")
          .set({"message": "Followers collection initialized"});

    } catch (e) {
      print("Error registering admin: $e");
      throw e;
    }
  }

  // Login Admin
  Future<Admin?> loginAdmin(String email, String password) async {
    try {
      QuerySnapshot query = await _firestore
          .collection("admins")
          .where("email", isEqualTo: email)
          .where("password", isEqualTo: password)
          .get();

      if (query.docs.isNotEmpty) {
        _currentAdmin = Admin.fromJson(query.docs.first.data() as Map<String, dynamic>);
        notifyListeners(); // Wuxuu update gareynayaa UI-ga markuu user-ka helo
        return _currentAdmin;
      }
      return null;
    } catch (e) {
      print("Error logging in: $e");
      return null;
    }
  }

  // Get Current Admin
  Admin? getCurrentAdmin() {
    return _currentAdmin;
  }

  // Update Admin
  Future<void> updateAdmin(Admin admin) async {
    try {
      await _firestore.collection("admins").doc(admin.id).update(admin.toJson());
      _currentAdmin = admin; // Update the current admin object
      notifyListeners(); // Notify listeners (e.g., UI)
    } catch (e) {
      print("Error updating admin: $e");
      throw e; // Re-throw the error to be handled in the UI.
    }
  }

  // Logout Admin
  void logoutAdmin() {
    _currentAdmin = null;
    notifyListeners();
  }
}