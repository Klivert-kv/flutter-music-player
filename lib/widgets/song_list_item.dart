import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../providers/library_provider.dart';
import '../utils/app_theme.dart';

class SongListItem extends StatelessWidget {
  final Song song;
  final int index;
  final bool isSelected;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onAddToPlaylist;

  const SongListItem({
    super.key, required this.song, required this.index,
    required this.isSelected, required this.isPlaying,
    required this.onTap, this.onEdit, this.onAddToPlaylist,
  });

  @override
  Widget build(BuildContext context) {
    final ac = context.ac;
    final library = context.watch<LibraryProvider>();
    final isFav = library.isFavorite(song.assetPath);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? ac.surfaceHigh : Colors.transparent,
        ),
        child: Row(children: [
          SizedBox(width: 26,
            child: isSelected
                ? _EqIndicator(isPlaying: isPlaying)
                : Text('${index + 1}', textAlign: TextAlign.center,
                    style: TextStyle(color: ac.textSecondary, fontSize: 13)),
          ),
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(width: 46, height: 46,
              child: song.imagePath != null
                  ? Image.asset(song.imagePath!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _MusicIcon(isSelected: isSelected, ac: ac))
                  : _MusicIcon(isSelected: isSelected, ac: ac),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : ac.textPrimary,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                )),
            const SizedBox(height: 2),
            Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: ac.textSecondary, fontSize: 12)),
          ])),
          GestureDetector(
            onTap: () => library.toggleFavorite(song.assetPath),
            child: Padding(padding: const EdgeInsets.all(6),
              child: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFav ? AppColors.primary : ac.textDisabled, size: 18)),
          ),
          GestureDetector(
            onTap: () => _showOptions(context, library),
            child: Padding(padding: const EdgeInsets.all(6),
              child: Icon(Icons.more_vert_rounded, color: ac.textDisabled, size: 18)),
          ),
        ]),
      ),
    );
  }

  void _showOptions(BuildContext context, LibraryProvider library) {
    final ac = context.ac;
    showModalBottomSheet(
      context: context,
      backgroundColor: ac.surfaceHigh,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 36, height: 4,
            decoration: BoxDecoration(color: ac.textDisabled, borderRadius: BorderRadius.circular(2))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(song.title, style: TextStyle(color: ac.textPrimary, fontWeight: FontWeight.bold, fontSize: 15))),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.edit_rounded, color: AppColors.primary),
          title: Text('Editar nombre / artista', style: TextStyle(color: ac.textPrimary)),
          onTap: () { Navigator.pop(context); if (onEdit != null) onEdit!(); },
        ),
        ListTile(
          leading: Icon(Icons.playlist_add_rounded, color: ac.textSecondary),
          title: Text('Agregar a playlist', style: TextStyle(color: ac.textPrimary)),
          onTap: () { Navigator.pop(context); if (onAddToPlaylist != null) onAddToPlaylist!(); },
        ),
        ListTile(
          leading: Icon(library.isFavorite(song.assetPath) ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: AppColors.primary),
          title: Text(library.isFavorite(song.assetPath) ? 'Quitar de favoritos' : 'Agregar a favoritos',
              style: TextStyle(color: ac.textPrimary)),
          onTap: () { Navigator.pop(context); library.toggleFavorite(song.assetPath); },
        ),
        const SizedBox(height: 8),
      ])),
    );
  }
}

class _MusicIcon extends StatelessWidget {
  final bool isSelected;
  final AppColorScheme ac;
  const _MusicIcon({required this.isSelected, required this.ac});
  @override
  Widget build(BuildContext context) => Container(
    color: ac.surface,
    child: Icon(Icons.music_note_rounded, size: 22,
        color: isSelected ? AppColors.primary : ac.textDisabled),
  );
}

class _EqIndicator extends StatelessWidget {
  final bool isPlaying;
  const _EqIndicator({required this.isPlaying});
  @override
  Widget build(BuildContext context) {
    if (!isPlaying) return const Center(child: Icon(Icons.pause_rounded, color: AppColors.primary, size: 16));
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _AnimBar(maxH: 10, ms: 400), SizedBox(width: 2),
        _AnimBar(maxH: 16, ms: 600), SizedBox(width: 2),
        _AnimBar(maxH: 8,  ms: 500),
      ],
    );
  }
}

class _AnimBar extends StatefulWidget {
  final double maxH;
  final int ms;
  const _AnimBar({required this.maxH, required this.ms});
  @override
  State<_AnimBar> createState() => _AnimBarState();
}

class _AnimBarState extends State<_AnimBar> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _h;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: Duration(milliseconds: widget.ms))..repeat(reverse: true);
    _h = Tween<double>(begin: 3, end: widget.maxH).animate(_c);
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _h,
    builder: (_, __) => Container(
      width: 3, height: _h.value,
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
    ),
  );
}
