import 'package:flutter/material.dart';
import 'package:sign_pain_admin/model/pain_descriptor_data.dart';

class PainDescriptorWidget extends StatelessWidget {
  const PainDescriptorWidget({super.key, required this.painDescriptorData, this.isCommon = true});

  final PainDescriptorData painDescriptorData;
  final bool isCommon;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      backgroundColor: isCommon ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary,
      label: Text("${painDescriptorData.descriptorName} ${painDescriptorData.associatedSymbol}", style: TextStyle(color: isCommon ? Theme.of(context).colorScheme.onTertiary : Theme.of(context).colorScheme.onPrimary)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onPressed: () => _showDetailsDialog(context)
    );
  }
  // dialog which provides user explanation of what descriptor means
  // TODO add sign language translation option and video
  void _showDetailsDialog(BuildContext context) {
    final dialogWidth = MediaQuery.widthOf(context)*0.6;
    final dialogHeight = MediaQuery.heightOf(context)* 0.6;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: isCommon ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary,
          scrollable: true,
          title: Center(child: Text("${painDescriptorData.descriptorName} ${painDescriptorData.associatedSymbol}", style: TextStyle(color: isCommon ? Theme.of(context).colorScheme.onTertiary : Theme.of(context).colorScheme.onPrimary))),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: dialogWidth,
              maxHeight: dialogHeight
            ),
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 12),
              child: SingleChildScrollView(
                child: Text(painDescriptorData.description, style: TextStyle(color: isCommon ? Theme.of(context).colorScheme.onTertiary : Theme.of(context).colorScheme.onPrimary))
              )
            )
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isCommon ? Theme.of(context).colorScheme.onTertiary : Theme.of(context).colorScheme.onPrimary, 
                foregroundColor: isCommon ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary, // Dark text matching dialog theme
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Fechar", style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }
}