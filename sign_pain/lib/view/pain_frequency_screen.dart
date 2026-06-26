import 'package:flutter/material.dart';
import 'package:sign_pain/model/pain_form_data.dart';
import 'package:sign_pain/view/pain_descriptor_screen.dart';
import 'package:sign_pain/widgets/pain_frequency.dart';
import 'package:sign_pain/widgets/step_indicator.dart';

class PainFrequencyScreen extends StatefulWidget {
  const PainFrequencyScreen({super.key, required this.formData, this.editing = false});

  final PainFormData formData;
  final bool editing; // false: form is new, true: form is an already existing one

  @override
  State<PainFrequencyScreen> createState() => _PainFrequencyScreenState();
}

class _PainFrequencyScreenState extends State<PainFrequencyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: .centerFloat,
			body: Center(
        child: Padding(
          padding: EdgeInsetsGeometry.directional(start: 20, end: 20, top: 10, bottom: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 10,
                child: Center(
                  child:Text(
                    "Qual é a frequência da tua dor?", 
                    textAlign: TextAlign.center, 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                  )
              ),
              SizedBox(height:20),

              Expanded(
                flex: 75,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildOptionCard(
                      title: "Contínua",
                      frequency: PainFrequency.continuous,
                    ),
                    _buildOptionCard(
                      title: "Intermitente",
                      frequency: PainFrequency.intermittent,
                    ),
                    _buildOptionCard(
                      title: "Espontânea",
                      frequency: PainFrequency.spontaneous,
                    ),
                  ],
                )
              ),
              Expanded(
                flex: 15,
                child: SizedBox()
              )
            ])
          ),
        ),
				floatingActionButton: SizedBox(
          width: MediaQuery.of(context).size.width, // Forces full screen width calculation
          child: Padding(
            // padding to match standard screen margins
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Pushes buttons to opposite ends
              children: [
                FloatingActionButton(
                  heroTag: 'btn_back',
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
                      totalSteps: 4,  // of 4 pages total
                    ),
                  )
                ),
                FloatingActionButton(
                  onPressed: () {
                    if (widget.formData.frequency != PainFrequency.none) { // no frequency has been selected
                      Navigator.of(context).push(
                        MaterialPageRoute(
                        builder: (context) => PainDescriptorScreen(formData: widget.formData, editing: widget.editing),
                        ),
                      );
                    }
                    else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Selecione a frequência da dor para continuar.")));
                    }
                  },
                  tooltip: 'Next step',
                  child: Icon(Icons.arrow_forward),
                )
              ]
            )
          ) 
        )
		);
  }

  Widget _buildOptionCard({required String title, required PainFrequency frequency}) {
    final isSelected = widget.formData.frequency == frequency;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final defaultColor = Theme.of(context).colorScheme.onSurface.withAlpha(114);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => widget.formData.frequency = frequency),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor.withAlpha(26) : Colors.transparent,
            border: Border.all(
              color: isSelected ? primaryColor : defaultColor,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FrequencyGraphIcon(
                frequency: frequency,
                color: isSelected ? primaryColor : defaultColor,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? primaryColor : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}