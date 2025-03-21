import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:uidesign/Themes/theme_provider.dart';
import 'package:uidesign/models/complete_lesson.dart';
import 'package:uidesign/models/course.dart';
import 'package:uidesign/models/discount.dart';
import 'package:uidesign/models/pdfs.dart';
import 'package:uidesign/models/purchased_course.dart';
import 'package:uidesign/models/user.dart';
import 'package:uidesign/providers/complete_provider.dart';
import 'package:uidesign/providers/user_provider.dart';
import 'package:uidesign/providers/purchased_course_provider.dart'; // Import PurchasedCourseProvider
import 'package:uidesign/services/cloudinary_services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';
import 'package:intl/intl.dart';

import 'package:uidesign/models/section.dart';
import 'package:uidesign/models/lesson.dart';
import 'package:uidesign/providers/section_provider.dart';
import 'package:uidesign/providers/lesson_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

const TextStyle titleTextStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
  // color: textColor, // Removed - will be themed
);

const TextStyle subtitleTextStyle = TextStyle(fontSize: 16, color: Colors.grey);

const TextStyle bodyTextStyle = TextStyle(
  fontSize: 14,
  // color: textColor // Removed - will be themed
);


class AllUserScreen extends StatefulWidget {
  const AllUserScreen({Key? key}) : super(key: key);

  @override
  State<AllUserScreen> createState() => _AllUserScreenState();
}

