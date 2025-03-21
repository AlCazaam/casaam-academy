import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uidesign/Themes/theme_provider.dart';
import 'package:uidesign/models/course.dart';
import 'package:uidesign/providers/course_provider.dart';
import 'package:uidesign/providers/purchased_course_provider.dart';
import 'package:uidesign/screens/course_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uidesign/screens/display_seaction_screen.dart';

class DisplayCourseScreen extends StatefulWidget {
  const DisplayCourseScreen({Key? key}) : super(key: key);

  @override
  State<DisplayCourseScreen> createState() => _DisplayCourseScreenState();
}

class _DisplayCourseScreenState extends State<DisplayCourseScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Consumer<CourseProvider>(
        builder: (context, courseProvider, child) {
          return StreamBuilder<List<Course>>(
            stream: courseProvider.getCourses(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final courses = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 24.0,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return CourseCard(course: course)
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 50.ms * index)
                        .slideY(
                          begin: 0.1,
                          end: 0,
                          duration: 600.ms,
                          curve: Curves.easeInOut,
                        );
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
          );
        },
      ),
    );
  }
}
class CourseCard extends StatefulWidget {
  final Course course;

  const CourseCard({Key? key, required this.course}) : super(key: key);

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool _isElevated = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (event) => setState(() => _isElevated = true),
      onExit: (event) => setState(() => _isElevated = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: colorScheme.surface, // Changed to colorScheme.surface
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(_isElevated ? 0.5 : 0.2),
              spreadRadius: _isElevated ? 3 : 1,
              blurRadius: _isElevated ? 7 : 3,
              offset: Offset(0, _isElevated ? 3 : 2),
            ),
          ],
        ),
        margin: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12.0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DisplayCourseWithSections(courseId: widget.course.id),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          widget.course.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => SizedBox(
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: colorScheme.inverseSurface,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CourseScreen(course: widget.course),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.course.title,
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: colorScheme
                              .inverseSurface, // Changed to colorScheme.tertiary
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 12),

                      // New Section: Number of Pending Purchases
                      FutureBuilder<int>(
                        future: _getPendingPurchaseCount(context, widget.course.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text("Loading  purchases...");
                          } else if (snapshot.hasError) {
                            return Text("Error: ${snapshot.error}");
                          } else {
                            int pendingCount = snapshot.data ?? 0;
                            return Text(
                              "Purchases: $pendingCount",
                              style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 4),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.person,
                            size: 16,
                            color: colorScheme.onSurface,
                          ), // Changed to colorScheme.onSurface
                          Flexible(
                            child: Text(
                              widget.course.instructor,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme
                                    .onSurface, // Changed to colorScheme.onSurface
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: 16,
                            color: colorScheme
                                .onSurface, // Changed to colorScheme.onSurface
                          ),
                          Text(
                            "\$${widget.course.price}",
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme
                                  .onSurface, // Changed to colorScheme.onSurface
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Created At: ${DateFormat('yyyy-MM-dd HH:mm').format(widget.course.createdAt)}",
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSecondary,
                        ), // Changed to colorScheme.onSecondary
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to get the count of pending purchases for a specific course
  Future<int> _getPendingPurchaseCount(BuildContext context, String courseId) async {
    final purchasedCourseProvider = Provider.of<PurchasedCourseProvider>(context, listen: false);
    final purchasedCourses = await purchasedCourseProvider.getPurchasedCoursesList(); // Get the list

    int count = 0;
    for (var purchasedCourse in purchasedCourses) {
      if (purchasedCourse.courseIds.contains(courseId) && purchasedCourse.pending == true) {
        count++;
      }
    }
    return count;
  }
}