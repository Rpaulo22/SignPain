import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_pain/core/providers/sign_language_provider.dart';
import 'package:sign_pain/database_seeder.dart';
import 'package:sign_pain/view/medical_condition_screen.dart';
import 'package:sign_pain/view/pain_info_screen.dart';
import 'package:sign_pain/view/pain_level_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    final isSignMode = Provider.of<SignLanguageProvider>(context).isSignLanguageMode;

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
                : Text(
                  '👋\nBem vindo ao SignPain, a aplicação de comunicação de dor para a Comunidade Surda.',
                  textAlign: TextAlign.center,
                  textScaler: TextScaler.linear(2),
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
              else TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PainLevelScreen(),
                    ),
                  );
                },
                child: Text('Registe aqui o seu diário da dor 📋')
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
              else TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PainInfoScreen(),
                    ),
                  );
                },
                child: Text('Veja aqui o seu histórico de dor 📈')
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
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MedicalConditionScreen(),
                      ),
                    );
                  },
                  child: Text('Informação sobre a sua condição ℹ️🩺')
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
    );
  }
}