import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uidesign/Themes/theme_provider.dart';
import 'package:uidesign/models/category.dart';
import 'package:uidesign/models/course.dart';
import 'package:uidesign/providers/category_provider.dart';
import 'package:uidesign/providers/course_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Added flutter_animate

class CourseScreen extends StatefulWidget {
  final Course? course;
  const CourseScreen({Key? key, this.course}) : super(key: key);

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _introVideoController = TextEditingController();
  final TextEditingController _instructorController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();

  XFile? _pickedImage;
  Uint8List? _webImageBytes;
  String? _selectedCategoryId;
  bool _isPublished = false;
  bool _isLoading = false;
  bool _buttonPressed = false;

  @override
  void initState() {
    super.initState();
    if (widget.course != null) {
      _titleController.text = widget.course!.title;
      _descriptionController.text = widget.course!.description;
      _introVideoController.text = widget.course!.introVideo;
      _instructorController.text = widget.course!.instructor;
      _priceController.text = widget.course!.price.toString();
      _ratingController.text = widget.course!.rating.toString();
      _isPublished = widget.course!.isPublished;
      _selectedCategoryId = widget.course!.categoryId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _introVideoController.dispose();
    _instructorController.dispose();
    _priceController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _pickedImage = image;
      });

      if (kIsWeb) {
        try {
          _webImageBytes = await image.readAsBytes();
        } catch (e) {
          print('Error reading image bytes: $e');
          _webImageBytes = null;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error reading image. Please try again.'),
            ),
          );
        }
      } else {
        _webImageBytes = null;
      }
    } else {
      setState(() {
        _pickedImage = null;
        _webImageBytes = null;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_buttonPressed) return;

    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      _buttonPressed = true;
      setState(() {
        _isLoading = true;
      });

      String title = _titleController.text.trim();
      String description = _descriptionController.text.trim();
      String introVideo = _introVideoController.text.trim();
      String instructor = _instructorController.text.trim();
      double price = double.parse(_priceController.text.trim());
      double rating = double.parse(_ratingController.text.trim());

      try {
        final courseProvider = Provider.of<CourseProvider>(
          context,
          listen: false,
        );

        if (widget.course == null) {
          await courseProvider.addCourse(
            title: title,
            description: description,
            introVideo: introVideo,
            categoryId: _selectedCategoryId!,
            instructor: instructor,
            price: price,
            rating: rating,
            imageFile: _pickedImage,
            webImageBytes: _webImageBytes,
            isPublished: _isPublished,
          );
        } else {
          Course updatedCourse = Course(
            id: widget.course!.id,
            title: title,
            description: description,
            introVideo: introVideo,
            categoryId: _selectedCategoryId!,
            instructor: instructor,
            price: price,
            rating: rating,
            imageUrl: widget.course!.imageUrl,
            createdAt: widget.course!.createdAt,
            updatedAt: DateTime.now(),
            isPublished: _isPublished,
          );

          await courseProvider.updateCourse(
            course: updatedCourse,
            imageFile: _pickedImage,
            webImageBytes: _webImageBytes,
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.course == null
                  ? "Course added successfully!"
                  : "Course updated successfully!",
            ),
          ),
        );

        _titleController.clear();
        _descriptionController.clear();
        _introVideoController.clear();
        _instructorController.clear();
        _priceController.clear();
        _ratingController.clear();
        setState(() {
          _pickedImage = null;
          _webImageBytes = null;
          _selectedCategoryId = null;
          _isPublished = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      } finally {
        setState(() {
          _isLoading = false;
          _buttonPressed = false;
        });
      }
    } else {
      _buttonPressed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.course == null ? "Add Course" : "Edit Course",
          style: TextStyle(color: colorScheme.tertiary),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: colorScheme.tertiary),
      ),
      backgroundColor: colorScheme.background,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      style: TextStyle(color: colorScheme.tertiary),
                      decoration: InputDecoration(
                        labelText: "Title",
                        labelStyle: TextStyle(color: colorScheme.tertiary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.tertiary),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.tertiary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.tertiary),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a title";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      style: TextStyle(color: colorScheme.tertiary),
                      decoration: InputDecoration(
                        labelText: "Description",
                        labelStyle: TextStyle(color: colorScheme.tertiary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.tertiary),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.tertiary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.tertiary),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a description";
                        }
                        return null;
                      },
                      maxLines: 3,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _introVideoController,
                      style: TextStyle(color: colorScheme.tertiary),
                      decoration: InputDecoration(
                        labelText: "Intro Video URL",
                        labelStyle: TextStyle(color: colorScheme.tertiary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.tertiary),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.tertiary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.tertiary),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter intro video URL";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    StreamBuilder<List<Category>>(
                      stream: categoryProvider.getCategories(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final categories = snapshot.data!;
                          return DropdownButtonFormField<String>(
                            value: _selectedCategoryId,
                            dropdownColor: colorScheme.primary,
                            style: TextStyle(color: colorScheme.tertiary),
                            decoration: InputDecoration(
                              labelText: "Category",
                              labelStyle: TextStyle(
                                color: colorScheme.tertiary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: colorScheme.tertiary,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: colorScheme.tertiary,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: colorScheme.tertiary,
                                ),
                              ),
                            ),
                            items:
                                categories.map((category) {
                                  return DropdownMenuItem<String>(
                                    value: category.id,
                                    child: Text(
                                      category.name,
                                      style: TextStyle(
                                        color: colorScheme.tertiary,
                                      ),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategoryId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return "Please select a category";
                              }
                              return null;
                            },
                          );
                        } else if (snapshot.hasError) {
                          return Text(
                            "Error loading categories: ${snapshot.error}",
                            style: TextStyle(color: colorScheme.error),
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _instructorController,
                      style: TextStyle(color: colorScheme.tertiary),
                      decoration: InputDecoration(
                        labelText: "Instructor",
                        labelStyle: TextStyle(color: colorScheme.tertiary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.tertiary),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.tertiary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.tertiary),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter instructor name";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _priceController,
                      style: TextStyle(color: colorScheme.tertiary),
                      decoration: InputDecoration(
                        labelText: "Price",
                        labelStyle: TextStyle(color: colorScheme.tertiary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.tertiary),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.tertiary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.tertiary),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter the price";
                        }
                        if (double.tryParse(value) == null) {
                          return "Please enter valid price";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _ratingController,
                      style: TextStyle(color: colorScheme.tertiary),
                      decoration: InputDecoration(
                        labelText: "Rating",
                        labelStyle: TextStyle(color: colorScheme.tertiary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.tertiary),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.tertiary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.tertiary),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter the rating";
                        }
                        if (double.tryParse(value) == null) {
                          return "Please enter valid rating";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: colorScheme.inverseSurface,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _pickImage,
                      child: Text(
                        "Pick Image",
                        style: TextStyle(color: colorScheme.background),
                      ),
                    ),
                    SizedBox(height: 12),
                    _pickedImage != null
                        ? kIsWeb && _webImageBytes != null
                            ? Image.memory(_webImageBytes!, height: 100)
                            : !kIsWeb && _pickedImage != null
                            ? Image.file(File(_pickedImage!.path), height: 100)
                            : Container()
                        : Container(),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          "Is Published",
                          style: TextStyle(color: colorScheme.tertiary),
                        ),
                        Checkbox(
                          value: _isPublished,
                          activeColor: colorScheme.inverseSurface,
                          onChanged: (value) {
                            setState(() {
                              _isPublished = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: colorScheme.inverseSurface,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _isLoading ? null : _submitForm,
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                              : Text(
                                widget.course == null
                                    ? "Add Course"
                                    : "Update Course",
                                style: TextStyle(color: colorScheme.background),
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Course List"),
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.tertiary),
      ),
      backgroundColor: colorScheme.background,
      body: StreamBuilder<List<Course>>(
        stream:
            Provider.of<CourseProvider>(context, listen: false).getCourses(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final courses = snapshot.data!;
            if (courses.isEmpty) {
              return Center(
                child: Text(
                  "No courses available. Add one!",
                  style: TextStyle(color: colorScheme.tertiary),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return CourseListItem(course: course);
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: TextStyle(color: colorScheme.error),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.inverseSurface,
        foregroundColor: colorScheme.onPrimary,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: colorScheme.primary,
            builder: (BuildContext context) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: const CourseScreen(course: null),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CourseListItem extends StatelessWidget {
  final Course course;

  const CourseListItem({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 3,
      color: colorScheme.secondary,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: colorScheme.tertiary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              course.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: colorScheme.tertiary),
            ),
            const SizedBox(height: 8),
            Text(
              "Price: \$${course.price.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 16, color: colorScheme.tertiary),
            ),
            Text(
              "Published: ${course.isPublished ? 'Yes' : 'No'}",
              style: TextStyle(fontSize: 16, color: colorScheme.tertiary),
            ),
            const SizedBox(height: 8),
            if (course.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  course.imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text("Failed to load image"));
                  },
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.tertiary,
                  ),
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit"),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: CourseScreen(course: course),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
