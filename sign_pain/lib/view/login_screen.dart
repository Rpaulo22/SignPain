import 'package:flutter/material.dart';
import 'package:sign_pain/view/create_account_screen.dart';
import 'package:sign_pain/view/home_page_screen.dart';
import 'package:sign_pain/viewmodel/account_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  late TextEditingController userStringController;
  late TextEditingController passwordController;

  final accountViewModel = AccountViewModel();

  var obscurePassword = true;

  @override
  void initState() {
    super.initState();
    userStringController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    userStringController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
	Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
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
                TextField(
                  controller: userStringController,
                  obscureText: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'E-mail',
                  ),
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

                ),
                Padding(
                  padding: EdgeInsetsGeometry.all(16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await accountViewModel.loginUser(userStringController.text, passwordController.text);

                        if (!context.mounted) return;

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePageScreen(),
                          ),
                        );
                      }
                      catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString()))
                        );
                      }
                    }, 
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
    );
  }
}