import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../utils/app_theme.dart';
import '../utils/time_utils.dart';

class ProgressBarWidget extends StatelessWidget {
  const ProgressBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ac = context.ac;
    return Consumer<AudioProvider>(builder: (_, audio, __) {
      final pos = audio.position;
      final dur = audio.duration;
      double val = dur.inMilliseconds > 0
          ? (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0)
          : 0.0;
      return Column(children: [
        Slider(
          value: val,
          onChanged: audio.hasSongs
              ? (v) => audio.seekTo(Duration(milliseconds: (v * dur.inMilliseconds).toInt()))
              : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(TimeUtils.format(pos), style: TextStyle(color: ac.textSecondary, fontSize: 12)),
            Text(TimeUtils.format(dur), style: TextStyle(color: ac.textSecondary, fontSize: 12)),
          ]),
        ),
      ]);
    });
  }
}
