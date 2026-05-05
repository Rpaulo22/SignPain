import 'package:flutter/material.dart';
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

  var obscurePassword = true;

  @override
  void initState() {
    super.initState();
    userStringController = TextEditingController();
    passwordController = TextEditingController();
    numberController = TextEditingController();
    nameController = TextEditingController();
  }

  @override
  void dispose() {
    userStringController.dispose();
    passwordController.dispose();
    numberController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
	Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
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
                TextField(
                  controller: userStringController,
                  obscureText: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'E-mail',
                  ),
                ),
                const Divider(height: 10.0, color: Colors.transparent),
                TextField(
                  controller: nameController,
                  obscureText: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nome (Primeiro e último)',
                  ),
                ),
                const Divider(height: 10.0, color: Colors.transparent),
                TextField(
                  controller: numberController,
                  obscureText: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nº telemóvel 🇵🇹',
                  ),
                  maxLength: 9, 
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
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await accountViewModel.createUser(
                          userStringController.text, 
                          numberController.text, 
                          passwordController.text, 
                          nameController.text
                        );

                        if (!context.mounted) return;

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
                    }, 
                    child: const Text("Criar conta")
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}