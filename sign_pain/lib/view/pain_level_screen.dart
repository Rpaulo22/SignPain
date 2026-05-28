import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_pain/core/providers/sign_language_provider.dart';
import 'package:sign_pain/model/pain_form_data.dart';
import 'package:sign_pain/view/pain_body_screen.dart';
import 'package:sign_pain/widgets/sign_video_player.dart';
import 'package:sign_pain/widgets/step_indicator.dart';

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
    final bool isDarkMode = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final paddingSlider = MediaQuery.widthOf(context)/10;

		return Scaffold(
      floatingActionButtonLocation: .centerFloat,
			body: Padding(
        padding: EdgeInsetsGeometry.directional(start: 20, end: 20, top: 10, bottom: 50),
        child: Center(
          child: Column(
            children: [
              Expanded(
                flex: 30,
                child: Center( 
                  child: isSignMode 
                    ? SignVideoPlayer(
                        videoPath: "assets/videos/dor.mp4",
                        doubleTap: true 
                      )
                    : const Text(
                        "Indica o teu nível de dor 0️⃣-🔟", 
                        textScaler: TextScaler.linear(1.6), 
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: .center,
                      ),
                ),
              ),
              Expanded(
                flex: 55,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image(
                      image: AssetImage(
                        isDarkMode 
                        ? 'assets/images/ipt_dark.png'
                        : 'assets/images/ipt.png'
                      ),
                      fit: BoxFit.contain, 
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 30.0, 
                        activeTrackColor: Colors.white,   // Must be white so the gradient shader can paint over it
                        inactiveTrackColor: Colors.white.withAlpha(100), // Gives a dimmed background gradient
                        thumbColor: Colors.white,          
                        
                        // This removes the default overlay halo when tapping so it doesn't look messy
                        overlayColor: Colors.transparent, 

                        valueIndicatorShape: const PaddleSliderValueIndicatorShape(), 

                        valueIndicatorColor: getGradientColor(currentSliderValue),
    
                        valueIndicatorTextStyle: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: ShaderMask(
                        blendMode: BlendMode.srcIn, 
                        
                        
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            colors: [
                              Colors.white70,
                              Colors.red,
                            ],
                          ).createShader(bounds);
                        },
                        
                        child: Slider(
                          value: currentSliderValue,
                          max: 10,
                          divisions: 10,
                          label: currentSliderValue.round().toString(),
                          showValueIndicator: ShowValueIndicator.alwaysVisible,
                          padding: EdgeInsetsDirectional.only(top: 30.0, start: paddingSlider, end: paddingSlider),
                          onChanged: (double value) {
                            setState(() {
                              currentSliderValue = value;
                              _formData.painLevel = currentSliderValue.toInt();
                            });
                          },
                        ),
                      ),
                    )
                  ],
                )
              ),
              Expanded(
                flex: 15,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 64.0),
                  child: StepIndicator(
                    currentStep: 1, // user is on page 1
                    totalSteps: 3,  // of 3 pages total
                  ),
                ),
              )
            ],
          ),
        ),
      ),
			floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width, // Forces full screen width calculation
        child:Padding(
          // padding to match standard screen margins
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Pushes buttons to opposite ends
            children: [
              FloatingActionButton(
                heroTag: 'btn_back', // CRUCIAL: Unique tag prevents animation crashes!
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(Icons.arrow_back),
              ),
              FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                    builder: (context) => PainBodyScreen(formData: _formData),
                    ),
                  );
                },
                tooltip: 'pain type',
                child: const Icon(Icons.arrow_forward)
              ),
            ]
          )
        )
      )
		);
	}
  
   Color? getGradientColor(double value) {
    double normalized = value / 10.0;

    return Color.lerp(Colors.white70, Colors.red, normalized)!;
  }
}