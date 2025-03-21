import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uidesign/Themes/theme_provider.dart';
import 'package:uidesign/models/purchased_course.dart';
import 'package:uidesign/providers/purchased_course_provider.dart';
import 'package:uidesign/models/user.dart';
import 'package:uidesign/models/course.dart';
import 'package:flutter_animate/flutter_animate.dart'; //for animations
import 'package:uidesign/models/pdfs.dart'; // Import PDF model

class PurchasedScreen extends StatefulWidget {
  const PurchasedScreen({Key? key}) : super(key: key);

  @override
  State<PurchasedScreen> createState() => _PurchasedScreenState();
}

class _PurchasedScreenState extends State<PurchasedScreen> {
  int? _selectedYear;
  int? _selectedMonth;

  List<int> _availableYears = [];
  late Future<void> _dataLoading;

  @override
  void initState() {
    super.initState();
    _dataLoading = _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    List<PurchasedCourse> allPurchasedCourses =
        await Provider.of<PurchasedCourseProvider>(
          context,
          listen: false,
        ).getPurchasedCourses().first;

    Set<int> yearsSet =
        allPurchasedCourses.map((e) => e.purchasedAt.year).toSet();
    _availableYears = yearsSet.toList();
    _availableYears.sort((a, b) => b.compareTo(a));

    if (_availableYears.isNotEmpty) {
      _selectedYear = _availableYears.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData theme = themeProvider.themeData;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Purchased Courses",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: theme.colorScheme.background,
      body: FutureBuilder<void>(
        future: _dataLoading,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primaryContainer,
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    DropdownButton<int>(
                      dropdownColor: theme.colorScheme.primary,
                      style: TextStyle(color: theme.colorScheme.tertiary),
                      value: _selectedYear,
                      hint: Text("Select Year",
                          style: TextStyle(color: theme.colorScheme.onSurface)),
                      items: _availableYears.map((year) {
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text(year.toString(),
                              style:
                                  TextStyle(color: theme.colorScheme.onSurface)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedYear = value;
                          _selectedMonth = null;
                        });
                      },
                    ),
                    DropdownButton<int>(
                      dropdownColor: theme.colorScheme.primary,
                      style: TextStyle(color: theme.colorScheme.tertiary),
                      value: _selectedMonth,
                      hint: Text("Select Month",
                          style: TextStyle(color: theme.colorScheme.onSurface)),
                      items: _selectedYear != null
                          ? List<int>.generate(
                              12,
                              (index) => index + 1,
                            ).map((month) {
                              return DropdownMenuItem<int>(
                                value: month,
                                child: Text(
                                  DateFormat('MMMM')
                                      .format(DateTime(_selectedYear!, month)),
                                  style: TextStyle(
                                      color: theme.colorScheme.onSurface),
                                ),
                              );
                            }).toList()
                          : [],
                      onChanged: _selectedYear != null
                          ? (value) {
                              setState(() {
                                _selectedMonth = value;
                              });
                            }
                          : null,
                    ),
                  ],
                ),
                PurchasedCoursesList(
                  selectedYear: _selectedYear,
                  selectedMonth: _selectedMonth,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                  child: Text(
                    "All Purchases Timeline",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface),
                  ),
                ),
                TimelineView(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PurchasedCoursesList extends StatelessWidget {
  final int? selectedYear;
  final int? selectedMonth;

  const PurchasedCoursesList({Key? key, this.selectedYear, this.selectedMonth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData theme = themeProvider.themeData;

    return StreamBuilder<List<PurchasedCourse>>(
      stream: Provider.of<PurchasedCourseProvider>(
        context,
        listen: false,
      ).getPurchasedCourses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: theme.colorScheme.primaryContainer,
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
              child: Text("Error: ${snapshot.error}",
                  style: TextStyle(color: theme.colorScheme.error)));
        }

        List<PurchasedCourse> purchasedCourses = snapshot.data ?? [];

        if (selectedYear != null) {
          purchasedCourses = purchasedCourses
              .where((pc) => pc.purchasedAt.year == selectedYear)
              .toList();
        }
        if (selectedMonth != null) {
          purchasedCourses = purchasedCourses
              .where((pc) => pc.purchasedAt.month == selectedMonth)
              .toList();
        }

        return purchasedCourses.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: purchasedCourses.length,
                itemBuilder: (context, index) {
                  final purchasedCourse = purchasedCourses[index];
                  return PurchasedCourseCard(
                      purchasedCourse: purchasedCourse);
                },
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "No purchases found for the selected month/year.",
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              );
      },
    );
  }
}

