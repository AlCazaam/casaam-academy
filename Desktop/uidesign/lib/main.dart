import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:uidesign/Themes/theme_provider.dart';
import 'package:uidesign/firebase_options.dart';
import 'package:uidesign/models/complete_lesson.dart';
import 'package:uidesign/providers/admin_provider.dart';
import 'package:uidesign/providers/category_provider.dart';
import 'package:uidesign/providers/complete_provider.dart';
import 'package:uidesign/providers/course_provider.dart';
import 'package:uidesign/providers/discount_provider.dart';
import 'package:uidesign/providers/follower_provider.dart';
import 'package:uidesign/providers/hero_section_provider.dart';
import 'package:uidesign/providers/lesson_provider.dart';
import 'package:uidesign/providers/pdfs_provider.dart';
import 'package:uidesign/providers/post_video_provider.dart';
import 'package:uidesign/providers/purchased_course_provider.dart';
import 'package:uidesign/providers/section_provider.dart';
import 'package:uidesign/providers/user_provider.dart';
import 'package:uidesign/screens/admin_login_screen.dart';
import 'package:uidesign/screens/admin_register_screen.dart';
import 'package:uidesign/screens/intro_screen.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AdminProvider()),
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
        ChangeNotifierProvider(create: (context) => CourseProvider()),
        ChangeNotifierProvider(create: (context) => SectionProvider()),
        ChangeNotifierProvider(create: (context) => LessonProvider()),
        ChangeNotifierProvider(create: (context) => DiscountProvider()),
        ChangeNotifierProvider(create: (context) => HeroSectionProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => PostVideoProvider()),
        ChangeNotifierProvider(create: (context) => PurchasedCourseProvider()),
        ChangeNotifierProvider(create: (context) => FollowerProvider()),
        ChangeNotifierProvider(create: (context) => PdfProvider()),
        ChangeNotifierProvider(create: (context) => CompleteLessonProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider ()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            builder: EasyLoading.init(),
            home: IntroScreen(),
            theme: themeProvider.themeData,
          );
        },
      ),
    );
  }
}
