import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:uidesign/models/post_video.dart';
import 'package:uidesign/providers/admin_provider.dart';

class PostVideoProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add PostVideo
  Future<void> addPostVideo(BuildContext context, PostVideo postVideo) async {
    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      final currentAdmin = adminProvider.getCurrentAdmin();

      if (currentAdmin == null) {
        throw Exception("Admin not logged in");
      }

      final newPostVideo = PostVideo(
        id: postVideo.id, // Or generate a unique ID here
        adminId: currentAdmin.id, // Use the current admin's ID
        title: postVideo.title,
        description: postVideo.description,
        videoUrl: postVideo.videoUrl,
        isShow: postVideo.isShow,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        likes: 0,
      );

      await _firestore.collection("post_videos").doc(newPostVideo.id).set(newPostVideo.toJson());
      notifyListeners();
    } catch (e) {
      print("Error adding post video: $e");
      throw e;
    }
  }

  // Update PostVideo
  Future<void> updatePostVideo(PostVideo postVideo) async {
    try {
      await _firestore.collection("post_videos").doc(postVideo.id).update(postVideo.toJson());
      notifyListeners();
    } catch (e) {
      print("Error updating post video: $e");
      throw e;
    }
  }
  
  //Update Likes
  Future<void> updateLikes(String postId, int newLikes) async {
    try {
      await _firestore.collection("post_videos").doc(postId).update({"likes": newLikes});
      notifyListeners();
    } catch (e) {
      print("Error updating likes: $e");
      throw e;
    }
  }

  // Delete PostVideo
  Future<void> deletePostVideo(String postId) async {
    try {
      await _firestore.collection("post_videos").doc(postId).delete();
      notifyListeners();
    } catch (e) {
      print("Error deleting post video: $e");
      throw e;
    }
  }

  // Get All Post Videos (You might want to add pagination for large datasets)
  Stream<List<PostVideo>> getAllPostVideos() {
    return _firestore.collection("post_videos").orderBy("createdAt", descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => PostVideo.fromJson(doc.data() as Map<String, dynamic>)).toList();
    });
  }
}