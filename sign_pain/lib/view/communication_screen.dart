import 'package:flutter/material.dart';

class CommunicationScreen extends StatefulWidget {
  const CommunicationScreen({super.key});

  @override
  State<CommunicationScreen> createState() => _CommunicationScreen();
}

class _CommunicationScreen extends State<CommunicationScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Communicação por LGP em breve...", style: TextStyle(fontSize: 28, fontWeight: .bold), textAlign: .center,))
    );
  }
}