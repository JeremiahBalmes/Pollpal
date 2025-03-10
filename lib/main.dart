// ignore_for_file: unused_import
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/create_survey_screen.dart';  
import 'screens/qr_scanner_screen.dart';    
import 'screens/survey_details_screen.dart'; 
import 'screens/survey_preview_screen.dart';
import 'package:flutter_application_1/screens/answer_survey_screen.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _handleDynamicLinks();
  }

  void _handleDynamicLinks() async {
    // ✅ Check for initial Dynamic Link when app is launched
    final PendingDynamicLinkData? initialLink =
        await FirebaseDynamicLinks.instance.getInitialLink();
    _handleDeepLink(initialLink?.link);

    // ✅ Listen for incoming dynamic links when app is running
    FirebaseDynamicLinks.instance.onLink.listen(
      (PendingDynamicLinkData dynamicLink) {
        _handleDeepLink(dynamicLink.link);
      },
      onError: (error) {
        print('Dynamic Link Error: $error');
      },
    );
  }

  void _handleDeepLink(Uri? deepLink) {
    if (deepLink != null) {
      print("Deep Link received: $deepLink");
      
       if (deepLink.host == "pollpal.page.link" && deepLink.pathSegments.contains('survey')) {
      String surveyId = deepLink.pathSegments.last;
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => AnswerSurveyScreen(surveyId: surveyId),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Survey App',
      theme: ThemeData(
        primaryColor: const Color(0xFF0b592f),
      ),
      home: const AuthWrapper(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/create_survey': (context) => const CreateSurveyScreen(),
        '/scan_qr': (context) => const QRScannerScreen(),
        '/survey_details': (context) => const SurveyDetailsScreen(),
        '/survey_preview': (context) => SurveyPreviewScreen(surveyId: "someUniqueId"),
        '/answer_survey': (context) => AnswerSurveyScreen(surveyId: ''),
      },
      navigatorKey: navigatorKey,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
