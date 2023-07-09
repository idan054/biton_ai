import 'dart:async';

import 'package:biton_ai/common/extensions/context_ext.dart';
import 'package:biton_ai/common/extensions/widget_ext.dart';
import 'package:biton_ai/common/services/color_printer.dart';
import 'package:biton_ai/common/services/wooApi.dart';
import 'package:biton_ai/screens/resultsScreen.dart';
import 'package:biton_ai/screens/wordpress/auth_screen.dart';
import 'package:biton_ai/screens/wordpress/woo_posts_screen.dart';
import 'package:biton_ai/widgets/resultsList.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'common/constants.dart';
import 'dart:html' as html;
import 'package:hive/hive.dart';
import 'common/models/uniModel.dart';
import 'common/models/user/woo_user_model.dart';
import 'common/services/gpt_service.dart';
import 'firebase_options.dart';
import 'screens/homeScreen.dart';
import 'package:firebase_core/firebase_core.dart';


Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await dotenv.load();
    await Hive.initFlutter();
    final token = await setUserToken();
    mixpanel = await Mixpanel.init('d4a54319e5c410306cf1be4b92f339e3',
        trackAutomaticEvents: true);

    const sentryUrl =
        'https://58ec3c5acddb489c8bcbc70d51dbb1c4@o1148186.ingest.sentry.io/4505254606864384';
    await SentryFlutter.init((options) {
      options.dsn = sentryUrl;
      options.tracesSampleRate = 1.0; // 1.0 = capture 100%
    });
    // --
    runApp(MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => UniProvider()),
    ], child: MyApp(token)));
    // --
  },
      (exception, stackTrace) async =>
          await Sentry.captureException(exception, stackTrace: stackTrace));
}

class MyApp extends StatelessWidget {
  final String? token;

  const MyApp(this.token, {super.key});

  @override
  Widget build(BuildContext context) {
    context.uniProvider.updateWooUserModel(
        context.uniProvider.currUser.copyWith(token: token),
        notify: false);

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

Future<String?> setUserToken({String? token, String? userEmail, String? userPass}) async {
  printWhite('START: setJwtToken()');
  var box = await Hive.openBox('currUserBox');

  //> 1) Set token on signup / login
  if (token != null) {
    printYellow('Login user Token found! $token');
    box.put('token', token);
    box.put('userEmail', userEmail);
    box.put('userPass', userPass);
    appConfig_userJwt = token;
    return token;
  } else {
    //> 2) Try use cache
    var cacheToken = box.get('token');
    if (cacheToken != null) {
      printGreen('Get Token by Cache! $cacheToken');
      appConfig_userJwt = cacheToken;
      return cacheToken;
    }

    //> 3) Require login (open dialog)
    printRed('Token not found! User should login');

    // if (kDebugMode) {
    //   appConfig_userJwt = adminJwt;
    //   return true;
    // } else {
    //   // redirect in Live
    //   // html.window.location.href = 'https://www.textstore.ai/my-account/';
    //   return false;
    // }

    return null;
  }
}
