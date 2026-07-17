import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sign_pain/view/main_navigation_screen.dart';
import 'package:sign_pain/view/phone_verification_screen.dart';
import 'package:sign_pain/viewmodel/account_view_model.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final accountViewModel = AccountViewModel();

  late TextEditingController userStringController;
  late TextEditingController passwordController;
  late TextEditingController numberController;
  late TextEditingController nameController;
  late TextEditingController healthIdentifierController;
  late TextEditingController birthDateController;

  DateTime? selectedBirthDate;

  var obscurePassword = true;

  @override
  void initState() {
    super.initState();
    userStringController = TextEditingController();
    passwordController = TextEditingController();
    numberController = TextEditingController();
    nameController = TextEditingController();
    healthIdentifierController = TextEditingController();
    birthDateController = TextEditingController();
  }

  @override
  void dispose() {
    userStringController.dispose();
    passwordController.dispose();
    numberController.dispose();
    nameController.dispose();
    healthIdentifierController.dispose();
    birthDateController.dispose();
    super.dispose();
  }

  @override
	Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: accountViewModel, 
        builder: (BuildContext context, Widget? child) {
          bool isLoading = accountViewModel.isLoading;

          if (accountViewModel.errorMessage != null) {
            // tells flutter to wait to render the snackbar after the rest of elements (to avoid error)
            WidgetsBinding.instance.addPostFrameCallback((_) {
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(accountViewModel.errorMessage!))
              );
              
              // only show error message once
              accountViewModel.errorMessage = null; 
            });
          }

          if (accountViewModel.isSmsCodeSent) { // if user is logging in with phone
            WidgetsBinding.instance.addPostFrameCallback((_) { // makes it not crash
              if (!mounted) return;
              
              accountViewModel.isSmsCodeSent = false; 
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PhoneVerificationScreen(accountViewModel: accountViewModel, firstTime: true)
                )
              );
            });
          }

          return Stack(
            children: [
              IgnorePointer(
                ignoring: isLoading,
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(), // tapping outside the text box dismisses the keyboards
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding( 
                        padding: const EdgeInsetsDirectional.only(start: 20.0, end: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.only(bottom: 50.0),
                              child: FractionallySizedBox(
                                widthFactor: 0.5,
                                child: Image(
                                  image: const AssetImage('assets/images/signpain.png'),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text("Criar nova conta", textScaler: TextScaler.linear(2.0))
                            ),
                            AutofillGroup(
                              child: Column(
                                children: [
                                  TextField(
                                    controller: userStringController,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      labelText: 'E-mail',
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    autofillHints: [AutofillHints.email],
                                    textInputAction: TextInputAction.next
                                  ),
                                  const SizedBox(height: 10),
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
                                    textInputAction: TextInputAction.next
                                  ),
                                  const SizedBox(height: 10),
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
                                  const SizedBox(height: 10),
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
                                  TextFormField(
                                    controller: numberController,

                                    keyboardType: TextInputType.number, 
                                    autofillHints: [AutofillHints.telephoneNumber],
                                    
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    
                                    // validate the string before using it
                                    validator: (value) {
                                      if (value != null && value.isNotEmpty && value.length < 9) {
                                        return 'O número deve ter 9 dígitos';
                                      }
                                      return null;
                                    },
                                    
                                    decoration: InputDecoration(
                                      labelText: "Nº telemóvel (opcional)",
                                      prefixText: "+351 ", // Keeps the country code visible but uneditable
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),

                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: passwordController,
                                    obscureText: obscurePassword,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      labelText: 'Palavra-passe',
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          obscurePassword ? Icons.visibility_off : Icons.visibility
                                        ),
                                        onPressed: () => setState(() {
                                          obscurePassword = !obscurePassword;
                                        })
                                      )
                                    ),
                                    keyboardType: TextInputType.visiblePassword,
                                    autofillHints: [AutofillHints.newPassword],

                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _createUser(),
                                  ),
                                ]
                              )
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  elevation: 4.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => _createUser(), 
                                child: const Text("Criar conta")
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  )
                )
              ),
              if (accountViewModel.isLoading) 
              Container(
                color: Colors.black.withAlpha(128), 
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  )
                )
              )
            ]  
          );
        }
      )
    );
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    
    final DateTime earliestDate = DateTime(now.year - 120); // up to 120 years ago
    final DateTime latestDate = DateTime(now.year - 5);    // at least 5 years old

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

  Future<void> _createUser() async {
    try {
      await accountViewModel.createUser(
        userStringController.text, 
        numberController.text, 
        passwordController.text, 
        nameController.text,
        healthIdentifierController.text,
        selectedBirthDate
      );

      TextInput.finishAutofillContext();

      if (!mounted) return;

      if (numberController.text.isEmpty) { // only goes to home page if the user did not give a phone number (no verification needed)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainNavigationScreen(),
          )
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()))
      );
    }
  }
}