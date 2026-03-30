import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/audio_provider.dart';
import 'providers/library_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  final allAssets = manifest.listAssets();
  final library = LibraryProvider();
  await library.init();
  runApp(MyApp(allAssets: allAssets, library: library));
}

class MyApp extends StatelessWidget {
  final List<String> allAssets;
  final LibraryProvider library;
  const MyApp({super.key, required this.allAssets, required this.library});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: library),
        ChangeNotifierProvider(
          create: (_) => AudioProvider()..loadSongs(allAssets),
        ),
      ],
      child: Consumer<LibraryProvider>(
        builder: (_, lib, __) => MaterialApp(
          title: 'Music Player',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: lib.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          // SplashScreen como pantalla inicial
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