class _AllUserScreenState extends State<AllUserScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData theme = themeProvider.themeData;

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Users", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent, // Use theme's primary color
      ),
      backgroundColor: theme.colorScheme.background, // Use theme's background color
      body: StreamBuilder<List<User>>(
        stream: _getUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final users = snapshot.data!;

            // Split users into rows of 2
            List<List<User>> rows = [];
            for (int i = 0; i < users.length; i += 2) {
              rows.add(
                users.sublist(i, i + 2 > users.length ? users.length : i + 2),
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
                          row.map((user) {
                            return Expanded(
                              child: AnimationConfiguration.staggeredList(
                                position: rowIndex * 2 + row.indexOf(user),
                                duration: const Duration(milliseconds: 500),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: GestureDetector(
                                      // Wrap the UserCard with GestureDetector
                                      onTap: () {
                                        // Navigate to User Details Screen
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => UserDetailScreen(
                                                  user: user,
                                                ),
                                          ),
                                        );
                                      },
                                      child: UserCard(user: user),
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
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(  // Add a floating action button to toggle theme
        onPressed: () {
          themeProvider.toggleTheme();
        },
        child: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
      ),
    );
  }

  Stream<List<User>> _getUsersStream() {
    return FirebaseFirestore.instance.collection('users').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => User.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}

class UserCard extends StatefulWidget {
  final User user;

  const UserCard({Key? key, required this.user}) : super(key: key);

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  late bool _isLoggedIn;
  late bool _isStudent;
  bool _isSaving = false; // Track saving state

  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.user.isLoggedIn;
    _isStudent = widget.user.isStudent;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData theme = themeProvider.themeData;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailScreen(user: widget.user),
          ),
        );
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(8.0),
        color: theme.colorScheme.surface, // Card background color
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage:
                        widget.user.imageUrl.isNotEmpty
                            ? NetworkImage(widget.user.imageUrl)
                            : null,
                    radius: 30,
                    backgroundColor: theme.colorScheme.primary,
                    child:
                        widget.user.imageUrl.isEmpty
                            ? Icon(Icons.person, color: theme.colorScheme.onPrimary)
                            : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.fullname,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface
                          ),
                        ),
                        Text(
                          "@${widget.user.username}",
                          style: TextStyle(color: theme.colorScheme.tertiary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text("Email: ${widget.user.email}", style: TextStyle(color: theme.colorScheme.onSurface)),
              Text("Number: ${widget.user.number}", style: TextStyle(color: theme.colorScheme.onSurface)),
              Text("Description: ${widget.user.description}", style: TextStyle(color: theme.colorScheme.onSurface)),
              Row(
                children: [
                  Text("Is Logged In:", style: TextStyle(color: theme.colorScheme.onSurface)),
                  Switch(
                    value: _isLoggedIn,
                    onChanged:
                        _isSaving
                            ? null
                            : (value) {
                              setState(() {
                                _isLoggedIn = value;
                              });
                              _updateUser(context, isLoggedIn: value);
                            },
                  ),
                ],
              ),
              Row(
                children: [
                  Text("Is Student:", style: TextStyle(color: theme.colorScheme.onSurface)),
                  Switch(
                    value: _isStudent,
                    onChanged:
                        _isSaving
                            ? null
                            : (value) {
                              setState(() {
                                _isStudent = value;
                              });
                              _updateUser(context, isStudent: value);
                            },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isSaving
                            ? null
                            : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          EditUserScreen(user: widget.user),
                                ),
                              );
                            },
                    style: TextButton.styleFrom(foregroundColor: Colors.blue),
                    child: const Text("Edit"),
                  ),
                  TextButton(
                    onPressed:
                        _isSaving
                            ? null
                            : () {
                              _showDeleteConfirmationDialog(
                                context,
                                widget.user.id,
                              );
                            },
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text("Delete"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateUser(
    BuildContext context, {
    bool? isLoggedIn,
    bool? isStudent,
  }) async {
    if (_isSaving) return; // Prevent multiple updates

    setState(() {
      _isSaving = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final updatedUser = User(
      id: widget.user.id,
      fullname: widget.user.fullname,
      username: widget.user.username,
      email: widget.user.email,
      number: widget.user.number,
      description: widget.user.description,
      imageUrl: widget.user.imageUrl,
      password: widget.user.password,
      createdAt: widget.user.createdAt,
      updatedAt: DateTime.now(),
      isLoggedIn: isLoggedIn ?? widget.user.isLoggedIn,
      isStudent: isStudent ?? widget.user.isStudent,
      lastActivated: widget.user.lastActivated,
    );

    try {
      await userProvider.updateUser(updatedUser);
      MotionToast.success(
        title: const Text("Success"),
        description: const Text("User Update Successfully"),
        animationType: AnimationType.slideInFromRight,
        position: MotionToastPosition.bottom,
      ).show(context);
    } catch (e) {
      MotionToast.error(
        title: const Text("Error"),
        description: Text("Failed to update user: $e"),
        animationType: AnimationType.slideInFromRight,
        position: MotionToastPosition.bottom,
      ).show(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to update user.")));
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, String userId) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final ThemeData theme = themeProvider.themeData;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text("Confirm Delete", style: TextStyle(color: theme.colorScheme.onSurface)),
          content: Text("Are you sure you want to delete this user?", style: TextStyle(color: theme.colorScheme.onSurface)),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () {
                if (_isSaving) return; // Prevent multiple deletes

                setState(() {
                  _isSaving = true;
                });

                Provider.of<UserProvider>(context, listen: false)
                    .deleteUser(userId)
                    .then((_) {
                      MotionToast.success(
                        title: const Text("Success"),
                        description: const Text("User deleted Successfully"),
                        animationType: AnimationType.slideInFromRight,
                        position: MotionToastPosition.bottom,
                      ).show(context);
                    })
                    .catchError((error) {
                      MotionToast.error(
                        title: const Text("Error"),
                        description: Text("Failed to Delete user: $error"),
                        animationType: AnimationType.slideInFromRight,
                        position: MotionToastPosition.bottom,
                      ).show(context);
                    })
                    .whenComplete(() {
                      setState(() {
                        _isSaving = false;
                      });
                      Navigator.of(context).pop(); // Dismiss the dialog
                    });
              },
            ),
          ],
        );
      },
    );
  }
}


class EditUserScreen extends StatefulWidget {
  final User user;

  const EditUserScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSaving = false; // Track saving state

  Uint8List? _webImageBytes;
  String? _imageError;
  String? _imageUrl;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  @override
  void initState() {
    super.initState();
    _fullnameController.text = widget.user.fullname;
    _usernameController.text = widget.user.username;
    _emailController.text = widget.user.email;
    _numberController.text = widget.user.number;
    _descriptionController.text = widget.user.description;
    _passwordController.text = widget.user.password;
    _imageUrl = widget.user.imageUrl;
  }

  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
        final ImagePicker imagePicker = ImagePicker();
        final XFile? pickedFile = await imagePicker.pickImage(
          source: ImageSource.gallery,
        );
        if (pickedFile != null) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
            _imageError = null;
            _imageUrl = null;
          });
        } else {
          setState(() {
            _imageError = 'No image selected.';
            _webImageBytes = null;
            _imageUrl = null;
          });
        }
      } else {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
        );

        if (image != null) {
          setState(() {
            _webImageBytes = File(image.path).readAsBytesSync();
            _imageError = null;
            _imageUrl = null;
          });
        } else {
          setState(() {
            _imageError = 'No image selected.';
            _webImageBytes = null;
            _imageUrl = null;
          });
        }
      }
    } catch (e) {
      setState(() {
        _imageError = 'Error picking image: $e';
        _webImageBytes = null;
        _imageUrl = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData theme = themeProvider.themeData;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit User", style: TextStyle(color: Colors.white)),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      backgroundColor: theme.colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _fullnameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  border: const OutlineInputBorder(),
                  labelStyle: TextStyle(color: theme.colorScheme.onSurface)
                ),
                style: TextStyle(color: theme.colorScheme.onSurface),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter full name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  border: const OutlineInputBorder(),
                  labelStyle: TextStyle(color: theme.colorScheme.onSurface)

                ),
                style: TextStyle(color: theme.colorScheme.onSurface),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter username";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: const OutlineInputBorder(),
                  labelStyle: TextStyle(color: theme.colorScheme.onSurface)
                ),
                style: TextStyle(color: theme.colorScheme.onSurface),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter email";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _numberController,
                decoration: InputDecoration(
                  labelText: "Number",
                  border: const OutlineInputBorder(),
                  labelStyle: TextStyle(color: theme.colorScheme.onSurface)
                ),
                style: TextStyle(color: theme.colorScheme.onSurface),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: const OutlineInputBorder(),
                  labelStyle: TextStyle(color: theme.colorScheme.onSurface)
                ),
                style: TextStyle(color: theme.colorScheme.onSurface),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: const OutlineInputBorder(),
                  labelStyle: TextStyle(color: theme.colorScheme.onSurface)
                ),
                style: TextStyle(color: theme.colorScheme.onSurface),
                // Consider: Only show/require this if changing password
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isSaving ? null : _pickImage,
                child: const Text("Pick Image"),
              ),
              const SizedBox(height: 10),
              if (_imageError != null)
                Text(_imageError!, style: TextStyle(color: theme.colorScheme.error)),
              if (_webImageBytes != null)
                Image.memory(_webImageBytes!, height: 100),
              if (_imageUrl != null)
                Image.network(
                  _imageUrl!,
                  height: 100,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(Icons.error),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed:
                    _isSaving
                        ? null
                        : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isSaving = true;
                            });
                            EasyLoading.show(status: 'Updating...');
                            try {
                              String imageUrl =
                                  _imageUrl ??
                                  ""; // Use existing URL if no new image selected

                              if (_webImageBytes != null) {
                                imageUrl =
                                    await _cloudinaryService.uploadImageBytes(
                                      _webImageBytes!,
                                    ) ??
                                    ''; // Handle potential null from upload
                              }

                              final updatedUser = User(
                                id: widget.user.id,
                                fullname: _fullnameController.text,
                                username: _usernameController.text,
                                email: _emailController.text,
                                number: _numberController.text,
                                description: _descriptionController.text,
                                imageUrl: imageUrl,
                                password: _passwordController.text,
                                createdAt: widget.user.createdAt,
                                updatedAt: DateTime.now(),
                                isLoggedIn: widget.user.isLoggedIn,
                                isStudent: widget.user.isStudent,
                                lastActivated: widget.user.lastActivated,
                              );

                              await Provider.of<UserProvider>(
                                context,
                                listen: false,
                              ).updateUser(updatedUser);
                              MotionToast.success(
                                title: const Text("Success"),
                                description: const Text(
                                  "User Updated Successfully",
                                ),
                                animationType: AnimationType.slideInFromRight,
                                position: MotionToastPosition.bottom,
                              ).show(context);
                              Navigator.pop(context); // Go back to the list
                            } catch (e) {
                              MotionToast.error(
                                title: const Text("Error"),
                                description: Text('Failed to update user: $e'),
                                animationType: AnimationType.slideInFromRight,
                                position: MotionToastPosition.bottom,
                              ).show(context);
                            } finally {
                              setState(() {
                                _isSaving = false;
                              });
                              EasyLoading.dismiss();
                            }
                          }
                        },
                child:
                    _isSaving
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                        : const Text("Update User"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _numberController.dispose();
    _descriptionController.dispose();
    _passwordController.dispose();
    EasyLoading.dismiss();
    super.dispose();
  }
}