class TimelineTile extends StatelessWidget {
  final PurchasedCourse purchasedCourse;

  const TimelineTile({Key? key, required this.purchasedCourse})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData theme = themeProvider.themeData;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, //Tile Background
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer, //Circle Avatar
          child: Text(
            DateFormat('MMM').format(purchasedCourse.purchasedAt),
            style: TextStyle(color: theme.colorScheme.onPrimary),
          ),
        ),
        title: Text(
          'Course Purchase',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
        ),
        subtitle: Text(
          DateFormat('dd, yyyy').format(purchasedCourse.purchasedAt),
          style: TextStyle(color: theme.colorScheme.tertiary),
        ),
        trailing: Text(
          NumberFormat.currency(locale: 'en_US', symbol: '\$')
              .format(purchasedCourse.totalPrice),
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
      ),
    );
  }
}
class PurchasedCourseCard extends StatefulWidget {
  final PurchasedCourse purchasedCourse;

  const PurchasedCourseCard({Key? key, required this.purchasedCourse})
      : super(key: key);

  @override
  State<PurchasedCourseCard> createState() => _PurchasedCourseState();
}

class _PurchasedCourseState extends State<PurchasedCourseCard> {
  bool _show = false;
  bool _pending = false;
  bool _isButtonEnabled = true;

