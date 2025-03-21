import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uidesign/Themes/theme_provider.dart';
import 'package:uidesign/models/course.dart';
import 'package:uidesign/models/discount.dart';
import 'package:uidesign/providers/course_provider.dart';
import 'package:uidesign/providers/discount_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DiscountCourseScreen extends StatefulWidget {
  final Discount? discount;

  const DiscountCourseScreen({Key? key, this.discount}) : super(key: key);

  @override
  State<DiscountCourseScreen> createState() => _DiscountCourseScreenState();
}

class _DiscountCourseScreenState extends State<DiscountCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _percentageController = TextEditingController();
  final TextEditingController _couponCodeController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isActive = true;
  bool _isLoading = false;

  List<String> _selectedCourseIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.discount != null) {
      _selectedCourseIds = List<String>.from(widget.discount!.courseIds);
      _percentageController.text = widget.discount!.percentage.toString();
      _couponCodeController.text = widget.discount!.couponCode;
      _startDate = widget.discount!.startDate;
      _endDate = widget.discount!.endDate;
      _isActive = widget.discount!.isActive;
    }
  }

  @override
  void dispose() {
    _percentageController.dispose();
    _couponCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final courseProvider = Provider.of<CourseProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.discount == null ? "Add Discount" : "Edit Discount",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: colorScheme.tertiary),
            ).animate().fadeIn(duration: 500.ms),
            const SizedBox(height: 20),

            Wrap(
              children:
                  _selectedCourseIds
                      .map(
                        (courseId) => CourseChip(
                          courseId: courseId,
                          onDeleted: () {
                            setState(() {
                              _selectedCourseIds.remove(courseId);
                            });
                          },
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 10),

            StreamBuilder<List<Course>>(
              stream: courseProvider.getCourses(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final courses = snapshot.data!;
                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: "Courses", labelStyle: TextStyle(color: colorScheme.tertiary)),
                    style: TextStyle(color: colorScheme.tertiary),
                    dropdownColor: colorScheme.primary,
                    items:
                        courses.map((course) {
                          return DropdownMenuItem<String>(
                            value: course.id,
                            child: Text(course.title, style: TextStyle(color: colorScheme.tertiary)),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        if (newValue != null) {
                          if (_selectedCourseIds.contains(newValue)) {
                            _selectedCourseIds.remove(newValue);
                          } else {
                            _selectedCourseIds.add(newValue);
                          }
                        }
                      });
                    },
                    isExpanded: true,
                    isDense: true,
                  );
                } else if (snapshot.hasError) {
                  return Text("Error loading courses: ${snapshot.error}", style: TextStyle(color: colorScheme.error));
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _percentageController,
              style: TextStyle(color: colorScheme.tertiary),
              decoration: InputDecoration(labelText: "Percentage", labelStyle: TextStyle(color: colorScheme.tertiary)),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter a percentage";
                }
                if (double.tryParse(value) == null) {
                  return "Please enter a valid number";
                }
                return null;
              },
            ),

            TextFormField(
              controller: _couponCodeController,
               style: TextStyle(color: colorScheme.tertiary),
              decoration: InputDecoration(labelText: "Coupon Code", labelStyle: TextStyle(color: colorScheme.tertiary)),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter a coupon code";
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  _startDate == null
                      ? "No Start Date Chosen"
                      : "Start Date: ${DateFormat('MM-dd-yyyy').format(_startDate!)}",
                       style: TextStyle(color: colorScheme.tertiary),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2050),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _startDate = pickedDate;
                      });
                    }
                  },
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  _endDate == null
                      ? "No End Date Chosen"
                      : "End Date: ${DateFormat('MM-dd-yyyy').format(_endDate!)}",
                       style: TextStyle(color: colorScheme.tertiary),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2050),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _endDate = pickedDate;
                      });
                    }
                  },
                ),
              ],
            ),

            Row(
              children: [
                 Text("Active:", style: TextStyle(color: colorScheme.tertiary)),
                Switch(
                  value: _isActive,
                  activeColor: colorScheme.inverseSurface,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),
            AnimatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      _startDate != null &&
                      _endDate != null) {
                    setState(() {
                      _isLoading = true;
                    });
                    double percentage = double.parse(
                      _percentageController.text.trim(),
                    );
                    String couponCode = _couponCodeController.text.trim();

                    try {
                      final discountProvider = Provider.of<DiscountProvider>(
                        context,
                        listen: false,
                      );

                      if (widget.discount == null) {
                        await discountProvider.addDiscount(
                          courseIds: _selectedCourseIds,
                          percentage: percentage,
                          couponCode: couponCode,
                          startDate: _startDate!,
                          endDate: _endDate!,
                          isActive: _isActive,
                        );
                      } else {
                        Discount updatedDiscount = Discount(
                          id: widget.discount!.id,
                          courseIds: _selectedCourseIds,
                          percentage: percentage,
                          couponCode: couponCode,
                          startDate: _startDate!,
                          endDate: _endDate!,
                          isActive: _isActive,
                        );
                        await discountProvider.updateDiscount(
                          updatedDiscount,
                        );
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            widget.discount == null
                                ? "Discount added!"
                                : "Discount updated!",
                          ),
                        ),
                      );

                      Provider.of<DiscountProvider>(
                        context,
                        listen: false,
                      ).notifyListeners();

                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: ${e.toString()}")),
                      );
                    } finally {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                },
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
                          widget.discount == null
                              ? "Add Discount"
                              : "Update Discount",
                          style: const TextStyle(color: Colors.white),
                        ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1000.ms),

            const SizedBox(height: 20),
            Divider(color: colorScheme.tertiary),
            const SizedBox(height: 10),

             Text(
              "Existing Discounts",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.tertiary),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: DiscountList(),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

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
        widget.onPressed();
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
          color: colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(8),
          boxShadow:
              _isPressed
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
        child: widget.child,
      ),
    );
  }
}

