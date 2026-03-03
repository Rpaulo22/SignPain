import 'package:flutter/material.dart';
import 'package:sign_pain/model/pain_form_data.dart';
import 'package:sign_pain/view/pain_descriptor_screen.dart';
import 'package:video_player/video_player.dart';

class PainLevelScreen extends StatefulWidget {
  const PainLevelScreen({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  // final String title;

  @override
  State<PainLevelScreen> createState() => _PainLevelScreenState();
}

class _PainLevelScreenState extends State<PainLevelScreen> {
  	final PainFormData _formData = PainFormData();
  	late VideoPlayerController _controller;
  	late Future<void> _initializeVideoPlayerFuture;

	final painScale = [0,1,2,3,4,5,6,7,8,9,10];

	@override
	void initState() {
		super.initState();

		_controller = VideoPlayerController.asset(
			'assets/videos/video.mp4', 
		);

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

	final snackBar = SnackBar(
		content: Text('Reset pain level!'),
		duration: const Duration(milliseconds: 1500),
		);

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				backgroundColor: Theme.of(context).colorScheme.inversePrimary,
				title: const Text("SignPain"),
			),
			body: SingleChildScrollView(
				child:Center(
					child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						FutureBuilder(
						future: _initializeVideoPlayerFuture,
						builder: (context, snapshot) {
							if (snapshot.connectionState == ConnectionState.done) {
								return Padding(
									padding: const EdgeInsets.all(16.0),
									child: GestureDetector(
									// wraps the video on a clickable item
									onTap: () {
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
													onTap: () => Navigator.pop(context), 
													child: AspectRatio(
													aspectRatio: _controller.value.aspectRatio,
													child: VideoPlayer(_controller),
													),
												),
												],
											),
											);
										},
										);
									},
									// the video being displayed in the main screen
									child: AspectRatio(
										aspectRatio: _controller.value.aspectRatio,
										child: VideoPlayer(_controller),
									),
									));
								} else {
								return Center(child: CircularProgressIndicator());
							}
						},
						),
						Row(
						mainAxisAlignment: MainAxisAlignment.center, 
						children: [
							// IPT image
							Expanded(
								flex: 1,
								child: Image(
									image: AssetImage('assets/images/ipt.png'),
									fit: BoxFit.contain, 
								),
							),
							// Options for pain
							Expanded(
							child: 
								RadioGroup<int>(
								groupValue: _formData.painLevel,
								onChanged: (int? value) {
									setState(() {
									_formData.painLevel = value;
									});
								},
								child:
									Column(
									children: <Widget>[
									for (var i in painScale.reversed.toList())
										ListTile(
										title: Text(i.toString()),
										leading: Radio<int>(value: i))
									],
									)
								)
							),
						],
						),
					],
					),
				)
			),
			floatingActionButton: FloatingActionButton(
				onPressed: () {
					Navigator.push(
						context,
						MaterialPageRoute(
						builder: (context) => PainDescriptorScreen(formData: _formData),
						),
					);
				},
				tooltip: 'pain type',
				child: Icon(Icons.arrow_forward)
			),
		);
	}
}