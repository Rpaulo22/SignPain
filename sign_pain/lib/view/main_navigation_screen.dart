import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_pain/core/providers/sign_language_provider.dart';
import 'package:sign_pain/view/home_page_screen.dart';
import 'package:sign_pain/view/communication_screen.dart';
import 'package:sign_pain/view/login_screen.dart';
import 'package:sign_pain/view/medical_condition_screen.dart';
import 'package:sign_pain/viewmodel/account_view_model.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int selectedIndex = 0;

  // list of screens that you navigate between
  final List<Widget> _pages = [
    HomePageScreen(),
    CommunicationScreen(),
    MedicalConditionScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSignMode = Provider.of<SignLanguageProvider>(context).isSignLanguageMode;

    final accountViewModel = AccountViewModel();

    return Scaffold(
      appBar: AppBar(
        // logout option on top
        leading: IconButton(
          onPressed: () {
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
          icon: Icon(Icons.logout)),
        centerTitle: true,
				title: const Text("SignPain"),
        actions: [
          IconButton(
            onPressed: () {
              // toggle between sign language and text
              Provider.of<SignLanguageProvider>(context, listen: false).toggleMode();
            },
            icon: isSignMode ? Icon(Icons.sign_language) : Icon(Icons.sign_language_outlined)
          )
        ],
			),
      // body displays the class from the list based on the index
      body: IndexedStack(
        index: selectedIndex,
        children: _pages
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withAlpha(100),
        backgroundColor: const Color.fromARGB(255, 233, 129, 64),
        showUnselectedLabels: true,
        elevation: 4,
        type: BottomNavigationBarType.shifting,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
            backgroundColor: Color.fromARGB(255, 233, 129, 64),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.interpreter_mode),
            label: 'Comunicar',
            backgroundColor: Color.fromARGB(255, 233, 129, 64),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_information),
            label: 'Info. Médica',
            backgroundColor: Color.fromARGB(255, 233, 129, 64),
          ),
        ],
      ),
    );
  }
}