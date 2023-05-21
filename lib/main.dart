import 'package:biton_ai/common/services/color_printer.dart';
import 'package:biton_ai/screens/resultsScreen.dart';
import 'package:biton_ai/screens/wordpress/auth_screen.dart';
import 'package:biton_ai/screens/wordpress/woo_posts_screen.dart';
import 'package:biton_ai/widgets/resultsList.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'common/constants.dart';
import 'dart:html' as html;
import 'package:hive/hive.dart';
import 'common/models/uniModel.dart';
import 'firebase_options.dart';
import 'screens/homeScreen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  userJwt = await setJwtToken();


  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UniProvider()),
      // Provider.value(value: StreamModel().serverClient),
      // FutureProvider<List<Activity>?>.value(
      //     value: StreamModel().getFeedActivities(), initialData: const []),
    ],
    // builder:(context, child) =>
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (BuildContext context, Widget? child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'TextStore.AI',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: const HomeScreen()
          // home: ResultsScreen()
          ),
    );
  }
}

Future<String> setJwtToken() async {
  printWhite('START: setJwtToken()');

  var box = await Hive.openBox('myBox');

  String hash = html.window.location.href.split('?').last;
  // print('hash ${hash}');
  Uri uri = Uri.parse('http://Whatever/?$hash');
  Map<String, String> queryParams = uri.queryParameters;

  //> 1) try use queryToken
  if (queryParams['token'] != null) {
    printYellow('Get Token by query! $queryParams');
    var queryToken = queryParams['token'].toString();
    box.put('token', queryToken);
    //
    return queryToken;
  } else {
    //> 2) try use cache
    var cacheToken = box.get('token');
    if (cacheToken != null) {
      printGreen('Get Token by Cache! $cacheToken');
      return cacheToken;
    }

    //> 3) redirect login
    printRed('Token not found! Should Redirect login page');
    if (!kDebugMode) {
      // redirect in Live
      html.window.location.href = 'https://www.textstore.ai/my-account/';
    }
    return debugJwt;
  }
}
