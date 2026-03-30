import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';
import '../models/playlist.dart';

class LibraryProvider extends ChangeNotifier {
  Set<String> _favorites = {};
  List<Playlist> _playlists = [];
  Map<String, Map<String, String>> _editedMeta = {};
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;
  List<Playlist> get playlists => _playlists;
  Set<String> get favorites => _favorites;

  bool isFavorite(String assetPath) => _favorites.contains(assetPath);
  String? editedTitle(String assetPath) => _editedMeta[assetPath]?['title'];
  String? editedArtist(String assetPath) => _editedMeta[assetPath]?['artist'];

  List<Song> applyEdits(List<Song> songs) => songs.map((s) {
        final meta = _editedMeta[s.assetPath];
        if (meta == null) return s;
        return s.copyWith(title: meta['title'], artist: meta['artist']);
      }).toList();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _favorites = Set<String>.from(prefs.getStringList('favorites') ?? []);
    final raw = prefs.getStringList('playlists') ?? [];
    _playlists = raw
        .map((s) => Playlist.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
    final metaRaw = prefs.getString('editedMeta');
    if (metaRaw != null) {
      final decoded = jsonDecode(metaRaw) as Map<String, dynamic>;
      _editedMeta = decoded.map((k, v) => MapEntry(k, Map<String, String>.from(v as Map)));
    }
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    notifyListeners();
  }

  Future<void> toggleFavorite(String assetPath) async {
    if (_favorites.contains(assetPath)) _favorites.remove(assetPath);
    else _favorites.add(assetPath);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites.toList());
  }

  Future<void> createPlaylist(String name) async {
    _playlists.add(Playlist(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name));
    notifyListeners();
    await _savePlaylists();
  }

  Future<void> deletePlaylist(String id) async {
    _playlists.removeWhere((p) => p.id == id);
    notifyListeners();
    await _savePlaylists();
  }

  Future<void> renamePlaylist(String id, String newName) async {
    _playlists.firstWhere((p) => p.id == id).name = newName;
    notifyListeners();
    await _savePlaylists();
  }

  Future<void> addToPlaylist(String playlistId, String assetPath) async {
    final pl = _playlists.firstWhere((p) => p.id == playlistId);
    if (!pl.songPaths.contains(assetPath)) {
      pl.songPaths.add(assetPath);
      notifyListeners();
      await _savePlaylists();
    }
  }

  Future<void> removeFromPlaylist(String playlistId, String assetPath) async {
    _playlists.firstWhere((p) => p.id == playlistId).songPaths.remove(assetPath);
    notifyListeners();
    await _savePlaylists();
  }

  Future<void> _savePlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('playlists', _playlists.map((p) => jsonEncode(p.toJson())).toList());
  }

  Future<void> editSongMeta(String assetPath, String title, String artist) async {
    _editedMeta[assetPath] = {'title': title, 'artist': artist};
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('editedMeta', jsonEncode(_editedMeta));
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }
}
