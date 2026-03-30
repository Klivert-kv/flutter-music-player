import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/library_provider.dart';
import '../utils/app_theme.dart';
import '../utils/time_utils.dart';
import '../widgets/song_list_item.dart';
import '../widgets/edit_song_dialog.dart';
import 'now_playing_screen.dart';
import 'playlists_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  bool _showSearch = false;

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final ac = context.ac;
    return Scaffold(
      backgroundColor: ac.background,
      body: Column(children: [
        _Header(
          showSearch: _showSearch,
          searchCtrl: _searchCtrl,
          query: _query,
          onToggleSearch: () {
            setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) { _query = ''; _searchCtrl.clear(); }
            });
          },
          onQueryChanged: (v) => setState(() => _query = v),
        ),
        Expanded(child: _SongList(query: _query)),
        const _MiniPlayer(),
      ]),
    );
  }
}

// ── Encabezado ────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final bool showSearch;
  final TextEditingController searchCtrl;
  final String query;
  final VoidCallback onToggleSearch;
  final ValueChanged<String> onQueryChanged;

  const _Header({
    required this.showSearch, required this.searchCtrl, required this.query,
    required this.onToggleSearch, required this.onQueryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ac = context.ac;
    final isDark = context.watch<LibraryProvider>().isDarkMode;

    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: isDark
            ? [const Color(0xFF1A3829), AppColors.bgDark]
            : [const Color(0xFFD4EFD4), AppColors.bgLight],
      )),
      child: SafeArea(bottom: false, child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
          child: Row(children: [
            Container(width: 32, height: 32,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                child: const Icon(Icons.music_note_rounded, color: Colors.black, size: 18)),
            const SizedBox(width: 10),
            Text('Mi Biblioteca', style: TextStyle(color: ac.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const Spacer(),
            Consumer<AudioProvider>(builder: (_, a, __) =>
                Text('${a.songs.length}', style: TextStyle(color: ac.textSecondary, fontSize: 13))),
            // Buscador toggle
            IconButton(
              icon: Icon(showSearch ? Icons.search_off_rounded : Icons.search_rounded,
                  color: showSearch ? AppColors.primary : ac.textSecondary),
              onPressed: onToggleSearch,
            ),
            IconButton(icon: Icon(Icons.queue_music_rounded, color: ac.textSecondary),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlaylistsScreen()))),
            IconButton(icon: Icon(Icons.settings_rounded, color: ac.textSecondary),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
          ]),
        ),
        // Barra de búsqueda animada
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: showSearch ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: const SizedBox(height: 0),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: searchCtrl,
              autofocus: true,
              onChanged: onQueryChanged,
              style: TextStyle(color: ac.textPrimary),
              decoration: InputDecoration(
                hintText: 'Buscar cancion o artista...',
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, color: ac.textSecondary),
                        onPressed: () { searchCtrl.clear(); onQueryChanged(''); },
                      )
                    : null,
              ),
            ),
          ),
        ),
      ])),
    );
  }
}

// ── Lista de canciones ────────────────────────────────────────────────────────
class _SongList extends StatelessWidget {
  final String query;
  const _SongList({required this.query});

