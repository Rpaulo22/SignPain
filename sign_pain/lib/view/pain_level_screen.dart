import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_pain/core/providers/sign_language_provider.dart';
import 'package:sign_pain/model/pain_form_data.dart';
import 'package:sign_pain/view/pain_body_screen.dart';
import 'package:sign_pain/widgets/sign_video_player.dart';
import 'package:video_player/video_player.dart';

class PainLevelScreen extends StatefulWidget {
  const PainLevelScreen({super.key});

  @override
  State<PainLevelScreen> createState() => _PainLevelScreenState();
}

class _PainLevelScreenState extends State<PainLevelScreen> {
  final PainFormData _formData = PainFormData(); // TODO change to actual userID

	final painScale = [0,1,2,3,4,5,6,7,8,9,10];

	final snackBar = SnackBar(
		content: Text('Reset pain level!'),
		duration: const Duration(milliseconds: 1500),
		);

	@override
	Widget build(BuildContext context) {
    final isSignMode = Provider.of<SignLanguageProvider>(context).isSignLanguageMode;

		return Scaffold(
			appBar: AppBar(
				backgroundColor: Theme.of(context).colorScheme.inversePrimary,
				title: const Text("SignPain"),
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
            if (isSignMode) // sign language content
              SignVideoPlayer(
                videoPath: "assets/videos/dor.mp4",
                doubleTap: true // double tap makes video able to pop up (for better readibility of movements if needed)
              )
            else
              Text("Indica o teu nível de dor", textScaler: TextScaler.linear(2)),
						Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage('assets/images/ipt.png'),
                  fit: BoxFit.contain, 
                ),

                // Options for pain
                RadioGroup<int>(
                  groupValue: _formData.painLevel,
                  onChanged: (int? value) {
                    setState(() {
                    _formData.painLevel = value;
                    });
                  },
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    
                    children: <Widget>[
                      for (var i in painScale)
                        Row(
                          mainAxisSize: MainAxisSize.min, 
                          children: [
                            Radio<int>(value: i),
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(i.toString(), style: const TextStyle(fontSize: 16)),
                            ),
                          ],
                        )
                    ],
                  )
                )
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
						builder: (context) => PainBodyScreen(formData: _formData),
						),
					);
				},
				tooltip: 'pain type',
				child: Icon(Icons.arrow_forward)
			),
		);
	}
}