class UserDetailScreen extends StatefulWidget {
  final User user;

  const UserDetailScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  bool _showPurchaseInfo = true; // Added state for tab selection
  bool _showMyCourses = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData theme = themeProvider.themeData;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "User Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      backgroundColor: theme.colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tab Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabButton(
                  context,
                  "Order Details",
                  _showPurchaseInfo,
                  () {
                    setState(() {
                      _showPurchaseInfo = true;
                      _showMyCourses = false;
                    });
                  },
                ),
                _buildTabButton(
                  context,
                  "Approved Courses",
                  _showMyCourses,
                  () {
                    setState(() {
                      _showPurchaseInfo = false;
                      _showMyCourses = true;
                    });
                  },
                ),
              ],
            ),
            Expanded(
              child: PageTransitionSwitcher(
                // Animated transition between sections
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (
                  child,
                  primaryAnimation,
                  secondaryAnimation,
                ) {
                  return FadeThroughTransition(
                    animation: primaryAnimation,
                    secondaryAnimation: secondaryAnimation,
                    child: child,
                  );
                },
                child:
                    _showPurchaseInfo
                        ? PurchaseInfoSection(
                          userId: widget.user.id,
                          key: const ValueKey('purchaseInfo'),
                        )
                        : ApprovedCoursesSection(
                          userId: widget.user.id,
                          key: const ValueKey('approvedCourses'),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(
    BuildContext context,
    String text,
    bool isActive,
    VoidCallback onPressed,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData theme = themeProvider.themeData;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? theme.colorScheme.primaryContainer : Colors.grey[300],
        foregroundColor: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.tertiary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: isActive ? 4 : 0, // Raised effect when active
      ),
      child: Text(text),
    );
  }
}

