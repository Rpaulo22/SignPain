
import 'package:body_part_selector/body_part_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_pain/core/providers/sign_language_provider.dart';
import 'package:sign_pain/model/pain_form_data.dart';
import 'package:sign_pain/view/pain_descriptor_screen.dart';
import 'package:sign_pain/widgets/step_indicator.dart';

class PainBodyScreen extends StatefulWidget {
  const PainBodyScreen({super.key, required this.formData});

  final PainFormData formData;

  @override
  State<PainBodyScreen> createState() => _PainBodyScreenState();
}

class _PainBodyScreenState extends State<PainBodyScreen> {
  BodyParts _selectedParts = BodyParts();

  @override
  void initState() {
    super.initState();

    if (widget.formData.bodyParts.isNotEmpty) {
      _selectedParts = BodyPartsMapper.fromList(widget.formData.bodyParts);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSignMode = Provider.of<SignLanguageProvider>(context).isSignLanguageMode;
    
    return PopScope(
      // Tell Flutter not to pop the screen automatically
      canPop: false, 
      
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;

        // saves body parts even if user backs out to previous screen
        List<String> partsList = _selectedParts.toList();
        widget.formData.bodyParts = partsList; // adds body parts to form data (in list format)

        Navigator.pop(context, true);
      },

      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("SignPain", style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),

          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            }, 
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary)
          ),

          actions: [
            IconButton(
              onPressed: () {
                // toggle between sign language and text
                Provider.of<SignLanguageProvider>(context, listen: false).toggleMode();
              },
              icon: 
                isSignMode 
                ? Icon(Icons.sign_language, color: Theme.of(context).colorScheme.onPrimary) 
                : Icon(Icons.sign_language_outlined, color: Theme.of(context).colorScheme.onPrimary)
            )
          ],
        ),
        body: Padding(
          padding: EdgeInsetsGeometry.directional(start: 20, end: 20, top: 10, bottom: 50),
          child: Column(
            children: [
              Expanded(
                flex: 10,
                child: Center(
                  child: Text(
                    "Onde sente a dor? 🧍", 
                    textScaler: TextScaler.linear(1.8),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ),
              ),
              Expanded(
                flex: 75,
                child:SafeArea(
                  child: BodyPartSelectorTurnable(
                    bodyParts: _selectedParts,
                    onSelectionUpdated: (p) => setState(() => _selectedParts = p),
                    labelData: const RotationStageLabelData(
                      front: 'Frente',
                      left: 'Esquerda',
                      right: 'Direita',
                      back: 'Trás',
                    ),
                  ),
                )
              ),
              Expanded(
                flex: 15,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 64.0),
                  child: StepIndicator(
                    currentStep: 2, // user is on page 2
                    totalSteps: 3,  // of 3 pages total
                  ),
                ),
              )
            ]
          )
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            List<String> partsList = _selectedParts.toList();
            widget.formData.bodyParts = partsList; // adds body parts to form data (in list format)
            Navigator.push(
              context,
              MaterialPageRoute(
              builder: (context) => PainDescriptorScreen(formData: widget.formData),
              ),
            );
          },
          tooltip: 'pain type',
          child: Icon(Icons.arrow_forward)
        ),
      )
    );
  }
  
}