import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/* Widget which displays a sign language video and defines its behaviour (ability to double tap and optional action button below video) */
class SignVideoPlayer extends StatefulWidget {
  final String videoPath;
  
  final VoidCallback? onTap; // defines action done by clicking on button next to video
  final bool doubleTap; // double tap makes video able to pop up (for better readibility of movements if needed)

  const SignVideoPlayer({
    super.key, 
    required this.videoPath,
    this.onTap, 
    this.doubleTap = false
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
                  onDoubleTap: () {
                    if (widget.doubleTap) {
                      // ensure the video loops
                      _controller.setLooping(true);
                      _controller.play();

                      // dialog = popup
                      showDialog(
                        context: context,
                        // barrierDismissible: true means tapping the darkened background closes the popup
                        barrierDismissible: true, 
                        builder: (BuildContext context) {
                          // return a Dialog widget
                          return Dialog(
                            backgroundColor: Colors.transparent, // hides the default white dialog box
                            insetPadding: const EdgeInsets.all(10), // leaves a gap at the edges
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                              // video
                                GestureDetector(
                                  // tap the video itself to close it
                                  onTap: () {
                                    _controller.pause();
                                    _controller.setLooping(false);
                                    Navigator.pop(context);
                                  }, 
                                  child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: VideoPlayer(_controller),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      );
                    }
                  },
                  child: ClipRRect( // forces video to also have rounded corners
                    borderRadius: BorderRadius.vertical(top: const Radius.circular(12), bottom: (widget.onTap == null) ? const Radius.circular(12) : Radius.zero),
                    child: AspectRatio(
                      aspectRatio: 1.0,
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
                    )
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