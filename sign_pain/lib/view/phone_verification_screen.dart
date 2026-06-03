import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sign_pain/view/main_navigation_screen.dart';
import 'package:sign_pain/viewmodel/account_view_model.dart';

class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({super.key, required this.accountViewModel, required this.firstTime});

  final AccountViewModel accountViewModel;
  final bool firstTime;

  @override
  State<PhoneVerificationScreen> createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _formKey = GlobalKey<FormState>(); 
  late final TextEditingController verificationCodeController;

  @override
  void initState() {
    super.initState();
    verificationCodeController = TextEditingController();
  }

  @override
  void dispose() {
    verificationCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.widthOf(context) / 4;

    return Scaffold(
      body: ListenableBuilder(
        listenable: widget.accountViewModel, 
        builder: (BuildContext context, Widget? child) {
          
          bool isLoading = widget.accountViewModel.isLoading;

          return Center(
            child: IgnorePointer(
              ignoring: isLoading,
              child: Form( 
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 45,
                      child: FractionallySizedBox(
                        widthFactor: 0.5,
                        child: const Image(
                          image: AssetImage('assets/images/signpain.png'),
                          fit: BoxFit.contain,
                        ),
                      )
                    ),
                    Expanded(
                      flex: 55,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            "📲 Verificação SMS", 
                            textScaler: TextScaler.linear(1.8), 
                            style: TextStyle(fontWeight: FontWeight.bold)
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: padding),
                            child: TextFormField(
                              controller: verificationCodeController,
                              keyboardType: TextInputType.number, 
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              autofillHints: const [AutofillHints.oneTimeCode],
                              textInputAction: TextInputAction.done,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira um número';
                                }
                                if (value.length != 6) {
                                  return 'Número tem 6 dígitos';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: "Código SMS",
                                border: UnderlineInputBorder(),
                              ),
                              onFieldSubmitted: (_) => _loginSMS(),
                            )
                          ),
                          Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: isLoading 
                              ? const CircularProgressIndicator() // 3. Beautiful UI feedback instead of freezing!
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                    elevation: 4.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () => _loginSMS(),
                                  child: const Text('Entrar'),
                                ),
                          )
                        ],
                      )
                    )
                  ],
                ),
              ),
            ),
          );
        }
      )
    );
  }

  Future<void> _loginSMS() async {
    if (_formKey.currentState?.validate() != true) return;

    try {
      if (widget.firstTime) {
        await widget.accountViewModel.verifySMSCode(verificationCodeController.text);
      }
      else {
        await widget.accountViewModel.verifySMSAndLogin(verificationCodeController.text);
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainNavigationScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()))
      );
    }
  }
}