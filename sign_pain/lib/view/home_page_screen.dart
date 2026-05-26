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
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface
                            ),
                            children: <TextSpan>[
                              TextSpan(text:'👋\nOlá ',
                                style: TextStyle(fontSize: 32)
                              ),
                              TextSpan(text: '${snapshot.data}',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32)
                              ),
                              TextSpan(text:'\n\nBem vindo ao SignPain!',
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
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(12))
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
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                        foregroundColor: Theme.of(context).colorScheme.onTertiary,
                        elevation: 4.0, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(12))
                      ),
                      child: Text('Histórico 📈', textScaler: TextScaler.linear(1.25))
                    )
                  )
                ),
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