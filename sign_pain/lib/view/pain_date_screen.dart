import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sign_pain/model/pain_form_data.dart';
import 'package:sign_pain/view/pain_body_screen.dart';
import 'package:sign_pain/widgets/step_indicator.dart';

class PainDateScreen extends StatefulWidget {
  const PainDateScreen({super.key, required this.formData, this.editing = false});

  final PainFormData formData;
  final bool editing; // false: form is new, true: form is an already existing one

  @override
  State<PainDateScreen> createState() => _PainDateScreenState();
}

class _PainDateScreenState extends State<PainDateScreen> {

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      floatingActionButtonLocation: .centerFloat,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            showDialog(
              context: context,
              useRootNavigator: true,
              builder: (BuildContext dialogContext) {
                return Dialog(  
                  child: SizedBox(
                    height: size.height*0.25,
                    child: Padding(
                      padding: EdgeInsetsGeometry.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Text('Cancelar registo da dor?', style: TextStyle(fontSize: 20, fontWeight: .bold)),
                          const Text('Irá perder estes dados.', style: TextStyle(fontSize: 18)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                },
                                child: Text(
                                  'Continuar',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 14
                                  )
                                )
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
                                },
                                child: const Text(
                                  'Sair',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14
                                  )
                                )
                              ),
                            ]
                          ),
                        ],
                      ),
                    )
                  )
                );
              }
            );
          },
          icon: Icon(Icons.close)  
        ),
        title: Text("Registo de dor"),
        centerTitle: true,
        elevation: 4
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.directional(start: 20, end: 20, top: 10, bottom: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              "Quando sentiu a dor? 🕒", 
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),

          // date/time field
          InkWell(
            onTap: _pickDateTime, // triggers the dialogs
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.primary),
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.primary.withAlpha(25), 
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 15),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(widget.formData.date),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Icon(Icons.edit, color: Theme.of(context).colorScheme.primary, size: 20),
                ],
              ),
            ),
          ),
        ]
        )
      ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width, // Forces full screen width calculation
        child:Padding(
          // padding to match standard screen margins
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Pushes buttons to opposite ends
            children: [
              FloatingActionButton(
                heroTag: 'btn_back', // CRUCIAL: Unique tag prevents animation crashes!
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(Icons.arrow_back),
              ),
              // included step indicator here to make it align with FABs
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0), 
                  child: StepIndicator(
                    currentStep: 1, // step 1 of the pain form
                    totalSteps: 6,  // of 6 pages total 
                  ),
                ),
              ),
              FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                    builder: (context) => PainBodyScreen(formData: widget.formData, editing: widget.editing),
                    ),
                  );
                },
                tooltip: 'pain type',
                child: const Icon(Icons.arrow_forward)
              ),
            ]
          )
        )
      )
    );
  }

  Future<void> _pickDateTime() async {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // show the calendar
    await showCupertinoModalPopup(
      context: context,
      builder: (popupContext) => Container(
        height: 300, 
        color: Theme.of(context).scaffoldBackgroundColor,
        
        child: CupertinoTheme(
          data: CupertinoThemeData(
            brightness: isDarkMode ? Brightness.dark : Brightness.light,
            textTheme: CupertinoTextThemeData(
              dateTimePickerTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface, // Uses high-contrast text color
                fontSize: 20,
              ),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    child: const Text('Concluído'),
                    onPressed: () => Navigator.of(popupContext).pop(),
                  )
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  use24hFormat: true,
                  initialDateTime: widget.formData.date, 
                  // restrict it so you can't log pain in the future
                  maximumDate: DateTime.now(), 
                  onDateTimeChanged: (DateTime pickedDate) {
                    setState(() {
                      widget.formData.date = pickedDate;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}