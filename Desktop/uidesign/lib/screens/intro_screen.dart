import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uidesign/Themes/theme_provider.dart';
import 'package:uidesign/providers/admin_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uidesign/screens/access_course_screen.dart';
import 'package:uidesign/screens/admin_login_screen.dart';
import 'package:uidesign/screens/admin_profile_screen.dart';
import 'package:uidesign/screens/all_users_screen.dart';
import 'package:uidesign/screens/calculator.dart';
import 'package:uidesign/screens/category_screen.dart';
import 'package:uidesign/screens/course_screen.dart';
import 'package:uidesign/screens/discount_screaan.dart';
import 'package:uidesign/screens/display_course.dart';
import 'package:uidesign/screens/display_purchased_screen.dart';
import 'package:uidesign/screens/hero_section_screen.dart';
import 'package:uidesign/screens/lesson_screen.dart';
import 'package:uidesign/screens/pdfs_screen.dart';
import 'package:uidesign/screens/post_video_screen.dart';
import 'package:uidesign/screens/section_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  int _selectedIndex = 0;
  late List<Widget> _pages;
  final double _drawerWidth = 250.0; // Width of the drawer

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AdminProvider>(context);
    final user = authProvider.getCurrentAdmin();
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData theme = themeProvider.themeData;

    if (user == null) {
      // If the admin is not logged in, redirect to the login screen.
      return const AdminLoginScreen(); // Or whatever login screen you have
    }

    _pages = [
      CategoryScreen(),
      CourseScreen(),
      DisplayCourseScreen(),
      SectionScreen(),
      DiscountCourseScreen(),
      AllUserScreen(),
      PurchasedScreen(),
      AccessCourseScreen(),
      AdminProfileScreen(),
      PostVideoScreen(),
      HeroSectionScreen(),
      AddPdfScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ADMIN DASHBORAD",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: theme.colorScheme.primaryContainer,
        actions: [
          IconButton(
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            color: Colors.white,
            icon: Icon(Icons.calculate, color: theme.colorScheme.error),
            onPressed: () {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const CalculatorDialog();
    },
  );
},
          ),

          const SizedBox(width: 20),
          Switch(
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
          ),
          const SizedBox(width: 20),
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              // Logout the admin and navigate to the login screen.
              authProvider.logoutAdmin();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const AdminLoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Side Navigation Drawer
          Container(
            width: _drawerWidth,
            color: theme.colorScheme.primary, // A light background color
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome, ${user.username}!",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ).animate().fadeIn(),
                      const SizedBox(height: 8),
                      Text(
                        "Admin Access",
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.category,
                          color: theme.colorScheme.onSurface,
                        ),
                        title: Text(
                          'Categories',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                        selected: _selectedIndex == 0,
                        selectedTileColor: theme.colorScheme.secondaryContainer,
                        onTap: () {
                          setState(() {
                            _selectedIndex = 0;
                          });
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.library_add,
                          color: theme.colorScheme.onSurface,
                        ),
                        title: Text(
                          'Add Course',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                        selected: _selectedIndex == 1,
                        selectedTileColor: theme.colorScheme.secondaryContainer,
                        onTap: () {
                          setState(() {
                            _selectedIndex = 1;
                          });
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.menu_book,
                          color: theme.colorScheme.onSurface,
                        ),
                        title: Text(
                          'Course List',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                        selected: _selectedIndex == 2,
                        selectedTileColor: theme.colorScheme.secondaryContainer,
                        onTap: () {
                          setState(() {
                            _selectedIndex = 2;
                          });
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.video_library,
                          color: theme.colorScheme.onSurface,
                        ),
                        title: Text(
                          'Sections & Lessons',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                        selected: _selectedIndex == 3,
                        selectedTileColor: theme.colorScheme.secondaryContainer,
                        onTap: () {
                          setState(() {
                            _selectedIndex = 3;
                          });
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.local_offer,
                          color: theme.colorScheme.onSurface,
                        ),
                        title: Text(
                          'Discounts & Coupons',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                        selected: _selectedIndex == 4,
                        selectedTileColor: theme.colorScheme.secondaryContainer,
                        onTap: () {
                          setState(() {
                            _selectedIndex = 4;
                          });
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.group,
                          color: theme.colorScheme.onSurface,
                        ),
                        title: Text(
                          'All Users',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                        selected: _selectedIndex == 5,
                        selectedTileColor: theme.colorScheme.secondaryContainer,
                        onTap: () {
                          setState(() {
                            _selectedIndex = 5;
                          });
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.payment,
                          color: theme.colorScheme.onSurface,
                        ),
                        title: Text(
                          'Paid Courses',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                        selected: _selectedIndex == 6,
                        selectedTileColor: theme.colorScheme.secondaryContainer,
                        onTap: () {
                          setState(() {
                            _selectedIndex = 6;
                          });
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.library_books,
                          color: theme.colorScheme.onSurface,
                        ),
                        title: Text(
                          'Access Course',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                        selected: _selectedIndex == 7,
                        selectedTileColor: theme.colorScheme.secondaryContainer,
                        onTap: () {
                          setState(() {
                            _selectedIndex = 7;
                          });
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.admin_panel_settings,
                          color: theme.colorScheme.onSurface,
                        ),
                        title: Text(
                          'Admin Profile',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                        selected: _selectedIndex == 8,
                        selectedTileColor: theme.colorScheme.secondaryContainer,
                        onTap: () {
                          setState(() {
                            _selectedIndex = 8;
                          });
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.video_library,
                          color: theme.colorScheme.onSurface,
                        ),
                        title: Text(
                          'Video Status',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                        selected: _selectedIndex == 9,
                        selectedTileColor: theme.colorScheme.secondaryContainer,
                        onTap: () {
                          setState(() {
                            _selectedIndex = 9;
                          });
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.star,
                          color: theme.colorScheme.onSurface,
                        ),
                        title: Text(
                          'Hero Section',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                        selected: _selectedIndex == 10,
                        selectedTileColor: theme.colorScheme.secondaryContainer,
                        onTap: () {
                          setState(() {
                            _selectedIndex = 10;
                          });
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.picture_as_pdf,
                          color: theme.colorScheme.onSurface,
                        ),
                        title: Text(
                          'Add PDF',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                        selected: _selectedIndex == 11,
                        selectedTileColor: theme.colorScheme.secondaryContainer,
                        onTap: () {
                          setState(() {
                            _selectedIndex = 11;
                          });
                        },
                      ),
                      IconButton(
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        color: Colors.white,
                        icon: Icon(
                          Icons.logout,
                          color: theme.colorScheme.error,
                        ),
                        onPressed: () {
                          // Logout the admin and navigate to the login screen.
                          authProvider.logoutAdmin();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const AdminLoginScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().slideX(
            duration: 500.ms,
            curve: Curves.easeInOut,
          ), // Slide in the side nav
          // Main Content Area
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
