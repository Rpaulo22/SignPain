import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_pain/core/providers/sign_language_provider.dart';
import 'package:sign_pain/model/medical_condition_data.dart';
import 'package:sign_pain/viewmodel/conditions_view_model.dart';
import 'package:sign_pain/widgets/medical_condition_widget.dart';

class MedicalConditionScreen extends StatefulWidget {
  const MedicalConditionScreen({super.key});

  @override
  State<MedicalConditionScreen> createState() => _MedicalConditionScreenState();
}

class _MedicalConditionScreenState extends State<MedicalConditionScreen> { 
  late Future<List<MedicalConditionData>> _medDataFuture;
  final ConditionsViewModel _conditionsViewModel = ConditionsViewModel();

  @override
  void initState() {
    super.initState();
    _medDataFuture = _conditionsViewModel.getMedicalConditions();
  }

  @override
  Widget build(BuildContext context) {
    bool isSignMode = Provider.of<SignLanguageProvider>(context).isSignLanguageMode;

    return Scaffold(
      appBar: AppBar(
				backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
			body: Center(
        child: SingleChildScrollView(
          child: FutureBuilder<List<MedicalConditionData>>(
            future: _medDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) { // data still loading
                return const Center(child: CircularProgressIndicator());
              } 
              else if (snapshot.hasError) { // data loading has incurred in some error
                return Center(child: Text("Erro a carregar página: ${snapshot.error}"));
              }
              else if (snapshot.hasData) { // data has been loaded
                final data = snapshot.data!;
                return Column(
                  children: [
                    for (var medCondition in data)
                      MedicalConditionWidget(medData: medCondition)
                  ],
                );
              }
              return const Center(child: Text("Não tem nenhuma condição indicada"));
            }
          )
        ),
      )
    );
  }
}