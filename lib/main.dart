import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:social_media_app/services/prefrences_services.dart';
import 'package:social_media_app/utils/color_utility.dart';
import 'package:social_media_app/views/home.dart';
import 'package:social_media_app/views/login.dart';
import 'package:social_media_app/views/profile.dart';
import 'package:social_media_app/views/sign_up.dart';
import 'package:social_media_app/views/splash.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await PreferencesServices.initPreferences();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['API_KEY']!,
      appId: dotenv.env['APP_ID']!,
      messagingSenderId: dotenv.env['MESSAGING_SENDER_ID']!,
      projectId: dotenv.env['PROJECT_ID']!,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Social Media App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: ColorUtility.scaffoldBackground,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashView(),
        '/sign-up': (context) => SignUp(),
        '/login': (context) => Login(),
        '/home': (context) => Home(),
        '/profile': (context) => Profile(),
      },
    );
  }
}
