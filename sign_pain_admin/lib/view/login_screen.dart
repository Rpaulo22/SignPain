import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:sign_pain_admin/view/landing_screen.dart';
import 'package:sign_pain_admin/viewmodel/account_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  late TextEditingController emailController;
  late TextEditingController passwordController;

  final accountViewModel = AccountViewModel();

  var obscurePassword = true;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    passwordController.dispose();
    emailController.dispose();
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

          return Stack(
            children: [
              IgnorePointer(
                ignoring: isLoading,
                child: Center(
                  child: Padding( 
                    padding: EdgeInsetsGeometry.directional(start: 20.0, end: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: .stretch,
                      children: [
                        Center(
                          child: Padding(
                            padding: EdgeInsetsGeometry.directional(bottom: 50.0),
                            child: FractionallySizedBox(
                              widthFactor: 0.1,
                              child: Image(
                                image: const AssetImage('assets/images/signpain.png'),
                                fit: BoxFit.contain,
                              )
                            )
                          )
                        ),
                        Center(
                          child: AutoSizeText(
                            "Bem-vindo(a) à pagina admin do SignPain",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: .bold
                            ),
                            maxLines: 1,                  
                            minFontSize: 12,              
                            overflow: TextOverflow.ellipsis
                          ),
                        ),
                        SizedBox(height:80),
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
                              SizedBox(height:20),
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

                              Padding(
                                padding: EdgeInsetsGeometry.directional(top:16.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                    elevation: 4.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  
                                  onPressed: () => _login(),
                                  child: Text("Continuar")
                                ),
                              ),
                            ]
                          )
                        ),
                      ],
                    ),
                  )
                )
              ),
              if (accountViewModel.isLoading)
                Container(
                  color: Colors.black.withAlpha(123), 
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
      await accountViewModel.loginAdmin(emailController.text, passwordController.text);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LandingScreen(title: "SignPain Admin"),
        ),
      );
    }
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()))
      );
    }
  }
}