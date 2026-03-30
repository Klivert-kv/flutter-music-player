import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/playlist.dart';
import '../providers/audio_provider.dart';
import '../providers/library_provider.dart';
import '../utils/app_theme.dart';
import 'playlist_detail_screen.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ac = context.ac;
    final library = context.watch<LibraryProvider>();
    final audio = context.watch<AudioProvider>();
    final allSongs = library.applyEdits(audio.songs);
    final favSongs = allSongs.where((s) => library.isFavorite(s.assetPath)).toList();

    return Scaffold(
      backgroundColor: ac.background,
      appBar: AppBar(
        title: const Text('PLAYLISTS'),
        actions: [
          IconButton(icon: const Icon(Icons.add_rounded), onPressed: () => _showCreateDialog(context)),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        _Card(icon: Icons.favorite_rounded, iconColor: AppColors.primary,
            name: 'Favoritos', count: favSongs.length,
            onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => PlaylistDetailScreen(name: 'Favoritos', songs: favSongs)))),
        const SizedBox(height: 8),
        _Card(icon: Icons.library_music_rounded, iconColor: Colors.blueAccent,
            name: 'Todas las canciones', count: allSongs.length,
            onTap: () { audio.clearQueue(); Navigator.pop(context); }),
        if (library.playlists.isNotEmpty) ...[
          const SizedBox(height: 16),
          Padding(padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text('MIS PLAYLISTS', style: TextStyle(
                  color: ac.textSecondary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5))),
          ...library.playlists.map((pl) {
            final plSongs = allSongs.where((s) => pl.songPaths.contains(s.assetPath)).toList();
            return _Card(
              name: pl.name, count: plSongs.length,
              icon: Icons.queue_music_rounded, iconColor: Colors.purpleAccent,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => PlaylistDetailScreen(name: pl.name, songs: plSongs, playlist: pl))),
              onDelete: () => library.deletePlaylist(pl.id),
              onRename: () => _showRenameDialog(context, pl),
            );
          }),
        ],
        const SizedBox(height: 80),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.black),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final ctrl = TextEditingController();
    final ac = context.ac;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ac.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Nueva playlist', style: TextStyle(color: ac.textPrimary, fontWeight: FontWeight.bold)),
        content: TextField(controller: ctrl, autofocus: true,
            style: TextStyle(color: ac.textPrimary),
            decoration: const InputDecoration(labelText: 'Nombre',
                prefixIcon: Icon(Icons.queue_music_rounded, color: AppColors.primary))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar', style: TextStyle(color: ac.textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              if (ctrl.text.trim().isNotEmpty) {
                await context.read<LibraryProvider>().createPlaylist(ctrl.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, Playlist pl) {
    final ctrl = TextEditingController(text: pl.name);
    final ac = context.ac;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ac.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Renombrar', style: TextStyle(color: ac.textPrimary, fontWeight: FontWeight.bold)),
        content: TextField(controller: ctrl, autofocus: true,
            style: TextStyle(color: ac.textPrimary),
            decoration: const InputDecoration(labelText: 'Nuevo nombre')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar', style: TextStyle(color: ac.textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              if (ctrl.text.trim().isNotEmpty) {
                await context.read<LibraryProvider>().renamePlaylist(pl.id, ctrl.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String name;
  final int count;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onRename;
  const _Card({required this.name, required this.count, required this.icon,
      required this.iconColor, required this.onTap, this.onDelete, this.onRename});

  @override
  Widget build(BuildContext context) {
    final ac = context.ac;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: ac.surface, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Container(width: 46, height: 46,
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 24)),
        title: Text(name, style: TextStyle(color: ac.textPrimary, fontWeight: FontWeight.w600)),
        subtitle: Text('\ canciones', style: TextStyle(color: ac.textSecondary, fontSize: 12)),
        trailing: (onDelete != null || onRename != null)
            ? PopupMenuButton<String>(
                color: ac.surfaceHigh,
                icon: Icon(Icons.more_vert_rounded, color: ac.textDisabled),
                onSelected: (v) {
                  if (v == 'rename' && onRename != null) onRename!();
                  if (v == 'delete' && onDelete != null) onDelete!();
                },
                itemBuilder: (_) => [
                  if (onRename != null) PopupMenuItem(value: 'rename',
                      child: Text('Renombrar', style: TextStyle(color: ac.textPrimary))),
                  if (onDelete != null) const PopupMenuItem(value: 'delete',
                      child: Text('Eliminar', style: TextStyle(color: Colors.redAccent))),
                ])
            : const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
      ),
    );
  }
}
