import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_pain/model/pain_form_data.dart';
import 'package:sign_pain/viewmodel/form_view_model.dart';
import 'package:sign_pain/widgets/pain_frequency.dart';
import 'package:sign_pain/widgets/step_indicator.dart';

class PainMedicationScreen extends StatefulWidget {

	const PainMedicationScreen({super.key, required this.formData, this.editing = false});

  final PainFormData formData;
  final bool editing; // false: form is new, true: form is an already existing one

	@override
  State<PainMedicationScreen> createState() => _PainMedicationScreenState();
}

class _PainMedicationScreenState extends State<PainMedicationScreen> {

  late final TextEditingController notesController;

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    notesController = TextEditingController(text: widget.formData.medicationNotes);
  }
	
	@override
	Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
			body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // tapping outside the text box dismisses the keyboards
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsetsGeometry.directional(start: 20, end: 20, top: 10, bottom: 50),
              child: Column(
                mainAxisAlignment: .center,
                crossAxisAlignment: .stretch,
                children: [
                  Text(
                    "Tomou medicação? 💊", 
                    textAlign: TextAlign.center, 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)
                  ),
                  SizedBox(height:20),
                  Row (
                    mainAxisAlignment: .spaceEvenly,
                    children: [
                      _buildOptionCard(
                        title: "Não",
                        tookMedication: false
                      ),
                      _buildOptionCard(
                        title: "Sim",
                        tookMedication: true
                      ),
                    ],
                  ),

                  if (widget.formData.tookMedication == true) ... [
                    const SizedBox(height: 32),

                    // Text field to let users take notes on their medication (e.g. which medicine, quantity, interval, etc.)
                    TextField(
                      controller: notesController,
                      
                      keyboardType: TextInputType.multiline,
                      minLines: 3, 
                      maxLines: null, 
                      maxLength: 40,
                      textCapitalization: TextCapitalization.sentences, // auto-capitalizes the first letter of sentences
                      
                      decoration: InputDecoration(
                        hintText: "Notas (medicamento, dose, etc.)",
                        alignLabelWithHint: true, // Keeps the hint text at the top-left instead of middle
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary, 
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100),
                      ),
                      
                      onChanged: (value) {
                        widget.formData.medicationNotes = value;
                      },
                    ),
                  ],
                  
                  const SizedBox(height: 120),
                ]
              )
            )
          )
        )
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
                    currentStep: 6, // user is on page 6
                    totalSteps: 6,  // of 6 pages total
                  ),
                )
              ),
              FloatingActionButton(
                onPressed: () {
                  if (widget.formData.isComplete) {
                    showDialog(
                      context: context,
                      barrierDismissible: false, 
                      useRootNavigator: true,
                      builder: (BuildContext dialogContext) {
                        // return the confirm dialog widget
                        return confirmDialog(dialogContext);
                      }
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Por favor complete o formulário!")));
                  }
                },
                heroTag: 'btn_save',
                tooltip: 'Save form',
                child: Icon(Icons.save),
              )
            ]
          )
        ) 
      )
		);
	}

  // Pop-up used for confirming a form submission
  Dialog confirmDialog(BuildContext dialogContext){
    // size is info of screen size, used so that pop-up is consistent across devices
    final size = MediaQuery.of(context).size;

    return Dialog(
      insetPadding: const EdgeInsets.all(10),   
      child: SizedBox(
        width: size.width*0.8,
        height: size.height*0.4,
        child: Padding(
          padding: EdgeInsetsGeometry.directional(start:20, end:20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const Text('Gravar?', textScaler: TextScaler.linear(2)),
              Text("Nível: ${widget.formData.painLevel}/10"),
              Text("Descrição: ${widget.formData.descriptors.join(", ")}"),
              Text("Parte(s) do corpo: ${BodyPartsMapper.listToPortuguese(widget.formData.bodyParts).join(", ")}"),
              Text("Frequência: ${painFrequencyToStringPT(widget.formData.frequency)}"),
              Text("Medicação: ${widget.formData.tookMedication! ? "Sim" : "Não"}"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text(
                      'Não',
                      textScaler: TextScaler.linear(1.5),
                      style: TextStyle(
                        color: Colors.red
                      )
                    )
                  ),
            
                  TextButton(
                    onPressed: () async {
                      if (widget.formData.isComplete) {
                        final formViewModel = context.read<FormViewModel>();
                        if (widget.editing) {
                          try {
                            await formViewModel.updatePainForm(widget.formData);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(snackBar("Registo guardado com sucesso!"));
                            
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(snackBar(e.toString()));
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                          } 
                        }
                        else {
                          bool successful = await formViewModel.savePainForm(widget.formData);
                          if (!mounted) return;
                          if (successful) { // use viewmodel to save pain form
                            ScaffoldMessenger.of(context).showSnackBar(snackBar("Registo guardado com sucesso!"));
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          }
                          else {
                            ScaffoldMessenger.of(context).showSnackBar(snackBar("Erro a gravar. Por favor tente novamente."));
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                          }
                        }
                      }
                      else {
                        ScaffoldMessenger.of(context).showSnackBar(snackBar("Formulário incompleto. Por favor indique o seu nível de dor e descreva a sua dor."));
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
                      }
                    },
                    child: const Text(
                      'Sim',
                      textScaler: TextScaler.linear(1.5),
                      style: TextStyle(
                        color: Colors.green
                      )
                    )
                  ),
                ]
              )
            ],
          ),
        )
      )
    );
  }

  SnackBar snackBar(String message) { 
    return SnackBar(
      content: Text(message),
      duration: const Duration(milliseconds: 5000),
    );
  }

  Widget _buildOptionCard({required String title, required bool tookMedication}) {
    final isSelected = widget.formData.tookMedication == tookMedication;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final defaultColor = Theme.of(context).colorScheme.onSurface.withAlpha(114);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => widget.formData.tookMedication = tookMedication),
        child: Container(
          width: 80,
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
              Icon(
                tookMedication ? Icons.check_box_outlined : Icons.disabled_by_default_outlined,
                color: tookMedication ? Colors.green : Colors.red,
                size: 40
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
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