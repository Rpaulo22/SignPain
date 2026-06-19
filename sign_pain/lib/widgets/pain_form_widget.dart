import 'package:body_part_selector/body_part_selector.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sign_pain/model/pain_form_data.dart';
import 'package:sign_pain/viewmodel/form_view_model.dart';
import 'package:sign_pain/widgets/pain_frequency.dart';

class PainFormWidget extends StatelessWidget {
  final PainFormData data;

  const PainFormWidget({
    super.key,
    required this.data
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDetailsDialog(context), 
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: getPainColor(data.painLevel!)),
          color: getPainColor(data.painLevel!).withAlpha(150),
          borderRadius: BorderRadius.circular(12)
        ),
        padding: EdgeInsetsDirectional.only(top: 15, bottom: 15, start: 10, end: 10),
        child: Row(
          mainAxisSize: .max,
          crossAxisAlignment: .center,
          children: [
            Text(
              "Dor ${data.painLevel!}/10", 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 18,
                color: Theme.of(context).colorScheme.onPrimary
              ),
              textAlign: .center,
            ),
            VerticalDivider(
              color: Theme.of(context).colorScheme.secondary,
              width: 10,
              thickness: 5,
            ),
            Expanded(
              child: Text(
                data.bodyParts.isNotEmpty 
                  ? BodyPartsMapper.listToPortuguese(data.bodyParts).join(", ") 
                  : "Dor não situada", 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onPrimary
                ),
                textAlign: .center,
              )
            )
          ]
        )
      )
    );
  }

  // dialog function
  void _showDetailsDialog(BuildContext context) {
    final dialogWidth = MediaQuery.widthOf(context)*0.8;
    final dialogHeight = MediaQuery.heightOf(context)*0.8;

    final BodyParts front = BodyPartsMapper.frontFromList(data.bodyParts);
    final BodyParts back = BodyPartsMapper.backFromList(data.bodyParts);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Registo de dor"),
          content: SizedBox(
            height: dialogHeight,
            width: dialogWidth,
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 12),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: .spaceEvenly,
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(data.date!),
                      style: TextStyle(
                        color: Colors.grey
                      )
                    ),

                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: dialogHeight/2),
                      child: Row(
                        children: [
                          Expanded(
                            child: BodyPartSelector(
                              bodyParts: front,
                              onSelectionUpdated: (parts) {},
                              side: .front
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: BodyPartSelector(
                              bodyParts: back, 
                              onSelectionUpdated: (parts) {},
                              side: .back
                            ),
                          )
                        ]
                      ),
                    ),
                    
                    Row(
                      children: [
                        Expanded(
                          flex: 60,
                          child: Column(
                            crossAxisAlignment: .start,
                            children: [
                              Text(
                                "${data.painLevel}/10",
                                style: TextStyle(
                                  color: getPainColor(data.painLevel!),
                                  fontWeight: .bold,
                                  fontSize: 18
                                )
                              ),
                              SizedBox(height: 10),
                              Text(
                                data.descriptors.join(", "),
                                style: TextStyle(
                                  fontSize: 14
                                ),
                              ),
                            ]
                          )
                        ),
                        Expanded(
                          flex: 40,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withAlpha(26),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FrequencyGraphIcon(
                                  frequency: data.frequency,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  painFrequencyToStringPT(data.frequency),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        )
                      ]
                    ),

                    SizedBox(
                      height:40
                    ),

                    Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {}, // implement edit entry function
                          child: Text(
                            "Editar",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: .bold
                            )
                          )
                        ),

                        TextButton(
                          onPressed: () async {
                            try {
                              // global, single instance of FormViewModel
                              final formViewModel = context.read<FormViewModel>();
                              
                              await formViewModel.deletePainForm(data.docID!);
                              
                              if (!dialogContext.mounted) return;

                              Navigator.pop(dialogContext);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Registo apagado com sucesso!")),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Erro ao apagar: $e")),
                              );
                            }
                          }, // implement delete function
                          child: Text(
                            "Eliminar",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: .bold
                            )
                          )
                        )
                      ]
                    )
                  ]
                )
              )
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Use the dialogContext to close ONLY the dialog
                Navigator.pop(dialogContext); 
              },
              child: const Text("Fechar"),
            ),
          ],
        );
      },
    );
  }

  Color getPainColor(int painLevel) {
    if (painLevel < 3) return Colors.green;
    if (painLevel < 6) return Colors.orange;
    if (painLevel < 9) return Colors.redAccent;
    return Colors.red;
  }
}