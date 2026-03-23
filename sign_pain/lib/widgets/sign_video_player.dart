import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SignVideoPlayer extends StatefulWidget {
  final String videoPath;
  
  final VoidCallback? onTap; 

  const SignVideoPlayer({
    super.key, 
    required this.videoPath,
    this.onTap, 
  });

  @override
  State<SignVideoPlayer> createState() => _SignVideoPlayerState();
}

class _SignVideoPlayerState extends State<SignVideoPlayer> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoFuture;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(widget.videoPath);
    
    _initializeVideoFuture = _controller.initialize().then((_) {
      _controller.setVolume(0.0);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoFuture, 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        else if (snapshot.connectionState == ConnectionState.done) {
          final controller = _controller;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            // the video being displayed in the screen
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
                if (widget.onTap != null)
                  // button to execute action
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: widget.onTap,
                    icon: Icon(Icons.forward),
                    label: Text('Avançar para página'),
                  ),
              ]
            )
          );
        }
        return Center(child: Text("Erro a carregar vídeo. Por favor tente novamente mais tarde."));
      }
    );
  }
}