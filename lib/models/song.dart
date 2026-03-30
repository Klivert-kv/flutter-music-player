class Song {
  final String title;
  final String artist;
  final String assetPath;
  final String? imagePath;

  const Song({
    required this.title,
    required this.artist,
    required this.assetPath,
    this.imagePath,
  });

  Song copyWith({String? title, String? artist}) => Song(
        title: title ?? this.title,
        artist: artist ?? this.artist,
        assetPath: assetPath,
        imagePath: imagePath,
      );

  static String titleFromPath(String path) {
    final name = path.split('/').last.replaceAll(RegExp(r'\.[^.]+$'), '');
    return name
        .replaceAll(RegExp(r'[-_]'), ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  factory Song.fromAsset(String assetPath, List<String> allAssets) {
    final name = assetPath.split('/').last.replaceAll(RegExp(r'\.[^.]+$'), '');
    String? image;
    for (final ext in ['jpg', 'jpeg', 'png', 'webp']) {
      final candidate = 'assets/images/$name.$ext';
      if (allAssets.contains(candidate)) { image = candidate; break; }
    }
    return Song(
      title: titleFromPath(assetPath),
      artist: 'Artista Desconocido',
      assetPath: assetPath,
      imagePath: image,
    );
  }
}
