import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myinformatika/firebase_options.dart';
import 'package:myinformatika/services/auth_service.dart';
import 'package:myinformatika/services/notification_service.dart';
import 'package:myinformatika/screens/login_screen.dart';
import 'package:myinformatika/screens/signup_screen.dart';
import 'package:myinformatika/screens/home_screen.dart';
import 'package:myinformatika/screens/camera_screen.dart';
import 'package:myinformatika/screens/location_screen.dart';
import 'package:myinformatika/screens/courses_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notifications
  await NotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Informatika',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/camera': (context) => const CameraScreen(),
        '/location': (context) => const LocationScreen(),
        '/student/courses': (context) => const CoursesListScreen(isInstructor: false),
        '/instructor/courses': (context) => const CoursesListScreen(isInstructor: true),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

