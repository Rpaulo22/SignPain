import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_pain/core/providers/sign_language_provider.dart';
import 'package:sign_pain/model/pain_form_data.dart';
import 'package:sign_pain/viewmodel/form_view_model.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class PainInfoScreen extends StatefulWidget {
  const PainInfoScreen({super.key});

  @override
  State<PainInfoScreen> createState() => _PainInfoScreenState();
}

class _PainInfoScreenState extends State<PainInfoScreen> {
  final FormViewModel formViewModel = FormViewModel();
  String userID = FirebaseAuth.instance.currentUser!.uid;
  late Future<void> _painDataFuture;
  
  int mode = 0; // 0 -> calendar | 1 -> graph | 2 -> list

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _painDataFuture = formViewModel.getUserPainData(userID);
  }

	@override
	Widget build(BuildContext context) {
    final isSignMode = Provider.of<SignLanguageProvider>(context).isSignLanguageMode;
    

		return Scaffold(
      floatingActionButtonLocation: .startFloat,
      
			body: FutureBuilder<void>(
        future: _painDataFuture, 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) { 
            return const Center(child: CircularProgressIndicator());
          } 
          else if (snapshot.hasError) { 
            return Center(child: Text("Erro a carregar página: ${snapshot.error}"));
          } 
          else if (snapshot.hasData) { 
            final data = formViewModel.painRecords;
              
            if (data.isEmpty) {
              return const Center(
                child: Text(
                  "❌📋\nAinda não tem quaisquer registos de dor",
                  textAlign: TextAlign.center,
                  textScaler: TextScaler.linear(1.6),
                ),
              );
            }

            return Column(
              children: [
                // buttons to change mode
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mode == 0 ? Color.fromARGB(255, 233, 129, 64) : Color.fromARGB(255, 233, 129, 64).withAlpha(80),
                        foregroundColor: mode == 0 ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onPrimary.withAlpha(80),
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          mode = 0;
                        });
                      },
                      child: const Text("Calendário 📅")
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mode == 1 ? Color.fromARGB(255, 233, 129, 64) : Color.fromARGB(255, 233, 129, 64).withAlpha(80),
                        foregroundColor: mode == 1 ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onPrimary.withAlpha(80),
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
                            mode = 1;
                          });
                        }
                      },
                      child: const Text("Gráfico 📈")
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mode == 2 ? Color.fromARGB(255, 233, 129, 64) : Color.fromARGB(255, 233, 129, 64).withAlpha(80),
                        foregroundColor: mode == 2 ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onPrimary.withAlpha(80),
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          mode = 2;
                        });
                      },
                      child: const Text("Lista 📋")
                    )
                  ],
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (mode == 2) {
                        // LIST VIEW
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                for (var entry in data) ...[
                                  painFormWidget(entry),
                                  const SizedBox(height: 10),
                                ],
                                const SizedBox(height: 60) // Bottom padding for FAB
                              ],
                            ),
                          ),
                        );
                      } else if (mode == 1) {
                        // GRAPH VIEW
                        return Column(
                          children: [
                            const Text(
                              "Progressão da dor",
                              textScaler: TextScaler.linear(1.8),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: painChart(data),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        // CALENDAR VIEW
                        return painCalendar(data);
                      }
                    },
                  ),
                )
              ]
            );
          }
          return const Center(child: Text("Não tem quaisquer registos de dor"));
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'btn_back',
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.arrow_back),
      ),
    );
	}

  // individual pain form entry
  Widget painFormWidget(PainFormData data) {

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: getPainColor(data.painLevel!)),
        color: getPainColor(data.painLevel!).withAlpha(150),
        borderRadius: BorderRadius.circular(12)
      ),
      padding: EdgeInsetsDirectional.only(top: 15, bottom: 15, start: 10, end: 10),
      child: Row(
        mainAxisSize: .max,
        crossAxisAlignment: .center,
        children: [
          Text(
            "Dor ${data.painLevel!}/10", 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 18,
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
  
  // chart representing the evolution of 
  Widget painChart(List<PainFormData> data) {

    final ascendingData = List<PainFormData>.from(data);
    ascendingData.sort((a,b) => a.date!.compareTo(b.date!));
    final dataX = getDataX(ascendingData);

    double totalDaysSpan = dataX.last.toDouble();
    double strictInterval = totalDaysSpan / 5; 
    if (strictInterval < 1) strictInterval = 1.0; 

    return AspectRatio(
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
              color: Color.fromARGB(255, 233, 129, 64),
              barWidth: 4,
              isStrokeCapRound: true,
            ),
          ],
          
          // When user taps a point
          lineTouchData: LineTouchData( 
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (LineBarSpot touchedSpot) => Color.fromARGB(255, 233, 129, 64),
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
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: dateString,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary.withAlpha(200),
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
    );
  }

  // visualization of pain history through calendar
  Widget painCalendar(List<PainFormData> data) {
    final firstDay = data.reduce((curr, next) => curr.date!.compareTo(next.date!) < 0 ? curr : next).date!;

    // format the list to a map to more easily access data pertaining to a specific day
    Map<DateTime, List<PainFormData>> historyMap = data.fold({}, (map, record) {
      final date = record.date!;
      final normalizedKey = DateTime.utc(date.year, date.month, date.day);
      map.putIfAbsent(normalizedKey, () => []).add(record);
      return map;
    });

    // helper function to match exact days ignoring timestamps
    List<PainFormData>? getPainRecordsForDay(DateTime day) {
      return historyMap[day]; 
    }

    List<PainFormData> dayPainList = [];
    if (_selectedDay != null) {
      final normalizedDate = DateTime.utc(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
      dayPainList = historyMap[normalizedDate] ?? [];
    }

    return Column(
      children: [
        TableCalendar(
          locale: 'pt_PT', 
          firstDay: firstDay,
          lastDay: DateTime.now(),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            focusedDay = focusedDay;
          },

          daysOfWeekHeight: 24,

          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              final dayEntries = getPainRecordsForDay(date);
              if (dayEntries == null) return const SizedBox.shrink();

              // average pain level reported in that day
              final painLevel = (dayEntries.map((entry) => entry.painLevel!).reduce((a, b) => a + b) / dayEntries.length).round();

              // Build a beautiful colored badge under the date matching your pain scale
              return Positioned(
                bottom: 4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: getPainColor(painLevel),
                  ),
                  child: Text(
                    painLevel.toString(),
                    style: TextStyle(fontSize: 10),
                    textAlign: .center,
                  ),
                ),
              );
            },

            dowBuilder: (context, day) {
              // format the day to a 3-letter abbreviation
              final text = DateFormat.E('pt_PT').format(day);
              
              final cleanText = text.substring(0, 1).toUpperCase() + text.substring(1, 3);

              return Center(
                child: Text(
                  cleanText,
                  style: TextStyle(
                    color: day.weekday == DateTime.sunday || day.weekday == DateTime.saturday
                        ? Theme.of(context).colorScheme.error // Red-ish for weekends
                        : Theme.of(context).colorScheme.onSurface, // Standard color for weekdays
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              );
            },
          ),
          
          // UI Theme custom styling that shifts nicely with dark/light mode
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(110),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const Divider(height: 20, thickness: 1),
        Expanded(
          child: _selectedDay == null
            ? const Center(
                child: Text(
                  "Selecione um dia para ver os registos",
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              )
            : dayPainList.isEmpty
              ? const Center(
                  child: Text(
                    "Sem registos de dor neste dia.",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  itemCount: dayPainList.length,
                  itemBuilder: (context, index) {
                    final entry = dayPainList[index];
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: painFormWidget(entry),
                    );
                  },
                ),
        )
      ],
    );
  }

  Color getPainColor(int painLevel) {
    if (painLevel < 3) return Colors.green;
    if (painLevel < 6) return Colors.orange;
    if (painLevel < 9) return Colors.redAccent;
    return Colors.red;
  }
}