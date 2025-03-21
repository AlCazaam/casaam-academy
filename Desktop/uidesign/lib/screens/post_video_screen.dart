import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uidesign/Themes/theme_provider.dart';
import 'package:uidesign/models/post_video.dart';
import 'package:uidesign/providers/post_video_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';


class PostVideoScreen extends StatefulWidget {
  @override
  _PostVideoScreenState createState() => _PostVideoScreenState();
}

class _PostVideoScreenState extends State<PostVideoScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData theme = themeProvider.themeData;

    TextStyle labelStyle() => GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: theme.colorScheme.tertiary);
    // final bodyStyle = GoogleFonts.openSans(fontSize: 14, color: Colors.black87);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Videos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: theme.colorScheme.background,
      body: Consumer<PostVideoProvider>(
        builder: (context, postVideoProvider, child) {
          return StreamBuilder<List<PostVideo>>(
            stream: postVideoProvider.getAllPostVideos(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primaryContainer,
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: TextStyle(color: theme.colorScheme.error)));
              }

              final postVideos = snapshot.data ?? [];

              List<List<PostVideo>> rows = [];
              for (int i = 0; i < postVideos.length; i += 2) {
                rows.add(
                  postVideos.sublist(
                    i,
                    i + 2 > postVideos.length ? postVideos.length : i + 2,
                  ),
                );
              }

              return AnimationLimiter(
                child: ListView.builder(
                  itemCount: rows.length,
                  itemBuilder: (context, rowIndex) {
                    final row = rows[rowIndex];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children:
                            row.map((postVideo) {
                              return Expanded(
                                child: AnimationConfiguration.staggeredList(
                                  position:
                                      rowIndex * 2 + row.indexOf(postVideo),
                                  duration: const Duration(milliseconds: 500),
                                  child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: PostVideoCard(
                                        postVideo: postVideo,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          _showAddDialog(context);
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final ThemeData theme = themeProvider.themeData;

    final _formKey = GlobalKey<FormState>();
    String title = '';
    String description = '';
    String videoUrl = '';
    bool _isSaving = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: theme.colorScheme.surface,
              title: Text('Add New Post Video',
                  style: TextStyle(color: theme.colorScheme.onSurface)),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: TextStyle(color: theme.colorScheme.onSurface),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.onSurface)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.primary)),
                          border: OutlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.onSurface)),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Title is required' : null,
                        onChanged: (value) => title = value,
                      ),
                      TextFormField(
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(color: theme.colorScheme.onSurface),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.onSurface)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.primary)),
                          border: OutlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.onSurface)),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Description is required' : null,
                        onChanged: (value) => description = value,
                      ),
                      TextFormField(
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Video URL',
                          labelStyle: TextStyle(color: theme.colorScheme.onSurface),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.onSurface)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.primary)),
                          border: OutlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.onSurface)),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Video URL is required' : null,
                        onChanged: (value) => videoUrl = value,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child:
                      _isSaving
                          ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                          : const Text('Add'),
                  onPressed:
                      _isSaving
                          ? null
                          : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isSaving = true;
                              });
                              final newPostVideo = PostVideo(
                                id:
                                    FirebaseFirestore.instance
                                        .collection('post_videos')
                                        .doc()
                                        .id,
                                adminId:
                                    '', // This will be populated in the provider
                                title: title,
                                description: description,
                                videoUrl: videoUrl,
                                isShow: true,
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                                likes: 0,
                              );

                              try {
                                EasyLoading.show(status: 'Adding...');
                                await Provider.of<PostVideoProvider>(
                                  context,
                                  listen: false,
                                ).addPostVideo(
                                  context,
                                  newPostVideo,
                                ); // Pass context
                                EasyLoading.dismiss();
                                Navigator.of(context).pop(); // Close the dialog
                              } catch (e) {
                                EasyLoading.showError('Failed to add post: $e');
                                MotionToast.error(
                                  title: const Text("Error"),
                                  description: Text('Failed to add post: $e',
                                      style: TextStyle(
                                        color: theme.colorScheme.error,
                                      )),
                                  animationType: AnimationType.slideInFromRight,
                                  position: MotionToastPosition.bottom,
                                ).show(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to add post: $e',
                                        style: TextStyle(
                                          color: theme.colorScheme.error,
                                        )),
                                  ),
                                );
                              } finally {
                                setState(() {
                                  _isSaving = false;
                                });
                              }
                            } else {
                              MotionToast.error(
                                title: const Text("Error"),
                                description: const Text(
                                  'Please fill in all fields.',
                                ),
                                animationType: AnimationType.slideInFromRight,
                                position: MotionToastPosition.bottom,
                              ).show(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill in all fields.'),
                                ),
                              );
                            }
                          },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class PostVideoCard extends StatefulWidget {
  final PostVideo postVideo;

  const PostVideoCard({Key? key, required this.postVideo}) : super(key: key);

  @override
  State<PostVideoCard> createState() => _PostVideoCardState();
}

