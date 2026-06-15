import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // 'pw' to avoid conflicts with standard Flutter widgets
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:sign_pain/model/pain_form_data.dart';

class PdfService {
  
  // function which generates a pdf report of the user's pain records and allows the user to share it
  static Future<File> generateAndSharePainReport(List<PainFormData> records) async {
    final pdf = pw.Document();

    final regularFontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final boldFontData = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");
    final italicFontData = await rootBundle.load("assets/fonts/Roboto-Italic.ttf");

    final robotoRegular = pw.Font.ttf(regularFontData);
    final robotoBold = pw.Font.ttf(boldFontData);
    final robotoItalic = pw.Font.ttf(italicFontData);

    // Sort records chronologically
    final sortedRecords = List<PainFormData>.from(records)
      ..sort((a, b) => b.date!.compareTo(a.date!));

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
            _buildHeader(),
            pw.SizedBox(height: 20),
            _buildSummary(sortedRecords),
            pw.SizedBox(height: 20),
            _buildDataTable(sortedRecords),
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

  static pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Relatório de Dor - SignPain',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
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
      headers: ['Data', 'Nível de Dor', 'Área Afetada', 'Descrição'],
      data: records.map((record) {
        return [
          DateFormat('dd/MM/yyyy').format(record.date!),
          record.painLevel.toString(),
          BodyPartsMapper.listToPortuguese(record.bodyParts).join(", "), // Assuming you have a list of areas
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
}