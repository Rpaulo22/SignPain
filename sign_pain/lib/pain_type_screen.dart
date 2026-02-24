import 'dart:math' as math;

import 'package:flutter/material.dart';

class PainTypeScreen extends StatefulWidget {

	const PainTypeScreen({super.key});

	@override
  	State<PainTypeScreen> createState() => _PainTypeScreenState();
}

class _PainTypeScreenState extends State<PainTypeScreen> {
	Set<String> painType = {};

	final painTypes = ["Latente", "Ardor", "Formigueiro", "Perfurante", "Frio", "Choque"];

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
							for (var i in painTypes)
								CheckboxListTile(
									title: Text(i.toString()),
									value: painType.contains(i),
									onChanged: (bool? checked) {
										setState(() {
										if (checked == true) {
											painType.add(i);
										} else {
											painType.remove(i);
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
					child: Transform(
						alignment: Alignment.center,
						transform: Matrix4.rotationY(math.pi),
						child: Icon(Icons.redo),
						),
				)
		);
	}
}