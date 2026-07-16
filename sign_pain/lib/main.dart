import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_pain/core/providers/sign_language_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sign_pain/theme/app_colors.dart';
import 'package:sign_pain/utils/theme_controller.dart';
import 'package:sign_pain/view/login_screen.dart';
import 'package:sign_pain/view/main_navigation_screen.dart';
import 'package:sign_pain/viewmodel/conditions_view_model.dart';
import 'package:sign_pain/viewmodel/form_view_model.dart';
import 'utils/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest_all.dart' as tz;

final themeController = ThemeController();

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

  // initialize the time zone database
  tz.initializeTimeZones();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignLanguageProvider()),
        
        ChangeNotifierProvider(create: (_) => FormViewModel()),

        ChangeNotifierProvider(create: (_) => ConditionsViewModel())
      ],
      child: const MyApp(), // Or whatever your root app widget is named
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
        colorScheme: .fromSeed(seedColor: AppColors.primaryOrange, brightness: .light),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryOrange,
        ),
        brightness: .light
      ),
      darkTheme: ThemeData(
        colorScheme: .fromSeed(seedColor: AppColors.primaryOrange, brightness: .dark),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: AppColors.primaryOrange
        ),
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
            return const MainNavigationScreen();
          }
          
          // if it reaches here, user is not logged in yet
          return const LoginScreen(); 
        },
      ),

      // permits changing theme withot redrawing the whole app
      builder: (context, child) {
        return ListenableBuilder(
          listenable: themeController,
          builder: (context, _) {
            
            // what mode it is on
            bool isDark;
      
            if (themeController.themeMode == ThemeMode.system) {
              // If set to system, ask the physical device what brightness it is using
              isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
            } else {
              // Otherwise, strictly follow the user's manual override
              isDark = themeController.themeMode == ThemeMode.dark;
            }

            return Theme(
              data: isDark
                  ? ThemeData(
                      colorScheme: ColorScheme.fromSeed(
                        seedColor: AppColors.primaryOrange, 
                        brightness: Brightness.dark,
                      ),
                      appBarTheme: const AppBarTheme(
                        backgroundColor: Colors.black,
                        foregroundColor: AppColors.primaryOrange,
                      ),
                      brightness: Brightness.dark,
                    )
                  : ThemeData(
                      colorScheme: ColorScheme.fromSeed(
                        seedColor: AppColors.primaryOrange, 
                        brightness: Brightness.light,
                      ),
                      appBarTheme: const AppBarTheme(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryOrange,
                      ),
                      brightness: Brightness.light,
                    ),
              child: child!, // Holds the currently active screen state safely
              
            );
          },
        );
      },

    );
    
    
  }
}


