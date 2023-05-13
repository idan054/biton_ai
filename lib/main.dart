import 'package:biton_ai/screens/resultsScreen.dart';
import 'package:biton_ai/screens/wordpress/auth_screen.dart';
import 'package:biton_ai/screens/wordpress/woo_posts_screen.dart';
import 'package:biton_ai/widgets/resultsList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'common/constants.dart';
import 'screens/homeScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (BuildContext context, Widget? child) =>
          MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Better Seller',
              theme: ThemeData(primarySwatch: Colors.blue),
              home: const HomeScreen()
              // home: ResultsScreen()
          ),
    );
  }
}


