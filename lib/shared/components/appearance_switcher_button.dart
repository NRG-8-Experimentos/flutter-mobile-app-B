import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/theme/theme_cubit.dart';
// ajusta el import según tu app:
import '../../l10n/app_localizations.dart'; // o: import 'package:synhub_flutter/l10n/app_localizations.dart';

class AppearanceSwitcherButton extends StatelessWidget {
  const AppearanceSwitcherButton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;        // <- i18n
    final mode = context.watch<ThemeCubit>().state;

    final modeLabel = switch (mode) {
      ThemeMode.light => t.appearance_light,
      ThemeMode.dark  => t.appearance_dark,
      _               => t.appearance_system,
    };

    return ListTile(
      leading: const Icon(Icons.brightness_6, color: Colors.white),
      title: Text(t.appearance,                     // <- i18n
          style: const TextStyle(color: Colors.white, fontSize: 17)),
      trailing: Text(modeLabel,                     // <- i18n
          style: const TextStyle(color: Colors.white70)),
      onTap: () => _openBottomSheet(context, mode),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  void _openBottomSheet(BuildContext context, ThemeMode current) {
    final t = AppLocalizations.of(context)!;        // <- i18n también aquí
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        final cubit = context.read<ThemeCubit>();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(t.appearance,               // <- i18n
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.system,
              groupValue: current,
              onChanged: (_) { cubit.setSystem(); Navigator.pop(context); },
              title: Text(t.appearance_system),       // <- i18n
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.light,
              groupValue: current,
              onChanged: (_) { cubit.setLight(); Navigator.pop(context); },
              title: Text(t.appearance_light),        // <- i18n
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.dark,
              groupValue: current,
              onChanged: (_) { cubit.setDark(); Navigator.pop(context); },
              title: Text(t.appearance_dark),         // <- i18n
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
