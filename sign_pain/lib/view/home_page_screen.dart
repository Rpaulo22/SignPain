import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_pain/core/providers/sign_language_provider.dart';
import 'package:sign_pain/view/pain_info_screen.dart';
import 'package:sign_pain/view/pain_level_screen.dart';
import 'package:sign_pain/viewmodel/account_view_model.dart';
import 'package:sign_pain/widgets/sign_video_player.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final List<String> videoPaths = [
    'assets/videos/ola.mp4',
    'assets/videos/historia.mp4',
    'assets/videos/dor.mp4',
    'assets/videos/doenca.mp4'
  ];

  final accountViewModel = AccountViewModel();

  @override
  Widget build(BuildContext context) {
    final isSignMode = Provider.of<SignLanguageProvider>(context).isSignLanguageMode;
    User? currentUser = FirebaseAuth.instance.currentUser;

    // safely handle the split-second where it might be null
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    Future<String> userNameFuture = accountViewModel.getUserName(currentUser.uid);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: isSignMode
                            ? SignVideoPlayer(
                                videoPath: videoPaths[0],
                                doubleTap: true,
                              )
                            : FutureBuilder(
                                future: userNameFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  } else {
                                    return RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                        children: <TextSpan>[
                                          const TextSpan(
                                            text: '👋\nOlá ',
                                            style: TextStyle(fontSize: 32),
                                          ),
                                          TextSpan(
                                            text: '${snapshot.data}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold, 
                                              fontSize: 32,
                                              color: Color.fromARGB(255, 233, 129, 64)
                                            ),
                                          ),
                                          const TextSpan(
                                            text: '\n\nBem vindo ao SignPain!',
                                            style: TextStyle(fontSize: 24),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                              ),
                      ),

                      SizedBox(height: 30),
                      
                      // Redirects to pain form submission
                      if (isSignMode)
                        SignVideoPlayer(
                          videoPath: videoPaths[2],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const PainLevelScreen(),
                              ),
                            );
                          },
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 20),
                          child: SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const PainLevelScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                elevation: 4.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Registar dor 📋', 
                                textScaler: TextScaler.linear(1.25),
                              ),
                            ),
                          ),
                        ),
                        
                      // Redirects to pain history screen
                      if (isSignMode)
                        SignVideoPlayer(
                          videoPath: videoPaths[1],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const PainInfoScreen(),
                              ),
                            );
                          },
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 20),
                          child: SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const PainInfoScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.tertiary,
                                foregroundColor: Theme.of(context).colorScheme.onTertiary,
                                elevation: 4.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Histórico 📈', 
                                textScaler: TextScaler.linear(1.25),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}