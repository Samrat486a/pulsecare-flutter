import 'package:flutter/material.dart';

/// Bespoke vector logo widget for PulseCare
/// Renders a modern clinical emblem: a curved gradient squircle containing
/// an interconnected medical cross and an active ECG heartbeat waveform.
class PulseCareLogo extends StatelessWidget {
  final double size;
  final bool showBadge;
  final bool showGlow;

  const PulseCareLogo({
    super.key,
    this.size = 56,
    this.showBadge = false,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = size * 0.28;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0284C7), // Vibrant Ocean Cyan
            Color(0xFF1D4ED8), // Royal Medical Blue
            Color(0xFF0F172A), // Deep Navy
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                  blurRadius: size * 0.35,
                  offset: Offset(0, size * 0.12),
                ),
                BoxShadow(
                  color: const Color(0xFF1D4ED8).withValues(alpha: 0.25),
                  blurRadius: size * 0.2,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Custom Drawn ECG Heartbeat + Clinical Cross
          CustomPaint(
            size: Size(size * 0.72, size * 0.72),
            painter: _PulseCarePainter(),
          ),

          // Optional Active Pulse Dot (Top-Right)
          if (showBadge)
            Positioned(
              top: size * 0.12,
              right: size * 0.12,
              child: Container(
                width: size * 0.18,
                height: size * 0.18,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x6610B981),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PulseCarePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Subtle Translucent Clinical Cross Background
    final crossPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    final crossWidth = w * 0.26;
    final crossHeight = h * 0.82;
    final cornerRadius = Radius.circular(w * 0.08);

    // Vertical bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w / 2, h / 2), width: crossWidth, height: crossHeight),
        cornerRadius,
      ),
      crossPaint,
    );

    // Horizontal bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w / 2, h / 2), width: crossHeight, height: crossWidth),
        cornerRadius,
      ),
      crossPaint,
    );

    // 2. Crisp Glowing ECG Heartbeat Pulse Line
    final pulsePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.088
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    // Start flat on the left
    path.moveTo(w * 0.08, h * 0.52);
    // Baseline segment
    path.lineTo(w * 0.28, h * 0.52);
    // Small dip before beat
    path.lineTo(w * 0.36, h * 0.62);
    // Sharp high systolic QRS peak
    path.lineTo(w * 0.50, h * 0.18);
    // Deep diastolic drop
    path.lineTo(w * 0.64, h * 0.84);
    // Recovery spike
    path.lineTo(w * 0.74, h * 0.44);
    // Return to baseline
    path.lineTo(w * 0.80, h * 0.52);
    // End flat on the right
    path.lineTo(w * 0.94, h * 0.52);

    // Draw shadow underneath pulse line for extra depth
    final shadowPulsePaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, shadowPulsePaint);

    // Draw main white pulse line
    canvas.drawPath(path, pulsePaint);

    // 3. Central Vital Dot on Peak
    final dotPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.50, h * 0.18), w * 0.065, dotPaint);

    final dotCore = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.50, h * 0.18), w * 0.035, dotCore);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
