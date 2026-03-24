import 'package:body_part_selector/body_part_selector.dart';
import 'package:flutter/material.dart';
import 'package:sign_pain/model/medical_condition_data.dart';
import 'package:sign_pain/model/pain_form_data.dart';

class MedicalConditionWidget extends StatefulWidget{
  const MedicalConditionWidget({super.key, required this.medData});

  final MedicalConditionData medData;

  @override
  State<MedicalConditionWidget> createState() => _MedicalConditionWidgetState();
}

class _MedicalConditionWidgetState extends State<MedicalConditionWidget> {

  @override 
  Widget build(BuildContext context) {
    final medData = widget.medData;

    BodyParts parts = BodyPartsMapper.fromList(medData.bodyPartsAffected); // BodyParts object which holds the body parts affected by the condition for visualization purposes

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.primaryContainer)
      ),
      padding: EdgeInsetsDirectional.only(top: 15, bottom: 15, start: 10, end: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(medData.name, textScaler: TextScaler.linear(1.2), style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("Descrição: ${medData.description}"),
          Text("Causas: ${medData.causes.join(", ")}"),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 12.0, right: 8.0), // Align text with the first chip
                child: Text("Dor:", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: Wrap(
                  spacing: 8.0,    // Horizontal gap between tags
                  runSpacing: 8.0, // Vertical gap between lines
                  children: medData.commonDescriptors.map((cd) {
                    return Chip(
                      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                      label: Text(cd, style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    );
                  }).toList(),
                )
              )
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 12.0, right: 8.0), // Align text with the first chip
                child: Text("Raramente:", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: Wrap(
                  spacing: 8.0,    // Horizontal gap between tags
                  runSpacing: 8.0, // Vertical gap between lines
                  children: medData.uncommonDescriptors.map((cd) {
                    return Chip(
                      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                      label: Text(cd, style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    );
                  }).toList(),
                )
              )
            ],
          ),
          Text("Tratamento: ${medData.treatment}"),
          SizedBox(
            height: 400,
            child: BodyPartSelector(
              bodyParts: parts, 
              onSelectionUpdated: (parts) {},
              side: defineSide(medData.side)
            ),
          ),
        ],
      )
    );
  }

  BodySide defineSide(String side) {
    return switch (side) {
      'left' => BodySide.left,
      'right' => BodySide.right,
      'front' => BodySide.front,
      'back' => BodySide.back,
      _ => BodySide.front 
    };
  }
}