  @override
  Widget build(BuildContext context) {
    final ac = context.ac;
    return Consumer2<AudioProvider, LibraryProvider>(builder: (_, audio, library, __) {
      var songs = library.applyEdits(audio.songs);

      // Filtrar por búsqueda
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        songs = songs.where((s) =>
            s.title.toLowerCase().contains(q) ||
            s.artist.toLowerCase().contains(q)).toList();
      }

      if (songs.isEmpty) {
        return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(
          mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(query.isNotEmpty ? Icons.search_off_rounded : Icons.audio_file_outlined,
                size: 72, color: ac.textDisabled),
            const SizedBox(height: 16),
            Text(query.isNotEmpty ? 'Sin resultados para "$query"' : 'No hay canciones',
                style: TextStyle(color: ac.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            if (query.isEmpty) ...[
              const SizedBox(height: 8),
              Text('Agrega .mp3 en assets/audio/ y ejecuta flutter run',
                  style: TextStyle(color: ac.textSecondary, fontSize: 14, height: 1.6),
                  textAlign: TextAlign.center),
            ],
          ],
        )));
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: songs.length,
        itemBuilder: (_, i) {
          // Índice real en la lista completa para el reproductor
          final realIndex = audio.songs.indexWhere((s) => s.assetPath == songs[i].assetPath);
          return SongListItem(
            song: songs[i], index: i,
            isSelected: audio.currentSong?.assetPath == songs[i].assetPath,
            isPlaying: audio.currentSong?.assetPath == songs[i].assetPath && audio.isPlaying,
            onTap: () => audio.playSongAt(realIndex),
            onEdit: () => showEditSongDialog(context, songs[i]),
            onAddToPlaylist: () => _showAddToPlaylist(context, songs[i].assetPath, library),
          );
        },
      );
    });
  }

  void _showAddToPlaylist(BuildContext context, String assetPath, LibraryProvider library) {
    final ac = context.ac;
    if (library.playlists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Crea una playlist primero'),
        backgroundColor: ac.surfaceHigh, behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: ac.surfaceHigh,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheetCtx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(margin: const EdgeInsets.only(top: 10, bottom: 6), width: 36, height: 4,
            decoration: BoxDecoration(color: ac.textDisabled, borderRadius: BorderRadius.circular(2))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text('Agregar a playlist',
                style: TextStyle(color: ac.textPrimary, fontWeight: FontWeight.bold, fontSize: 15))),
        ...library.playlists.map((pl) => ListTile(
          leading: const Icon(Icons.queue_music_rounded, color: AppColors.primary),
          title: Text(pl.name, style: TextStyle(color: ac.textPrimary)),
          onTap: () async {
            await library.addToPlaylist(pl.id, assetPath);
            if (sheetCtx.mounted) Navigator.pop(sheetCtx);
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Agregada a "${pl.name}"'),
              backgroundColor: ac.surfaceHigh, behavior: SnackBarBehavior.floating,
            ));
          },
        )),
        const SizedBox(height: 8),
      ])),
    );
  }
}

// ── Mini reproductor ──────────────────────────────────────────────────────────
class _MiniPlayer extends StatelessWidget {
  const _MiniPlayer();

  @override
  Widget build(BuildContext context) {
    final ac = context.ac;
    return Consumer2<AudioProvider, LibraryProvider>(builder: (_, audio, library, __) {
      if (!audio.hasSongs) return const SizedBox.shrink();
      final raw = audio.currentSong;
      final song = raw != null
          ? raw.copyWith(title: library.editedTitle(raw.assetPath), artist: library.editedArtist(raw.assetPath))
          : null;

      return GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NowPlayingScreen())),
        child: Container(
          decoration: BoxDecoration(color: ac.surfaceHigh,
              border: Border(top: BorderSide(color: ac.divider, width: 0.5))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _ThinProgress(audio: audio, ac: ac),
            SafeArea(top: false, child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(children: [
                ClipRRect(borderRadius: BorderRadius.circular(6),
                  child: SizedBox(width: 46, height: 46,
                    child: song?.imagePath != null
                        ? Image.asset(song!.imagePath!, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: ac.surface,
                                child: Icon(Icons.music_note_rounded,
                                    color: audio.isPlaying ? AppColors.primary : ac.textDisabled)))
                        : Container(color: ac.surface,
                            child: Icon(Icons.music_note_rounded,
                                color: audio.isPlaying ? AppColors.primary : ac.textDisabled)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Text(song?.title ?? '---', maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: ac.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                  Text('${TimeUtils.format(audio.position)} / ${TimeUtils.format(audio.duration)}',
                      style: TextStyle(color: ac.textSecondary, fontSize: 12)),
                ])),
                IconButton(icon: Icon(Icons.skip_previous_rounded, color: ac.textPrimary), iconSize: 28, onPressed: audio.previousSong),
                IconButton(icon: Icon(audio.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: AppColors.primary),
                    iconSize: 34, onPressed: audio.togglePlayPause),
                IconButton(icon: Icon(Icons.skip_next_rounded, color: ac.textPrimary), iconSize: 28, onPressed: audio.nextSong),
              ]),
            )),
          ]),
        ),
      );
    });
  }
}

class _ThinProgress extends StatelessWidget {
  final AudioProvider audio;
  final AppColorScheme ac;
  const _ThinProgress({required this.audio, required this.ac});
  @override
  Widget build(BuildContext context) {
    double v = 0;
    if (audio.duration.inMilliseconds > 0) {
      v = (audio.position.inMilliseconds / audio.duration.inMilliseconds).clamp(0.0, 1.0);
    }
    return LinearProgressIndicator(value: v,
        backgroundColor: ac.progressBg,
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
        minHeight: 2);
  }
}
