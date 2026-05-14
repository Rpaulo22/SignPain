import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_pain/core/providers/sign_language_provider.dart';
import 'package:sign_pain/model/pain_form_data.dart';
import 'package:sign_pain/view/pain_body_screen.dart';
import 'package:sign_pain/widgets/sign_video_player.dart';

class PainLevelScreen extends StatefulWidget {
  const PainLevelScreen({super.key});

  @override
  State<PainLevelScreen> createState() => _PainLevelScreenState();
}

class _PainLevelScreenState extends State<PainLevelScreen> {
  final PainFormData _formData = PainFormData();

	final painScale = [0,1,2,3,4,5,6,7,8,9,10];

  double currentSliderValue = 0;

	final snackBar = SnackBar(
		content: Text('Reset pain level!'),
		duration: const Duration(milliseconds: 1500),
		);

	@override
	Widget build(BuildContext context) {
    final isSignMode = Provider.of<SignLanguageProvider>(context).isSignLanguageMode;
    final paddingSlider = MediaQuery.widthOf(context)/10;

		return Scaffold(
			appBar: AppBar(
        centerTitle: true,
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
			body: Center(
        child: Column(
          children: [
            Expanded(
              flex: 40,
              child: Center( 
                child: isSignMode 
                  ? SignVideoPlayer(
                      videoPath: "assets/videos/dor.mp4",
                      doubleTap: true 
                    )
                  : const Text(
                      "Indica o teu nível de dor 0️⃣-🔟", 
                      textScaler: TextScaler.linear(1.8), 
                      style: TextStyle(fontWeight: FontWeight.bold)
                    ),
              ),
            ),
            Expanded(
              flex: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image(
                    image: AssetImage('assets/images/ipt.png'),
                    fit: BoxFit.contain, 
                  ),

                  Slider(
                    value: currentSliderValue,
                    max: 10,
                    divisions: 10,
                    label: currentSliderValue.round().toString(),
                    showValueIndicator: ShowValueIndicator.alwaysVisible,
                    padding: EdgeInsetsGeometry.directional(top: 30.0, start: paddingSlider, end: paddingSlider),
                    onChanged: (double value) {
                      setState(() {
                        currentSliderValue = value;
                        _formData.painLevel = currentSliderValue.toInt();
                      });
                    }
                  )
                ],
              )
            )
          ],
        ),
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