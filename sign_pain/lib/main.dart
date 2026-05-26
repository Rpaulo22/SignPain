import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_pain/core/providers/sign_language_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sign_pain/view/login_screen.dart';
import 'package:sign_pain/view/main_navigation_screen.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load the environment variables
  await dotenv.load(fileName: ".env");
  
  // Now initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // if it's the duplicate app error
    if (e.toString().contains('duplicate-app')) {
      print('Firebase was already initialized natively');
    } else {
      // if it's a different error
      rethrow; 
    }
  }

  // ensures Flutter bindings are initialized before calling async code
  WidgetsFlutterBinding.ensureInitialized();

  // load the Portuguese date formatting data (could crash if not awaited for)
  await initializeDateFormatting('pt_PT', null);
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => SignLanguageProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SignPain',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: const Color.fromARGB(255, 233, 129, 64), brightness: .light),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 233, 129, 64),
          foregroundColor: Colors.white,
        ),
        brightness: .light
      ),
      darkTheme: ThemeData(
        colorScheme: .fromSeed(seedColor: const Color.fromARGB(255, 233, 129, 64), brightness: .dark),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 233, 129, 64)
        ),
      ),
      themeMode: ThemeMode.system,
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
            return const MainNavigationScreen();
          }
          
          // if it reaches here, user is not logged in yet
          return const LoginScreen(); 
        },
      ),
    );
  }
}