class PurchaseInfoSection extends StatelessWidget {
  final String userId;

  const PurchaseInfoSection({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final purchasedCourseProvider = Provider.of<PurchasedCourseProvider>(
      context,
    );
     final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData theme = themeProvider.themeData;

    return StreamBuilder<List<PurchasedCourse>>(
      stream: purchasedCourseProvider.getPurchasedCourses(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final purchasedCourses = snapshot.data!;

          final userPurchasedCourses =
              purchasedCourses
                  .where((course) => course.userId == userId)
                  .toList();

          if (userPurchasedCourses.isEmpty) {
            return const Center(
              child: Text(
                "This user hasn't purchased anything yet.",
                style: bodyTextStyle,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: userPurchasedCourses.length,
            itemBuilder: (context, index) {
              final purchasedCourse = userPurchasedCourses[index];

              return FutureBuilder<PurchaseDetails>(
                future: _getPurchaseDetails(purchasedCourse),
                builder: (context, detailsSnapshot) {
                  if (detailsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return  Center(
                      child: CircularProgressIndicator(color: theme.primaryColor ),
                    );
                  } else if (detailsSnapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error: ${detailsSnapshot.error}",
                        style: bodyTextStyle,
                      ),
                    );
                  } else if (detailsSnapshot.hasData) {
                    final details = detailsSnapshot.data!;

                    return PurchasedItemCard(
                      purchasedCourse: purchasedCourse,
                      courses: details.courses,
                      pdfs: details.pdfs,
                    );
                  } else {
                    return const Center(
                      child: Text("No items found.", style: bodyTextStyle),
                    );
                  }
                },
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text("Error: ${snapshot.error}", style: bodyTextStyle),
          );
        } else {
          return  Center(
            child: CircularProgressIndicator(color: theme.primaryColor),
          );
        }
      },
    );
  }

  Future<PurchaseDetails> _getPurchaseDetails(
    PurchasedCourse purchasedCourse,
  ) async {
    List<Course> courses = [];
    List<PDF> pdfs = [];

    // Fetch courses
    for (var courseId in purchasedCourse.courseIds) {
      var snapshot =
          await FirebaseFirestore.instance
              .collection('courses')
              .doc(courseId)
              .get();
      if (snapshot.exists) {
        courses.add(Course.fromJson(snapshot.data() as Map<String, dynamic>));
      }
    }

    // Fetch PDFs
    if (purchasedCourse.pdfIds != null) {
      for (var pdfId in purchasedCourse.pdfIds!) {
        var snapshot =
            await FirebaseFirestore.instance
                .collection('pdfs')
                .doc(pdfId)
                .get();
        if (snapshot.exists) {
          pdfs.add(PDF.fromJson(snapshot.data() as Map<String, dynamic>));
        }
      }
    }

    return PurchaseDetails(courses: courses, pdfs: pdfs);
  }
}

class PurchaseDetails {
  final List<Course> courses;
  final List<PDF> pdfs;

  PurchaseDetails({required this.courses, required this.pdfs});
}

class PurchasedItemCard extends StatefulWidget {
  final PurchasedCourse purchasedCourse;
  final List<Course> courses;
  final List<PDF> pdfs;

  const PurchasedItemCard({
    Key? key,
    required this.purchasedCourse,
    required this.courses,
    required this.pdfs,
  }) : super(key: key);

  @override
  State<PurchasedItemCard> createState() => _PurchasedItemCardState();
}

class _PurchasedItemCardState extends State<PurchasedItemCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData theme = themeProvider.themeData;

    return MouseRegion(
      onEnter: (event) => setState(() => _isHovering = true),
      onExit: (event) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovering ? 1.02 : 1.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(_isHovering ? 0.5 : 0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        margin: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone, color: theme.colorScheme.primaryContainer),
                  const SizedBox(width: 8),
                  Text(
                    "Phone Number: ${widget.purchasedCourse.number}",
                    style:
                        bodyTextStyle.copyWith(color: theme.colorScheme.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.monetization_on,
                      color: theme.colorScheme.primaryContainer),
                  const SizedBox(width: 8),
                  Text(
                    "Total Price: \$${widget.purchasedCourse.totalPrice.toStringAsFixed(2)}",
                    style:
                        bodyTextStyle.copyWith(color: theme.colorScheme.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      color: theme.colorScheme.primaryContainer),
                  const SizedBox(width: 8),
                  Text(
                    "Purchase Date: ${DateFormat('MMMM d, yyyy – kk:mm').format(widget.purchasedCourse.purchasedAt)}",
                    style:
                        bodyTextStyle.copyWith(color: theme.colorScheme.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    widget.purchasedCourse.show
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: theme.colorScheme.primaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Show: ${widget.purchasedCourse.show ? 'Visible' : 'Hidden'}",
                    style:
                        bodyTextStyle.copyWith(color: theme.colorScheme.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    widget.purchasedCourse.pending
                        ? Icons.pending
                        : Icons.check_circle,
                    color: theme.colorScheme.primaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Status: ${widget.purchasedCourse.pending ? 'Approved' : 'Pending'}", //Reversed
                    style:
                        bodyTextStyle.copyWith(color: theme.colorScheme.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (widget.courses.isNotEmpty) ...[
                Text("Courses:",
                    style: titleTextStyle.copyWith(
                        fontSize: 16, color: theme.colorScheme.onSurface)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.courses
                      .map(
                        (course) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Icon(Icons.school,
                                  color: theme.colorScheme.secondaryContainer),
                              const SizedBox(width: 8),
                              Text(
                                "• ${course.title}",
                                style: bodyTextStyle.copyWith(
                                    color: theme.colorScheme.onSurface),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              if (widget.pdfs.isNotEmpty) ...[
                Text("PDFs:",
                    style: titleTextStyle.copyWith(
                        fontSize: 16, color: theme.colorScheme.onSurface)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.pdfs
                      .map(
                        (pdf) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.picture_as_pdf,
                                color: theme.colorScheme.secondaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text("• ${pdf.name}",
                                  style: bodyTextStyle.copyWith(
                                      color: theme.colorScheme.onSurface)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ApprovedCoursesSection extends StatelessWidget {
  final String userId;

  const ApprovedCoursesSection({Key? key, required this.userId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData theme = themeProvider.themeData;

    final purchasedCourseProvider = Provider.of<PurchasedCourseProvider>(
      context,
    );

    return StreamBuilder<List<PurchasedCourse>>(
      stream: purchasedCourseProvider.getPurchasedCourses(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final purchasedCourses = snapshot.data!;

          final userApprovedCourses = purchasedCourses
              .where(
                (course) => course.userId == userId && course.pending,
              ) // Only show approved courses (pending: false)
              .toList();

          if (userApprovedCourses.isEmpty) {
            return Center(
              child: Text(
                "This user doesn't have any approved courses yet.",
                style: bodyTextStyle.copyWith(color: theme.colorScheme.onSurface),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: userApprovedCourses.length,
            itemBuilder: (context, index) {
              final purchasedCourse = userApprovedCourses[index];
              return CourseListByCourseId(purchasedCourse: purchasedCourse);
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text("Error: ${snapshot.error}",
                style: bodyTextStyle.copyWith(color: theme.colorScheme.error)),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(
                color: theme.colorScheme.primaryContainer),
          );
        }
      },
    );
  }
}

class CourseListByCourseId extends StatelessWidget {
  const CourseListByCourseId({Key? key, required this.purchasedCourse})
    : super(key: key);
  final PurchasedCourse purchasedCourse;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Conditionally build the UI based on whether this purchase contains courses or just PDFs
    if (purchasedCourse.courseIds.isNotEmpty) {
      // This is a course purchase
      return FutureBuilder<List<Course>>(
        future: _getCourseList(purchasedCourse.courseIds),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final courses = snapshot.data!;
            return CourseCard(courses: courses);
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
            );
          }
        },
      );
    } else if (purchasedCourse.pdfIds != null &&
        purchasedCourse.pdfIds!.isNotEmpty) {
      // This is a PDF-only purchase
      return const Text(
        "",//PDF Only Purchase
      ); //Placeholder, build your PDF display here.
    } else {
      //Should not happen but added for safety
      return const Text("Empty Purchase");
    }
  }


  Future<List<Course>> _getCourseList(List<String> courseIds) async {
    List<Course> courses = [];
    // Fetch courses from Firestore based on courseIds
    for (var courseId in courseIds) {
      var snapshot =
          await FirebaseFirestore.instance
              .collection('courses')
              .doc(courseId)
              .get();
      if (snapshot.exists) {
        courses.add(Course.fromJson(snapshot.data() as Map<String, dynamic>));
      }
    }
    return courses;
  }
}

class CourseCard extends StatefulWidget {
  final List<Course> courses;

  const CourseCard({Key? key, required this.courses}) : super(key: key);

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData theme = themeProvider.themeData;

    return MouseRegion(
      onEnter: (event) => setState(() => _isHovering = true),
      onExit: (event) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovering ? 1.02 : 1.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(_isHovering ? 0.5 : 0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        margin: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Course Title: ${widget.courses.first.title}",
                style: titleTextStyle.copyWith(color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return SizedBox(
                    width: constraints.maxWidth,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final courseId = widget.courses.first.id;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CourseDetailsPage(courseId: courseId),
                          ),
                        );
                      },
                      icon: Icon(Icons.visibility, color: theme.colorScheme.onPrimary),
                      label: Text(
                        "View Course Details",
                        style: TextStyle(color: theme.colorScheme.onPrimary),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.w500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class CourseDetailsPage extends StatelessWidget {
  final String courseId;

  const CourseDetailsPage({Key? key, required this.courseId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("CourseDetailsPage build method called with courseId: $courseId");
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData theme = themeProvider.themeData;

    final sectionProvider = Provider.of<SectionProvider>(context);
    final completeLessonProvider = Provider.of<CompleteLessonProvider>(context);
    final userId =
        Provider.of<UserProvider>(context, listen: false).currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Course Details", style: TextStyle(color: Colors.white)),
            StreamBuilder<List<Lesson>>(
              stream: FirebaseFirestore.instance
                  .collection('lessons')
                  .where('courseId', isEqualTo: courseId)
                  .snapshots()
                  .map((snapshot) {
                return snapshot.docs
                    .map(
                      (doc) => Lesson.fromJson(
                        doc.data() as Map<String, dynamic>,
                      ),
                    )
                    .toList();
              }),
              builder: (context, lessonSnapshot) {
                if (lessonSnapshot.hasData) {
                  final lessons = lessonSnapshot.data!;
                  return StreamBuilder<List<CompleteLesson>>(
                    stream: completeLessonProvider.getCompleteLessons(
                      userId: userId,
                      courseId: courseId,
                    ),
                    builder: (context, completeLessonSnapshot) {
                      if (completeLessonSnapshot.hasData) {
                        final completedLessons = completeLessonSnapshot.data!;
                        final completedCount = lessons.where((lesson) {
                          return completedLessons.any(
                            (completedLesson) =>
                                completedLesson.lessonId == lesson.id &&
                                completedLesson.status,
                          );
                        }).length;

                        final percentage = lessons.isNotEmpty
                            ? (completedCount / lessons.length * 100).round()
                            : 0;

                        return Text(
                          "$percentage%",
                          style: const TextStyle(color: Colors.white),
                        );
                      } else {
                        return const Text(
                          "Loading...",
                          style: TextStyle(color: Colors.white),
                        );
                      }
                    },
                  );
                } else {
                  return const Text(
                    "Loading...",
                    style: TextStyle(color: Colors.white),
                  );
                }
              },
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.primaryContainer,
        elevation: 0,
      ),
      backgroundColor: theme.colorScheme.background,
      body: StreamBuilder<List<Section>>(
        stream: FirebaseFirestore.instance
            .collection('sections')
            .where('courseId', isEqualTo: courseId)
            .snapshots()
            .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => Section.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList();
        }),
        builder: (context, sectionSnapshot) {
          if (sectionSnapshot.hasData) {
            final sections = sectionSnapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];

                return SectionCard(section: section);
              },
            );
          } else if (sectionSnapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${sectionSnapshot.error}",
                style: bodyTextStyle.copyWith(color: theme.colorScheme.error),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(
                  color: theme.colorScheme.primaryContainer),
            );
          }
        },
      ),
    );
  }
}

// Section Card
class SectionCard extends StatelessWidget {
  final Section section;

  const SectionCard({Key? key, required this.section}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData theme = themeProvider.themeData;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.title,
              style: titleTextStyle.copyWith(
                  fontSize: 18, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 8),
          Text(section.description,
              style:
                  bodyTextStyle.copyWith(color: theme.colorScheme.onSurface)),
          const SizedBox(height: 16),
          LessonList(sectionId: section.id, courseId: section.courseId),
        ],
      ),
    );
  }
}

// Lesson List Widget
class LessonList extends StatelessWidget {
  final String sectionId;
  final String courseId;

  const LessonList({Key? key, required this.sectionId, required this.courseId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData theme = themeProvider.themeData;

    final completeLessonProvider = Provider.of<CompleteLessonProvider>(context);
    final userId =
        Provider.of<UserProvider>(context, listen: false).currentUser?.id;

    return StreamBuilder<List<Lesson>>(
      stream: FirebaseFirestore.instance
          .collection('lessons')
          .where('sectionId', isEqualTo: sectionId)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map(
              (doc) => Lesson.fromJson(doc.data() as Map<String, dynamic>),
            )
            .toList();
      }),
      builder: (context, lessonSnapshot) {
        if (lessonSnapshot.hasData) {
          final lessons = lessonSnapshot.data!;

          return StreamBuilder<List<CompleteLesson>>(
            stream: completeLessonProvider.getCompleteLessons(
              userId: userId,
              courseId: courseId,
              sectionId: sectionId,
            ),
            builder: (context, completeLessonSnapshot) {
              if (completeLessonSnapshot.hasData) {
                final completedLessons = completeLessonSnapshot.data!;
                final completedCount = lessons.where((lesson) {
                  return completedLessons.any(
                    (completedLesson) =>
                        completedLesson.lessonId == lesson.id &&
                        completedLesson.status,
                  );
                }).length;
                final percentage = lessons.isNotEmpty
                    ? (completedCount / lessons.length * 100).round()
                    : 0;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Progress: $percentage%",
                            style: titleTextStyle.copyWith(
                                fontSize: 16, color: theme.colorScheme.onSurface),
                          ),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.secondaryContainer),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: lessons.map((lesson) {
                        return LessonCard(
                          lesson: lesson,
                          courseId: courseId,
                          sectionId: sectionId,
                        );
                      }).toList(),
                    ),
                  ],
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(
                      color: theme.colorScheme.primaryContainer),
                );
              }
            },
          );
        } else if (lessonSnapshot.hasError) {
          return Center(
            child: Text("Error: ${lessonSnapshot.error}",
                style: bodyTextStyle.copyWith(color: theme.colorScheme.error)),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(
                color: theme.colorScheme.primaryContainer),
          );
        }
      },
    );
  }
}

// Lesson Card
class LessonCard extends StatefulWidget {
  final Lesson lesson;
  final String courseId;
  final String sectionId;

  const LessonCard({
    Key? key,
    required this.lesson,
    required this.courseId,
    required this.sectionId,
  }) : super(key: key);

  @override
  State<LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<LessonCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData theme = themeProvider.themeData;

    final completeLessonProvider = Provider.of<CompleteLessonProvider>(context);
    final userId =
        Provider.of<UserProvider>(context, listen: false).currentUser?.id;

    return MouseRegion(
      onEnter: (event) => setState(() => _isHovering = true),
      onExit: (event) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(_isHovering ? 0.5 : 0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: Icon(Icons.play_circle_fill,
              color: theme.colorScheme.primaryContainer),
          title: Text(widget.lesson.title,
              style:
                  bodyTextStyle.copyWith(color: theme.colorScheme.onSurface)),
          subtitle: Text(
            "${widget.lesson.duration} minutes",
            style: subtitleTextStyle.copyWith(color: theme.colorScheme.tertiary),
          ),
          trailing: StreamBuilder<List<CompleteLesson>>(
            stream: completeLessonProvider.getCompleteLessons(
              userId: userId,
              courseId: widget.courseId,
              sectionId: widget.sectionId,
              lessonId: widget.lesson.id,
            ),
            builder: (context, snapshot) {
              bool isComplete = false;
              String completeLessonId = '';
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                isComplete = snapshot.data!.first.status;
                completeLessonId = snapshot.data!.first.id;
              }

              return IconButton(
                icon: Icon(
                  Icons.check_circle,
                  color: isComplete ? Colors.green : Colors.grey,
                  size: 28,
                ),
                onPressed: () {
                  if (userId != null) {
                    _toggleLessonCompletion(
                      context,
                      userId,
                      isComplete,
                      completeLessonId,
                    );
                  }
                },
              );
            },
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    VideoPlayerPage(videoUrl: widget.lesson.videoUrl),
              ),
            );
          },
        ),
      ),
    );
  }

  void _toggleLessonCompletion(
    BuildContext context,
    String userId,
    bool isComplete,
    String completeLessonId,
  ) {
    final completeLessonProvider = Provider.of<CompleteLessonProvider>(
      context,
      listen: false,
    );

    if (completeLessonId.isNotEmpty) {
      // Update existing completion
      completeLessonProvider.markLessonComplete(
        id: completeLessonId,
        userId: userId,
        courseId: widget.courseId,
        sectionId: widget.sectionId,
        lessonId: widget.lesson.id,
        status: !isComplete,
      );
    } else {
      // Create a new completion record
      completeLessonProvider.markLessonComplete(
        id: const Uuid().v4(),
        userId: userId,
        courseId: widget.courseId,
        sectionId: widget.sectionId,
        lessonId: widget.lesson.id,
        status: true,
      );
    }
  }
}

