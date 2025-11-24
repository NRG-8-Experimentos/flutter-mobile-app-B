import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synhub_flutter/shared/bloc/locale/locale_bloc.dart';
import 'package:synhub_flutter/shared/bloc/locale/locale_event.dart';

import '../../l10n/app_localizations.dart'; // Para probar el texto

class LanguageSwitcherButton extends StatelessWidget {
  const LanguageSwitcherButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchar el Locale actual del Bloc para que el widget se reconstruya
    final currentLocale = context.watch<LocaleBloc>().state;
    final isEnglish = currentLocale.languageCode == 'en';

    // Determinar el idioma al que se cambiará y el texto del botón
    final newLanguageCode = isEnglish ? 'es' : 'en';
    final buttonLabel = isEnglish ? 'Cambiar a Español' : 'Switch to English';

    // Obtener las localizaciones para probar la funcionalidad
    final localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              context.read<LocaleBloc>().add(
                LocaleChanged(Locale(newLanguageCode)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: Text(
              buttonLabel,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}