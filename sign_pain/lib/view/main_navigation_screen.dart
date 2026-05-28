import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_pain/core/providers/sign_language_provider.dart';
import 'package:sign_pain/view/home_page_screen.dart';
import 'package:sign_pain/view/communication_screen.dart';
import 'package:sign_pain/view/login_screen.dart';
import 'package:sign_pain/view/medical_condition_screen.dart';
import 'package:sign_pain/view/settings_screen.dart';
import 'package:sign_pain/viewmodel/account_view_model.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    pageController.jumpToPage(index);
  }

  // allows to have a nested navigator (home page can go through different screens and keep its context (appbar and navbar))
  final GlobalKey<NavigatorState> homeNavigatorKey = GlobalKey<NavigatorState>();

  final PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final isSignMode = Provider.of<SignLanguageProvider>(context).isSignLanguageMode;

    final accountViewModel = AccountViewModel();

    // list of screens that you navigate between
    final List<Widget> pages = [
      KeepAliveTabWrapper(
        child: Navigator(
          key: homeNavigatorKey,
          onGenerateRoute: (routeSettings) {
            return MaterialPageRoute(
              builder: (context) => const HomePageScreen(),
            );
          },
        ),
      ),
      CommunicationScreen(),
      MedicalConditionScreen(),
      SettingsScreen()
    ];

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
				title: Text("SignPain"),
        actions: [
          IconButton(
            onPressed: () {
              // toggle between sign language and text
              Provider.of<SignLanguageProvider>(context, listen: false).toggleMode();
            },
            icon: 
            isSignMode 
            ? Icon(Icons.sign_language) 
            : Icon(Icons.sign_language_outlined)
          )
        ],

        elevation: 4,
			),
      
      body: PopScope(
        canPop: false, 
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          
          // only intercept the back button if we are currently on the Home Page (index 0)
          if (selectedIndex == 0) {
            final NavigatorState? homeNav = homeNavigatorKey.currentState;
            if (homeNav != null && homeNav.canPop()) {
              homeNav.pop(); // close sub-screen inside Home Page
              return;
            }
          }
        },
        // body displays the class from the list based on the index
        child: PageView(
          controller: pageController,
          physics: const NeverScrollableScrollPhysics(), // Disable swipe gestures so it feels like a normal tab bar
          children: pages
        )
      ),
      
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          // removes tap feedback visuals
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Theme.of(context).appBarTheme.foregroundColor,
          unselectedItemColor: Theme.of(context).appBarTheme.foregroundColor!.withAlpha(90),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          showUnselectedLabels: true,
          elevation: 4,
          type: BottomNavigationBarType.fixed,
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
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Definições',
              backgroundColor: Color.fromARGB(255, 233, 129, 64),
            ),
          ],
        ),
      )
    );
  }
}

class KeepAliveTabWrapper extends StatefulWidget {
  final Widget child;
  const KeepAliveTabWrapper({super.key, required this.child});

  @override
  State<KeepAliveTabWrapper> createState() => _KeepAliveTabWrapperState();
}

// AutomaticKeepAliveClientMixin is the magic ingredient
class _KeepAliveTabWrapperState extends State<KeepAliveTabWrapper> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Forces Flutter to preserve this widget's exact state

  @override
  Widget build(BuildContext context) {
    super.build(context); // Mandatory line when using this mixin
    return widget.child;
  }
}