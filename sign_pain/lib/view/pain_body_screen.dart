
import 'package:body_part_selector/body_part_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_pain/core/providers/sign_language_provider.dart';
import 'package:sign_pain/model/pain_form_data.dart';
import 'package:sign_pain/view/pain_descriptor_screen.dart';

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
          title: Text("SignPain"),
          actions: [
            IconButton(
              onPressed: () {Provider.of<SignLanguageProvider>(context).toggleMode();}, 
              icon: isSignMode ? Icon(Icons.sign_language) : Icon(Icons.sign_language_outlined)
            )
          ],
        ),
        body: SafeArea(
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