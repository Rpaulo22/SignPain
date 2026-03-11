import 'package:flutter/material.dart';
import 'package:sign_pain/model/pain_form_data.dart';
import 'package:sign_pain/viewmodel/form_view_model.dart';
import 'package:intl/intl.dart';

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
            return Column(
              children: <Widget>[
                for (var entry in data) 
                  painFormWidget(entry),
                  const Divider(
                    thickness: 5,
                    indent: 25,
                    endIndent: 25,
                    color: Colors.transparent,
                  )
              ]
            );
          }
          return const Center(child: Text("Não tem quaisquer registos de dor"));
        },
		  )
    );
	}

  // individual pain form entry
  Widget painFormWidget(PainFormData data) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.primaryContainer)
      ),
      padding: EdgeInsetsDirectional.only(top: 15, bottom: 15, start: 10, end: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Dor registada: ${data.painLevel}/10", textScaler: TextScaler.linear(1.2)),
              Text("Data: ${DateFormat('dd-MM-yyy | kk:mm').format(data.date!)}", textScaler: TextScaler.linear(1.2), style: TextStyle(fontWeight: FontWeight.bold))
            ]
          ),
          const Divider(
            thickness: 5,
            indent: 10,
            endIndent: 10,
            color: Colors.transparent,
          ),
          RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
              style: const TextStyle(
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(text: "Descrição da dor: "),
                TextSpan(text: data.descriptors.isNotEmpty ? data.descriptors.join(", ") : "Nenhuma", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            )
          )
        ],
      )
    );
  }
}