// Video Player Page
class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerPage({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

    if (videoId != null) {
      try {
        _controller = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
        );
      } catch (e) {
        print("Error initializing YoutubePlayerController: $e");
      }
    } else {
      print("Invalid YouTube URL: $widget.videoUrl");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData theme = themeProvider.themeData;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Lesson Video",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: theme.colorScheme.primaryContainer,
        elevation: 0,
      ),
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: theme.colorScheme.secondaryContainer,
          progressColors: ProgressBarColors(
            playedColor: theme.colorScheme.secondaryContainer,
            handleColor: theme.colorScheme.primaryContainer,
          ),
          onReady: () {
            print("Player is ready");
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

// New Widget for "My PDFs" Section
class MyPDFsSection extends StatelessWidget {
  const MyPDFsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData theme = themeProvider.themeData;

    final userProvider = Provider.of<UserProvider>(context);
    final purchasedCourseProvider = Provider.of<PurchasedCourseProvider>(
      context,
    );

    final user = userProvider.currentUser;

    if (user == null) {
      return Center(
        child: Text("Please log in to see your PDFs.",
            style: bodyTextStyle.copyWith(color: theme.colorScheme.onSurface)),
      );
    }

    return StreamBuilder<List<PurchasedCourse>>(
      stream: purchasedCourseProvider.getPurchasedCourses(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final purchasedCourses = snapshot.data!;

          final userPurchasedCourses = purchasedCourses
              .where((course) => course.userId == user.id)
              .toList();

          List<String> allPdfIds = [];
          for (var purchasedCourse in userPurchasedCourses) {
            if (purchasedCourse.pdfIds != null) {
              allPdfIds.addAll(purchasedCourse.pdfIds!);
            }
          }

          if (allPdfIds.isEmpty) {
            return Center(
              child: Text(
                "You haven't purchased any PDFs yet.",
                style: bodyTextStyle.copyWith(color: theme.colorScheme.onSurface),
              ),
            );
          }

          return FutureBuilder<List<PDF>>(
            future: _getPdfList(allPdfIds),
            builder: (context, pdfSnapshot) {
              if (pdfSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                      color: theme.colorScheme.primaryContainer),
                );
              } else if (pdfSnapshot.hasError) {
                return Center(
                  child: Text(
                    "Error: ${pdfSnapshot.error}",
                    style: bodyTextStyle.copyWith(color: theme.colorScheme.error),
                  ),
                );
              } else if (pdfSnapshot.hasData) {
                final pdfs = pdfSnapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: pdfs.length,
                  itemBuilder: (context, index) {
                    final pdf = pdfs[index];
                    return PdfCard(pdf: pdf);
                  },
                );
              } else {
                return Center(
                  child: Text("No PDFs found.",
                      style: bodyTextStyle.copyWith(color: theme.colorScheme.onSurface)),
                );
              }
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text("Error: ${snapshot.error}",
                style: bodyTextStyle.copyWith(color: theme.colorScheme.error)),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(
                color: theme.colorScheme.primaryContainer),
          );
        }
      },
    );
  }

  Future<List<PDF>> _getPdfList(List<String> pdfIds) async {
    List<PDF> pdfs = [];

    for (var pdfId in pdfIds) {
      var snapshot =
          await FirebaseFirestore.instance.collection('pdfs').doc(pdfId).get();
      if (snapshot.exists) {
        pdfs.add(PDF.fromJson(snapshot.data() as Map<String, dynamic>));
      }
    }

    return pdfs;
  }
}

