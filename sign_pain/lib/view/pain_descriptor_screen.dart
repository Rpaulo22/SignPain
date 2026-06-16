import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_pain/core/providers/sign_language_provider.dart';
import 'package:sign_pain/model/pain_form_data.dart';
import 'package:sign_pain/view/main_navigation_screen.dart';
import 'package:sign_pain/viewmodel/form_view_model.dart';
import 'package:sign_pain/widgets/pain_frequency.dart';
import 'package:sign_pain/widgets/step_indicator.dart';

class PainDescriptorScreen extends StatefulWidget {

	const PainDescriptorScreen({super.key, required this.formData});

  final PainFormData formData;

	@override
  State<PainDescriptorScreen> createState() => _PainDescriptorScreenState();
}

class _PainDescriptorScreenState extends State<PainDescriptorScreen> {
	final painDescriptors = ["Moedeira", "Tensão", "Latejante", "Ardor", "Formigueiro", "Perfurante", "Frio", "Choque", "Localizada", "Mecânica", "Difusa", "Irradiada", "Aguda", "Cansaço", "Rigidez", "Peso"];
  final FormViewModel formViewModel = FormViewModel();

	@override
	Widget build(BuildContext context) {
    final isSignMode = Provider.of<SignLanguageProvider>(context).isSignLanguageMode;

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
                child: Text(
                "Qual destas palavras melhor caracteriza a tua dor?", 
                textAlign: TextAlign.center, 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              ),
              SizedBox(height:20),

              Expanded(
                flex: 75,
                child:SingleChildScrollView(
                  child: Column(
                    children: [
                    for (var i in painDescriptors)
                      CheckboxListTile(
                        title: Text("${i.toString()} ${descriptorIconMap[i.toString()] ?? "🩺"}"),
                        value: widget.formData.descriptors.contains(i),
                        onChanged: (bool? checked) {
                          setState(() {
                          if (checked == true) {
                            widget.formData.descriptors.add(i);
                          } else {
                            widget.formData.descriptors.remove(i);
                          }
                          });
                        },
                      )
                    ],
                  )
                )
              ),
              Expanded(
                flex: 15,
                child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 64.0),
                child: StepIndicator(
                  currentStep: 4, // user is on page 4
                  totalSteps: 4,  // of 4 pages total
                ),
              ),
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
                FloatingActionButton(
                  onPressed: () {
                    if (widget.formData.isComplete) {
                      showDialog(
                        context: context,
                        barrierDismissible: false, 
                        useRootNavigator: true,
                        builder: (BuildContext context) {
                          // return the confirm dialog widget
                          return confirmDialog();
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
  Dialog confirmDialog() {
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
              Padding(
                padding: EdgeInsetsGeometry.directional(start:20, end:20),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: const Text(
                        'Não',
                        textScaler: TextScaler.linear(1.5),
                        style: TextStyle(
                          color: Colors.red
                        )
                      )
                    ),
                    const Divider(
                      thickness: 5,
                      indent: 25,
                      endIndent: 25,
                      color: Colors.transparent,
                    ),
                    TextButton(
                      onPressed: () async {
                        if (widget.formData.isComplete) {
                          bool successful = await formViewModel.saveDailyForm(widget.formData);
                          if (!mounted) return;
                          if (successful) { // use viewmodel to save pain form
                            ScaffoldMessenger.of(context).showSnackBar(snackBar("Registo guardado com sucesso!"));
                            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                              (Route<dynamic> route) => false, // false condition clears the entire stack
                            );
                          }
                          else {
                            ScaffoldMessenger.of(context).showSnackBar(snackBar("Erro a gravar. Por favor tente novamente."));
                            Navigator.of(context, rootNavigator: true).pop();
                          }
                        }
                        else {
                          ScaffoldMessenger.of(context).showSnackBar(snackBar("Formulário incompleto. Por favor indique o seu nível de dor e descreva a sua dor."));
                          Navigator.of(context, rootNavigator: true).pop();
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
                ),
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