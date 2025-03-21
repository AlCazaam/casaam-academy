import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uidesign/Themes/theme_provider.dart';
import 'package:uidesign/models/course.dart';
import 'package:uidesign/models/user.dart';
import 'package:uidesign/providers/course_provider.dart';
import 'package:uidesign/providers/purchased_course_provider.dart';
import 'package:uidesign/providers/user_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart'; // Import EasyLoading
import 'package:flutter_animate/flutter_animate.dart'; // Import flutter_animate
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart'; // Grid view package
import 'package:google_fonts/google_fonts.dart'; // Modern fonts

class AccessCourseScreen extends StatefulWidget {
  const AccessCourseScreen({Key? key}) : super(key: key);

  @override
  State<AccessCourseScreen> createState() => _AccessCourseScreenState();
}

class _AccessCourseScreenState extends State<AccessCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _totalPriceController = TextEditingController();
  String? _selectedUserId;
  List<String> _selectedCourseIds = [];
  bool _pending = true;
  bool _show = true;
  String _searchQuery = '';
  String _selectedUserNumber = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _totalPriceController.dispose();
    super.dispose();
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData theme = themeProvider.themeData;

    final userProvider = Provider.of<UserProvider>(context);
    final courseProvider = Provider.of<CourseProvider>(context);


  

    TextStyle labelStyle() => GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: theme.colorScheme.tertiary);
    TextStyle bodyStyle() => GoogleFonts.openSans(
        fontSize: 14, color: theme.colorScheme.onSurface);
    TextStyle buttonStyle() => GoogleFonts.montserrat(
        fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.onPrimary);

    Widget userDropdown(List<User> users) {
      return DropdownButtonFormField<String>(
        dropdownColor: theme.colorScheme.primary,
        decoration: InputDecoration(
          labelText: "User Number",
          labelStyle: labelStyle(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.colorScheme.secondary),
          ),
        ),
        value: _selectedUserId,
        onChanged:
            _isLoading
                ? null
                : (String? newValue) {
                  setState(() {
                    _selectedUserId = newValue;
                    final selectedUser = users.firstWhere(
                      (user) => user.id == newValue,
                    );
                    _selectedUserNumber = selectedUser.number;
                  });
                },
        items:
            users.map((user) {
              return DropdownMenuItem<String>(
                value: user.id,
                child: Text(user.number, style: bodyStyle()),
              );
            }).toList(),
        validator: (value) {
          if (value == null) {
            return "Please select a user";
          }
          return null;
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Access Course",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: theme.colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                style: bodyStyle(),
                decoration: InputDecoration(
                  labelText: "Search User Number",
                  labelStyle: labelStyle(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 500)),
              const SizedBox(height: 10),
              StreamBuilder<List<User>>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .snapshots()
                    .map(
                      (snapshot) =>
                          snapshot.docs
                              .map(
                                (doc) => User.fromJson(
                                  doc.data() as Map<String, dynamic>,
                                ),
                              )
                              .toList(),
                    ),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<User> users = snapshot.data!;
                    if (_searchQuery.isNotEmpty) {
                      users =
                          users
                              .where(
                                (user) => user.number.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ),
                              )
                              .toList();
                    }
                    return userDropdown(users);
                  } else if (snapshot.hasError) {
                    return Text(
                      "Error loading users: ${snapshot.error}",
                      style: TextStyle(color: theme.colorScheme.error),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primaryContainer,
                      ),
                    );
                  }
                },
              )
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 500)),
              const SizedBox(height: 20),
              StreamBuilder<List<Course>>(
                stream: courseProvider.getCourses(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final courses = snapshot.data!;
                    return Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: MultiSelectCourseGrid(
                          courses: courses,
                          selectedCourseIds: _selectedCourseIds,
                          onCourseSelected: (courseId, isSelected) {
                            setState(() {
                              if (isSelected) {
                                _selectedCourseIds.add(courseId);
                              } else {
                                _selectedCourseIds.remove(courseId);
                              }
                            });
                          },
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                      "Error loading courses: ${snapshot.error}",
                      style: TextStyle(color: theme.colorScheme.error),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primaryContainer,
                      ),
                    );
                  }
                },
              ),
              TextFormField(
                controller: _totalPriceController,
                style: bodyStyle(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Total Price",
                  labelStyle: labelStyle(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.colorScheme.secondary),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the total price";
                  }
                  if (double.tryParse(value) == null) {
                    return "Please enter a valid number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text("Pending", style: bodyStyle()),
                  Checkbox(
                    value: _pending,
                    activeColor: theme.colorScheme.primaryContainer,
                    onChanged:
                        _isLoading
                            ? null
                            : (value) {
                              setState(() {
                                _pending = value!;
                              });
                            },
                  ),
                ],
              ),
              Row(
                children: [
                  Text("Show", style: bodyStyle()),
                  Checkbox(
                    value: _show,
                    activeColor: theme.colorScheme.primaryContainer,
                    onChanged:
                        _isLoading
                            ? null
                            : (value) {
                              setState(() {
                                _show = value!;
                              });
                            },
                  ),
                ],
              ),
              TextFormField(
                controller: _messageController,
                style: bodyStyle(),
                decoration: InputDecoration(
                  labelText: "Message",
                  labelStyle: labelStyle(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.colorScheme.secondary),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      textStyle: buttonStyle(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                    ),
                    onPressed: _isLoading ? null : _grantAccess,
                    child: const Text("Grant Access"),
                  )
                  .animate(
                    target: _isLoading ? 1 : 0,
                    onPlay: (controller) {
                      if (_isLoading) {
                        controller.repeat(reverse: true);
                      }
                    },
                  )
                  .shimmer(duration: const Duration(seconds: 1)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _grantAccess() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      EasyLoading.show(status: 'Granting Access...');

      try {
        final purchasedCourseProvider = Provider.of<PurchasedCourseProvider>(
          context,
          listen: false,
        );
        if (_selectedUserId != null && _selectedCourseIds.isNotEmpty) {
          double totalPrice =
              double.tryParse(_totalPriceController.text) ?? 0.0;

          await purchasedCourseProvider.addPurchasedCourse(
            number: _selectedUserNumber,
            userId: _selectedUserId!,
            courseIds: _selectedCourseIds,
            message: _messageController.text,
            totalPrice: totalPrice,
          );
          EasyLoading.showSuccess('Access granted!');
        } else {
          EasyLoading.showError(
            'Please select a user and at least one course.',
          );
        }
      } catch (e) {
        EasyLoading.showError('Error: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class MultiSelectCourseGrid extends StatefulWidget {
  final List<Course> courses;
  final List<String> selectedCourseIds;
  final Function(String courseId, bool isSelected) onCourseSelected;

  const MultiSelectCourseGrid({
    Key? key,
    required this.courses,
    required this.selectedCourseIds,
    required this.onCourseSelected,
  }) : super(key: key);

  @override
  State<MultiSelectCourseGrid> createState() => _MultiSelectCourseGridState();
}

class _MultiSelectCourseGridState extends State<MultiSelectCourseGrid> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData theme = themeProvider.themeData;

    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      itemCount: widget.courses.length,
      itemBuilder: (context, index) {
        final course = widget.courses[index];
        final isSelected = widget.selectedCourseIds.contains(course.id);

        return CourseCard(
          theme: theme,
          course: course,
          isSelected: isSelected,
          onTap: () {
            widget.onCourseSelected(course.id, !isSelected);
          },
        );
      },
    );
  }
}

class CourseCard extends StatelessWidget {
  final Course course;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const CourseCard({
    Key? key,
    required this.course,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              course.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.tertiary),
            ),
          ],
        ),
      ),
    );
  }
}