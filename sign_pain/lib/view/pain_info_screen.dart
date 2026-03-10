import 'package:flutter/material.dart';
import 'package:sign_pain/model/pain_form_data.dart';
import 'package:sign_pain/viewmodel/form_view_model.dart';

class PainInfoScreen extends StatefulWidget {
  const PainInfoScreen({super.key});

  @override
  State<PainInfoScreen> createState() => _PainInfoScreenState();
}

class _PainInfoScreenState extends State<PainInfoScreen> {
  final FormViewModel formViewModel = FormViewModel();
  String userID = "user1"; // TODO use actual user ID
  late Future<List<PainFormData>> _painDataFuture;

  @override
  void initState() {
    super.initState();
    _painDataFuture = formViewModel.getUserPainData(userID);
  }

  }
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				backgroundColor: Theme.of(context).colorScheme.inversePrimary,
				title: const Text("SignPain"),
			),
			body: SingleChildScrollView(
        child: Center(
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for ()
            ]
          )
        )
      )
		);
	}
}