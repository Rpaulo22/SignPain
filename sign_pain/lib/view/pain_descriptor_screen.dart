import 'package:flutter/material.dart';
import 'package:sign_pain/model/pain_form_data.dart';

class PainDescriptorScreen extends StatefulWidget {

	const PainDescriptorScreen({super.key, required this.formData});

  final PainFormData formData;

	@override
  State<PainDescriptorScreen> createState() => _PainDescriptorScreenState();
}

class _PainDescriptorScreenState extends State<PainDescriptorScreen> {
	final painDescriptors = ["Latente", "Ardor", "Formigueiro", "Perfurante", "Frio", "Choque"];

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
			appBar: AppBar(
				backgroundColor: Theme.of(context).colorScheme.inversePrimary,
				title: const Text("SignPain"),
			),
			body: Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Text("Qual destes melhor caracteriza a tua dor?", textScaler: TextScaler.linear(2), textAlign: TextAlign.center,),
						Padding(padding: EdgeInsetsGeometry.all(20)),
						Column(
							children: [
							for (var i in painDescriptors)
								CheckboxListTile(
									title: Text(i.toString()),
									value: widget.formData.descriptors.contains(i),
									onChanged: (bool? checked) {
										setState(() {
										if (checked == true) {
											widget.formData.descriptors.add(i);
										} else {
											widget.formData.descriptors.remove(i);
										}
										});
									},
								)
							],
						)
					]),
				),
				floatingActionButton: FloatingActionButton(
					onPressed: () {
						Navigator.pop(context);
					},
					tooltip: 'pain type',
					child: Icon(Icons.arrow_back),
				)
		);
	}
}