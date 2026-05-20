import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sign_pain/view/create_account_screen.dart';
import 'package:sign_pain/view/home_page_screen.dart';
import 'package:sign_pain/view/main_navigation_screen.dart';
import 'package:sign_pain/viewmodel/account_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController verificationCodeController;
  late TextEditingController phoneNumberController;

  final accountViewModel = AccountViewModel();

  var obscurePassword = true;
  var loginWithPhone = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    verificationCodeController = TextEditingController();
    phoneNumberController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    verificationCodeController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
	Widget build(BuildContext context) {
    bool isLoading = accountViewModel.isLoading;

    return Scaffold(
      body: ListenableBuilder(
        listenable: accountViewModel, 
        builder: (BuildContext context, Widget? child) {

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
          final padding = MediaQuery.widthOf(context)/4;

          return Stack(
            children: [
              IgnorePointer(
                ignoring: isLoading,
                child: !accountViewModel.isSmsCodeSent ?
                  Center(
                    child: SingleChildScrollView(
                      child: Padding( 
                        padding: EdgeInsetsGeometry.directional(start: 20.0, end: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsetsGeometry.directional(bottom: 50.0),
                              child: FractionallySizedBox(
                                widthFactor: 0.5,
                                child: Image(
                                  image: const AssetImage('assets/images/signpain.png'),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsGeometry.all(16.0),
                              child: Text("Entrar na conta", textScaler: TextScaler.linear(2.0),)
                            ),
                            if (!loginWithPhone) ... [
                              AutofillGroup(
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: emailController,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'E-mail',
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      autofillHints: [AutofillHints.email],
                                      textInputAction: TextInputAction.next,
                                    ),
                                    Divider(height: 10.0, color: Colors.transparent,),
                                    TextField(
                                      controller: passwordController,
                                      obscureText: obscurePassword,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
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
                                      autofillHints: [AutofillHints.password],

                                      textInputAction: TextInputAction.done,
                                      onSubmitted: (_) => _login(),
                                    ),
                                  ]
                                )
                              )
                            ]
                            else 
                              AutofillGroup(
                                child: TextFormField(
                                  controller: phoneNumberController,

                                  keyboardType: TextInputType.phone,
                                  autofillHints: [AutofillHints.telephoneNumber],
                                  
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  
                                  // validate the string before using it
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return "Insira um nº de telemóvel";
                                    if (value.isNotEmpty && value.length != 9 && value[0] != '9') return "Insira um nº de telemóvel válido";

                                    return null;
                                  },
                                  
                                  decoration: const InputDecoration(
                                    labelText: "Nº telemóvel",
                                    prefixText: "+351 ", // Keeps the country code visible but uneditable
                                    border: OutlineInputBorder(),
                                  ),

                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _login(),
                                ),
                              ),
                            TextButton(
                              onPressed: () => setState(() {loginWithPhone = !loginWithPhone;}),
                              child: !loginWithPhone ? Text("Entrar com nº telemóvel") : Text("Entrar com e-mail")
                            ),
                            Padding(
                              padding: EdgeInsetsGeometry.all(16.0),
                              child: ElevatedButton(
                                onPressed: () => _login(),
                                child: Text("Entrar")
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateAccountScreen(),
                                  ),
                                );
                              }, 
                              child: Text("Criar conta")
                            )
                          ],
                        ),
                      )
                    )
                  )
                :
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 45,
                          child: FractionallySizedBox(
                            widthFactor: 0.5,
                            child: Image(
                              image: const AssetImage('assets/images/signpain.png'),
                              fit: BoxFit.contain,
                            ),
                          )
                        ),
                        Expanded(
                          flex: 55,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text("📲 Verificação SMS", textScaler: TextScaler.linear(1.8), style: TextStyle(fontWeight: FontWeight.bold)),
                              Padding(
                                padding: EdgeInsetsGeometry.directional(start:padding, end: padding),
                                child: TextFormField(
                                  controller: verificationCodeController,

                                  keyboardType: TextInputType.number, 
                                  
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],

                                  autofillHints: [AutofillHints.oneTimeCode],
                                  textInputAction: TextInputAction.done,
                                  
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

                                  onFieldSubmitted: (_) => _loginSMS(),
                                )
                              ),
                              Padding(
                                padding: EdgeInsetsGeometry.all(30.0),
                                child: ElevatedButton(
                                  onPressed: () => _loginSMS(),
                                  child: Text('Entrar')
                                )
                              )
                            ]
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

  Future<void> _login() async {
    try {
      if (loginWithPhone) { // if phone number is given, login through phone number authentication
        await accountViewModel.loginUserWithPhoneAuth(phoneNumberController.text);
        TextInput.finishAutofillContext();
        if (!mounted) return;
      }
      else { // else, attempt to login with email + password
        await accountViewModel.loginUser(emailController.text, passwordController.text);
        TextInput.finishAutofillContext();
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigationScreen(),
          ),
        );
      }
    }
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()))
      );
    }
  }

  Future<void> _loginSMS() async {
    try {
      await accountViewModel.verifySMSAndLogin(verificationCodeController.text);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainNavigationScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()))
      );
    }
  }
}