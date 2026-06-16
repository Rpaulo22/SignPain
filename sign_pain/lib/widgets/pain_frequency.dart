import 'package:flutter/material.dart';

enum PainFrequency { continuous, intermittent, spontaneous, none}

class FrequencyGraphIcon extends StatelessWidget {
  final PainFrequency frequency;
  final Color color;

  const FrequencyGraphIcon({
    super.key,
    required this.frequency,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 30,
      child: CustomPaint(
        painter: _GraphPainter(frequency: frequency, color: color),
      ),
    );
  }
}

class _GraphPainter extends CustomPainter {
  final PainFrequency frequency;
  final Color color;

  _GraphPainter({required this.frequency, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final w = size.width;
    final h = size.height;
    final midY = h / 2;

    switch (frequency) {
      case PainFrequency.continuous:
        // A steady, flat horizontal line
        path.moveTo(0, midY);
        path.lineTo(w, midY);
        break;

      case PainFrequency.intermittent:
        // A repeating, smooth wave
        path.moveTo(0, midY);
        path.quadraticBezierTo(w * 0.25, 0, w * 0.5, midY);
        path.quadraticBezierTo(w * 0.75, h, w, midY);
        break;

      case PainFrequency.spontaneous:
        // A flat line with a sudden, sharp spike in the middle
        path.moveTo(0, midY);
        path.lineTo(w * 0.35, midY);
        path.lineTo(w * 0.5, h * 0.1); // spike
        path.lineTo(w * 0.65, midY);
        path.lineTo(w, midY);
        break;

      case PainFrequency.none:
        // A steady, flat horizontal line in y = 0
        path.moveTo(0, 0);
        path.lineTo(w, 0);
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) {
    return oldDelegate.frequency != frequency || oldDelegate.color != color;
  }
}

String painFrequencyToString(PainFrequency frequency) {
  // change pain frequency to string format
  switch (frequency) {
    case PainFrequency.continuous: 
      return "continuous";
    case PainFrequency.intermittent: 
      return "intermittent";
    case PainFrequency.spontaneous: 
      return "spontaneous";
    default: 
      return "none";
  }
}

String painFrequencyToStringPT(PainFrequency frequency) {
  // change pain frequency to string format
  switch (frequency) {
    case PainFrequency.continuous: 
      return "Contínua";
    case PainFrequency.intermittent: 
      return "Intermitente";
    case PainFrequency.spontaneous: 
      return "Espontânea";
    default: 
      return "Nenhuma";
  }
}