import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart'; // Import for web (CONDITIONAL)
import 'package:provider/provider.dart';
import 'package:uidesign/models/hero_section.dart';
import 'package:uidesign/providers/hero_section_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_animate/flutter_animate.dart'; //for animations


class HeroSectionScreen extends StatefulWidget {
  const HeroSectionScreen({Key? key}) : super(key: key);

  @override
  State<HeroSectionScreen> createState() => _HeroSectionScreenState();
}

class _HeroSectionScreenState extends State<HeroSectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Uint8List? _webImageBytes;
  String? _imageError;
  String? _imageUrl;

  bool _isEditing = false;
  bool _isButtonEnabled = true; // Track button state
  final Duration animationDuration = const Duration(
    milliseconds: 300,
  ); //Animation duration

  @override
  void initState() {
    super.initState();
    EasyLoading.instance.indicatorType = EasyLoadingIndicatorType.fadingCircle;
  }

  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
        // Web platform
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
        // Mobile platform
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

  void _populateForEdit(HeroSection heroSection) {
    
    setState(() {
      // Wrap in setState
      _isEditing = true;
      _idController.text = heroSection.id;
      _titleController.text = heroSection.title;
      _subtitleController.text = heroSection.subtitle;
      _descriptionController.text = heroSection.description;
      _imageUrl = heroSection.imageUrl;
    });
  }

  Future<void> _submitForm(HeroSectionProvider heroSectionProvider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_webImageBytes == null && _imageUrl == null) {
          final heroSectionProvider = Provider.of<HeroSectionProvider>(context);
    final theme = Theme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content:  Text('Please select an image.', style: TextStyle(color: theme.colorScheme.onError)),
          backgroundColor: theme.colorScheme.error,
        ),
      );
      return;
    }
    final theme = Theme.of(context);

    // Disable the button immediately
    setState(() {
      _isButtonEnabled = false;
    });

    EasyLoading.show(status: 'Saving...');

    try {
      if (_isEditing) {
        await heroSectionProvider.updateHeroSection(
          id: _idController.text,
          title: _titleController.text,
          webImageBytes: _webImageBytes,
          subtitle: _subtitleController.text,
          description: _descriptionController.text,
        );
      } else {
        await heroSectionProvider.addHeroSection(
          title: _titleController.text,
          webImageBytes: _webImageBytes,
          subtitle: _subtitleController.text,
          description: _descriptionController.text,
        );
      }

      _titleController.clear();
      _subtitleController.clear();
      _descriptionController.clear();
      setState(() {
        _webImageBytes = null;
        _imageUrl = null;
        _imageError = null;
        _isEditing = false;
        _idController.clear();
      });

      EasyLoading.showSuccess(
        'Hero Section ${_isEditing ? "Updated" : "Added"}!',
      );
    } catch (e) {
      EasyLoading.showError(
        'Failed to ${_isEditing ? "update" : "add"} hero section: $e',
      );
    } finally {
      // Re-enable the button after a delay. Adjust the delay as needed.
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isButtonEnabled = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final heroSectionProvider = Provider.of<HeroSectionProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Hero Section"),
        backgroundColor: Colors.transparent, //Modern Color
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ), //Elegant Typography
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), //High-Quality Icons
      ),
      backgroundColor: theme.colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                enabled: false,
                 style: TextStyle(color: theme.colorScheme.tertiary),
                controller: _idController,
                decoration: InputDecoration(
                  labelText: "ID (Readonly)",
                  labelStyle: TextStyle(color: theme.colorScheme.tertiary),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _titleController,
                 style: TextStyle(color: theme.colorScheme.tertiary),
                decoration: InputDecoration(
                  labelText: "Title",
                  labelStyle: TextStyle(color: theme.colorScheme.tertiary),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a title";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _subtitleController,
                 style: TextStyle(color: theme.colorScheme.tertiary),
                decoration: InputDecoration(
                  labelText: "Subtitle",
                  labelStyle: TextStyle(color: theme.colorScheme.tertiary),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a subtitle";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                 style: TextStyle(color: theme.colorScheme.tertiary),
                decoration: InputDecoration(
                  labelText: "Description",
                  labelStyle: TextStyle(color: theme.colorScheme.tertiary),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a description";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  foregroundColor: theme.colorScheme.onSecondaryContainer,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _pickImage,
                child: const Text("Pick Image"),
              ),
              const SizedBox(height: 10),
              if (_imageError != null)
                Text(_imageError!, style:  TextStyle(color: theme.colorScheme.error)),
              if (_webImageBytes != null)
                Image.memory(
                  _webImageBytes!,
                  height: 100,
                ).animate().fadeIn(duration: animationDuration),
              if (_imageUrl != null)
                Image.network(
                  _imageUrl!,
                  height: 100,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(Icons.error),
                ).animate().fadeIn(duration: animationDuration),
              const SizedBox(height: 20),
              AnimatedButton(
                onPressed:
                    _isButtonEnabled
                        ? () => _submitForm(heroSectionProvider)
                        : null,
                child: Text(
                  _isEditing ? "Update Hero Section" : "Add Hero Section",
                  style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 18),
                ),
              ).animate().scale(duration: animationDuration), //Apply animation

              const SizedBox(height: 30),
               Text(
                "Existing Hero Sections",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.tertiary),
              ),
              StreamBuilder<List<HeroSection>>(
                stream: heroSectionProvider.getHeroSections(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final heroSections = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: heroSections.length,
                      itemBuilder: (context, index) {
                        final heroSection = heroSections[index];
                        return Card(
                          color: theme.colorScheme.surface,
                          elevation: 4, //Add shadow
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ), //Rounded corners
                          child: ListTile(
                            leading: SizedBox(
                              width: 50,
                              height: 50,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  heroSection.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(Icons.error),
                                ),
                              ),
                            ),
                            title: Text(
                              heroSection.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.tertiary
                              ),
                            ), //Style title
                            subtitle: Text(heroSection.description, style: TextStyle(color: theme.colorScheme.onSurface)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon:  Icon(
                                    Icons.edit,
                                    color: theme.colorScheme.primaryContainer,
                                  ), //Color the icon
                                  onPressed: () {
                                    _populateForEdit(heroSection);
                                  },
                                ),
                                IconButton(
                                   icon:  Icon(
                                    Icons.delete,
                                    color: theme.colorScheme.errorContainer,
                                  ), //Color the icon
                                  onPressed: () {
                                    // Show confirmation dialog
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                           backgroundColor: theme.colorScheme.primary,
                                          surfaceTintColor: theme.colorScheme.background,
                                          title:  Text("Confirm Delete",  style: TextStyle(color: theme.colorScheme.tertiary)),
                                          content:  Text(
                                            "Are you sure you want to delete this hero section?",  style: TextStyle(color: theme.colorScheme.tertiary)
                                          ),
                                          actions: [
                                            TextButton(
                                              child: const Text("Cancel"),
                                              onPressed: () {
                                                Navigator.of(
                                                  context,
                                                ).pop(); // Dismiss the dialog
                                              },
                                            ),
                                            TextButton(
                                              child: const Text(
                                                "Delete",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                              onPressed: () {
                                                // Delete the item
                                                heroSectionProvider
                                                    .deleteHeroSection(
                                                      heroSection.id,
                                                    );
                                                Navigator.of(
                                                  context,
                                                ).pop(); // Dismiss the dialog
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}",  style: TextStyle(color: theme.colorScheme.error)));
                  } else {
                    return Center(child: CircularProgressIndicator(color: theme.colorScheme.primaryContainer));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _idController.dispose();
    EasyLoading.dismiss(); //Dismiss loading indicator on dispose
    super.dispose();
  }
}

// Animated Button Widget
class AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed; //Make onPressed nullable
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
    final theme = Theme.of(context);
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
          //Check if onPressed is not null
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
                  : theme.colorScheme.primaryContainer, //Grey out when disabled
          borderRadius: BorderRadius.circular(8),
          boxShadow:
              _isPressed || widget.onPressed == null
                  ? []
                  : [
                      BoxShadow(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Center(child: widget.child), //Center the child
      ),
    );
  }
}