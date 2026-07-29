import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sign_pain_admin/firebase_options.dart';
import 'package:sign_pain_admin/theme/app_colors.dart';
import 'package:sign_pain_admin/view/landing_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // TEMPORARY ACCESS TO ADMIN, WHEN PROD ADD AUTHENTICATION TODO
  if (FirebaseAuth.instance.currentUser == null) {
    await FirebaseAuth.instance.signInAnonymously();
  } 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SignPain Admin',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: AppColors.primaryOrange),
      ),
      home: const LandingScreen(title: 'SignPain Admin'),
    );
  }
}


