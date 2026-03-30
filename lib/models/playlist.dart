class Playlist {
  final String id;
  String name;
  List<String> songPaths;

  Playlist({required this.id, required this.name, List<String>? songPaths})
      : songPaths = songPaths ?? [];

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'songPaths': songPaths};

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
        id: json['id'] as String,
        name: json['name'] as String,
        songPaths: List<String>.from(json['songPaths'] as List),
      );
}
