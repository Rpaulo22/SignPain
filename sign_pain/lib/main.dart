import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

final painScale = [0,1,2,3,4,5,6,7,8,9,10];

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int? painLevel;

  void reset() {
    setState((){painLevel = null;});
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  final snackBar = SnackBar(
    content: Text('Reset pain level!'),
    duration: const Duration(milliseconds: 1500),
    );

  @override
  Widget build(BuildContext context) {

    return Scaffold(
		appBar: AppBar(
			backgroundColor: Theme.of(context).colorScheme.inversePrimary,
			title: const Text("SignPain"),
		),
		body: Center(
			child: Column(
			mainAxisAlignment: MainAxisAlignment.center,
			children: [
				const Text('Select your pain level'),
				Row(
				mainAxisAlignment: MainAxisAlignment.center, 
				children: [
					// IPT image
					Expanded(
						flex: 1,
						child: Image(
							image: AssetImage('assets/images/ipt.png'),
							fit: BoxFit.contain, 
						),
					),
					// Options for pain
					Expanded(
					child: 
					  RadioGroup<int>(
                        groupValue: painLevel,
                        onChanged: (int? value) {
                            setState(() {
                            painLevel = value;
                            });
                        },
                        child:
                            Column(
                            children: <Widget>[
                            for (var i in painScale.reversed.toList())
                                ListTile(
                                title: Text(i.toString()),
                                leading: Radio<int>(value: i))
                            ],
                        )
					)),
				],
				),
			],
			),
		),
		floatingActionButton: FloatingActionButton(
			onPressed: reset,
			tooltip: 'reset',
			child: const Icon(Icons.lock_reset),
		),
		);
  }
}