class CourseChip extends StatelessWidget {
  final String courseId;
  final VoidCallback onDeleted;

  const CourseChip({Key? key, required this.courseId, required this.onDeleted})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Consumer<CourseProvider>(
      builder: (context, courseProvider, child) {
        return StreamBuilder<List<Course>>(
          stream: courseProvider.getCourses(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final courses = snapshot.data!;
              try {
                final course = courses.firstWhere(
                  (course) => course.id == courseId,
                );

                return Chip(
                  label: Text(course.title, style: TextStyle(color: colorScheme.tertiary)),
                  onDeleted: onDeleted,
                  backgroundColor: colorScheme.secondaryContainer,
                   deleteIconColor: colorScheme.tertiary,
                );
              } catch (e) {
                return Container();
              }
            } else {
              return Container();
            }
          },
        );
      },
    );
  }
}

class DiscountList extends StatelessWidget {
  const DiscountList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final discountProvider = Provider.of<DiscountProvider>(context);

    return StreamBuilder<List<Discount>>(
      stream: discountProvider.getDiscounts(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final discounts = snapshot.data!;
          return ListView.builder(
            itemCount: discounts.length,
            itemBuilder: (context, index) {
              final discount = discounts[index];
              return DiscountCard(discount: discount);
            },
          );
        } else if (snapshot.hasError) {
          return Text("Error loading discounts: ${snapshot.error}", style: TextStyle(color: Theme.of(context).colorScheme.error));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class DiscountCard extends StatelessWidget {
  final Discount discount;

  const DiscountCard({Key? key, required this.discount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.secondary,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Coupon: ${discount.couponCode}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.tertiary),
            ),
            const SizedBox(height: 4),
            Text("Percentage: ${discount.percentage}%", style: TextStyle(color: colorScheme.tertiary)),
            Text(
              "Start Date: ${DateFormat('MM-dd-yyyy').format(discount.startDate)}",
              style: TextStyle(color: colorScheme.tertiary),
            ),
            Text(
              "End Date: ${DateFormat('MM-dd-yyyy').format(discount.endDate)}",
              style: TextStyle(color: colorScheme.tertiary),
            ),
            Text("Active: ${discount.isActive ? 'Yes' : 'No'}", style: TextStyle(color: colorScheme.tertiary)),
            const SizedBox(height: 8),
             Text(
              "Courses:",
              style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.tertiary),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  discount.courseIds.map((courseId) {
                    return CourseName(courseId: courseId);
                  }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => Scaffold(
                              appBar: AppBar(
                                title: const Text("Edit Discount"),
                                backgroundColor: colorScheme.primary,
                                iconTheme: IconThemeData(color: colorScheme.tertiary),
                              ),
                              backgroundColor: colorScheme.background,
                              body: DiscountCourseScreen(discount: discount),
                            ),
                      ),
                    );
                  },
                  child:  Text("Edit", style: TextStyle(color: colorScheme.primary)),
                ),
                IconButton(
                  icon:  Icon(Icons.delete, color: colorScheme.error),
                  onPressed: () {
                    Provider.of<DiscountProvider>(
                      context,
                      listen: false,
                    ).deleteDiscount(discount.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Discount deleted!")),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}

class CourseName extends StatelessWidget {
  final String courseId;

  const CourseName({Key? key, required this.courseId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Consumer<CourseProvider>(
      builder: (context, courseProvider, child) {
        return StreamBuilder<List<Course>>(
          stream: courseProvider.getCourses(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final courses = snapshot.data!;
              try {
                final course = courses.firstWhere(
                  (course) => course.id == courseId,
                );
                return Text("- ${course.title}",  style: TextStyle(color: colorScheme.tertiary));
              } catch (e) {
                return const Text("Course not found");
              }
            } else {
              return const Text("Loading courses...");
            }
          },
        );
      },
    );
  }
}