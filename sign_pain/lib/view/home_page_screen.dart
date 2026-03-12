import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_pain/core/providers/sign_language_provider.dart';
import 'package:sign_pain/view/pain_info_screen.dart';
import 'package:sign_pain/view/pain_level_screen.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {

  @override
  Widget build(BuildContext context) {
    final isSignMode = Provider.of<SignLanguageProvider>(context).isSignLanguageMode;

    return Scaffold(
      appBar: AppBar(
				backgroundColor: Theme.of(context).colorScheme.inversePrimary,
				title: const Text("SignPain", textAlign: TextAlign.center),
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
			body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FractionallySizedBox(
              widthFactor: 0.5,
              child: Image(
                image: const AssetImage('assets/images/signpain.png'),
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: EdgeInsetsGeometry.all(12),
              child: Text(
                'Bem vindo ao SignPain, a aplicação de comunicação de dor para a Comunidade Surda.',
                textAlign: TextAlign.center,
                textScaler: TextScaler.linear(2),
                )
            ),
            // redirects to pain form submission
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PainLevelScreen(),
                  ),
                );
              },
              child: Text('Registe aqui o seu diário da dor')
            ),
            // redirects to pain history screen
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PainInfoScreen(),
                  ),
                );
              },
              child: Text('Veja aqui o seu histórico de dor')
            )
          ],
        )
      )
    );
  }
}