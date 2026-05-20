import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep; 
  final int totalSteps;  

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps * 2 - 1, (index) {
        // If index is even, it's a circle (step)
        if (index % 2 == 0) {
          int stepIndex = index ~/ 2 + 1;
          bool isCompleted = stepIndex < currentStep;
          bool isActive = stepIndex == currentStep;

          return Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted || isActive ? Theme.of(context).colorScheme.primary : Colors.grey[300],
              border: Border.all(
                color: isActive ? Theme.of(context).colorScheme.primary.withAlpha(180) : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : Text(
                      '$stepIndex',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          );
        } 
        // If index is odd, it's a connecting line
        else {
          int stepIndex = index ~/ 2 + 1;
          bool isLineActive = stepIndex < currentStep;

          return Expanded(
            child: Container(
              height: 4,
              color: isLineActive ? Theme.of(context).colorScheme.primary : Colors.grey[300],
            ),
          );
        }
      }),
    );
  }
}