  @override
  void initState() {
    super.initState();
    _show = widget.purchasedCourse.show;
    _pending = widget.purchasedCourse.pending;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData theme = themeProvider.themeData;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Purchase ID: ${widget.purchasedCourse.id}",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface),
            ),
            const Divider(height: 20, thickness: 1),
            FutureBuilder<User?>(
              future: _getUser(widget.purchasedCourse.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Loading User...");
                }
                final user = snapshot.data;
                return Text(
                  "User: ${user?.fullname ?? 'Unknown'} (${user?.username ?? 'N/A'})",
                  style: TextStyle(color: theme.colorScheme.onSurface),
                );
              },
            ),
            FutureBuilder<List<String>>(
              future: _getCourseTitles(widget.purchasedCourse.courseIds),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Loading Courses...");
                }
                final courseTitles = snapshot.data ?? [];
                return Text(
                  "Courses: ${courseTitles.join(', ')}",
                  style: TextStyle(color: theme.colorScheme.onSurface),
                );
              },
            ),
            FutureBuilder<List<String>>(
              future: _getPdfNames(widget.purchasedCourse.pdfIds),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Loading PDFs...");
                }
                final pdfNames = snapshot.data ?? [];
                return Text(
                  "PDFs: ${pdfNames.join(', ')}",
                  style: TextStyle(color: theme.colorScheme.onSurface),
                );
              },
            ),
            Text(
              "Number: ${widget.purchasedCourse.number}",
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            Text(
              "Total Price: \$${widget.purchasedCourse.totalPrice.toStringAsFixed(2)}",
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            Text(
              "Purchased At: ${DateFormat('yyyy-MM-dd HH:mm').format(widget.purchasedCourse.purchasedAt)}",
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            Text(
              "Message: ${widget.purchasedCourse.message}",
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            const Divider(height: 20, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text("Show:",
                        style: TextStyle(color: theme.colorScheme.onSurface)),
                    Switch(
                      value: _show,
                      onChanged: (value) {
                        setState(() {
                          _show = value;
                        });
                        _updatePurchasedCourse(context, show: value);
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text("Pending:",
                        style: TextStyle(color: theme.colorScheme.onSurface)),
                    Switch(
                      value: _pending,
                      onChanged: (value) {
                        setState(() {
                          _pending = value;
                        });
                        _updatePurchasedCourse(context, pending: value);
                      },
                    ),
                  ],
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.edit),
                onPressed:
                    _isButtonEnabled
                        ? () => _showEditDialog(context, widget.purchasedCourse)
                        : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<User?> _getUser(String userId) async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection("users").doc(userId).get();
    if (doc.exists) {
      return User.fromJson(doc.data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  Future<List<String>> _getCourseTitles(List<String> courseIds) async {
    List<String> courseTitles = [];
    for (String courseId in courseIds) {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection("courses")
              .doc(courseId)
              .get();
      if (doc.exists) {
        courseTitles.add(
          (doc.data() as Map<String, dynamic>)['title'] as String,
        );
      }
    }
    return courseTitles;
  }

  Future<List<String>> _getPdfNames(List<String> pdfIds) async {
    List<String> pdfNames = [];
    for (String pdfId in pdfIds) {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection("pdfs").doc(pdfId).get();
      if (doc.exists) {
        pdfNames.add((doc.data() as Map<String, dynamic>)['name'] as String);
      }
    }
    return pdfNames;
  }

  void _updatePurchasedCourse(
    BuildContext context, {
    bool? show,
    bool? pending,
  }) async {
    final purchasedCourseProvider = Provider.of<PurchasedCourseProvider>(
      context,
      listen: false,
    );

    PurchasedCourse updatedPurchasedCourse = PurchasedCourse(
      id: widget.purchasedCourse.id,
      number: widget.purchasedCourse.number,
      userId: widget.purchasedCourse.userId,
      courseIds: widget.purchasedCourse.courseIds,
      purchasedAt: widget.purchasedCourse.purchasedAt,
      pending: pending ?? widget.purchasedCourse.pending,
      show: show ?? widget.purchasedCourse.show,
      message: widget.purchasedCourse.message,
      totalPrice: widget.purchasedCourse.totalPrice,
      pdfIds: widget.purchasedCourse.pdfIds,
    );

    try {
      await purchasedCourseProvider.updatePurchasedCourse(
        updatedPurchasedCourse,
      );
    } catch (e) {
      print("Error updating purchased course: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update purchased course.")),
      );
    }
  }

  void _showEditDialog(
    BuildContext context,
    PurchasedCourse purchasedCourse,
  ) async {
    final TextEditingController _numberController = TextEditingController(
      text: purchasedCourse.number,
    );
    final TextEditingController _totalPriceController = TextEditingController(
      text: purchasedCourse.totalPrice.toString(),
    );
    final TextEditingController _messageController = TextEditingController(
      text: purchasedCourse.message,
    );
    DateTime _selectedDate = purchasedCourse.purchasedAt;
    List<String> _selectedCourses = List<String>.from(
      purchasedCourse.courseIds,
    );
    List<String> _selectedPdfs = List<String>.from(
      purchasedCourse.pdfIds,
    );

    List<Course> availableCourses = [];
    List<PDF> availablePdfs = [];

    QuerySnapshot<Map<String, dynamic>> coursesSnapshot =
        await FirebaseFirestore.instance.collection('courses').get();

    availableCourses =
        coursesSnapshot.docs.map((doc) => Course.fromJson(doc.data())).toList();

    QuerySnapshot<Map<String, dynamic>> pdfsSnapshot =
        await FirebaseFirestore.instance.collection('pdfs').get();

    availablePdfs =
        pdfsSnapshot.docs.map((doc) => PDF.fromJson(doc.data())).toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Purchased Course'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text("Purchased At"),
                      subtitle: Text(
                        DateFormat('yyyy-MM-dd HH:mm').format(_selectedDate),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2050),
                        );

                        if (pickedDate != null) {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_selectedDate),
                            initialEntryMode: TimePickerEntryMode.dial,
                          );

                          if (pickedTime != null) {
                            setState(() {
                              _selectedDate = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                            });
                          }
                        }
                      },
                    ),
                    const Text("Select Courses"),
                    FutureBuilder<List<Course>>(
                      future: Future.value(availableCourses),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        } else {
                          final courses = snapshot.data ?? [];
                          return Wrap(
                            children: courses.map((course) {
                              return FilterChip(
                                label: Text(course.title),
                                selected: _selectedCourses.contains(course.id),
                                onSelected: (bool selected) {
                                  setState(() {
                                    if (selected) {
                                      if (!_selectedCourses.contains(
                                        course.id,
                                      )) {
                                        _selectedCourses.add(course.id);
                                      }
                                    } else {
                                      _selectedCourses.remove(course.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          );
                        }
                      },
                    ),
                    const Text("Select PDFs"),
                    FutureBuilder<List<PDF>>(
                      future: Future.value(availablePdfs),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        } else {
                          final pdfs = snapshot.data ?? [];
                          return Wrap(
                            children: pdfs.map((pdf) {
                              return FilterChip(
                                label: Text(pdf.name),
                                selected: _selectedPdfs.contains(pdf.id),
                                onSelected: (bool selected) {
                                  setState(() {
                                    if (selected) {
                                      if (!_selectedPdfs.contains(pdf.id)) {
                                        _selectedPdfs.add(pdf.id);
                                      }
                                    } else {
                                      _selectedPdfs.remove(pdf.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          );
                        }
                      },
                    ),
                    TextFormField(
                      controller: _numberController,
                      decoration: const InputDecoration(labelText: "Number"),
                    ),
                    TextFormField(
                      controller: _totalPriceController,
                      decoration: const InputDecoration(
                        labelText: "Total Price",
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: _messageController,
                      decoration: const InputDecoration(labelText: "Message"),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Update'),
              onPressed:
                  _isButtonEnabled
                      ? () async {
                        setState(() {
                          _isButtonEnabled = false;
                        });
                        try {
                          EasyLoading.show(status: 'Updating...');
                          final updatedPurchasedCourse = PurchasedCourse(
                            id: purchasedCourse.id,
                            number: _numberController.text,
                            userId: purchasedCourse.userId,
                            courseIds: _selectedCourses,
                            purchasedAt: _selectedDate,
                            pending: purchasedCourse.pending,
                            show: purchasedCourse.show,
                            message: _messageController.text,
                            totalPrice: double.parse(
                              _totalPriceController.text,
                            ),
                            pdfIds: _selectedPdfs,
                          );

                          await Provider.of<PurchasedCourseProvider>(
                            context,
                            listen: false,
                          ).updatePurchasedCourse(updatedPurchasedCourse);
                          EasyLoading.showSuccess('Purchased course updated!');
                          Navigator.of(context).pop();
                        } catch (e) {
                          EasyLoading.showError(
                            'Failed to update purchased course: $e',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to update purchased course: $e',
                              ),
                            ),
                          );
                        } finally {
                          setState(() {
                            _isButtonEnabled = true;
                          });
                        }
                      }
                      : null,
            ),
          ],
        );
      },
    );
  }
}

class TimelineView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData theme = themeProvider.themeData;

    return StreamBuilder<List<PurchasedCourse>>(
      stream: Provider.of<PurchasedCourseProvider>(
        context,
        listen: false,
      ).getPurchasedCourses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: theme.colorScheme.primaryContainer,
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text(
            'No purchases available.',
            style: TextStyle(color: theme.colorScheme.onSurface),
          );
        }

        final purchasedCourses = snapshot.data!;

        Map<int, Map<int, List<PurchasedCourse>>> groupedPurchases = {};

        for (var purchase in purchasedCourses) {
          int year = purchase.purchasedAt.year;
          int month = purchase.purchasedAt.month;

          if (!groupedPurchases.containsKey(year)) {
            groupedPurchases[year] = {};
          }

          if (!groupedPurchases[year]!.containsKey(month)) {
            groupedPurchases[year]![month] = [];
          }

          groupedPurchases[year]![month]!.add(purchase);
        }

        List<int> sortedYears =
            groupedPurchases.keys.toList()..sort((a, b) => b.compareTo(a));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sortedYears.map((year) {
            List<int> sortedMonths =
                groupedPurchases[year]!.keys.toList()
                  ..sort((a, b) => b.compareTo(a));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "$year",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface),
                  ),
                ),
                Column(
                  children: sortedMonths.map((month) {
                    List<PurchasedCourse> monthlyPurchases =
                        groupedPurchases[year]![month]!;
                    String monthName = DateFormat('MMMM').format(
                      DateTime(year, month),
                    );

                    return Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(
                              0,
                              1,
                            ),
                          ),
                        ],
                      ),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$monthName",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface),
                          ),
                          if (monthlyPurchases.isNotEmpty)
                            Text(
                              "Purchases: ${monthlyPurchases.length}",
                              style: TextStyle(
                                  color: theme.colorScheme.onSurface),
                            )
                          else
                            Text(
                              "No purchases this month",
                              style: TextStyle(
                                  color: theme.colorScheme.onSurface),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}