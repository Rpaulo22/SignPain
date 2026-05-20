import 'package:flutter/material.dart';
import 'package:sign_pain/view/home_page_screen.dart';
import 'package:sign_pain/view/communication_screen.dart';
import 'package:sign_pain/view/medical_condition_screen.dart';

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
    return Scaffold(

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