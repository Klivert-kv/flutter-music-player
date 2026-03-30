import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import '../models/song.dart';

enum PlaybackState { stopped, playing, paused }
enum SongRepeatMode { none, all, one }

class AudioProvider extends ChangeNotifier {
  final ap.AudioPlayer _player = ap.AudioPlayer();

  List<Song> _songs = [];
  List<Song> _queue = [];
  int _currentIndex = 0;
  PlaybackState _state = PlaybackState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _shuffle = false;
  SongRepeatMode _repeatMode = SongRepeatMode.none;

  List<Song> get songs => _songs;
  int get currentIndex => _currentIndex;
  PlaybackState get playbackState => _state;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isPlaying => _state == PlaybackState.playing;
  bool get hasSongs => _songs.isNotEmpty;
  bool get shuffle => _shuffle;
  SongRepeatMode get repeatMode => _repeatMode;

  List<Song> get _activeQueue => _queue.isNotEmpty ? _queue : _songs;
  Song? get currentSong {
    final q = _activeQueue;
    return q.isNotEmpty && _currentIndex < q.length ? q[_currentIndex] : null;
  }

  AudioProvider() { _setupListeners(); }

  void _setupListeners() {
    _player.onPositionChanged.listen((p) {
      _position = p;
      notifyListeners();
    });

    _player.onDurationChanged.listen((d) {
      _duration = d;
      notifyListeners();
    });

    // Cuando termina una cancion
    _player.onPlayerComplete.listen((_) async {
      final q = _activeQueue;
      if (q.isEmpty) return;

      if (_repeatMode == SongRepeatMode.one) {
        // Repetir la misma
        await _player.seek(Duration.zero);
        await _player.resume();
        return;
      }

      final next = _currentIndex + 1;
      if (next >= q.length) {
        // Llego al final — siempre vuelve al principio y reproduce
        await playSongAt(0);
      } else {
        await playSongAt(next);
      }
    });

    _player.onPlayerStateChanged.listen((s) {
      if (s == ap.PlayerState.playing) {
        _state = PlaybackState.playing;
      } else if (s == ap.PlayerState.paused) {
        _state = PlaybackState.paused;
      } else if (s == ap.PlayerState.stopped) {
        _state = PlaybackState.stopped;
      }
      notifyListeners();
    });
  }

  void loadSongs(List<String> allAssets) {
    const ext = {'.mp3', '.wav', '.aac', '.ogg', '.m4a'};
    _songs = allAssets
        .where((p) => p.startsWith('assets/audio/') && ext.any(p.endsWith))
        .map((p) => Song.fromAsset(p, allAssets))
        .toList()
      ..sort((a, b) => a.title.compareTo(b.title));
    _queue = [];
    notifyListeners();
  }

  Future<void> playQueue(List<Song> songs, {int startIndex = 0}) async {
    _queue = List.from(songs);
    await playSongAt(startIndex);
  }

  void clearQueue() { _queue = []; notifyListeners(); }

  Future<void> playSongAt(int index) async {
    final q = _activeQueue;
    if (index < 0 || index >= q.length) return;
    _currentIndex = index;
    _position = Duration.zero;
    _duration = Duration.zero;
    notifyListeners();
    await _player.stop();
    await _player.play(
      ap.AssetSource(q[index].assetPath.replaceFirst('assets/', '')),
    );
  }

  Future<void> togglePlayPause() async {
    if (_state == PlaybackState.playing) {
      await _player.pause();
    } else if (_state == PlaybackState.paused) {
      await _player.resume();
    } else if (hasSongs) {
      await playSongAt(_currentIndex);
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _position = Duration.zero;
    notifyListeners();
  }

  Future<void> nextSong() async {
    if (!hasSongs) return;
    final q = _activeQueue;
    if (_shuffle) {
      final indices = List.generate(q.length, (i) => i)
        ..remove(_currentIndex)
        ..shuffle();
      if (indices.isNotEmpty) await playSongAt(indices.first);
    } else {
      await playSongAt((_currentIndex + 1) % q.length);
    }
  }

  Future<void> previousSong() async {
    if (!hasSongs) return;
    if (_position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }
    final q = _activeQueue;
    await playSongAt((_currentIndex - 1 + q.length) % q.length);
  }

  Future<void> seekTo(Duration pos) => _player.seek(pos);

  void toggleShuffle() { _shuffle = !_shuffle; notifyListeners(); }

  void cycleRepeatMode() {
    if (_repeatMode == SongRepeatMode.none) {
      _repeatMode = SongRepeatMode.all;
    } else if (_repeatMode == SongRepeatMode.all) {
      _repeatMode = SongRepeatMode.one;
    } else {
      _repeatMode = SongRepeatMode.none;
    }
    notifyListeners();
  }

  @override
  void dispose() { _player.dispose(); super.dispose(); }
}
