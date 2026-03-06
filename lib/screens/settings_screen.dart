import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_calender/providers/theme_provider.dart';

/// 앱 설정 화면
///
/// 현재 기능: 테마 모드 선택 (시스템 자동 / 라이트 / 다크)
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          // ─── 테마 섹션 헤더 ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              '화면 테마',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          // ─── 시스템 자동 ──────────────────────────────────────────────────
          _ThemeOptionTile(
            icon: Icons.brightness_auto_rounded,
            label: '시스템 설정 따르기',
            description: '기기의 다크 모드 설정에 자동으로 맞춥니다',
            isSelected: themeProvider.themeMode == ThemeMode.system,
            onTap: () => themeProvider.setThemeMode(ThemeMode.system),
          ),

          // ─── 라이트 모드 ─────────────────────────────────────────────────
          _ThemeOptionTile(
            icon: Icons.light_mode_rounded,
            label: '라이트 모드',
            description: '항상 밝은 화면으로 표시합니다',
            isSelected: themeProvider.themeMode == ThemeMode.light,
            onTap: () => themeProvider.setThemeMode(ThemeMode.light),
          ),

          // ─── 다크 모드 ───────────────────────────────────────────────────
          _ThemeOptionTile(
            icon: Icons.dark_mode_rounded,
            label: '다크 모드',
            description: '항상 어두운 화면으로 표시합니다',
            isSelected: themeProvider.themeMode == ThemeMode.dark,
            onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
          ),

          const Divider(height: 32),

          // ─── 앱 정보 섹션 ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              '앱 정보',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('버전'),
            trailing: Text(
              '1.0.0',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 테마 선택 옵션 타일 위젯
class _ThemeOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? colorScheme.primary : null,
        ),
      ),
      subtitle: Text(description),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: colorScheme.primary)
          : Icon(Icons.radio_button_unchecked_rounded,
              color: colorScheme.onSurfaceVariant),
      onTap: onTap,
    );
  }
}
