import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uidesign/models/follower.dart';

class FollowerProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get Followers
  Stream<Follower?> getFollowers(String adminId) {
    return _firestore
        .collection("followers")
        .doc(adminId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return Follower.fromJson(snapshot.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    });
  }

  // Add Follower
  Future<void> addFollower(String adminId, String userId) async {
    try {
      // Check if a document exists for this adminId in the "followers" collection
      DocumentSnapshot docSnapshot = await _firestore.collection("followers").doc(adminId).get();

      if (docSnapshot.exists) {
        // If the document exists, update the existing document
        Follower existingFollower = Follower.fromJson(docSnapshot.data() as Map<String, dynamic>);

        // Add the new user ID to the list if it doesn't already exist
        if (!existingFollower.follower.contains(userId)) {
          existingFollower.follower.add(userId);
        }

        // Update the existing document in the "followers" collection
        await _firestore.collection("followers").doc(adminId).update(existingFollower.toJson());
      } else {
        // If the document doesn't exist, create a new document
        final newFollower = Follower(
          id: FirebaseFirestore.instance.collection('followers').doc().id, // Generate a new ID
          adminId: adminId,
          follower: [userId], // Initialize with the new user ID
        );

        // Set the new document in the "followers" collection
        await _firestore.collection("followers").doc(adminId).set(newFollower.toJson());
      }

      notifyListeners();
    } catch (e) {
      print("Error adding follower: $e");
      throw e;
    }
  }

  // Remove Follower
  Future<void> removeFollower(String adminId, String userId) async {
    try {
      // Get the current follower data
      DocumentSnapshot followerDoc = await _firestore.collection("followers").doc(adminId).get();

      if (followerDoc.exists) {
        Follower follower = Follower.fromJson(followerDoc.data() as Map<String, dynamic>);

        // Remove the user ID from the list
        follower.follower.remove(userId);

        // Update the follower data in Firestore
        await _firestore.collection("followers").doc(adminId).update(follower.toJson());
        notifyListeners();
      } else {
        print("Follower document does not exist for adminId: $adminId");
      }
    } catch (e) {
      print("Error removing follower: $e");
      throw e;
    }
  }
}