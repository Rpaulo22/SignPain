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
      padding: EdgeInsetsDirectional.symmetric(vertical: 10, horizontal: 15),
      child: Column(
        mainAxisAlignment: .center,
        crossAxisAlignment: .start,
        children: [
          Text(
            medData.name, 
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18
            ),
            textAlign: .start,
          ),

          Text(
            medData.description,
            textAlign: .start,
            style: TextStyle(
              color: Colors.grey, fontWeight: FontWeight.w600
            )
          ),
          SizedBox(height:25),

          RichText(
            text: TextSpan(
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface
              ),
              children: <TextSpan>[
                TextSpan(
                  text: "Causas\n",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: .bold
                  )
                ),
                TextSpan(
                  text: medData.causes.join(", "),
                  style: TextStyle(
                    fontSize: 16
                  )
                )
              ]
            )
          ),
          SizedBox(height: 15),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 12.0, right: 8.0), // Align text with the first chip
                child: Text("Dor", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: Wrap(
                  spacing: 8.0,    // Horizontal gap between tags
                  runSpacing: 8.0, // Vertical gap between lines
                  children: medData.commonDescriptors.map((cd) {
                    return Chip(
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      label: Text("$cd ${descriptorIconMap[cd]}", style: TextStyle(color: Theme.of(context).colorScheme.onTertiary)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    );
                  }).toList(),
                )
              )
            ],
          ),
          SizedBox(height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 12.0, right: 8.0), // Align text with the first chip
                child: Text("Raramente", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: Wrap(
                  spacing: 8.0,    // Horizontal gap between tags
                  runSpacing: 8.0, // Vertical gap between lines
                  children: medData.uncommonDescriptors.map((cd) {
                    return Chip(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      label: Text("$cd ${descriptorIconMap[cd]}", style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    );
                  }).toList(),
                )
              )
            ],
          ),
          SizedBox(height: 15),
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface
              ),
              children: <TextSpan>[
                TextSpan(
                  text: "Tratamento\n",
                  style: TextStyle(
                    fontWeight: .bold,
                    fontSize: 18
                  )
                ),
                TextSpan(
                  text: medData.treatment,
                  style: TextStyle(
                    fontSize: 15
                  )
                )
              ]
            )
          ),
          SizedBox(height: 20),

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

  static const Map<String, String> descriptorIconMap = {
    "Ardor": "🔥",
    "Formigueiro": "🐜",
    "Frio": "❄️",
    "Mecânica": "⚙️",
    "Peso": "🏋️",
    "Cansaço": "🥱",
    "Choque": "⚡",
    "Moedeira": "🔨",  
    "Tensão": "🗜️",        
    "Latejante": "💓",         
    "Perfurante": "🗡️",    
    "Localizada": "🎯",    
    "Difusa": "🌫️",        
    "Irradiada": "🔆",     
    "Aguda": "🪡",          
    "Intermitente": "🌊",   
    "Rigidez": "🧱",
  };
}