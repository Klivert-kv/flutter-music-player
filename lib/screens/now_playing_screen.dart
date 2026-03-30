import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:palette_generator/palette_generator.dart';
import '../providers/audio_provider.dart';
import '../providers/library_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/album_art_widget.dart';
import '../widgets/progress_bar_widget.dart';
import '../widgets/player_controls_widget.dart';
import '../widgets/waveform_widget.dart';
import '../widgets/edit_song_dialog.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  Color _dominantColor = const Color(0xFF1A3829);
  Color _textColor = Colors.white;
  String? _lastImagePath;

  /// Extrae el color dominante de la carátula actual.
  Future<void> _extractColor(String? imagePath) async {
    if (imagePath == null || imagePath == _lastImagePath) return;
    _lastImagePath = imagePath;

    try {
      final generator = await PaletteGenerator.fromImageProvider(
        AssetImage(imagePath),
        size: const Size(200, 200),
        maximumColorCount: 20,
      );

      final color = generator.dominantColor?.color ??
          generator.vibrantColor?.color ??
          const Color(0xFF1A3829);

      // Oscurece el color para que el fondo no sea muy brillante
      final hsl = HSLColor.fromColor(color);
      final darkened = hsl
          .withLightness((hsl.lightness * 0.4).clamp(0.05, 0.35))
          .withSaturation((hsl.saturation * 0.8).clamp(0.0, 1.0))
          .toColor();

      // Decide si el texto debe ser blanco o negro
      final luminance = darkened.computeLuminance();
      final textColor = luminance > 0.3 ? Colors.black : Colors.white;

      if (mounted) {
        setState(() {
          _dominantColor = darkened;
          _textColor = textColor;
        });
      }
    } catch (_) {
      // Si falla, usa el color por defecto
    }
  }

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();
    final library = context.watch<LibraryProvider>();
    final raw = audio.currentSong;
    final song = raw != null
        ? raw.copyWith(
            title: library.editedTitle(raw.assetPath),
            artist: library.editedArtist(raw.assetPath),
          )
        : null;
    final isFav = raw != null ? library.isFavorite(raw.assetPath) : false;
    final w = MediaQuery.of(context).size.width;

    // Extrae color cuando cambia la carátula
    _extractColor(song?.imagePath);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _dominantColor,
              Color.lerp(_dominantColor, const Color(0xFF121212), 0.7)!,
              const Color(0xFF121212),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── AppBar manual ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.keyboard_arrow_down_rounded,
                          size: 32, color: _textColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text('REPRODUCIENDO AHORA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _textColor.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          )),
                    ),
                    if (raw != null)
                      IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isFav ? AppColors.primary : _textColor.withValues(alpha: 0.7),
                        ),
                        onPressed: () => library.toggleFavorite(raw.assetPath),
                      ),
                  ],
                ),
              ),

              // ── Contenido scrollable ───────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(children: [
                    const SizedBox(height: 16),

                    // Carátula con flip
                    Center(
                      child: AlbumArtWidget(
                        imagePath: song?.imagePath,
                        isPlaying: audio.isPlaying,
                        size: w * 0.72,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Visualizador de onda
                    WaveformWidget(
                      isPlaying: audio.isPlaying,
                      height: 52,
                      barCount: 36,
                    ),

                    const SizedBox(height: 16),

                    // Título y artista
                    Row(children: [
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song?.title ?? 'Sin cancion',
                            style: TextStyle(
                              color: _textColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            song?.artist ?? '---',
                            style: TextStyle(
                              color: _textColor.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )),
                      if (raw != null)
                        IconButton(
                          icon: Icon(Icons.edit_rounded,
                              color: _textColor.withValues(alpha: 0.6), size: 20),
                          onPressed: () => showEditSongDialog(context, raw),
                        ),
                    ]),

                    const SizedBox(height: 16),
                    const ProgressBarWidget(),
                    const SizedBox(height: 16),
                    const PlayerControlsWidget(),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
