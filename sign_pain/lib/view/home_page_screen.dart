import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_pain/core/providers/sign_language_provider.dart';
import 'package:sign_pain/database_seeder.dart';
import 'package:sign_pain/view/pain_info_screen.dart';
import 'package:sign_pain/view/pain_level_screen.dart';
import 'package:video_player/video_player.dart';

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
  ];

  late List<VideoPlayerController> _controllers;

  late Future<void> _initializeAllVideosFuture;
  @override
	void initState() {
		super.initState();

		// a controller for each path
    _controllers = videoPaths.map((path) => VideoPlayerController.asset(path)).toList();

    _initializeAllVideosFuture = Future.wait(
      _controllers.map((controller) {
        return controller.initialize().then((_) {
          controller.setVolume(0.0); // muted 
        });
      }),
    );
	}

	@override
	void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
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
                  FutureBuilder(
                  future: _initializeAllVideosFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      final controller = _controllers[0];
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        // the video being displayed in the main screen
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [ 
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (controller.value.isPlaying) {
                                    controller.pause();
                                  } else {
                                    controller.play();
                                  }
                                });
                              },
                              child: AspectRatio(
                                aspectRatio: controller.value.aspectRatio,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // bottom Layer: the video
                                    VideoPlayer(controller),

                                    // top Layer: play icon
                                    if (!controller.value.isPlaying)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(12.0),
                                        child: const Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                          size: 50.0,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ]
                        )
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
              if (isSignMode) // sign language content
                FutureBuilder(
                future: _initializeAllVideosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                      final controller = _controllers[2];
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        // the video being displayed in the main screen
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [ 
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (controller.value.isPlaying) {
                                    controller.pause();
                                  } else {
                                    controller.play();
                                  }
                                });
                              },
                              child: AspectRatio(
                                aspectRatio: controller.value.aspectRatio,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // bottom Layer: the video
                                    VideoPlayer(controller),

                                    // top Layer: play icon
                                    if (!controller.value.isPlaying)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(12.0),
                                        child: const Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                          size: 50.0,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PainLevelScreen(),
                                  ),
                                );
                              },
                              icon: Icon(Icons.forward),
                              label: Text('Avançar para página'),
                            ),
                          ]
                        )
                      );
                    } else {
                    return Center(child: CircularProgressIndicator());
                    }
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
                child: Text('Registe aqui o seu diário da dor')
              ),
              // redirects to pain history screen
              if (isSignMode) // sign language content
                FutureBuilder(
                future: _initializeAllVideosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                      final controller = _controllers[1];
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        // the video being displayed in the main screen
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [ 
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (controller.value.isPlaying) {
                                    controller.pause();
                                  } else {
                                    controller.play();
                                  }
                                });
                              },
                              child: AspectRatio(
                                aspectRatio: controller.value.aspectRatio,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // bottom Layer: the video
                                    VideoPlayer(controller),

                                    // top Layer: play icon
                                    if (!controller.value.isPlaying)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(12.0),
                                        child: const Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                          size: 50.0,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PainInfoScreen(),
                                  ),
                                );
                              },
                              icon: Icon(Icons.forward),
                              label: Text('Avançar para página'),
                            ),
                          ]
                        )
                      );
                    } else {
                    return Center(child: CircularProgressIndicator());
                    }
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
                child: Text('Veja aqui o seu histórico de dor')
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