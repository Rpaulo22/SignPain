import 'package:fl_chart/fl_chart.dart';
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
  bool showGraph = false;

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
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                showGraph = !showGraph;
              });
            }, 
            icon: showGraph ? Icon(Icons.show_chart) : Icon(Icons.show_chart_outlined)
          )
        ],
			),
			body: SingleChildScrollView(
        child: FutureBuilder<List<PainFormData>>(
          future: _painDataFuture, 
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) { // pain data has not been loaded yet
              return const Center(child: CircularProgressIndicator());

            } else if (snapshot.hasError) { // data loading has incurred in some error
              return Center(child: Text("Erro a carregar página: ${snapshot.error}"));

            } else if (snapshot.hasData) { // data has been loaded
              final data = snapshot.data!;
              if (showGraph) {
                final dataX = getDataX(data);
                int interval = (dataX.last / 4).toInt();
                return Column(
                  children: [
                    Text("Progressão da dor", textScaler: TextScaler.linear(1.8), style: TextStyle(fontWeight: FontWeight.bold)),
                    Padding(
                      padding: EdgeInsetsGeometry.directional(start: 5, end: 25, top: 40),
                      child: AspectRatio(
                        aspectRatio: 1.5, // Keeps the graph rectangular and responsive
                        child: LineChart(
                          LineChartData(
                            minY: 0,
                            maxY: 10,
                            
                            lineBarsData: [
                              LineChartBarData(
                                spots:  [
                                  for (var i = 0; i < data.length; i++) 
                                    FlSpot(
                                      dataX[i].toDouble(), 
                                      data[i].painLevel!.toDouble())
                                ],
                                color: Theme.of(context).colorScheme.inversePrimary,
                                barWidth: 4,
                                isStrokeCapRound: true
                              ),
                            ],
                            lineTouchData: LineTouchData(
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipColor: (LineBarSpot touchedSpot) => Theme.of(context).colorScheme.inversePrimary,

                                tooltipPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                tooltipMargin: 30.0, // margin so that finger does not obstruct the information
                                
                                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                  return touchedSpots.map((LineBarSpot spot) {
                                    
                                    DateTime dayOne = data.first.date!;
                                    DateTime d = dayOne.add(Duration(days: spot.x.toInt()));
                                    String dateString = DateFormat('d MMM', 'pt_PT').format(d);

                                    return LineTooltipItem(
                                      'Dor: ${spot.y.toInt()}\n', 
                                      TextStyle(
                                        color: Theme.of(context).colorScheme.secondary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: dateString,
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              // Bottom X-Axis: Show the dates
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: interval.toDouble(),
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) {
                                    DateTime dayOne = data.first.date!;
                                    DateTime d = dayOne.add(Duration(days: value.toInt()));
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(DateFormat('dd/MM').format(d))
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 2, // Show a label every 2 levels (2, 4, 6...)
                                  reservedSize: 30, // Give the text enough room
                                ),
                              ),
                              // Hide the top and right titles for a cleaner look
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: const FlGridData(show: false)
                          ),
                        ),
                      )
                    )
                  ]
                );
              }
              else {
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
            }
            return const Center(child: Text("Não tem quaisquer registos de dor"));
          },
        )
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
          ),
          Text(data.bodyParts.isNotEmpty ? BodyPartsMapper.listToPortuguese(data.bodyParts).join(", ") : "Dor não situada", style: const TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(1.2))
        ],
      )
    );
  }

  // returns a list of days passed since first registered form for each submitted form
  List<int> getDataX(List<PainFormData> data) {
    DateTime dayOne = data.first.date!;
    DateTime dayOneAux = DateTime(dayOne.year, dayOne.month, dayOne.day); // 00:00:00 of each day (so that difference >= 24h)
    List<int> days = [0];
    for (var entry in data.skip(1)) {
      DateTime entryDate = entry.date!;
      DateTime dateAux = DateTime(entryDate.year, entryDate.month, entryDate.day);

      days.add(dateAux.difference(dayOneAux).inDays); // days elapsed between first registered form and this one
    }
    return days;
  }
}