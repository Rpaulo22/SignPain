import 'package:flutter/material.dart';
import 'package:sign_pain_admin/theme/app_colors.dart';
import 'package:sign_pain_admin/view/pain_descriptors_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key, required this.title});

  final String title;

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryOrange,
        title: Text(widget.title, style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface)),
        centerTitle: true
      ),
      body: Column(
        mainAxisAlignment: .start,
        children: [
          Padding(
            padding: EdgeInsetsGeometry.symmetric(vertical: 50),
            child: SizedBox(
              height: 200,
              child: Image(
                image: const AssetImage('assets/images/signpain.png'),
                fit: .contain,
              )
            )
          ),
          Text("Bem vindo à ferramenta de administração de conteúdo do SignPain", style: TextStyle(fontSize: 28, color: AppColors.primaryOrange)),
          SizedBox(height: 80),
          Row(
            mainAxisAlignment: .spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                child: Padding(
                  padding: EdgeInsetsGeometry.all(16), 
                  child: Text("Condições Médicas", style: TextStyle(fontSize: 20))
                )
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  foregroundColor: Theme.of(context).colorScheme.onTertiary,
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PainDescriptorsScreen(title: "Descritores de dor"),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsetsGeometry.all(16), 
                  child: Text("Descritores de dor", style: TextStyle(fontSize: 20))
                )
              )
            ],
          )
        ],
      )
    );
  }
}