
import 'package:body_part_selector/body_part_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_pain/core/providers/sign_language_provider.dart';
import 'package:sign_pain/model/pain_form_data.dart';
import 'package:sign_pain/view/pain_level_screen.dart';
import 'package:sign_pain/widgets/step_indicator.dart';

class PainBodyScreen extends StatefulWidget {
  const PainBodyScreen({super.key, required this.formData});

  final PainFormData formData;

  @override
  State<PainBodyScreen> createState() => _PainBodyScreenState();
}

class _PainBodyScreenState extends State<PainBodyScreen> {
  BodyParts _selectedPartsFront = BodyParts();
  BodyParts _selectedPartsBack = BodyParts();

  @override
  void initState() {
    super.initState();

    if (widget.formData.bodyParts.isNotEmpty) {
      _selectedPartsFront = BodyPartsMapper.fromList(widget.formData.bodyParts);
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
        List<String> partsList = BodyPartsMapper.toListBackAndFront(_selectedPartsBack, _selectedPartsFront);
        widget.formData.bodyParts = partsList; // adds body parts to form data (in list format)

        Navigator.pop(context, true);
      },

      child: Scaffold(
        floatingActionButtonLocation: .centerFloat,
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
                child: Row(
                  mainAxisSize: .max,
                  children: [
                    Expanded(
                      child: SafeArea(
                        child: Column(
                          children: [
                            Expanded(
                              child: BodyPartSelector(
                                bodyParts: _selectedPartsFront,
                                onSelectionUpdated: _onFrontUpdated,
                                side: BodySide.front
                              )
                            ),
                            Text("Frente", style: TextStyle(fontWeight: .bold))
                          ]
                        )
                      )
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: SafeArea(
                        child: Column(
                          children: [
                            Expanded(
                              child: BodyPartSelector(
                                bodyParts: _selectedPartsBack,
                                onSelectionUpdated: _onBackUpdated,
                                side: BodySide.back
                              )
                            ),
                            Text("Trás", style: TextStyle(fontWeight: .bold))
                          ]
                        )
                      )
                    )
                  ]
                )
              ),
              Expanded(
                flex: 15,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 64.0),
                  child: StepIndicator(
                    currentStep: 1, // user is on page 1
                    totalSteps: 4,  // of 4 pages total
                  ),
                ),
              )
            ]
          )
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
                    List<String> partsList = BodyPartsMapper.toListBackAndFront(_selectedPartsBack, _selectedPartsFront);
                    if (partsList.isNotEmpty) {
                      widget.formData.bodyParts = partsList; // adds body parts to form data (in list format)
                      Navigator.of(context).push(
                        MaterialPageRoute(
                        builder: (context) => PainLevelScreen(formData: widget.formData),
                        ),
                      );
                    }
                    else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Selecione pelo menos uma parte do corpo para continuar.")));
                    }
                  },
                  tooltip: 'pain type',
                  child: const Icon(Icons.arrow_forward)
                ),
              ]
            )
          )
        )
      )
    );
  }
  
  // Handles clicks on the front body
  void _onFrontUpdated(BodyParts updatedFront) {
    setState(() {
      // Accept all changes for the front
      _selectedPartsFront = updatedFront;

      // Mirror only the shared limbs to the back model
      _selectedPartsBack = _selectedPartsBack.copyWith(
        head: updatedFront.head,
        neck: updatedFront.neck,
        leftShoulder: updatedFront.leftShoulder,
        rightShoulder: updatedFront.rightShoulder,
        leftUpperArm: updatedFront.leftUpperArm,
        rightUpperArm: updatedFront.rightUpperArm,
        leftElbow: updatedFront.leftElbow,
        rightElbow: updatedFront.rightElbow,
        leftLowerArm: updatedFront.leftLowerArm,
        rightLowerArm: updatedFront.rightLowerArm,
        leftHand: updatedFront.leftHand,
        rightHand: updatedFront.rightHand,
        leftUpperLeg: updatedFront.leftUpperLeg,
        rightUpperLeg: updatedFront.rightUpperLeg,
        leftKnee: updatedFront.leftKnee,
        rightKnee: updatedFront.rightKnee,
        leftLowerLeg: updatedFront.leftLowerLeg,
        rightLowerLeg: updatedFront.rightLowerLeg,
        leftFoot: updatedFront.leftFoot,
        rightFoot: updatedFront.rightFoot
      );
    });
  }

  // Handles clicks on the back body
  void _onBackUpdated(BodyParts updatedBack) {
    setState(() {
      // Accept all changes for the back
      _selectedPartsBack = updatedBack;

      // Mirror only the shared limbs back to the front model
      _selectedPartsFront = _selectedPartsFront.copyWith(
        head: updatedBack.head,
        neck: updatedBack.neck,
        leftShoulder: updatedBack.leftShoulder,
        rightShoulder: updatedBack.rightShoulder,
        leftUpperArm: updatedBack.leftUpperArm,
        rightUpperArm: updatedBack.rightUpperArm,
        leftElbow: updatedBack.leftElbow,
        rightElbow: updatedBack.rightElbow,
        leftLowerArm: updatedBack.leftLowerArm,
        rightLowerArm: updatedBack.rightLowerArm,
        leftHand: updatedBack.leftHand,
        rightHand: updatedBack.rightHand,
        leftUpperLeg: updatedBack.leftUpperLeg,
        rightUpperLeg: updatedBack.rightUpperLeg,
        leftKnee: updatedBack.leftKnee,
        rightKnee: updatedBack.rightKnee,
        leftLowerLeg: updatedBack.leftLowerLeg,
        rightLowerLeg: updatedBack.rightLowerLeg,
        leftFoot: updatedBack.leftFoot,
        rightFoot: updatedBack.rightFoot
      );
    });
  }
}