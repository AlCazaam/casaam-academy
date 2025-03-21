import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uidesign/Themes/theme_provider.dart';
import 'package:uidesign/models/course.dart';
import 'package:uidesign/models/section.dart';
import 'package:uidesign/providers/course_provider.dart';
import 'package:uidesign/providers/section_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motion_toast/motion_toast.dart';


class SectionScreen extends StatefulWidget {
  final Section? section;

  const SectionScreen({Key? key, this.section}) : super(key: key);

  @override
  State<SectionScreen> createState() => _SectionScreenState();
}

class _SectionScreenState extends State<SectionScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _orderController = TextEditingController();

  String? _selectedCourseId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.section != null) {
      _titleController.text = widget.section!.title;
      _descriptionController.text = widget.section!.description;
      _orderController.text = widget.section!.order.toString();
      _selectedCourseId = widget.section!.courseId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final courseProvider = Provider.of<CourseProvider>(context);
    final sectionProvider = Provider.of<SectionProvider>(context);

    final labelStyle = GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: colorScheme.tertiary,
    );
    final buttonStyle = GoogleFonts.montserrat(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: colorScheme.onPrimary,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.section == null ? "Add Section" : "Edit Section",
          style: TextStyle(color: colorScheme.onPrimary),
        ).animate().fadeIn(duration: 500.ms),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: colorScheme.background,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: AnimationLimiter(
                  child: Column(
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 375),
                      childAnimationBuilder:
                          (widget) => SlideAnimation(
                            horizontalOffset: 50.0,
                            child: FadeInAnimation(child: widget),
                          ),
                      children: [
                        // --- Title ---
                        TextFormField(
                          controller: _titleController,
                           style: TextStyle(color: colorScheme.tertiary),
                          decoration: InputDecoration(
                            labelText: "Title",
                            labelStyle: labelStyle,
                            border: const OutlineInputBorder(),
                             enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter a title";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        // --- Description ---
                        TextFormField(
                          controller: _descriptionController,
                           style: TextStyle(color: colorScheme.tertiary),
                          decoration: InputDecoration(
                            labelText: "Description",
                            labelStyle: labelStyle,
                            border: const OutlineInputBorder(),
                              enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // --- Order ---
                        TextFormField(
                          controller: _orderController,
                           style: TextStyle(color: colorScheme.tertiary),
                          decoration: InputDecoration(
                            labelText: "Order",
                            labelStyle: labelStyle,
                            border: const OutlineInputBorder(),
                             enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter an order";
                            }
                            if (int.tryParse(value) == null) {
                              return "Please enter a valid order (number)";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        // --- Course Dropdown ---
                        StreamBuilder<List<Course>>(
                          stream: courseProvider.getCourses(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final courses = snapshot.data!;
                              return DropdownButtonFormField<String>(
                                dropdownColor: colorScheme.primary,
                                value: _selectedCourseId,
                                style: TextStyle(color: colorScheme.tertiary),
                                decoration: InputDecoration(
                                  labelText: "Course",
                                  labelStyle: labelStyle,
                                  border: const OutlineInputBorder(),
                                  enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                ),
                                items:
                                    courses.map((course) {
                                      return DropdownMenuItem<String>(
                                        value: course.id,
                                        child: Text(
                                          "${course.title} (ID: ${course.id})",
                                          style: TextStyle(color: colorScheme.tertiary),
                                        ),
                                      );
                                    }).toList(),
                                onChanged:
                                    _isSaving
                                        ? null
                                        : (value) {
                                          setState(() {
                                            _selectedCourseId = value;
                                          });
                                        },
                                validator: (value) {
                                  if (value == null) {
                                    return "Please select a course";
                                  }
                                  return null;
                                },
                              );
                            } else if (snapshot.hasError) {
                              return Text(
                                "Error loading courses: ${snapshot.error}",
                                style: TextStyle(color: colorScheme.error),
                              );
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 20),

                        // --- Add/Update Section Button ---
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.inverseSurface,
                            textStyle: buttonStyle,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: _isSaving ? null : _addOrUpdateSection,
                          child:
                              _isSaving
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                  : Text(
                                    widget.section == null
                                        ? "Add Section"
                                        : "Update Section",
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Display Added Sections - Improved Design
          Expanded(child: _buildSectionList(sectionProvider)),
        ],
      ),
    );
  }

  Future<void> _addOrUpdateSection() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      String title = _titleController.text.trim();
      String description = _descriptionController.text.trim();
      int order = int.parse(_orderController.text.trim());

      try {
        final sectionProvider = Provider.of<SectionProvider>(
          context,
          listen: false,
        );

        if (widget.section == null) {
          await sectionProvider.addSection(
            courseId: _selectedCourseId!,
            title: title,
            description: description,
            order: order,
          );

          MotionToast.success(
            title: const Text("Success"),
            description: const Text("Section added!"),
            animationType: AnimationType.slideInFromRight,
            position: MotionToastPosition.bottom,
          ).show(context);
        } else {
          Section updatedSection = Section(
            id: widget.section!.id,
            courseId: _selectedCourseId!,
            title: title,
            description: description,
            order: order,
            createdAt: widget.section!.createdAt,
            updatedAt: DateTime.now(),
          );
          await sectionProvider.updateSection(updatedSection);
          MotionToast.success(
            title: const Text("Success"),
            description: const Text("Section updated!"),
            animationType: AnimationType.slideInFromRight,
            position: MotionToastPosition.bottom,
          ).show(context);
        }

        // Stay on the screen and clear the form fields
        _titleController.clear();
        _descriptionController.clear();
        _orderController.clear();
        setState(() {
          _selectedCourseId = null; // Reset dropdown value
        });
      } catch (e) {
        MotionToast.error(
          title: const Text("Error"),
          description: Text("Error: $e"),
          animationType: AnimationType.slideInFromRight,
          position: MotionToastPosition.bottom,
        ).show(context);
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteSection(String sectionId) async {
    setState(() {
      _isSaving = true; // Prevent multiple deletes
    });
    try {
      final sectionProvider = Provider.of<SectionProvider>(
        context,
        listen: false,
      );
      await sectionProvider.deleteSection(sectionId);

      MotionToast.success(
        title: const Text("Success"),
        description: const Text("Section deleted!"),
        animationType: AnimationType.slideInFromRight,
        position: MotionToastPosition.bottom,
      ).show(context);
    } catch (e) {
      MotionToast.error(
        title: const Text("Error"),
        description: Text("Error deleting section: $e"),
        animationType: AnimationType.slideInFromRight,
        position: MotionToastPosition.bottom,
      ).show(context);
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Widget _buildSectionList(SectionProvider sectionProvider) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<List<Section>>(
      stream: sectionProvider.getSections(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Section> sections = snapshot.data!;
          sections.sort((a, b) => a.order.compareTo(b.order));

          // Split sections into rows of 3
          List<List<Section>> rows = [];
          for (int i = 0; i < sections.length; i += 3) {
            rows.add(
              sections.sublist(
                i,
                i + 3 > sections.length ? sections.length : i + 3,
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
                        row.map((section) {
                          return Expanded(
                            child: AnimationConfiguration.staggeredList(
                              position:
                                  rowIndex * 3 +
                                  row.indexOf(section),
                              duration: const Duration(milliseconds: 500),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: _buildSectionCard(
                                    section,
                                    sectionProvider,
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
          return Center(
            child: Text(
              "Error loading sections: ${snapshot.error}",
              style: TextStyle(color: colorScheme.error),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildSectionCard(Section section, SectionProvider sectionProvider) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.secondary,
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order: ${section.order}",
              style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.tertiary),
            ),
            Text(
              "Title: ${section.title}",
              style: TextStyle(fontSize: 16, color: colorScheme.tertiary),
            ),
            Text("Description: ${section.description}", style: TextStyle(color: colorScheme.tertiary)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon:  Icon(Icons.edit, color: colorScheme.inverseSurface),
                  onPressed:
                      _isSaving
                          ? null
                          : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        SectionScreen(section: section),
                              ),
                            );
                          },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: colorScheme.error),
                  onPressed:
                      _isSaving
                          ? null
                          : () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: colorScheme.primary,
                                  title:  Text("Confirm Delete",style: TextStyle(color: colorScheme.tertiary)),
                                  content: Text(
                                    "Are you sure you want to delete this section?",
                                    style: TextStyle(color: colorScheme.tertiary),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text(
                                        "Delete",
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _deleteSection(section.id!);
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
          ],
        ),
      ),
    );
  }
}