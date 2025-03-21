import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';
import 'package:uidesign/Themes/theme_provider.dart';
import 'package:uidesign/models/admin.dart';
import 'package:uidesign/providers/admin_provider.dart';
import 'package:provider/provider.dart';
import 'package:uidesign/services/cloudinary_services.dart';
import 'package:uidesign/providers/follower_provider.dart';
import 'package:uidesign/models/follower.dart';
import 'package:uidesign/models/user.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Import flutter_animate
import 'package:google_fonts/google_fonts.dart'; // Modern fonts
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';


class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({Key? key}) : super(key: key);

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Uint8List? _webImageBytes;
  String? _imageError;
  String? _imageUrl;
  bool _isButtonEnabled = true;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  List<String> _selectedDays = [];
  bool _isShowInfo = false;
  bool _isFollowing = false;
  String? _adminId;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _descriptionController.dispose();
    super.dispose();
    EasyLoading.dismiss();
  }

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    Admin? admin =
        Provider.of<AdminProvider>(context, listen: false).getCurrentAdmin();

    if (admin != null) {
      _adminId = admin.id;
      _usernameController.text = admin.username;
      _emailController.text = admin.email;
      _passwordController.text = admin.password;
      _descriptionController.text = admin.description;
      _selectedDays = List<String>.from(admin.dayAvailable);
      _imageUrl = admin.imageUrl;
      _isShowInfo = admin.isShowInfo;
      _checkIfFollowing();
    }
  }

  Future<void> _checkIfFollowing() async {
    Admin? admin =
        Provider.of<AdminProvider>(context, listen: false).getCurrentAdmin();
    if (admin != null && _adminId != null) {
      FollowerProvider followerProvider = Provider.of<FollowerProvider>(
        context,
        listen: false,
      );
      Follower? followersData =
          await followerProvider.getFollowers(admin.id).first;
      setState(() {
        _isFollowing =
            followersData != null && followersData.follower.contains(_adminId);
      });
    }
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

  Future<void> _showDaySelectionDialog() async {
    List<String> allDays = [
      "Sait",
      "Axad",
      "Isniin",
      "Talaado",
      "Arbaco",
      "Khamiis",
      "Jimco",
    ];
    List<String> tempSelectedDays = List<String>.from(_selectedDays);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        final ThemeData theme = themeProvider.themeData;

        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text(
            "Select Available Days",
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children:
                      allDays.map((day) {
                        return CheckboxListTile(
                          title: Text(
                            day,
                            style: TextStyle(color: theme.colorScheme.onSurface),
                          ),
                          value: tempSelectedDays.contains(day),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                tempSelectedDays.add(day);
                              } else {
                                tempSelectedDays.remove(day);
                              }
                            });
                          },
                        );
                      }).toList(),
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Save"),
              onPressed: () {
                setState(() {
                  _selectedDays = tempSelectedDays;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData theme = themeProvider.themeData;

    Admin? admin = Provider.of<AdminProvider>(context).getCurrentAdmin();

    if (admin == null) {
      return Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: Center(
            child: Text(
          "Admin data not available.",
          style: TextStyle(color: theme.colorScheme.error),
        )),
      );
    }

    TextStyle labelStyle() => GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: theme.colorScheme.tertiary);
    TextStyle bodyStyle() => GoogleFonts.openSans(
        fontSize: 14, color: theme.colorScheme.onSurface);
    TextStyle buttonStyle() => GoogleFonts.montserrat(
        fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.onPrimary);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Admin Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: theme.colorScheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: theme.colorScheme.primary,
                      backgroundImage:
                          _webImageBytes != null
                              ? MemoryImage(_webImageBytes!)
                              : _imageUrl != null
                              ? NetworkImage(_imageUrl!)
                              : const AssetImage('assets/placeholder_image.png')
                                  as ImageProvider,
                    )
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 500)),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit,
                            color: theme.colorScheme.onPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              StreamBuilder<Follower?>(
                stream: Provider.of<FollowerProvider>(
                  context,
                  listen: false,
                ).getFollowers(admin.id),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final follower = snapshot.data;
                    final followerCount = follower?.follower.length ?? 0;

                    return Card(
                      elevation: 2,
                      color: theme.colorScheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Followers: $followerCount",
                              style: labelStyle(),
                            ),
                            if (follower != null &&
                                follower.follower.isNotEmpty)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primaryContainer,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor: theme.colorScheme.surface,
                                        title: Text(
                                          "Followers List",
                                          style: TextStyle(color: theme.colorScheme.onSurface),
                                        ),
                                        content: SizedBox(
                                          width: double.maxFinite,
                                          child: FutureBuilder<List<String>>(
                                            future: _getFollowerUsernames(
                                              follower.follower,
                                            ),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: theme.colorScheme.primaryContainer,
                                                      ),
                                                );
                                              } else if (snapshot.hasError) {
                                                return Text(
                                                  "Error: ${snapshot.error}",
                                                  style: TextStyle(color: theme.colorScheme.error),
                                                );
                                              } else {
                                                final usernames =
                                                    snapshot.data ?? [];
                                                return ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: usernames.length,
                                                  itemBuilder: (
                                                    context,
                                                    index,
                                                  ) {
                                                    return ListTile(
                                                      title: Text(
                                                        usernames[index],
                                                        style: bodyStyle(),
                                                      ),
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.onSurface),
                                            child: const Text("Close"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Text("View Followers"),
                              ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Text(
                      "Followers: 0",
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _usernameController,
                style: bodyStyle(),
                decoration: InputDecoration(
                  labelText: "Username",
                  labelStyle: labelStyle(),
                  border: const OutlineInputBorder(),
                ),
              )
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 300)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                style: bodyStyle(),
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: labelStyle(),
                  border: const OutlineInputBorder(),
                ),
              )
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 300)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                style: bodyStyle(),
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: labelStyle(),
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
              )
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 300)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                style: bodyStyle(),
                decoration: InputDecoration(
                  labelText: "Description",
                  labelStyle: labelStyle(),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              )
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 300)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text("Day Availability:", style: labelStyle()),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _showDaySelectionDialog,
                  ),
                ],
              ),
              Wrap(
                children: _selectedDays
                    .map(
                      (day) => Chip(
                        label: Text(day, style: TextStyle(color: theme.colorScheme.onSurface)),
                        backgroundColor: theme.colorScheme.primary,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text("Show Info:", style: labelStyle()),
                  Switch(
                    activeColor: theme.colorScheme.primaryContainer,
                    value: _isShowInfo,
                    onChanged: (value) {
                      setState(() {
                        _isShowInfo = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AnimatedButton(
                    onPressed:
                        _isButtonEnabled
                            ? () async {
                              setState(() {
                                _isButtonEnabled = false;
                              });
                              EasyLoading.show(status: 'Updating...');
                              try {
                                String imageUrl = _imageUrl ?? "";
                                if (_webImageBytes != null) {
                                  imageUrl =
                                      await _cloudinaryService.uploadImageBytes(
                                        _webImageBytes!,
                                      ) ??
                                      "";
                                }

                                Admin updatedAdmin = Admin(
                                  id: admin.id,
                                  fullname: admin.fullname,
                                  username: _usernameController.text,
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                  description: _descriptionController.text,
                                  imageUrl: imageUrl,
                                  createdAt: admin.createdAt,
                                  updatedAt: DateTime.now(),
                                  dayAvailable: _selectedDays,
                                  isShowInfo: _isShowInfo,
                                );
                                await Provider.of<AdminProvider>(
                                  context,
                                  listen: false,
                                ).updateAdmin(updatedAdmin);
                                EasyLoading.showSuccess('Profile updated!');
                              } catch (e) {
                                EasyLoading.showError(
                                  'Error updating profile: $e',
                                );
                              } finally {
                                setState(() {
                                  _isButtonEnabled = true;
                                });
                              }
                            }
                            : null,
                    child: const Text(
                      "Update Profile",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                  .animate(
                    target: _isButtonEnabled ? 0 : 1, // Animate when disabled
                    onPlay: (controller) {
                      if (!_isButtonEnabled) {
                        controller.repeat(reverse: true);
                      }
                    },
                  )
                  .shimmer(duration: const Duration(seconds: 1)),
              const SizedBox(height: 20),
            
            ],
          ),
        ),
      ),
    );
  }

  Future<List<String>> _getFollowerUsernames(List<String> followerIds) async {
    List<String> usernames = [];
    for (String userId in followerIds) {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .get();
      if (doc.exists) {
        User user = User.fromJson(doc.data() as Map<String, dynamic>);
        usernames.add(user.username);
      }
    }
    return usernames;
  }
}

class AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const AnimatedButton({Key? key, required this.onPressed, required this.child})
      : super(key: key);

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData theme = themeProvider.themeData;

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
        if (widget.onPressed != null) {
          widget.onPressed!();
        }
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color:
              widget.onPressed == null
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
          boxShadow:
              _isPressed || widget.onPressed == null
                  ? []
                  : [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Center(child: widget.child),
      ),
    );
  }
}