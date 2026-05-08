import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_pain/core/providers/sign_language_provider.dart';
import 'package:sign_pain/view/login_screen.dart';
import 'package:sign_pain/view/medical_condition_screen.dart';
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
      appBar: AppBar(
				backgroundColor: Theme.of(context).colorScheme.inversePrimary,
				title: const Text("SignPain", textAlign: TextAlign.center),
        actions: [
          IconButton(
            onPressed: () {
              // toggle between sign language and text
              Provider.of<SignLanguageProvider>(context, listen: false).toggleMode();
            },
            icon: isSignMode ? Icon(Icons.sign_language) : Icon(Icons.sign_language_outlined)
          )
        ],
			),
			body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsetsGeometry.directional(start:15, end:15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.all(16.0),
                  child: FractionallySizedBox(
                    widthFactor: 0.5,
                    child: Image(
                      image: const AssetImage('assets/images/signpain.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsGeometry.all(12),
                  child: isSignMode ?
                    SignVideoPlayer(
                    videoPath: videoPaths[0],
                    doubleTap: true
                    )
                  : FutureBuilder(
                    future: userNameFuture, 
                    builder: (context, snapshot) { // waiting for user's name
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      else {
                        return RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              TextSpan(text:'👋\nOlá ',
                                style: TextStyle(fontSize: 32)
                              ),
                              TextSpan(text: '${snapshot.data}',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32)
                              ),
                              TextSpan(text:'\n\nBem vindo ao SignPain, a aplicação de comunicação de dor para a Comunidade Surda.',
                                style: TextStyle(fontSize: 24)
                              )
                            ]
                          )
                        );
                      }
                    }
                  )
                ),
                // redirects to pain form submission
                if (isSignMode) // sign language content
                  SignVideoPlayer(
                    videoPath: videoPaths[2],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PainLevelScreen(),
                        ),
                      );
                    },
                  )
                else Padding(
                  padding: EdgeInsetsGeometry.directional(top:10, bottom:20),
                  child: SizedBox(
                    width: double.infinity, // Stretches it to the edges of the screen
                    height: 60, // Makes it a bit taller and easier to tap
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PainLevelScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.inversePrimary, 
                        foregroundColor: Colors.white, // Text color
                        elevation: 4.0, 
                      ),
                      child: Text('Registar dor 📋', textScaler: TextScaler.linear(1.25))
                    )
                  )
                ),
                // redirects to pain history screen
                if (isSignMode) // sign language content
                  SignVideoPlayer(
                    videoPath: videoPaths[1],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PainInfoScreen(),
                        ),
                      );
                  },
                  )
                else Padding(
                  padding: EdgeInsetsGeometry.directional(top:10, bottom:20),
                  child:SizedBox(
                    width: double.infinity, // stretches it to the edge
                    height: 60, // makes it a bit taller and easier to tap
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PainInfoScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, 
                        foregroundColor: Colors.white, // Text color
                        elevation: 4.0, 
                      ),
                      child: Text('Histórico 📈', textScaler: TextScaler.linear(1.25))
                    )
                  )
                ),
                if (isSignMode)
                  SignVideoPlayer(
                    videoPath: videoPaths[3],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MedicalConditionScreen(),
                        ),
                      );
                    },
                  )
                else
                  Padding(
                    padding: EdgeInsetsGeometry.directional(top:10, bottom:20),
                    child: SizedBox(
                      width: double.infinity, // Stretches it to the edges of the screen
                      height: 60, // Makes it a bit taller and easier to tap
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MedicalConditionScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, 
                          foregroundColor: Colors.white, // Text color
                          elevation: 4.0, 
                        ),
                        child: Text('Informações ℹ️', textScaler: TextScaler.linear(1.25))
                      )
                    )
                  ),
                  ListTile(
                    trailing: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      "Terminar Sessão", 
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.end,
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Terminar Sessão"),
                            content: const Text("Tem a certeza que deseja sair da sua conta?"),
                            actions: [
                              // Cancel Button
                              TextButton(
                                onPressed: () => Navigator.pop(context), 
                                child: const Text("Cancelar"),
                              ),
                              // Confirm Button
                              TextButton(
                                onPressed: () async {
                                  // Close the dialog first
                                  Navigator.pop(context); 

                                  try {
                                    await accountViewModel.signOutUser();

                                    if (!context.mounted) return;

                                    // Send user back to Login
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')))
                                    );
                                  }
                                },
                                child: const Text(
                                  "Sair", 
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  )
                // button to be used when uploading medical data to firebase
                //ElevatedButton(
                //  onPressed: () async {
                //    await uploadMedicalConditions();
                //  },
                //  child: const Text("Carregar Dados"),
                //)
              ],
            )
          )
        )
      )
    );
  }
}