// PDF Card Widget
class PdfCard extends StatefulWidget {
  final PDF pdf;

  const PdfCard({Key? key, required this.pdf}) : super(key: key);

  @override
  State<PdfCard> createState() => _PdfCardState();
}

class _PdfCardState extends State<PdfCard> {
  bool _isHovering = false;

  Future<void> _downloadPdf(
      BuildContext context, String url, String fileName) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final ThemeData theme = themeProvider.themeData;

    try {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Storage permission is required to download files.',
              ),
            ),
          );
          return;
        }
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Directory? appDocDir = await getExternalStorageDirectory();
        if (appDocDir == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Could not get storage directory.'),
            ),
          );
          return;
        }
        String appDocPath = appDocDir.path;
        final filePath = '$appDocPath/$fileName.pdf';

        File pdfFile = File(filePath);
        await pdfFile.writeAsBytes(response.bodyBytes);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Downloaded to $filePath')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to download PDF. Status code: ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error downloading PDF: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData theme = themeProvider.themeData;

    return MouseRegion(
      onEnter: (event) => setState(() => _isHovering = true),
      onExit: (event) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovering ? 1.02 : 1.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(_isHovering ? 0.5 : 0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        margin: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.pdf.name,
                  style: titleTextStyle.copyWith(color: theme.colorScheme.onSurface)),
              const SizedBox(height: 8),
              Text(widget.pdf.description,
                  style: subtitleTextStyle.copyWith(color: theme.colorScheme.tertiary)),
              const SizedBox(height: 8),
              if (widget.pdf.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    widget.pdf.imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _downloadPdf(context, widget.pdf.fileUrl, widget.pdf.name),
                icon: Icon(Icons.download, color: theme.colorScheme.onPrimary),
                label: Text(
                  "Download PDF",
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w500),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}