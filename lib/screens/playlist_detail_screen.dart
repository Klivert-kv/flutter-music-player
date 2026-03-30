import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../providers/audio_provider.dart';
import '../providers/library_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/edit_song_dialog.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final String name;
  final List<Song> songs;
  final Playlist? playlist;

  const PlaylistDetailScreen({super.key, required this.name, required this.songs, this.playlist});

  @override
  Widget build(BuildContext context) {
    final ac = context.ac;
    final audio = context.watch<AudioProvider>();
    final library = context.watch<LibraryProvider>();

    return Scaffold(
      backgroundColor: ac.background,
      appBar: AppBar(title: Text(name.toUpperCase())),
      body: songs.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.queue_music_rounded, size: 64, color: ac.textDisabled),
              const SizedBox(height: 16),
              Text('Playlist vacía', style: TextStyle(color: ac.textSecondary, fontSize: 16)),
              const SizedBox(height: 8),
              Text('Agrega canciones desde la lista principal',
                  style: TextStyle(color: ac.textDisabled, fontSize: 13)),
            ]))
          : Column(children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 28),
                    label: Text('Reproducir todo (${songs.length})',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    onPressed: () { audio.playQueue(songs); Navigator.pop(context); },
                  ),
                ),
              ),
              Expanded(child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: songs.length,
                itemBuilder: (_, i) {
                  final song = songs[i];
                  final isSelected = audio.currentSong?.assetPath == song.assetPath;
                  return ListTile(
                    onTap: () { audio.playQueue(songs, startIndex: i); Navigator.pop(context); },
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(width: 46, height: 46,
                        child: song.imagePath != null
                            ? Image.asset(song.imagePath!, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(color: ac.surface,
                                    child: Icon(Icons.music_note_rounded, color: ac.textDisabled, size: 22)))
                            : Container(color: ac.surface,
                                child: Icon(Icons.music_note_rounded,
                                    color: isSelected ? AppColors.primary : ac.textDisabled, size: 22)),
                      ),
                    ),
                    title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected ? AppColors.primary : ac.textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 14,
                        )),
                    subtitle: Text(song.artist, style: TextStyle(color: ac.textSecondary, fontSize: 12)),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                        icon: Icon(Icons.edit_rounded, color: ac.textDisabled, size: 18),
                        onPressed: () => showEditSongDialog(context, song),
                      ),
                      if (playlist != null)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent, size: 20),
                          onPressed: () => library.removeFromPlaylist(playlist!.id, song.assetPath),
                        ),
                    ]),
                  );
                },
              )),
            ]),
    );
  }
}
