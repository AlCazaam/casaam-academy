import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uidesign/models/course.dart';
import 'package:uidesign/models/lesson.dart';
import 'package:uidesign/models/section.dart';
import 'package:uidesign/providers/course_provider.dart';
import 'package:uidesign/providers/lesson_provider.dart';
import 'package:uidesign/providers/section_provider.dart';

class LessonScreen extends StatefulWidget {
  final Lesson? lesson;

  const LessonScreen({Key? key, this.lesson}) : super(key: key);

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _videoUrlController = TextEditingController();
  final TextEditingController _textContentController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  String? _selectedCourseId;
  String? _selectedSectionId;

  @override
  void initState() {
    super.initState();
    if (widget.lesson != null) {
      _selectedCourseId = widget.lesson!.courseId;
      _selectedSectionId = widget.lesson!.sectionId;
      _titleController.text = widget.lesson!.title;
      _videoUrlController.text = widget.lesson!.videoUrl;
      _textContentController.text = widget.lesson!.textContent;
      _durationController.text = widget.lesson!.duration.toString();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _videoUrlController.dispose();
    _textContentController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Load Course
    final courseProvider = Provider.of<CourseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson == null ? "Add Lesson" : "Edit Lesson"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              //Load course list for dropdown
              StreamBuilder<List<Course>>(
                stream: courseProvider.getCourses(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final courses = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      value: _selectedCourseId,
                      decoration: const InputDecoration(labelText: "Course"),
                      items:
                          courses.map((course) {
                            return DropdownMenuItem<String>(
                              value: course.id,
                              child: Text(course.title),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCourseId = value;
                          _selectedSectionId = null; // Reset section selection
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
                    return Text("Error loading courses: ${snapshot.error}");
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),

              // Load only the course for section, must select course before
              if (_selectedCourseId != null)
                Consumer<SectionProvider>(
                  builder: (context, sectionProvider, child) {
                    return StreamBuilder<List<Section>>(
                      stream: FirebaseFirestore.instance
                          .collection("sections")
                          .where("courseId", isEqualTo: _selectedCourseId)
                          .snapshots()
                          .map(
                            (snapshot) =>
                                snapshot.docs
                                    .map(
                                      (doc) => Section.fromJson(
                                        doc.data() as Map<String, dynamic>,
                                      ),
                                    )
                                    .toList(),
                          ),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final sections = snapshot.data!;
                          return DropdownButtonFormField<String>(
                            value: _selectedSectionId,
                            decoration: const InputDecoration(
                              labelText: "Section",
                            ),
                            items:
                                sections.map((section) {
                                  return DropdownMenuItem<String>(
                                    value: section.id,
                                    child: Text(section.title),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSectionId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return "Please select a section";
                              }
                              return null;
                            },
                          );
                        } else if (snapshot.hasError) {
                          return Text(
                            "Error loading sections: ${snapshot.error}",
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    );
                  },
                ),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a title";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _videoUrlController,
                decoration: const InputDecoration(labelText: "Video URL"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a video URL";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _textContentController,
                decoration: const InputDecoration(labelText: "Text Content"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter text content";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: "Duration (seconds)",
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a duration";
                  }
                  if (int.tryParse(value) == null) {
                    return "Please enter a valid duration (number)";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    String title = _titleController.text.trim();
                    String videoUrl = _videoUrlController.text.trim();
                    String textContent = _textContentController.text.trim();
                    int duration = int.parse(_durationController.text.trim());

                    try {
                      final lessonProvider = Provider.of<LessonProvider>(
                        context,
                        listen: false,
                      );

                      if (widget.lesson == null) {
                        // Add Lesson
                        await lessonProvider.addLesson(
                          sectionId: _selectedSectionId!,
                          courseId: _selectedCourseId!,
                          title: title,
                          videoUrl: videoUrl,
                          textContent: textContent,
                          duration: duration,
                        );
                      } else {
                        // Edit Lesson
                        Lesson updatedLesson = Lesson(
                          id: widget.lesson!.id,
                          sectionId: _selectedSectionId!,
                          courseId: _selectedCourseId!,
                          title: title,
                          videoUrl: videoUrl,
                          textContent: textContent,
                          duration: duration,
                          createdAt: widget.lesson!.createdAt,
                          updatedAt: DateTime.now(),
                        );
                        await lessonProvider.updateLesson(updatedLesson);
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            widget.lesson == null
                                ? "Lesson added!"
                                : "Lesson updated!",
                          ),
                        ),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
                  }
                },
                child: Text(
                  widget.lesson == null ? "Add Lesson" : "Update Lesson",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
