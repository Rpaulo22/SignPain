import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_pain/core/providers/sign_language_provider.dart';
import 'package:sign_pain/view/pain_info_screen.dart';
import 'package:sign_pain/view/pain_level_screen.dart';
import 'package:video_player/video_player.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
	void initState() {
		super.initState();
    
    // start the video playback

		_controller = VideoPlayerController.asset(
			'assets/videos/ola.mp4', 
		);
    _controller.setVolume(0.0);
    
		_initializeVideoPlayerFuture = _controller.initialize();
		// ensure the video loops
		_controller.setLooping(true);
		_controller.play();
	}

	@override
	void dispose() {
		_controller.dispose();

		super.dispose();
	}

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
			body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FractionallySizedBox(
              widthFactor: 0.5,
              child: Image(
                image: const AssetImage('assets/images/signpain.png'),
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: EdgeInsetsGeometry.all(12),
              child: isSignMode ?
                FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      // the video being displayed in the main screen
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                      );
                    } else {
                    return Center(child: CircularProgressIndicator());
                    }
                  },
                )
              : Text(
                'Bem vindo ao SignPain, a aplicação de comunicação de dor para a Comunidade Surda.',
                textAlign: TextAlign.center,
                textScaler: TextScaler.linear(2),
                )
            ),
            // redirects to pain form submission
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PainLevelScreen(),
                  ),
                );
              },
              child: Text('Registe aqui o seu diário da dor')
            ),
            // redirects to pain history screen
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PainInfoScreen(),
                  ),
                );
              },
              child: Text('Veja aqui o seu histórico de dor')
            )
          ],
        )
      )
    );
  }
}