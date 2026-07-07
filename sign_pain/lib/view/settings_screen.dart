import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_pain/main.dart';
import 'package:sign_pain/viewmodel/conditions_view_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: .max,
              children: [
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
                )
              ],
            )
          )
        )
      )
    );
  }
}