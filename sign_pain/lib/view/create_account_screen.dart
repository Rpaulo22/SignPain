import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sign_pain/view/home_page_screen.dart';
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
  late TextEditingController verificationCodeController;

  var obscurePassword = true;

  @override
  void initState() {
    super.initState();
    userStringController = TextEditingController();
    passwordController = TextEditingController();
    numberController = TextEditingController();
    nameController = TextEditingController();
    verificationCodeController = TextEditingController();
  }

  @override
  void dispose() {
    userStringController.dispose();
    passwordController.dispose();
    numberController.dispose();
    nameController.dispose();
    verificationCodeController.dispose();
    super.dispose();
  }

  @override
	Widget build(BuildContext context) {
    bool isLoading = accountViewModel.isLoading;

    return Scaffold(
      body: ListenableBuilder(
        listenable: accountViewModel, 
        builder: (BuildContext context, Widget? child) {
          final padding = MediaQuery.widthOf(context)/4;

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

          return Stack(
            children: [
              IgnorePointer(
                ignoring: isLoading,
                child: !accountViewModel.isSmsCodeSent ? Center(
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
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'E-mail',
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: [AutofillHints.email],
                                  textInputAction: TextInputAction.next
                                ),
                                const Divider(height: 10.0, color: Colors.transparent),
                                TextField(
                                  controller: nameController,
                                  obscureText: false,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Nome (Primeiro e último)',
                                  ),
                                  keyboardType: TextInputType.name,
                                  autofillHints: [AutofillHints.name],
                                  textInputAction: TextInputAction.next
                                ),
                                const Divider(height: 10.0, color: Colors.transparent),
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
                                  
                                  decoration: const InputDecoration(
                                    labelText: "Nº telemóvel (opcional)",
                                    prefixText: "+351 ", // Keeps the country code visible but uneditable
                                    border: OutlineInputBorder(),
                                  ),

                                  textInputAction: TextInputAction.next,
                                ),
                                const Divider(height: 10.0, color: Colors.transparent),
                                TextField(
                                  controller: passwordController,
                                  obscureText: obscurePassword,
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
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
                              onPressed: () => _createUser(), 
                              child: const Text("Criar conta")
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                )
                :
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("📲 Verificação SMS", textScaler: TextScaler.linear(1.8), style: TextStyle(fontWeight: FontWeight.bold)),
                      Divider(height: padding, color: Colors.transparent),
                      Padding(
                        padding: EdgeInsetsGeometry.directional(start:padding, end: padding),
                        child: AutofillGroup(
                          child: TextFormField(
                            controller: verificationCodeController,

                            keyboardType: TextInputType.number,

                            autofillHints: [AutofillHints.oneTimeCode],
                            
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            
                            // validate the string before using it
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira um número';
                              }
                              if (value.length != 6) {
                                return 'Número tem 6 dígitos';
                              }
                              return null; // Input is valid
                            },
                            
                            decoration: const InputDecoration(
                              labelText: "Código SMS",
                              border: UnderlineInputBorder(),
                            ),

                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _verifySMS(),
                          )
                        )
                      ),
                      Padding(
                        padding: EdgeInsetsGeometry.all(30.0),
                        child: ElevatedButton(
                          onPressed: () => _verifySMS(),
                          child: Text('Verificar')
                        )
                      )
                    ]
                  )
                )
              ),
              if (accountViewModel.isLoading) 
              Container(
                color: Colors.black.withOpacity(0.5), 
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

  Future<void> _createUser() async {
    try {
      await accountViewModel.createUser(
        userStringController.text, 
        numberController.text, 
        passwordController.text, 
        nameController.text
      );

      TextInput.finishAutofillContext();

      if (!mounted) return;

      if (numberController.text.isEmpty) { // only goes to home page if the user did not give a phone number (no verification needed)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePageScreen(),
          )
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()))
      );
    }
  }

  Future<void> _verifySMS() async {
    try {
      await accountViewModel.verifySMSCode(verificationCodeController.text);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePageScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()))
      );
    }
  }
}