import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_pain/core/providers/sign_language_provider.dart';

class CommunicationScreen extends StatefulWidget {
  const CommunicationScreen({super.key});

  @override
  State<CommunicationScreen> createState() => _CommunicationScreen();
}

class _CommunicationScreen extends State<CommunicationScreen> {

  @override
  Widget build(BuildContext context) {
    bool isSignMode = Provider.of<SignLanguageProvider>(context).isSignLanguageMode;

    return Scaffold(
      appBar: AppBar(
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
      body: Center(child: Text("Communicação por LGP em breve...", style: TextStyle(fontSize: 28, fontWeight: .bold), textAlign: .center,))
    );
  }
}