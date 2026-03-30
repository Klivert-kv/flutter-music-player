import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../utils/app_theme.dart';

class PlayerControlsWidget extends StatelessWidget {
  const PlayerControlsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ac = context.ac;
    return Consumer<AudioProvider>(builder: (_, audio, __) {
      final on = audio.hasSongs;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.shuffle_rounded,
                color: audio.shuffle ? AppColors.primary : ac.textSecondary),
            iconSize: 24, onPressed: audio.toggleShuffle,
          ),
          IconButton(
            icon: Icon(Icons.skip_previous_rounded,
                color: on ? ac.textPrimary : ac.textDisabled),
            iconSize: 36, onPressed: on ? audio.previousSong : null,
          ),
          _PlayPauseBtn(isPlaying: audio.isPlaying, onTap: on ? audio.togglePlayPause : null),
          IconButton(
            icon: Icon(Icons.skip_next_rounded,
                color: on ? ac.textPrimary : ac.textDisabled),
            iconSize: 36, onPressed: on ? audio.nextSong : null,
          ),
          _RepeatBtn(mode: audio.repeatMode, onTap: audio.cycleRepeatMode),
        ],
      );
    });
  }
}

class _RepeatBtn extends StatelessWidget {
  final SongRepeatMode mode;
  final VoidCallback onTap;
  const _RepeatBtn({required this.mode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ac = context.ac;
    final IconData icon;
    final Color color;
    if (mode == SongRepeatMode.none) {
      icon  = Icons.repeat_rounded;
      color = ac.textSecondary;
    } else if (mode == SongRepeatMode.all) {
      icon  = Icons.repeat_rounded;
      color = AppColors.primary;
    } else {
      icon  = Icons.repeat_one_rounded;
      color = AppColors.primary;
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: IconButton(
        key: ValueKey(mode),
        icon: Icon(icon, color: color),
        iconSize: 24, onPressed: onTap,
        tooltip: mode == SongRepeatMode.none ? 'Sin repetir'
            : mode == SongRepeatMode.all ? 'Repetir todo'
            : 'Repetir una',
      ),
    );
  }
}

class _PlayPauseBtn extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback? onTap;
  const _PlayPauseBtn({required this.isPlaying, this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64, height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? AppColors.primary : context.ac.textDisabled,
          boxShadow: active
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.45), blurRadius: 24, spreadRadius: 2)]
              : [],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            key: ValueKey(isPlaying), color: Colors.black, size: 36,
          ),
        ),
      ),
    );
  }
}
