import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_pain/core/providers/sign_language_provider.dart';
import 'package:sign_pain/model/pain_form_data.dart';
import 'package:sign_pain/view/home_page_screen.dart';
import 'package:sign_pain/viewmodel/form_view_model.dart';

class PainDescriptorScreen extends StatefulWidget {

	const PainDescriptorScreen({super.key, required this.formData});

  final PainFormData formData;

	@override
  State<PainDescriptorScreen> createState() => _PainDescriptorScreenState();
}

class _PainDescriptorScreenState extends State<PainDescriptorScreen> {
	final painDescriptors = ["Latente", "Ardor", "Formigueiro", "Perfurante", "Frio", "Choque"];
  final FormViewModel formViewModel = FormViewModel();

	@override
	Widget build(BuildContext context) {
    final isSignMode = Provider.of<SignLanguageProvider>(context).isSignLanguageMode;

		return Scaffold(
			appBar: AppBar(
				backgroundColor: Theme.of(context).colorScheme.inversePrimary,
				title: const Text("SignPain"),
        actions: [
          IconButton(
            onPressed: () {
              // toggle between sign language and text
              Provider.of<SignLanguageProvider>(context, listen: false).toggleMode();
            },
            icon: isSignMode ? Icon(Icons.sign_language) : Icon(Icons.sign_language_outlined)
          )
        ],
			),
			body: Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Text("Qual destes melhor caracteriza a tua dor?", textScaler: TextScaler.linear(2), textAlign: TextAlign.center,),
						Padding(padding: EdgeInsetsGeometry.all(20)),
						Column(
							children: [
							for (var i in painDescriptors)
								CheckboxListTile(
									title: Text(i.toString()),
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
					]),
				),
				floatingActionButton: FloatingActionButton(
					onPressed: () {
						showDialog(
              context: context,
              barrierDismissible: false, 
              builder: (BuildContext context) {
                // return the confirm dialog widget
                return confirmDialog();
              }
            );
					},
					tooltip: 'pain type',
					child: Icon(Icons.save),
				)
		);
	}

  // Pop-up used for confirming a form submission
  Dialog confirmDialog() {
    // size is info of screen size, used so that pop-up is consistent across devices
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(10),   
      child: SizedBox(
        width: size.width*0.8,
        height: size.height*0.3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const Text('Gravar?', textScaler: TextScaler.linear(2)),
            Padding(
              padding: EdgeInsetsGeometry.directional(start:20, end:20),
              child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
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
                        if (successful) { // use viewmodel to save pain form
                          ScaffoldMessenger.of(context).showSnackBar(snackBar("Registo guardado com sucesso!"));
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const HomePageScreen()),
                            (Route<dynamic> route) => false, // false condition clears the entire stack
                          );
                        }
                        else {
                          ScaffoldMessenger.of(context).showSnackBar(snackBar("Erro a gravar. Por favor tente novamente."));
                          Navigator.pop(context);
                        }
                      }
                      else {
                        ScaffoldMessenger.of(context).showSnackBar(snackBar("Formulário incompleto. Por favor indique o seu nível de dor e descreva a sua dor."));
                        Navigator.pop(context);
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
    );
  }

  SnackBar snackBar(String message) { 
    return SnackBar(
      content: Text(message),
      duration: const Duration(milliseconds: 5000),
    );
  }
}