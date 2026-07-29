import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sign_pain_admin/utils/firebase_options.dart';
import 'package:sign_pain_admin/theme/app_colors.dart';
import 'package:sign_pain_admin/view/landing_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_pain_admin/view/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          
          // loading screen when checking if a user is authenticated
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          // if it throws an error
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text("Ocorreu um erro! Reinicie e tente mais tarde")),
            );
          }
          
          // if the snapshot has data, the user is valid and logged in
          if (snapshot.hasData) {
            return const LandingScreen(title: "SignPain Admin");
          }
          
          // if it reaches here, user is not logged in yet
          return const LoginScreen(); 
        },
      ),
    );
  }
}


