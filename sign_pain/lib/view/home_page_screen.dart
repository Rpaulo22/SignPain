import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sign_pain/model/pain_form_data.dart';
import 'package:sign_pain/model/user_data.dart';
import 'package:sign_pain/theme/app_colors.dart';
import 'package:sign_pain/utils/notification_service.dart';
import 'package:sign_pain/view/pain_date_screen.dart';
import 'package:sign_pain/viewmodel/account_view_model.dart';
import 'package:sign_pain/viewmodel/form_view_model.dart';
import 'package:sign_pain/widgets/pain_form_widget.dart';
import 'package:sign_pain/widgets/report_dialog.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final List<String> videoPaths = [
    'assets/videos/ola.mp4',
    'assets/videos/historia.mp4',
    'assets/videos/dor.mp4',
    'assets/videos/doenca.mp4'
  ];

  final accountViewModel = AccountViewModel();
  late Future<UserData> userDataFuture;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime focusedDay = DateTime.now();
  final ValueNotifier<DateTime?> selectedDayNotifier = ValueNotifier<DateTime?>(null);

  // 0 -> show last month's entries, 1 -> show last week's entries, 2 -> show last 24h
  final ValueNotifier<int?> chartIntervalNotifier = ValueNotifier<int?>(null);

  @override
  void dispose() {
    chartIntervalNotifier.dispose();
    selectedDayNotifier.dispose(); 
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Fetch data exactly once when the screen mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FormViewModel>().getUserPainData(FirebaseAuth.instance.currentUser!.uid);
      NotificationService().requestNotificationPermissions();
      NotificationService().scheduleDailyReminder();
    });
    userDataFuture = accountViewModel.getUserData(FirebaseAuth.instance.currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      body: SingleChildScrollView(
        child: ListenableBuilder(
          listenable: context.read<FormViewModel>(),
          builder: (context, child) {
            final formViewModel = context.read<FormViewModel>();

            if (formViewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            else {
              final userEntries = formViewModel.painRecords;

              // depending on the date of the last pain entry, change the graph's interval accordingly
              // in the last 24hrs => last 24hrs graph
              // in the last week => last week graph
              // in the last month => last month graph
              if (chartIntervalNotifier.value == null) {
                // if there are no entries yet, default to last 24hrs, although the graph will not show anything until there are 2 entries
                if (userEntries.isEmpty) {
                  chartIntervalNotifier.value = 2;
                } else {
                  DateTime lastEntry = userEntries.first.date;
                  // last 24hrs
                  if (lastEntry.isAfter(DateTime.now().subtract(Duration(days: 1)))) {
                    chartIntervalNotifier.value = 2;
                  }
                  // last week
                  else if (lastEntry.isAfter(DateTime.now().subtract(Duration(days: 7)))) {
                    chartIntervalNotifier.value = 1;
                  }
                  // last month
                  else if (lastEntry.isAfter(DateTime.now().subtract(Duration(days: 30)))) {
                    chartIntervalNotifier.value = 0;
                  }
                }
              }

              // pre-compile calendar history map once only
              final Map<DateTime, List<PainFormData>> historyMap = userEntries.fold({}, (map, record) {
                final date = record.date;
                final normalizedKey = DateTime.utc(date.year, date.month, date.day);
                map.putIfAbsent(normalizedKey, () => []).add(record);
                return map;
              });

              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: FutureBuilder(
                          future: userDataFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else {
                              return RichText( 
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  children: <TextSpan>[
                                    const TextSpan(
                                      text: '👋\nOlá ',
                                      style: TextStyle(fontSize: 26),
                                    ),
                                    TextSpan(
                                      text: snapshot.data!.fullName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold, 
                                        fontSize: 26,
                                        color: AppColors.primaryOrange
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ),

                      SizedBox(height: 30),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (context) => PainDateScreen(formData: PainFormData()),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: .min,
                          mainAxisAlignment: .center,
                          children: [
                            Text("Registar dor"),
                            SizedBox(width: 10),
                            Icon(Icons.add_circle_outline)
                          ]
                        )
                      ),

                      SizedBox(height: 30),


                      Text(
                        "Calendário da dor", 
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                        textAlign: .start,
                      ),
                      
                      Container(
                        height: 600,
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.onSurface),
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05), // Very soft modern shadow
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: painCalendar(userEntries, historyMap),
                      ),
                      SizedBox(height: 20),
                      
                      Text(
                        "Evolução da dor", 
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                        textAlign: .start,
                      ),
                      
                      Container(
                        height: 360,
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.onSurface),
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05), // Very soft modern shadow
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsetsGeometry.all(20),
                          child: painChart(userEntries),
                        )
                      ),
                      
                      SizedBox(height:20),
                      FutureBuilder(
                        future: userDataFuture,
                        builder: (context, snapshot) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.tertiary,
                              foregroundColor: Theme.of(context).colorScheme.onTertiary,
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              if (snapshot.hasData) { // only create report after user's name has been loaded
                                final user = snapshot.data!;
                                showDialog(
                                  context: context, 
                                  builder: (context) => ReportDialog(user: user, userEntries: userEntries)
                                );
                              }
                              else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Erro ao gerar resumo. Tente novamente"))
                                );
                              }
                            },
                            child: Row(
                              mainAxisSize: .min,
                              mainAxisAlignment: .center,
                              children: [
                                Text("Partilhar"),
                                SizedBox(width: 10),
                                Icon(Icons.picture_as_pdf)
                              ]
                            )
                          );
                        }
                      ),
                      SizedBox(height: 20)
                    ]
                  ),
                ),
              );
            }
          }
        )
      ),
    );
  }

  // returns a list of each entry's timestamp for the x-axis
  List<double> getDataX(List<PainFormData> data) {
    return data.map((entry) => entry.date.millisecondsSinceEpoch.toDouble()).toList();
  }
  
  // chart representing the evolution of 
  Widget painChart(List<PainFormData> data) {
    if (data.length < 2) {
      return const Center(
        child: Text(
          "❌📋\nRegiste mais vezes para ver progressão",
          textAlign: TextAlign.center,
          textScaler: TextScaler.linear(1.6),
        ),
      );
    }

    final ascendingData = List<PainFormData>.from(data);
    ascendingData.sort((a,b) => a.date.compareTo(b.date));
    final dataX = getDataX(ascendingData);

    return ValueListenableBuilder<int?>(
      valueListenable: chartIntervalNotifier,
      builder: (context, chartIntervalMode, _) {

        if (chartIntervalMode == null) {
          return const Center(
            child: Text(
              "❌📋\nNão tem registos este mês.\nRegiste para ver progressão",
              textAlign: TextAlign.center,
              textScaler: TextScaler.linear(1.6),
            ),
          );
        }

        // chart ends at current time
        final double maximumX = DateTime.now().millisecondsSinceEpoch.toDouble();
        
        double minimumX;
        double extraSpace; // breathing room for the graph
        final double oneDay = const Duration(days: 1).inMilliseconds.toDouble();
        
        if (chartIntervalMode == 0) {
          minimumX = maximumX - (oneDay * 30); // 1 Month
          extraSpace = oneDay;    // extra space of one day in chart
        } else if (chartIntervalMode == 1) {
          minimumX = maximumX - (oneDay * 7);  // 7 Days
          extraSpace = oneDay/4;  // extra space of a quarter of a day
        } else {
          minimumX = maximumX - oneDay;        // 24 Hours
          extraSpace = oneDay/24; // extra space of 1 hour
        }

        // Failsafe if data is totally broken
        if (maximumX <= minimumX) minimumX = maximumX - 1;

        // how much time the chart covers in total
        final double timeSpan = maximumX - minimumX;
        
        // Tell the chart to naturally divide that space into roughly 5-6 points
        final double dynamicInterval = timeSpan / 5; 

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilterChip(
                  label: const Text("1 Mês"),
                  selected: chartIntervalMode == 0,
                  onSelected: (_) => chartIntervalNotifier.value = 0,
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text("7 Dias"),
                  selected: chartIntervalMode == 1,
                  onSelected: (_) => chartIntervalNotifier.value = 1,
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text("Últimas 24h"),
                  selected: chartIntervalMode == 2,
                  onSelected: (_) => chartIntervalNotifier.value = 2,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1.5,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: 10,
                    minX: minimumX,
                    maxX: maximumX + extraSpace,
                    
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          for (var i = 0; i < ascendingData.length; i++)
                            FlSpot(
                              dataX[i].toDouble(),
                              ascendingData[i].painLevel!.toDouble(),
                            )
                        ],
                        color: AppColors.primaryOrange,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: chartIntervalMode != 0,
                          checkToShowDot: (spot, barData) {
                            // Find the original entry that matches this spot's X coordinate
                            final entry = ascendingData.firstWhere(
                              (e) => e.date.millisecondsSinceEpoch.toDouble() == spot.x,
                            );
                            // Only show the dot if they took medication
                            return entry.tookMedication == true; 
                          },
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 6,
                              color: Colors.cyanAccent,
                              strokeWidth: 3,
                              strokeColor: Theme.of(context).colorScheme.surface,
                            );
                          },
                        ),
                        isCurved: true,
                        curveSmoothness: 0.05,
                      ),
                    ],

                    // dotted lines which appear with entries where the user took medication
                    extraLinesData: ExtraLinesData(
                      verticalLines: [
                        if (chartIntervalMode != 0)
                          for (var entry in ascendingData)
                            if (entry.tookMedication == true)
                              VerticalLine(
                                x: entry.date.millisecondsSinceEpoch.toDouble(),
                                color: Colors.cyanAccent,
                                strokeWidth: 1.5,
                                dashArray: [5, 5],
                              ),
                      ],
                    ),
                    
                    lineTouchData: LineTouchData( 
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (LineBarSpot touchedSpot) => AppColors.primaryOrange,
                        tooltipPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        tooltipMargin: 30.0,
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((LineBarSpot spot) {
                            DateTime d = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                            String dateString = DateFormat('d MMM, HH:mm', 'pt_PT').format(d);

                            // entry corresponding to spot
                            final entry = ascendingData.firstWhere(
                              (e) => e.date.millisecondsSinceEpoch.toDouble() == spot.x,
                            );

                            // add medication info if true
                            String medText = (entry.tookMedication == true) ? "\n💊 ${(entry.medicationNotes != null) ? entry.medicationNotes : "Medicação"}" : "";

                            return LineTooltipItem(
                              'Dor: ${spot.y.toInt()}$medText\n',
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
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: dynamicInterval,
                          reservedSize: 45, // tiny bit more room for the 2-line text
                          getTitlesWidget: (value, meta) {
                            // Don't draw the very first and last label if they touch the edges
                            if (value == meta.min || value == meta.max) {
                              return const SizedBox.shrink();
                            }

                            DateTime d = DateTime.fromMillisecondsSinceEpoch(value.toInt());

                            String labelText;
                            if (chartIntervalMode == 2) {
                              labelText = DateFormat('HH:mm\ndd/MM').format(d);
                            } else {
                              labelText = DateFormat('dd/MM').format(d);
                            }
                            
                            return SideTitleWidget(
                              meta: meta,
                              space: 10.0, 
                              child: Text(
                                labelText, 
                                textAlign: TextAlign.center,
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
                                              
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 2, 
                          reservedSize: 30, 
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    
                    gridData: const FlGridData(show: false),
                    clipData: const FlClipData.all(),
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
              )
            )
          ]
        );
      }
    );
  }

  // visualization of pain history through calendar
  Widget painCalendar(List<PainFormData> data, Map<DateTime, List<PainFormData>> historyMap) {

    return ValueListenableBuilder<DateTime?>(
      valueListenable: selectedDayNotifier,
      builder: (context, selectedDay, _) {

        // helper function to match exact days ignoring timestamps
        List<PainFormData>? getPainRecordsForDay(DateTime day) {
          return historyMap[day]; 
        }

        List<PainFormData> dayPainList = [];
        if (selectedDay != null) {
          final normalizedDate = DateTime.utc(selectedDay.year, selectedDay.month, selectedDay.day);
          dayPainList = historyMap[normalizedDate] ?? [];
          dayPainList.sort((a,b) => a.date.compareTo(b.date));
        }

        return Column(
          children: [
            TableCalendar(
              locale: 'pt_PT', 
              firstDay: DateTime.utc(2020, 1, 1), 
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(selectedDay, day),
              onDaySelected: (newSelectedDay, newFocusedDay) {
                selectedDayNotifier.value = newSelectedDay;
                focusedDay = newFocusedDay;
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (newFocusedDay) {
                focusedDay = newFocusedDay;
              },

              // disable the swiping to change calendar format
              availableGestures: AvailableGestures.horizontalSwipe,

              // only want the user to look at the full month layout view.
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),

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
                weekendTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                defaultTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
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
              child: selectedDay == null
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
                          child: PainFormWidget(data: entry)
                        );
                      },
                    ),
            )
          ],
        );
      }
    );
  }

  Color getPainColor(int painLevel) {
    if (painLevel < 3) return Colors.green;
    if (painLevel < 7) return Colors.orange;
    if (painLevel < 9) return Colors.redAccent;
    return Colors.red;
  }
}