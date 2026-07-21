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
            _buildHeader(user),
            pw.SizedBox(height: 20),
            _buildSummary(descendingRecords),
            pw.SizedBox(height: 20),
            _buildDataTable(mostRecentRecords),
            pw.SizedBox(height: 20),
            _buildGraphs(ascendingRecords)
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

  static pw.Widget _buildHeader(UserData user) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Relatório de Dor SignPain - ${user.fullName}',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
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
      headers: ['Data', 'Nível de Dor', 'Área Afetada', 'Frequência', 'Descrição'],
      data: records.map((record) {
        return [
          DateFormat('dd/MM/yyyy').format(record.date),
          record.painLevel.toString(),
          BodyPartsMapper.listToPortuguese(record.bodyParts).join(", "),
          painFrequencyToStringPT(record.frequency),
          record.descriptors.join(", ")
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
  
  static pw.Widget _buildGraphs(List<PainFormData> records) {
    if (records.isEmpty) return pw.SizedBox();

    final dataX = getDataX(records);
    final int maxDays = dataX.isNotEmpty ? dataX.last : 0;

    // date of the most recent entry
    final DateTime lastEntryDate = records.last.date;
    
    // date 30 days before that
    final DateTime thirtyDaysAgo = lastEntryDate.subtract(const Duration(days: 30));
    
    // filtered list of records in last 30 days
    final List<PainFormData> recentRecords = records.where((entry) {
      return entry.date.isAfter(thirtyDaysAgo) || entry.date.isAtSameMomentAs(thirtyDaysAgo);
    }).toList();

    return pw.Inseparable(
      child:pw.Column(
        children: [
          pw.Text("Evolução da Dor", style: pw.TextStyle(fontSize: 20)),
          pw.SizedBox(height: 20),
          _buildChartWidget("Todo o histórico", records),
          if (maxDays > 30 && recentRecords.length > 1) ...[
            pw.SizedBox(height: 30), 
            _buildChartWidget("Últimos 30 Dias", recentRecords),
          ]
        ]
      )
    );
  }

  static pw.Widget _buildChartWidget(String title, List<PainFormData> chartRecords) {
    if (chartRecords.isEmpty) return pw.SizedBox();

    // Calculate limits specifically for this subset of records
    final dataX = getDataX(chartRecords);
    final int maxDays = dataX.isNotEmpty ? dataX.last : 0;
    final DateTime dayOne = chartRecords.first.date;
    final int labelStep = maxDays > 6 ? (maxDays / 5).ceil() : 1;

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
                xAxis: pw.FixedAxis.fromStrings(
                  List.generate(maxDays + 1, (dayIndex) {
                    final DateTime currentDate = dayOne.add(Duration(days: dayIndex));
                    if (dayIndex % labelStep != 0 && dayIndex != maxDays) return '';
                    return "${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}";
                  }),
                  ticks: true,
                ),
                yAxis: pw.FixedAxis([0, 2, 4, 6, 8, 10]), 
              ),
              datasets: [
                pw.LineDataSet(
                  color: PdfColors.orange,
                  lineWidth: 3,
                  isCurved: true,
                  smoothness: 0.05,
                  data: List<pw.PointChartValue>.generate(
                    chartRecords.length,
                    (i) => pw.PointChartValue(dataX[i].toDouble(), chartRecords[i].painLevel!.toDouble()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // returns a list of days passed since first registered form for each submitted form
  static List<int> getDataX(List<PainFormData> data) {
    DateTime dayOne = data.first.date;
    DateTime dayOneAux = DateTime(dayOne.year, dayOne.month, dayOne.day); // 00:00:00 of each day (so that difference >= 24h)
    List<int> days = [0];
    for (var entry in data.skip(1)) {
      DateTime entryDate = entry.date;
      DateTime dateAux = DateTime(entryDate.year, entryDate.month, entryDate.day);

      days.add(dateAux.difference(dayOneAux).inDays); // days elapsed between first registered form and this one
    }
    return days;
  }
}