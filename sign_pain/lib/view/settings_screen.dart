import 'package:firebase_auth/firebase_auth.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConditionsViewModel>().getMedicalConditionsInfo(FirebaseAuth.instance.currentUser!.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
        child: ListenableBuilder(
          listenable: context.read<ConditionsViewModel>(),
          builder: (context, child) {
            final conditionsViewModel = context.read<ConditionsViewModel>();
            if (conditionsViewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            else {
              final userMedicalConditionsIDs = conditionsViewModel.userMedicalConditions;
              final allMedicalConditions = conditionsViewModel.medicalConditions;

              final allMedicalConditionsIDs = allMedicalConditions.map((entry) => entry.id).toList();

              return Center(
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
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        "As suas condições médicas 🩺", 
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                        textAlign: .start,
                      ),
                      Container(
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
                            // list of available conditions
                            for (var condition in allMedicalConditionsIDs)
                              CheckboxListTile(
                                title: Text(allMedicalConditions.firstWhere((entry) => entry.id == condition).name),
                                value: userMedicalConditionsIDs.contains(condition),
                                onChanged: (bool? checked) async {  
                                  try {
                                    if (checked == true) {
                                      await conditionsViewModel.addCondition(condition);
                                    } else {
                                      await conditionsViewModel.removeCondition(condition);
                                    }
                                    if (!context.mounted) return;
                                  } catch(e) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                  }
                                },
                              )
                          ],
                        )
                      )
                    ],
                  )
                ),
              );
            }
          }
        )
      )
    );
  }
}