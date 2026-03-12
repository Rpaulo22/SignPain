import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
				backgroundColor: Theme.of(context).colorScheme.inversePrimary,
				title: const Text("SignPain", textAlign: TextAlign.center),
			),
			body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
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