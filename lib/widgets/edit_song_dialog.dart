import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../providers/library_provider.dart';
import '../utils/app_theme.dart';

Future<void> showEditSongDialog(BuildContext context, Song song) async {
  final library = context.read<LibraryProvider>();
  final ac = context.ac;
  final titleCtrl = TextEditingController(text: song.title);
  final artistCtrl = TextEditingController(text: song.artist);

  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            backgroundColor: ac.surfaceHigh,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Editar canción',
                style: TextStyle(color: ac.textPrimary, fontWeight: FontWeight.bold)),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: titleCtrl,
                style: TextStyle(color: ac.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Título',
                  prefixIcon: Icon(Icons.music_note_rounded, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: artistCtrl,
                style: TextStyle(color: ac.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Artista',
                  prefixIcon: Icon(Icons.person_rounded, color: ac.textSecondary),
                ),
              ),
            ]),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Cancelar', style: TextStyle(color: ac.textSecondary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  final newTitle = titleCtrl.text.trim().isEmpty ? song.title : titleCtrl.text.trim();
                  final newArtist = artistCtrl.text.trim().isEmpty ? song.artist : artistCtrl.text.trim();
                  // Guardamos sin await para evitar el problema de contexto
                  library.editSongMeta(song.assetPath, newTitle, newArtist);
                  Navigator.of(ctx).pop();
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      );
    },
  );

  titleCtrl.dispose();
  artistCtrl.dispose();
}