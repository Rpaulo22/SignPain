import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sign_pain/model/pain_form_data.dart';
import 'package:sign_pain/model/user_data.dart';
import 'package:sign_pain/utils/pdf_service.dart'; 

class ReportDialog extends StatefulWidget {
  final UserData user;
  final List<PainFormData> userEntries;

  const ReportDialog({
    super.key,
    required this.user,
    required this.userEntries,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  // first and last entries timewise
  late final DateTime firstDay;
  late final DateTime lastDay;

  late TextEditingController selectedFirstDayController;
  late TextEditingController selectedLastDayController;

  var selectedFirstDay;
  var selectedLastDay;

  @override
  void initState() {
    super.initState();

    // list is ordered descending by date, so the last entry is the oldest, and the most recent the first
    final firstEntryDate = widget.userEntries.last.date;
    final lastEntryDate = widget.userEntries.first.date;

    firstDay = DateTime(firstEntryDate.year, firstEntryDate.month, firstEntryDate.day); // that day at midnight
    lastDay = DateTime(lastEntryDate.year, lastEntryDate.month, lastEntryDate.day); // that day at midnight

    selectedFirstDay = firstDay;
    selectedLastDay = lastDay;

    selectedFirstDayController = TextEditingController(text: DateFormat("dd/MM/yyyy").format(firstDay));
    selectedLastDayController = TextEditingController(text: DateFormat("dd/MM/yyyy").format(lastDay));
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Partilhar relatório de dor"),
      content: Column(
        mainAxisSize: MainAxisSize.min, 
        children: [
          Text("Entre..."),
          SizedBox(height: 10),
          TextFormField(
            controller: selectedFirstDayController,
            readOnly: true,
            decoration: const InputDecoration(labelText: "Primeiro dia"),
            onTap: () => _pickDate(
              context: context,
              helpText: "Primeiro dia de registo",
              initialDate: firstDay,
              firstDate: firstDay,
              lastDate: selectedLastDay,
              onDateSelected: (date) {
                setState(() {
                  selectedFirstDay = date;
                  selectedFirstDayController.text = DateFormat('dd/MM/yyyy').format(date);
                });
              },
            )
          ),
          SizedBox(height: 10),
          Text("e..."),
          SizedBox(height: 10),
          TextFormField(
            controller: selectedLastDayController,
            readOnly: true,
            decoration: const InputDecoration(labelText: "Último dia"),
            onTap: () => _pickDate(
              context: context,
              helpText: "Último dia de registo",
              initialDate: lastDay,
              firstDate: selectedFirstDay,
              lastDate: lastDay,
              onDateSelected: (date) {
                setState(() {
                  selectedLastDay = date;
                  selectedLastDayController.text = DateFormat('dd/MM/yyyy').format(date);
                });
              },
            )
          ),
          SizedBox(height: 40),
          TextButton(
            onPressed: () async {
              try {
                final file = await PdfService.generateAndSharePainReport(widget.userEntries, widget.user, selectedFirstDay, selectedLastDay);

                if (!context.mounted) return;

                Navigator.of(context).pop();

                await SharePlus.instance.share(
                  ShareParams(
                    files: [XFile(file.path)],
                    text: 'Aqui está o meu relatório de dor exportado do SignPain.',
                    title: 'Relatório de dor SignPain'
                  ),
                );
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop(); 
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Erro ao gerar resumo: $e")),
                  );
                }
              } 
            },
            child: Text(
              "Partilhar", 
              style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _pickDate({
    required BuildContext context,
    required String helpText,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,

    required Function(DateTime) onDateSelected, 
  }) async {
    // to make sure that the calendar does not crash
    DateTime safeInitialDate = initialDate;
    if (safeInitialDate.isBefore(firstDate)) safeInitialDate = firstDate;
    if (safeInitialDate.isAfter(lastDate)) safeInitialDate = lastDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: helpText,
      initialDatePickerMode: DatePickerMode.day,
    );

    if (picked != null) {
      // Pass the picked date back out!
      onDateSelected(picked); 
    }
  }
}