class _PostVideoCardState extends State<PostVideoCard> {
  bool _isButtonEnabled = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData theme = themeProvider.themeData;

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.postVideo.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Likes: ${widget.postVideo.likes}",
              style: TextStyle(color: theme.colorScheme.tertiary),
            ),
            const SizedBox(height: 8),
            Text(
              widget.postVideo.description,
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text("Show:", style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface)),
                Switch(
                  activeColor: theme.colorScheme.primaryContainer,
                  value: widget.postVideo.isShow,
                  onChanged: (value) {
                    _updateIsShow(context, value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(fontSize: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed:
                      _isButtonEnabled
                          ? () {
                            _showEditDialog(context, widget.postVideo);
                          }
                          : null,
                  child: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.errorContainer,
                    foregroundColor: theme.colorScheme.onError,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(fontSize: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed:
                      _isButtonEnabled
                          ? () {
                            _deletePostVideo(context, widget.postVideo.id);
                          }
                          : null,
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, PostVideo postVideo) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final ThemeData theme = themeProvider.themeData;

    final _formKey = GlobalKey<FormState>();
    String title = postVideo.title;
    String description = postVideo.description;
    String videoUrl = postVideo.videoUrl;
    bool _isSaving = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: theme.colorScheme.surface,
              title: Text(
                'Edit Post Video',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: TextStyle(color: theme.colorScheme.onSurface),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.onSurface)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.primary)),
                          border: OutlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.onSurface)),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Title is required' : null,
                        controller: TextEditingController(text: title),
                        onChanged: (value) => title = value,
                      ),
                      TextFormField(
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(color: theme.colorScheme.onSurface),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.onSurface)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.primary)),
                          border: OutlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.onSurface)),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Description is required' : null,
                        controller: TextEditingController(text: description),
                        onChanged: (value) => description = value,
                      ),
                      TextFormField(
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Video URL',
                          labelStyle: TextStyle(color: theme.colorScheme.onSurface),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.onSurface)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.primary)),
                          border: OutlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.onSurface)),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Video URL is required' : null,
                        controller: TextEditingController(text: videoUrl),
                        onChanged: (value) => videoUrl = value,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: theme.colorScheme.onSurface),
                  child:  Text('Cancel', style: TextStyle(color: theme.colorScheme.primary),),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child:
                      _isSaving
                          ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.onError,
                            ),
                          )
                          : const Text('Update'),
                  onPressed:
                      _isSaving
                          ? null
                          : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isSaving = true;
                              });
                              try {
                                EasyLoading.show(status: 'Updating...');
                                final updatedPostVideo = PostVideo(
                                  id: postVideo.id,
                                  adminId: postVideo.adminId,
                                  title: title,
                                  description: description,
                                  videoUrl: videoUrl,
                                  isShow: postVideo.isShow,
                                  createdAt: postVideo.createdAt,
                                  updatedAt: DateTime.now(),
                                  likes: postVideo.likes,
                                );
                                await Provider.of<PostVideoProvider>(
                                  context,
                                  listen: false,
                                ).updatePostVideo(updatedPostVideo);
                                EasyLoading.dismiss();
                                Navigator.of(context).pop();
                              } catch (e) {
                                EasyLoading.showError(
                                  'Failed to update post: $e',
                                );
                                MotionToast.error(
                                  title: const Text("Error"),
                                  description: Text(
                                    'Failed to update post: $e',
                                    style: TextStyle(
                                        color: theme.colorScheme.error),
                                  ),
                                  animationType: AnimationType.slideInFromRight,
                                  position: MotionToastPosition.bottom,
                                ).show(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to update post: $e',
                                      style: TextStyle(
                                          color: theme.colorScheme.error),
                                    ),
                                  ),
                                );
                              } finally {
                                setState(() {
                                  _isSaving = false;
                                });
                              }
                            } else {
                              MotionToast.error(
                                title: const Text("Error"),
                                description: const Text(
                                  'Please fill in all fields.',
                                ),
                                animationType: AnimationType.slideInFromRight,
                                position: MotionToastPosition.bottom,
                              ).show(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill in all fields.'),
                                ),
                              );
                            }
                          },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deletePostVideo(BuildContext context, String postId) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final ThemeData theme = themeProvider.themeData;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text(
            'Delete Post Video',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: Text(
            'Are you sure you want to delete this post?',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: theme.colorScheme.onSurface),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.errorContainer,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: const Text('Delete'),
              onPressed: () async {
                setState(() {
                  // _isButtonEnabled = false; // Disable button
                });
                try {
                  EasyLoading.show(status: 'Deleting...');
                  await Provider.of<PostVideoProvider>(
                    context,
                    listen: false,
                  ).deletePostVideo(postId);
                  EasyLoading.dismiss();
                  Navigator.of(context).pop();
                } catch (e) {
                  EasyLoading.showError('Failed to delete post: $e');
                  MotionToast.error(
                    title: const Text("Error"),
                    description: Text('Failed to delete post: $e',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                        )),
                    animationType: AnimationType.slideInFromRight,
                    position: MotionToastPosition.bottom,
                  ).show(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete post: $e',
                          style: TextStyle(
                            color: theme.colorScheme.error,
                          )),
                    ),
                  );
                } finally {
                  setState(() {
                    // _isButtonEnabled = true; // Re-enable button
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateIsShow(BuildContext context, bool value) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final ThemeData theme = themeProvider.themeData;

    try {
      EasyLoading.show(status: 'Updating...');
      final updatedPostVideo = PostVideo(
        id: widget.postVideo.id,
        adminId: widget.postVideo.adminId,
        title: widget.postVideo.title,
        description: widget.postVideo.description,
        videoUrl: widget.postVideo.videoUrl,
        isShow: value,
        createdAt: widget.postVideo.createdAt,
        updatedAt: DateTime.now(),
        likes: widget.postVideo.likes,
      );
      await Provider.of<PostVideoProvider>(
        context,
        listen: false,
      ).updatePostVideo(updatedPostVideo);
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.showError('Failed to update Show status: $e');
      MotionToast.error(
        title: const Text("Error"),
        description: Text('Failed to update Show status: $e',
            style: TextStyle(
              color: theme.colorScheme.error,
            )),
        animationType: AnimationType.slideInFromRight,
        position: MotionToastPosition.bottom,
      ).show(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to update Show status: $e',
                style: TextStyle(
                  color: theme.colorScheme.error,
                ))),
      );
    }
  }
}