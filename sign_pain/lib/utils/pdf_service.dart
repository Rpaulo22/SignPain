import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // 'pw' to avoid conflicts with standard Flutter widgets
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:sign_pain/model/pain_form_data.dart';
import 'package:sign_pain/model/user_data.dart';
import 'package:sign_pain/utils/app_exception.dart';
import 'package:sign_pain/widgets/pain_frequency.dart';

const maxEntries = 20;

enum ChartIntervalMode {allRecords, lastMonthRecords, lastDayRecords}

class PdfService {

  
  // function which generates a pdf report of the user's pain records and a time interval and allows the user to share it
  static Future<File> generateAndSharePainReport(List<PainFormData> records, UserData user, DateTime firstDay, DateTime lastDay) async {

    // only shares info within the specified interval (until 23:59 on the last day)
    final intervalRecords = records.where((entry) => (entry.date.isAfter(firstDay) && entry.date.isBefore(lastDay.add(Duration(hours: 23, minutes: 59, seconds: 59, milliseconds: 999))))).toList();

    if (intervalRecords.length < 2) {
      throw AppException("não há registos suficientes neste intervalo de tempo.");
    }

    final pdf = pw.Document();

    final regularFontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final boldFontData = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");
    final italicFontData = await rootBundle.load("assets/fonts/Roboto-Italic.ttf");

    final robotoRegular = pw.Font.ttf(regularFontData);
    final robotoBold = pw.Font.ttf(boldFontData);
    final robotoItalic = pw.Font.ttf(italicFontData);

    // Sort records chronologically
    final descendingRecords = List<PainFormData>.from(intervalRecords)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    final mostRecentRecords = descendingRecords.length > maxEntries ? descendingRecords.getRange(0, maxEntries).toList() : descendingRecords; // limit records to the most recent maxEntries entries

    final ascendingRecords = List<PainFormData>.from(intervalRecords)..sort((a,b) => a.date.compareTo(b.date)); // inverted chronological order


    // build the pdf Layout
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),

        // custom font for pdf, allowing for the use of special characters (such as the ones found in the portuguese language)
        theme: pw.ThemeData.withFont(
          base: robotoRegular,
          bold: robotoBold,    
          italic: robotoItalic
        ),

