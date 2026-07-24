import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sign_pain/main.dart';
import 'package:sign_pain/model/user_data.dart';
import 'package:sign_pain/theme/app_colors.dart';
import 'package:sign_pain/view/edit_account_screen.dart';
import 'package:sign_pain/view/login_screen.dart';
import 'package:sign_pain/viewmodel/account_view_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  late Future<UserData> userDataFuture;
  final accountViewModel = AccountViewModel();

  @override
  void initState() {
    super.initState();
    userDataFuture = accountViewModel.getUserData(FirebaseAuth.instance.currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
        child: FutureBuilder(
          future: userDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              final userData = snapshot.data!;

              return Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: .max,
                    children: [
                      Container(
                        padding: EdgeInsetsGeometry.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.onSurface),
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05), // Very soft modern shadow
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              "A tua conta 🪪", 
                              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)
                            ),
                            SizedBox(height: 15),
                            Row(
                              children: [
                                Icon(Icons.account_circle_outlined, size: 40), // if in future there are profile pics, they go here
                                SizedBox(width: 10),
                                Text(
                                  userData.fullName, 
                                  style: 
                                    TextStyle(
                                      color: AppColors.primaryOrange,
                                      fontSize: 20,
                                      fontWeight: .bold
                                  )
                                )
                              ]
                            ),
                            SizedBox(height: 25),
                             Row(
                              children: [
                                Icon(Icons.email_outlined, size: 30),
                                SizedBox(width: 10),
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(fontSize: 16),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: "E-mail: ",
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurface
                                        )
                                      ),
                                      TextSpan(
                                        text: userData.email,
                                        style: TextStyle(
                                          color: AppColors.primaryOrange
                                        )
                                      )
                                    ]
                                  )
                                )
                              ]
                            ),
                            SizedBox(height: 15),
                             Row(
                              children: [
                                Icon(Icons.cake_outlined, size: 30),
                                SizedBox(width: 10),
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(fontSize: 16),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: "Dia de nascimento: ",
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurface
                                        )
                                      ),
                                      TextSpan(
                                        text: DateFormat('dd/MM/yyyy').format(userData.birthDate),
                                        style: TextStyle(
                                          color: AppColors.primaryOrange
                                        )
                                      )
                                    ]
                                  )
                                )
                              ]
                            ),
                            SizedBox(height: 15),
                            Row(
                              children: [
                                Icon(Icons.health_and_safety_outlined, size: 30),
                                SizedBox(width: 10),
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(fontSize: 16),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: "Nº de utente: ",
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurface
                                        )
                                      ),
                                      TextSpan(
                                        text: userData.healthIdentifier,
                                        style: TextStyle(
                                          color: AppColors.primaryOrange
                                        )
                                      )
                                    ]
                                  )
                                )
                              ]
                            ),
                            SizedBox(height: 20),
                            TextButton(
                              onPressed: () async {
                                await Navigator.of(context, rootNavigator: true).push(
                                  MaterialPageRoute(
                                    builder: (context) => EditAccountScreen(user: userData),
                                  ),
                                );

                                setState(() {
                                  // rebuilds this screen so it reads the updated userData
                                });
                              }, 
                              child: Text(
                                "Editar conta", 
                                style: TextStyle(
                                  color: Colors.green
                                ),
                              )
                            ),

                            SizedBox(height: 10),
                            TextButton(
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      actionsAlignment: MainAxisAlignment.spaceBetween,
                                      title: const Text("Terminar Sessão", textAlign: TextAlign.center),
                                      content: const Text("Tem a certeza que deseja sair da sua conta?", textAlign: TextAlign.center),
                                      actions: [
                                        // Cancel Button
                                        TextButton(
                                          onPressed: () => Navigator.pop(context), 
                                          child: const Text("Cancelar"),
                                        ),
                                        // Confirm Button
                                        TextButton(
                                          onPressed: () async {
                                            // Close the dialog first
                                            Navigator.pop(context); 

                                            try {
                                              await accountViewModel.signOutUser();

                                              if (!context.mounted) return;

                                              // Send user back to Login
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                                              );
                                            } catch (e) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')))
                                              );
                                            }
                                          },
                                          child: const Text(
                                            "Sair", 
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },               
                              child: Text("Terminar sessão", style: TextStyle(color: Colors.redAccent))
                            )
                          ]
                        )
                      ),

                      SizedBox(height: 100),
                      Row(
                        mainAxisAlignment: .center,
                        children: [
                          Text("Modo escuro"),
                          SizedBox(width: 10),
                          Switch(
                            value: Theme.of(context).brightness == Brightness.dark, 
                            onChanged: (bool value) {
                              themeController.toggleTheme(value);
                            }
                          )
                        ]
                      ),

                     
                    ]
                  )
                )
              );
            }
            else {
              return Center(child: Text("Erro de servidor. Tente novamente mais tarde."));
            }
          }
        )
      )
    );
  }
}