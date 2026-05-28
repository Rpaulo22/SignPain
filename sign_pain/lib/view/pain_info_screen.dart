import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_pain/core/providers/sign_language_provider.dart';
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
  String userID = FirebaseAuth.instance.currentUser!.uid;
  late Future<List<PainFormData>> _painDataFuture;
  bool showGraph = false;

  @override
  void initState() {
    super.initState();
    _painDataFuture = formViewModel.getUserPainData(userID);
  }

	@override
	Widget build(BuildContext context) {
    final isSignMode = Provider.of<SignLanguageProvider>(context).isSignLanguageMode;
    

		return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      
			body: FutureBuilder<List<PainFormData>>(
        future: _painDataFuture, 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) { 
            return const Center(child: CircularProgressIndicator());
          } 
          else if (snapshot.hasError) { 
            return Center(child: Text("Erro a carregar página: ${snapshot.error}"));
          } 
          else if (snapshot.hasData) { 
            final data = snapshot.data!;
              
            if (data.isEmpty) {
              return const Center(
                child: Text(
                  "❌📋\nAinda não tem quaisquer registos de dor",
                  textAlign: TextAlign.center,
                  textScaler: TextScaler.linear(1.6),
                ),
              );
            }
            else if (showGraph) {
              if (data.length < 2) {
                return const Center(
                  child: Text(
                    "É preciso 2 registos para ver gráfico",
                    textAlign: TextAlign.center,
                    textScaler: TextScaler.linear(1.6),
                  ),
                );
              }
              else {
                final ascendingData = List<PainFormData>.from(data);
                ascendingData.sort((a,b) => a.date!.compareTo(b.date!));
                final dataX = getDataX(ascendingData);

                double totalDaysSpan = dataX.last.toDouble();
                double strictInterval = totalDaysSpan / 5; 
                if (strictInterval < 1) strictInterval = 1.0; 
                
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Theme.of(context).colorScheme.onSecondary,
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            showGraph = !showGraph;
                          });
                        },
                        child: const Text("Gráfico 📈")
                      )
                    ),
                    const Text(
                      "Progressão da dor", 
                      textScaler: TextScaler.linear(1.8), 
                      style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    Expanded(
                      // Wrapped in a Center and Padding to make it look perfect in the middle
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: AspectRatio(
                            aspectRatio: 1.5,
                            child: LineChart(
                              LineChartData(
                                minY: 0,
                                maxY: 10,
                                
                                // the data being ilustrated
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: [
                                      for (var i = 0; i < ascendingData.length; i++)
                                        FlSpot(
                                          dataX[i].toDouble(),
                                          ascendingData[i].painLevel!.toDouble(),
                                        )
                                    ],
                                    color: Theme.of(context).colorScheme.inversePrimary,
                                    barWidth: 4,
                                    isStrokeCapRound: true,
                                  ),
                                ],
                                
                                // When user taps a point
                                lineTouchData: LineTouchData( 
                                  touchTooltipData: LineTouchTooltipData(
                                    getTooltipColor: (LineBarSpot touchedSpot) => Theme.of(context).colorScheme.inversePrimary,
                                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                    tooltipMargin: 30.0, // margin so that finger does not obstruct the information
                                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                      return touchedSpots.map((LineBarSpot spot) {
                                        
                                        DateTime dayOne = ascendingData.first.date!;
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
                                      interval: strictInterval,
                                      reservedSize: 30,
                                      getTitlesWidget: (value, meta) {
                                        if (value > meta.max - (strictInterval / 2) && value < meta.max) {
                                          return const SizedBox.shrink();
                                        }
                                        // Convert offset back to a Date
                                        DateTime dayOne = ascendingData.first.date!;
                                        DateTime d = dayOne.add(Duration(days: value.toInt()));
                                        
                                        return SideTitleWidget(
                                          meta: meta,
                                          space: 8.0, // Proper spacing from the X-axis line
                                          child: Text(
                                            DateFormat('dd/MM').format(d), 
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                                                    
                                  // Left Y-Axis: Pain levels
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
                                
                                gridData: const FlGridData(show: false),

                                borderData: FlBorderData(
                                  show: true,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Theme.of(context).colorScheme.onSurface.withAlpha(100), 
                                      width: 1.5,
                                    ),
                                    left: BorderSide(
                                      color: Theme.of(context).colorScheme.onSurface.withAlpha(100), 
                                      width: 1.5,
                                    ),
                                    top: const BorderSide(color: Colors.transparent),
                                    right: const BorderSide(color: Colors.transparent),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ]
                );
              }
            } else {
              // list may be big, so scrollable
              return Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 15, vertical:10),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Theme.of(context).colorScheme.onSecondary,
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (data.length < 2) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("É preciso 2 registos para ver gráfico"))
                              );
                            }
                            else {
                              setState(() {
                                showGraph = !showGraph;
                              });
                            }
                          },
                          child: const Text("Gráfico 📈")
                        )
                      ),
                      for (var entry in data) ... [
                        painFormWidget(entry),
                        SizedBox(height: 10)
                      ]
                    ]
                  ),
                )
              );
            }
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
        border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12)
      ),
      padding: EdgeInsetsDirectional.only(top: 15, bottom: 15, start: 10, end: 10),
      child: Row(
        mainAxisSize: .max,
        crossAxisAlignment: .center,
        children: [
          Text(
            DateFormat('dd-MM-yyy\nkk:mm').format(data.date!), 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 14,
              color: Theme.of(context).colorScheme.onPrimary
            ),
            textAlign: .center,
          ),
          VerticalDivider(
            color: Theme.of(context).colorScheme.secondary,
            width: 10,
            thickness: 5,
          ),
          Expanded(
            child: Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    children: <TextSpan>[
                      TextSpan(text: "Descrição: "),
                      TextSpan(text: data.descriptors.isNotEmpty ? data.descriptors.join(", ") : "Nenhuma", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  )
                ),
                SizedBox(height: 5),
                Text(
                  data.bodyParts.isNotEmpty 
                    ? BodyPartsMapper.listToPortuguese(data.bodyParts).join(", ") 
                    : "Dor não situada", 
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onPrimary
                  ),
                  textAlign: .center,
                )
              ]
            ),
          )
        ]
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