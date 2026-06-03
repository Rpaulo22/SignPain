import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:sign_pain/view/create_account_screen.dart';
import 'package:sign_pain/view/main_navigation_screen.dart';
import 'package:sign_pain/viewmodel/account_view_model.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key, required this.accountViewModel, required this.email});

  final AccountViewModel accountViewModel;
  final String email;

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {

  late TextEditingController passwordController;
  var obscurePassword = true;

  @override
  void initState() {
    super.initState();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: ListenableBuilder(
        listenable: widget.accountViewModel, 
        builder: (BuildContext context, Widget? child) {
          
          bool isLoading = widget.accountViewModel.isLoading;

          return Stack(
            children: [
              IgnorePointer(
                ignoring: isLoading,
                child: Center(
                  child: SingleChildScrollView(
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
                                widthFactor: 0.4,
                                child: Image(
                                  image: const AssetImage('assets/images/signpain.png'),
                                  fit: BoxFit.contain,
                                )
                              )
                            )
                          ),
                          Center(
                            child: AutoSizeText(
                              "Bem-vindo ao SignPain",
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
                            child: TextField(
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
                              child: Text("Entrar")
                            ),
                          ),
                          SizedBox(height:25),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.tertiary,
                              foregroundColor: Theme.of(context).colorScheme.onTertiary,
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed:() { 
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateAccountScreen(),
                                ),
                              );
                            },
                            child: Text("Criar nova conta")
                          ), 
                        ],
                      ),
                    )
                  )
                )
              ),
              if (widget.accountViewModel.isLoading)
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
  
  void _login() async {
    try {
      await widget.accountViewModel.loginUser(widget.email, passwordController.text); 
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainNavigationScreen(),
        ),
      );
    }
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}