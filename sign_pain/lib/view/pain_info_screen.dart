import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_pain/core/providers/sign_language_provider.dart';
import 'package:sign_pain/model/medical_condition_data.dart';
import 'package:sign_pain/viewmodel/conditions_view_model.dart';
import 'package:sign_pain/widgets/medical_condition_widget.dart';

class PainInfoScreen extends StatefulWidget {
  const PainInfoScreen({super.key});

  @override
  State<PainInfoScreen> createState() => _PainInfoScreenState();
}

class _PainInfoScreenState extends State<PainInfoScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConditionsViewModel>().getMedicalConditionsInfo(FirebaseAuth.instance.currentUser!.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isSignMode = Provider.of<SignLanguageProvider>(context).isSignLanguageMode;

    return Scaffold(
      body: ListenableBuilder(
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

            final userMedicalConditions = allMedicalConditions.where((entry) => userMedicalConditionsIDs.contains(entry.id)).toList();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      "ℹ️ Informação sobre a sua dor",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: .bold
                      ),
                    ),
                    SizedBox(height: 20.0),
                    if (isSignMode)
                      SizedBox()
                    else ... [
                      painInfo(),
                      Divider(
                        height: 50,
                        thickness: 2,
                        color: Theme.of(context).colorScheme.primary,
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
                      ),
                      SizedBox(height: 20.0),
                      if (userMedicalConditions.isNotEmpty) ...[
                        medicalConditionsInfo(userMedicalConditions)
                      ]
                    ],
                  ]
                )
              )
            );
          }
        }
      )
    );
  }

  Widget painInfo() {
    return Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.");
  }
  
  Widget medicalConditionsInfo(List<MedicalConditionData> userMedicalConditions) {
    return Column( 
      children: [
        for (var medicalCondition in userMedicalConditions) ... [
          MedicalConditionWidget(medData: medicalCondition),
          SizedBox(height: 20)
        ]
      ]
    );
  }
}