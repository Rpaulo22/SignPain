import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sign_pain/model/user_data.dart';
import 'package:sign_pain/theme/app_colors.dart';
import 'package:sign_pain/viewmodel/account_view_model.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key, required this.user});

  final UserData user;

  @override
  State<EditAccountScreen> createState() => _EditAccountScreen(); 
}

class _EditAccountScreen extends State<EditAccountScreen> {

  late TextEditingController nameController;
  late TextEditingController birthDateController;
  late TextEditingController healthIdentifierController;
  late DateTime selectedBirthDate;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.fullName);
    birthDateController = TextEditingController(text: DateFormat("dd/MM/yyyy").format(widget.user.birthDate));
    healthIdentifierController = TextEditingController(text: widget.user.healthIdentifier);
    selectedBirthDate = widget.user.birthDate;
  }

  @override
  void dispose() {
    healthIdentifierController.dispose();
    birthDateController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
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
                          const Text('Cancelar?', style: TextStyle(fontSize: 20, fontWeight: .bold)),
                          const Text('Irá perder quaisquer alterações.', style: TextStyle(fontSize: 18)),
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
        actions: [
          IconButton(
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
                            const Text('Guardar?', style: TextStyle(fontSize: 20, fontWeight: .bold)),
                            const Text('Guardará quaisquer alterações.', style: TextStyle(fontSize: 18)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext);
                                  },
                                  child: Text(
                                    'Cancelar',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontSize: 14,
                                    )
                                  )
                                ),
                                TextButton(
                                  onPressed: () async {
                                    try {
                                      await AccountViewModel().updateUserInfo(
                                        widget.user.userID, 
                                        nameController.text,
                                        healthIdentifierController.text,
                                        selectedBirthDate
                                      );

                                      // update the local userData if successful, which it is if no exception was caught
                                      widget.user.update(
                                        nameController.text,
                                        healthIdentifierController.text,
                                        selectedBirthDate
                                      );

                                      if (!context.mounted) return;

                                      Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
                                    }
                                    catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                      Navigator.pop(dialogContext);
                                    }
                                  },
                                  child: const Text(
                                    'Guardar',
                                    style: TextStyle(
                                      color: Colors.green,
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
            icon: Icon(Icons.save)  
          ),
        ],
        title: Text("Editar conta"),
        centerTitle: true,
        elevation: 4
      ),

      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // tapping outside the text box dismisses the keyboards
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Icon(Icons.account_circle_outlined, size: 100), // if in future there are profile pics, they go here
                SizedBox(height: 10),
                Text(
                  widget.user.email, 
                  style: 
                    TextStyle(
                      color: AppColors.primaryOrange,
                      fontSize: 20,
                      fontWeight: .bold
                  )
                ),
                SizedBox(height: 80),
                TextField(
                  controller: nameController,
                  obscureText: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: 'Nome (Primeiro e último)',
                  ),
                  keyboardType: TextInputType.name,
                  autofillHints: [AutofillHints.name],
                  textInputAction: TextInputAction.next,
                  maxLength: 25,
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: birthDateController,
                  readOnly: true, // stops the keyboard from popping up
                  onTap: () => _selectBirthDate(context), // opens the date picker instead
                  decoration: InputDecoration(
                    labelText: "Data de Nascimento",
                    hintText: "Selecione a sua data",
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor, introduza a sua data de nascimento";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                TextField(
                  controller: healthIdentifierController,
                  obscureText: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: 'Nº de utente SNS',
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next
                ),
                const SizedBox(height: 10),
              ],
            )
          ),
        )
      )
    );
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    
    final DateTime earliestDate = DateTime(now.year - 120); // up to 120 years ago
    final DateTime latestDate = DateTime(now.year - 6);    // at least 6 years old

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1), // Start somewhere logical (e.g. year 2000)
      firstDate: earliestDate,
      lastDate: latestDate,
      
      initialDatePickerMode: DatePickerMode.year, // opens showing years firstly
      initialEntryMode: DatePickerEntryMode.calendarOnly, // Forces a clean calendar screen
      
      helpText: "Selecione a sua data de nascimento",
      cancelText: "Cancelar",
      confirmText: "Confirmar",
    );

    if (picked != null && picked != selectedBirthDate) {
      setState(() {
        selectedBirthDate = picked;
        birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

}