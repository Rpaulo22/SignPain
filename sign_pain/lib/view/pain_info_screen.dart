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

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				backgroundColor: Theme.of(context).colorScheme.inversePrimary,
				title: const Text("SignPain"),
			),
			body: FutureBuilder<List<PainFormData>>(
        future: _painDataFuture, 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) { // pain data has not been loaded yet
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) { // data loading has incurred in some error
            return Center(child: Text("Erro a carregar página: ${snapshot.error}"));
          } else if (snapshot.hasData) { // data has been loaded
            final data = snapshot.data!;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text("Nível de dor: ${data[index].painLevel} | Data: ${data[index].date}"));
              },
            );
          }
          return const Center(child: Text("Não tem quaisquer registos de dor"));
        },
		  )
    );
	}
}