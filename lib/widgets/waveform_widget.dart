import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// Visualizador de onda animado que simula el espectro de audio.
/// Usa CustomPainter con AnimationController para animar barras suaves.
class WaveformWidget extends StatefulWidget {
  final bool isPlaying;
  final double height;
  final int barCount;

  const WaveformWidget({
    super.key,
    required this.isPlaying,
    this.height = 60,
    this.barCount = 32,
  });

  @override
  State<WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<WaveformWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final Random _rng = Random();
  late List<double> _heights;
  late List<double> _targets;
  late List<double> _speeds;

  @override
  void initState() {
    super.initState();
    _heights = List.generate(widget.barCount, (_) => 0.1);
    _targets = List.generate(widget.barCount, (_) => _rng.nextDouble());
    _speeds  = List.generate(widget.barCount, (_) => 0.02 + _rng.nextDouble() * 0.06);

    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 16))
      ..addListener(_tick)
      ..repeat();
  }

  void _tick() {
    if (!widget.isPlaying) {
      // Si no está reproduciendo, baja suavemente a mínimo
      setState(() {
        for (int i = 0; i < _heights.length; i++) {
          _heights[i] = (_heights[i] - 0.03).clamp(0.05, 1.0);
        }
      });
      return;
    }

    setState(() {
      for (int i = 0; i < _heights.length; i++) {
        // Mueve hacia el target suavemente
        if ((_heights[i] - _targets[i]).abs() < _speeds[i]) {
          // Llegó al target, genera uno nuevo
          _targets[i] = 0.1 + _rng.nextDouble() * 0.9;
          _speeds[i]  = 0.02 + _rng.nextDouble() * 0.06;
        } else if (_heights[i] < _targets[i]) {
          _heights[i] = (_heights[i] + _speeds[i]).clamp(0.05, 1.0);
        } else {
          _heights[i] = (_heights[i] - _speeds[i]).clamp(0.05, 1.0);
        }
      }
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: CustomPaint(
        painter: _WavePainter(
          heights: _heights,
          color: AppColors.primary,
          isPlaying: widget.isPlaying,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final List<double> heights;
  final Color color;
  final bool isPlaying;

  _WavePainter({required this.heights, required this.color, required this.isPlaying});

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / (heights.length * 1.6);
    final gap      = barWidth * 0.6;
    final totalW   = heights.length * (barWidth + gap) - gap;
    double x       = (size.width - totalW) / 2;

    for (int i = 0; i < heights.length; i++) {
      final barH  = size.height * heights[i];
      final top   = (size.height - barH) / 2;
      final alpha = isPlaying ? (0.4 + heights[i] * 0.6) : 0.25;

      final paint = Paint()
        ..color = color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, top, barWidth, barH),
        Radius.circular(barWidth / 2),
      );
      canvas.drawRRect(rect, paint);
      x += barWidth + gap;
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) => true;
}
