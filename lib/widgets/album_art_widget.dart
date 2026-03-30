import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class AlbumArtWidget extends StatefulWidget {
  final String? imagePath;
  final bool isPlaying;
  final double size;
  final String? previousImagePath; // para la transición

  const AlbumArtWidget({
    super.key,
    this.imagePath,
    required this.isPlaying,
    this.size = 260,
    this.previousImagePath,
  });

  @override
  State<AlbumArtWidget> createState() => _AlbumArtWidgetState();
}

class _AlbumArtWidgetState extends State<AlbumArtWidget>
    with TickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scale;

  late final AnimationController _flipCtrl;
  late final Animation<double> _flip;

  String? _displayedImage;

  @override
  void initState() {
    super.initState();
    _displayedImage = widget.imagePath;

    _scaleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scale = Tween<double>(begin: 0.88, end: 1.0)
        .animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut));
    if (widget.isPlaying) _scaleCtrl.forward();

    _flipCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _flip = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(AlbumArtWidget old) {
    super.didUpdateWidget(old);

    // Animación de escala al play/pause
    widget.isPlaying ? _scaleCtrl.forward() : _scaleCtrl.reverse();

    // Animación flip al cambiar de canción
    if (old.imagePath != widget.imagePath) {
      _flipCtrl.forward(from: 0).then((_) {
        setState(() => _displayedImage = widget.imagePath);
        _flipCtrl.reverse();
      });
    }
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _flipCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ac = context.ac;
    return ScaleTransition(
      scale: _scale,
      child: AnimatedBuilder(
        animation: _flip,
        builder: (_, child) {
          // Efecto flip en el eje Y
          final angle = _flip.value * pi;
          final isFront = _flip.value < 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isFront ? child : Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateY(pi),
              child: child,
            ),
          );
        },
        child: Container(
          width: widget.size, height: widget.size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 48, spreadRadius: 4, offset: const Offset(0, 24)),
              BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, 12)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _displayedImage != null
                ? Image.asset(_displayedImage!, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _Placeholder(size: widget.size, ac: ac))
                : _Placeholder(size: widget.size, ac: ac),
          ),
        ),
      ),
    );
  }
}

// Necesario para la animación flip
const double pi = 3.1415926535897932;

class _Placeholder extends StatelessWidget {
  final double size;
  final AppColorScheme ac;
  const _Placeholder({required this.size, required this.ac});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(gradient: LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [ac.surfaceHigh, ac.surface],
    )),
    child: Center(child: Icon(Icons.music_note_rounded,
        size: size * 0.38, color: ac.textDisabled)),
  );
}