        build: (pw.Context context) {
          return [
            _buildHeader(user, firstDay, lastDay),
            pw.SizedBox(height: 20),
            _buildSummary(descendingRecords),
            pw.SizedBox(height: 20),
            _buildDataTable(mostRecentRecords),
            pw.SizedBox(height: 20),
            _buildGraphs(ascendingRecords, firstDay, lastDay)
          ];
        },
      ),
    );

    // save to temporary directory
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/relatorio_signpain.pdf');
    return await file.writeAsBytes(await pdf.save());
  }

  // --- PDF WIDGET BUILDERS ---

  static pw.Widget _buildHeader(UserData user, DateTime firstDay, DateTime lastDay) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Relatório de Dor SignPain - ${user.fullName}',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          'Entre ${DateFormat("d MMM", 'pt_PT').format(firstDay)} e ${DateFormat("d MMM", 'pt_PT').format(lastDay)}',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          'Nº de utente SNS: ${user.healthIdentifer}',
          style: pw.TextStyle(fontSize: 16, color: PdfColors.grey800),
        ),
        pw.Text(
          'Data de nascimento: ${DateFormat("dd/MM/yyyy").format(user.birthDate)}',
          style: pw.TextStyle(fontSize: 16, color: PdfColors.grey800),
        ),
        pw.Text(
          'Gerado a: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildSummary(List<PainFormData> records) {
    if (records.isEmpty) return pw.Text("Sem registos para mostrar.");
    
    // Quick math for the summary
    double totalPain = records.fold(0, (sum, item) => sum + item.painLevel!);
    double avgPain = totalPain / records.length;

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Text(
        'Total de registos: ${records.length} | Intensidade média: ${avgPain.toStringAsFixed(1)}',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _buildDataTable(List<PainFormData> records) {
    return pw.TableHelper.fromTextArray(
      headers: ['Data', 'Nível de Dor', 'Área Afetada', 'Frequência', 'Descrição', 'Medicação'],
      data: records.map((record) {
        return [
          DateFormat('dd/MM/yyyy').format(record.date),
          record.painLevel.toString(),
          BodyPartsMapper.listToPortuguese(record.bodyParts).join(", "),
          painFrequencyToStringPT(record.frequency),
          record.descriptors.join(", "),
          record.tookMedication! ? (record.medicationNotes ?? "Sim") : "Não"
        ];
      }).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
      ),
      cellAlignment: pw.Alignment.centerLeft,
    );
  }
  
  static pw.Widget _buildGraphs(List<PainFormData> records, DateTime firstDay, DateTime lastDay) {
    if (records.isEmpty) return pw.SizedBox();

    // date 30 days before that
    final DateTime thirtyDaysAgo = lastDay.subtract(const Duration(days: 30));

    // date 24 hrs previous
    final DateTime oneDayAgo = lastDay.subtract(const Duration(days: 1));
    
    // filtered list of records in last 30 days
    final List<PainFormData> recentRecords = records.where((entry) {
      return entry.date.isAfter(thirtyDaysAgo) || entry.date.isAtSameMomentAs(thirtyDaysAgo);
    }).toList();

    // filtered list of records in last 24hrs (in relation to the given last day)
    final List<PainFormData> lastDayRecords = records.where((entry) {
      return entry.date.isAfter(oneDayAgo) || entry.date.isAtSameMomentAs(oneDayAgo);
    }).toList();

    final bool isLongerThanOneMonth = recentRecords.length < records.length;
    final bool hasRecordsLastDay = lastDayRecords.length > 1;

    return pw.Column(
      children: [
        pw.Text("Evolução da Dor", style: pw.TextStyle(fontSize: 20)),
        pw.SizedBox(height: 20),
        _buildChartWidget("Todo o histórico (${DateFormat("dd/MM/yyyy").format(firstDay)} - ${DateFormat("dd/MM/yyyy").format(lastDay)})", records),
        if (isLongerThanOneMonth && recentRecords.length > 1) ...[
          pw.SizedBox(height: 30), 
          _buildChartWidget("Últimos 30 Dias (${DateFormat("dd/MM").format(thirtyDaysAgo)} - ${DateFormat("dd/MM").format(lastDay)})", recentRecords, mode: .lastMonthRecords),
        ],
        if (hasRecordsLastDay) ... [
          pw.SizedBox(height: 30), 
          _buildChartWidget("Últimas 24 Horas (${DateFormat("dd/MM").format(oneDayAgo)} - ${DateFormat("dd/MM").format(lastDay)})", lastDayRecords, mode: .lastDayRecords),
        ]
      ]
    );
  }

  static pw.Widget _buildChartWidget(String title, List<PainFormData> chartRecords, {ChartIntervalMode mode = ChartIntervalMode.allRecords}) {
    if (chartRecords.isEmpty) return pw.SizedBox();

    final dataX = getDataX(chartRecords);

    final double minX = dataX.first;
    final double maxX = dataX.last;

    // generate 5 evenly spaced timestamp ticks between minX and maxX
    const int tickCount = 5;
    final double step = (maxX - minX) / (tickCount - 1);
    final List<num> xTicks = List.generate(
      tickCount, 
      (i) => (minX + (step * i)),
    );

    return pw.Inseparable(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 15),
          pw.Container(
            height: 200,
            child: pw.Chart(
              grid: pw.CartesianGrid(
                xAxis: pw.FixedAxis<num>(
                  xTicks,
                  format: (value) {
                    final DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                    String dateString;

                    // label presentation depends on interval of time covered by the records
                    switch (mode) {
                      case ChartIntervalMode.lastMonthRecords:
                        dateString = DateFormat("dd/MM").format(date);
                        break;
                      case ChartIntervalMode.lastDayRecords:
                        dateString = DateFormat("HH:mm").format(date);
                        break;
                      case ChartIntervalMode.allRecords:
                        dateString = DateFormat("dd/MM/yyyy").format(date);
                    }

                    return dateString;
                  },
                ),
                // Y-Axis for Pain level (0-10)
                yAxis: pw.FixedAxis<num>(
                  [0, 2, 4, 6, 8, 10],
                ), 
              ),
              datasets: [
                pw.LineDataSet(
                  color: PdfColors.orange,
                  lineWidth: 3,
                  isCurved: true,
                  smoothness: 0.05,
                  data: List<pw.PointChartValue>.generate(
                    chartRecords.length,
                    (i) => pw.PointChartValue(
                      dataX[i], 
                      chartRecords[i].painLevel!.toDouble(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // returns a list of each entry's timestamp for the x-axis
  static List<double> getDataX(List<PainFormData> data) {
    return data.map((entry) => entry.date.millisecondsSinceEpoch.toDouble()).toList();
  }
}