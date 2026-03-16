
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

  @override
  Widget build(BuildContext context) {
    final isSignMode = Provider.of<SignLanguageProvider>(context).isSignLanguageMode;
    return Scaffold(
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
          bodyParts: widget.formData.bodyParts,
          onSelectionUpdated: (p) => setState(() => widget.formData.bodyParts = p),
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
    );
  }
  
}