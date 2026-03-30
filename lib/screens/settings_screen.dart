import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/library_provider.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ac = context.ac;
    final library = context.watch<LibraryProvider>();
    return Scaffold(
      backgroundColor: ac.background,
      appBar: AppBar(title: const Text('CONFIGURACIÓN')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _SectionTitle('Apariencia'),
        _Tile(
          icon: Icons.dark_mode_rounded,
          iconColor: library.isDarkMode ? AppColors.primary : ac.textSecondary,
          title: 'Modo oscuro',
          subtitle: library.isDarkMode ? 'Activado' : 'Desactivado',
          trailing: Switch(
            value: library.isDarkMode,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
            onChanged: (_) => library.toggleTheme(),
          ),
        ),
        const SizedBox(height: 24),
        _SectionTitle('Ayuda'),
        _Tile(icon: Icons.music_note_rounded, iconColor: AppColors.primary,
            title: 'Agregar música',
            subtitle: 'Copia .mp3 en assets/audio/ y ejecuta flutter run'),
        _Tile(icon: Icons.image_rounded, iconColor: ac.textSecondary,
            title: 'Agregar carátulas',
            subtitle: 'Imagen con mismo nombre del .mp3 en assets/images/'),
        const SizedBox(height: 24),
        _SectionTitle('Acerca de'),
        _Tile(icon: Icons.info_outline_rounded, iconColor: ac.textSecondary,
            title: 'Music Player', subtitle: 'Versión 1.0.0 · Hecho con Flutter'),
      ]),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title, style: const TextStyle(
      color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
  );
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  const _Tile({required this.icon, required this.iconColor, required this.title, required this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    final ac = context.ac;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: ac.surface, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title, style: TextStyle(color: ac.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: ac.textSecondary, fontSize: 12)),
        trailing: trailing,
      ),
    );
  }
}
