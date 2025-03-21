import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uidesign/models/course.dart';
import 'package:uidesign/models/lesson.dart';
import 'package:uidesign/models/section.dart';
import 'package:uidesign/providers/course_provider.dart';
import 'package:uidesign/providers/lesson_provider.dart';
import 'package:uidesign/providers/section_provider.dart';

import 'package:uuid/uuid.dart';

class DisplayCourseWithSections extends StatelessWidget {
  final String courseId;

  const DisplayCourseWithSections({Key? key, required this.courseId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course and Sections'),
        backgroundColor: colorScheme.primary,
      ),
      backgroundColor: colorScheme.background,
      body: Consumer2<CourseProvider, SectionProvider>(
        builder: (context, courseProvider, sectionProvider, child) {
          return StreamBuilder<Course?>(
            stream: courseProvider.getCourseById(courseId),
            builder: (context, courseSnapshot) {
              if (courseSnapshot.hasError) {
                return Center(child: Text('Error: ${courseSnapshot.error}', style: TextStyle(color: colorScheme.error)));
              }

              if (!courseSnapshot.hasData || courseSnapshot.data == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final course = courseSnapshot.data!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(course.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.tertiary)),
                  ),
                  Expanded(
                    child: StreamBuilder<List<Section>>(
                      stream: sectionProvider.getSections(),
                      builder: (context, sectionSnapshot) {
                        if (sectionSnapshot.hasError) {
                          return Center(child: Text('Error: ${sectionSnapshot.error}', style: TextStyle(color: colorScheme.error)));
                        }

                        if (!sectionSnapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        List<Section> sections = sectionSnapshot.data!
                            .where((section) => section.courseId == courseId)
                            .toList();

                        sections.sort((a, b) => a.order.compareTo(b.order));

                        if (sections.isEmpty) {
                          return Center(child: Text('No sections available for this course.', style: TextStyle(color: colorScheme.tertiary)));
                        }

                        return ListView.builder(
                          itemCount: sections.length,
                          itemBuilder: (context, index) {
                            final section = sections[index];
                            return SectionCard(section: section, courseId: courseId);
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final Section section;
  final String courseId;

  const SectionCard({Key? key, required this.section, required this.courseId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.secondary,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order: ${section.order}', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.tertiary)),
                    Text('Title: ${section.title}', style: TextStyle(fontSize: 16, color: colorScheme.tertiary)),
                    Text('Description: ${section.description}', style: TextStyle(color: colorScheme.tertiary)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: colorScheme.inverseSurface),
                      onPressed: () {
                        _showEditSectionDialog(context, section);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: colorScheme.error),
                      onPressed: () {
                        _showDeleteSectionDialog(context, section);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: colorScheme.inverseSurface),
                      onPressed: () {
                        _showAddLessonDialog(context, courseId, section.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
            LessonsList(courseId: courseId, sectionId: section.id),
          ],
        ),
      ),
    );
  }

  void _showAddLessonDialog(BuildContext context, String courseId, String sectionId) {
    TextEditingController titleController = TextEditingController();
    TextEditingController videoUrlController = TextEditingController();
    TextEditingController textContentController = TextEditingController();
    TextEditingController durationController = TextEditingController();
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
           backgroundColor: colorScheme.primary,
          title:  Text('Add Lesson', style: TextStyle(color: colorScheme.tertiary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                   style: TextStyle(color: colorScheme.tertiary),
                  controller: titleController,
                  decoration:  InputDecoration(labelText: 'Title',labelStyle: TextStyle(color: colorScheme.tertiary)),
                ),
                TextFormField(
                   style: TextStyle(color: colorScheme.tertiary),
                  controller: videoUrlController,
                  decoration:  InputDecoration(labelText: 'Video URL',labelStyle: TextStyle(color: colorScheme.tertiary)),
                ),
                TextFormField(
                   style: TextStyle(color: colorScheme.tertiary),
                  controller: textContentController,
                  decoration:  InputDecoration(labelText: 'Text Content',labelStyle: TextStyle(color: colorScheme.tertiary)),
                ),
                TextFormField(
                   style: TextStyle(color: colorScheme.tertiary),
                  controller: durationController,
                  decoration:  InputDecoration(labelText: 'Duration (seconds)',labelStyle: TextStyle(color: colorScheme.tertiary)),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                String title = titleController.text.trim();
                String videoUrl = videoUrlController.text.trim();
                String textContent = textContentController.text.trim();
                String durationString = durationController.text.trim();

                if (title.isNotEmpty && videoUrl.isNotEmpty && textContent.isNotEmpty && durationString.isNotEmpty) {
                  int duration = int.tryParse(durationString) ?? 0;
                  if (duration > 0) {
                    final lessonProvider = Provider.of<LessonProvider>(context, listen: false);
                    try {
                      await lessonProvider.addLesson(
                        sectionId: sectionId,
                        courseId: courseId,
                        title: title,
                        videoUrl: videoUrl,
                        textContent: textContent,
                        duration: duration,
                      );

                      Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding lesson: $e', style: TextStyle(color: colorScheme.error))));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Invalid duration',)));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Please fill in all fields',)));
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditSectionDialog(BuildContext context, Section section) {
    TextEditingController titleController = TextEditingController(text: section.title);
    TextEditingController descriptionController = TextEditingController(text: section.description);
    TextEditingController orderController = TextEditingController(text: section.order.toString());
     final ColorScheme colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.primary,
          title:  Text('Edit Section', style: TextStyle(color: colorScheme.tertiary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                   style: TextStyle(color: colorScheme.tertiary),
                  controller: titleController,
                  decoration:  InputDecoration(labelText: 'Title',labelStyle: TextStyle(color: colorScheme.tertiary)),
                ),
                TextFormField(
                  controller: descriptionController,
                   style: TextStyle(color: colorScheme.tertiary),
                  decoration:  InputDecoration(labelText: 'Description',labelStyle: TextStyle(color: colorScheme.tertiary)),
                ),
                TextFormField(
                   style: TextStyle(color: colorScheme.tertiary),
                  controller: orderController,
                  decoration:  InputDecoration(labelText: 'Order',labelStyle: TextStyle(color: colorScheme.tertiary)),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
               child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                String title = titleController.text.trim();
                String description = descriptionController.text.trim();
                String orderString = orderController.text.trim();

                if (title.isNotEmpty && description.isNotEmpty && orderString.isNotEmpty) {
                  int order = int.tryParse(orderString) ?? 0;
                  if (order > 0) {
                    final sectionProvider = Provider.of<SectionProvider>(context, listen: false);
                    Section updatedSection = Section(
                      id: section.id,
                      courseId: section.courseId,
                      title: title,
                      description: description,
                      order: order,
                      createdAt: section.createdAt,
                      updatedAt: DateTime.now(),
                    );
                    try {
                      await sectionProvider.updateSection(updatedSection);
                      Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating section: $e', style: TextStyle(color: colorScheme.error))));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid order',)));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields',)));
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteSectionDialog(BuildContext context, Section section) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
           backgroundColor: colorScheme.primary,
          title:  Text('Delete Section',style: TextStyle(color: colorScheme.tertiary)),
          content:  Text('Are you sure you want to delete this section and all its lessons?', style: TextStyle(color: colorScheme.tertiary)),
          actions: [
            TextButton(
               child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                final sectionProvider = Provider.of<SectionProvider>(context, listen: false);
                final lessonProvider = Provider.of<LessonProvider>(context, listen: false);

                try {
                  List<Lesson> lessons = await lessonProvider.getLessonsForSection(section.id).first;

                  for (var lesson in lessons) {
                    await lessonProvider.deleteLesson(lesson.id);
                  }

                  await sectionProvider.deleteSection(section.id);

                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting section or lessons: $e',style: TextStyle(color: colorScheme.error))));
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class LessonsList extends StatelessWidget {
  final String courseId;
  final String sectionId;

  const LessonsList({Key? key, required this.courseId, required this.sectionId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lessonProvider = Provider.of<LessonProvider>(context);

    return StreamBuilder<List<Lesson>>(
      stream: lessonProvider.getLessonsForSection(sectionId),
      builder: (context, snapshot) {
        final ColorScheme colorScheme = Theme.of(context).colorScheme;
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: colorScheme.error)));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Lesson> lessons = snapshot.data!;

        if (lessons.isEmpty) {
          return Center(child: Text('No lessons available for this section.', style: TextStyle(color: colorScheme.tertiary)));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final lesson = lessons[index];
            return LessonCard(lesson: lesson, courseId: courseId);
          },
        );
      },
    );
  }
}

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final String courseId;

  const LessonCard({Key? key, required this.lesson, required this.courseId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.primary,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lesson: ${lesson.title}', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.tertiary)),
                Text('Video URL: ${lesson.videoUrl}', style: TextStyle(color: colorScheme.tertiary)),
                Text('Duration: ${lesson.duration} seconds', style: TextStyle(color: colorScheme.tertiary)),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: colorScheme.inverseSurface),
                  onPressed: () {
                    _showEditLessonDialog(context, lesson);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: colorScheme.error),
                  onPressed: () {
                    _showDeleteLessonDialog(context, lesson);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditLessonDialog(BuildContext context, Lesson lesson) {
    TextEditingController titleController = TextEditingController(text: lesson.title);
    TextEditingController videoUrlController = TextEditingController(text: lesson.videoUrl);
    TextEditingController textContentController = TextEditingController(text: lesson.textContent);
    TextEditingController durationController = TextEditingController(text: lesson.duration.toString());
     final ColorScheme colorScheme = Theme.of(context).colorScheme;

    String? selectedCourseId = lesson.courseId;
    String? selectedSectionId = lesson.sectionId;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: colorScheme.primary,
            title:  Text('Edit Lesson', style: TextStyle(color: colorScheme.tertiary)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StreamBuilder<List<Course>>(
                    stream: Provider.of<CourseProvider>(context, listen: false).getCourses(),
                    builder: (context, courseSnapshot) {
                      if (courseSnapshot.hasData) {
                        final courses = courseSnapshot.data!;
                        return DropdownButtonFormField<String>(
                          value: selectedCourseId,
                          decoration:  InputDecoration(labelText: 'Course',labelStyle: TextStyle(color: colorScheme.tertiary)),
                           dropdownColor: colorScheme.primary,
                           style: TextStyle(color: colorScheme.tertiary),
                          items: courses.map((course) {
                            return DropdownMenuItem<String>(
                              value: course.id,
                              child: Text(course.title, style: TextStyle(color: colorScheme.tertiary)),
                            );
                          }).toList(),
                          onChanged: (value) async {
                            setState(() {
                              selectedCourseId = value;
                              selectedSectionId = null;
                            });
                          },
                        );
                      } else if (courseSnapshot.hasError) {
                        return Text('Error loading courses: ${courseSnapshot.error}', style: TextStyle(color: colorScheme.error));
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                  if (selectedCourseId != null)
                    StreamBuilder<List<Section>>(
                      stream: Provider.of<SectionProvider>(context, listen: false)
                          .getSectionsForCourse(selectedCourseId!),
                      builder: (context, sectionSnapshot) {
                        if (sectionSnapshot.hasData) {
                          final sections = sectionSnapshot.data!;
                          return DropdownButtonFormField<String>(
                            value: selectedSectionId,
                            decoration:  InputDecoration(labelText: 'Section',labelStyle: TextStyle(color: colorScheme.tertiary)),
                             dropdownColor: colorScheme.primary,
                             style: TextStyle(color: colorScheme.tertiary),
                            items: sections.map((section) {
                              return DropdownMenuItem<String>(
                                value: section.id,
                                child: Text(section.title, style: TextStyle(color: colorScheme.tertiary)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedSectionId = value;
                              });
                            },
                          );
                        } else if (sectionSnapshot.hasError) {
                          return Text('Error loading sections: ${sectionSnapshot.error}',style: TextStyle(color: colorScheme.error));
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                  TextFormField(
                     style: TextStyle(color: colorScheme.tertiary),
                    controller: titleController,
                    decoration:  InputDecoration(labelText: 'Title',labelStyle: TextStyle(color: colorScheme.tertiary)),
                  ),
                  TextFormField(
                     style: TextStyle(color: colorScheme.tertiary),
                    controller: videoUrlController,
                    decoration:  InputDecoration(labelText: 'Video URL',labelStyle: TextStyle(color: colorScheme.tertiary)),
                  ),
                  TextFormField(
                     style: TextStyle(color: colorScheme.tertiary),
                    controller: textContentController,
                    decoration:  InputDecoration(labelText: 'Text Content',labelStyle: TextStyle(color: colorScheme.tertiary)),
                  ),
                  TextFormField(
                    controller: durationController,
                     style: TextStyle(color: colorScheme.tertiary),
                    decoration:  InputDecoration(labelText: 'Duration (seconds)',labelStyle: TextStyle(color: colorScheme.tertiary)),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                 child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Save'),
                onPressed: () async {
                  String title = titleController.text.trim();
                  String videoUrl = videoUrlController.text.trim();
                  String textContent = textContentController.text.trim();
                  String durationString = durationController.text.trim();

                  if (title.isNotEmpty && videoUrl.isNotEmpty && textContent.isNotEmpty && durationString.isNotEmpty && selectedCourseId != null && selectedSectionId != null) {
                    int duration = int.tryParse(durationString) ?? 0;
                    if (duration > 0) {
                      final lessonProvider = Provider.of<LessonProvider>(context, listen: false);
                      try {
                        Lesson updatedLesson = Lesson(
                          id: lesson.id,
                          courseId: selectedCourseId!,
                          sectionId: selectedSectionId!,
                          title: title,
                          videoUrl: videoUrl,
                          textContent: textContent,
                          duration: duration,
                          createdAt: lesson.createdAt,
                          updatedAt: DateTime.now(),
                        );
                        await lessonProvider.updateLesson(updatedLesson);

                        Navigator.of(context).pop();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating lesson: $e',style: TextStyle(color: colorScheme.error))));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid duration',)));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields',)));
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  void _showDeleteLessonDialog(BuildContext context, Lesson lesson) {
     final ColorScheme colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
           backgroundColor: colorScheme.primary,
          title:  Text('Delete Lesson',style: TextStyle(color: colorScheme.tertiary)),
          content:  Text('Are you sure you want to delete this lesson?',style: TextStyle(color: colorScheme.tertiary)),
          actions: [
            TextButton(
               child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                final lessonProvider = Provider.of<LessonProvider>(context, listen: false);
                try {
                  await lessonProvider.deleteLesson(lesson.id);
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting lesson: $e',style: TextStyle(color: colorScheme.error))));
                }
              },
            ),
          ],
        );
      },
    );
  }
}