import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_pain/core/providers/sign_language_provider.dart';
import 'package:sign_pain/model/pain_form_data.dart';
import 'package:sign_pain/view/pain_frequency_screen.dart';
import 'package:sign_pain/widgets/sign_video_player.dart';
import 'package:sign_pain/widgets/step_indicator.dart';

class PainLevelScreen extends StatefulWidget {
  const PainLevelScreen({super.key, required this.formData, this.editing = false});

  final PainFormData formData;
  final bool editing; // false: form is new, true: form is an already existing one
  
  @override
  State<PainLevelScreen> createState() => _PainLevelScreenState();
}

class _PainLevelScreenState extends State<PainLevelScreen> {
	final painScale = [0,1,2,3,4,5,6,7,8,9,10];

  final ValueNotifier<int> scaleNotifier = ValueNotifier<int>(0);

  @override
  void dispose() {
    scaleNotifier.dispose();
    super.dispose();
  }

	final snackBar = SnackBar(
		content: Text('Reset pain level!'),
		duration: const Duration(milliseconds: 1500),
  );

	@override
	Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final isSignMode = Provider.of<SignLanguageProvider>(context).isSignLanguageMode;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final paddingSlider = MediaQuery.widthOf(context)/16;

    double currentSliderValue = widget.formData.painLevel?.toDouble() ?? 0;

		return Scaffold(
      floatingActionButtonLocation: .centerFloat,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            showDialog(
              context: context,
              useRootNavigator: true,
              builder: (BuildContext dialogContext) {
                return Dialog(  
                  child: SizedBox(
                    height: size.height*0.25,
                    child: Padding(
                      padding: EdgeInsetsGeometry.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Text('Cancelar registo da dor?', style: TextStyle(fontSize: 20, fontWeight: .bold)),
                          const Text('Irá perder estes dados.', style: TextStyle(fontSize: 18)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                },
                                child: Text(
                                  'Continuar',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 14
                                  )
                                )
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
                                },
                                child: const Text(
                                  'Sair',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14
                                  )
                                )
                              ),
                            ]
                          ),
                        ],
                      ),
                    )
                  )
                );
              }
            );
          },
          icon: Icon(Icons.close)  
        ),
        title: Text("Registo de dor"),
        centerTitle: true,
        elevation: 4
      ),
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
                child: ValueListenableBuilder<int>(
                  valueListenable: scaleNotifier,
                  builder: (context, scaleMode, _) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FilterChip(
                              label: const Text("Termómetro 🌡️"),
                              selected: scaleMode == 0,
                              onSelected: (_) => scaleNotifier.value = 0,
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: const Text("Caras 🙁"),
                              selected: scaleMode == 1,
                              onSelected: (_) => scaleNotifier.value = 1,
                            ),
                          ],
                        ),
                        SizedBox(height:20),
                        Padding(
                          padding: EdgeInsetsGeometry.symmetric(horizontal: paddingSlider),
                          child: Image(
                            image: AssetImage(
                              isDarkMode
                              ? switch (scaleMode) {
                                0 => 'assets/images/ipt_dark.png',
                                1 => 'assets/images/faces_pain_scale_dark.png',
                                _ => 'assets/images/ipt_dark.png',
                              }
                              : switch (scaleMode) {
                                0 => 'assets/images/ipt.png',
                                1 => 'assets/images/faces_pain_scale.png',
                                _ => 'assets/images/ipt.png',
                              }
                            ),
                            fit: BoxFit.contain, 
                          )
                        ),
                        SizedBox(height: 20),
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
                                  widget.formData.painLevel = currentSliderValue.toInt();
                                });
                              },
                            ),
                          ),
                        )
                      ],
                    );
                  }
                )
              ),
              Expanded(
                flex: 15,
                child: SizedBox()
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: StepIndicator(
                    currentStep: 3, // user is on page 3
                    totalSteps: 6,  // of 6 pages total
                  ),
                )
              ),
              FloatingActionButton(
                onPressed: () {
                  if (widget.formData.painLevel != null) { // no level has been selected
                    Navigator.of(context).push(
                      MaterialPageRoute(
                      builder: (context) => PainFrequencyScreen(formData: widget.formData, editing: widget.editing),
                      ),
                    );
                  }
                  else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Selecione nível de dor atual para continuar.")));
                  }
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