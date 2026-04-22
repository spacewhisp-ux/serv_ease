import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/app_theme.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/localization/locale_cubit.dart';
import '../../../core/widgets/surface_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(context.l10n.settingsTitle)),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.settingsLanguageTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.settingsLanguageDescription,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: state.locale?.languageCode,
                      style: TextStyle(fontSize: 16, color: AppTheme.nearBlack),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            context.l10n.languageSystem,
                            style: TextStyle(color: AppTheme.expoBlack),
                          ),
                        ),
                        DropdownMenuItem<String>(
                          value: 'en',
                          child: Text(
                            context.l10n.languageEnglish,
                            style: TextStyle(color: AppTheme.expoBlack),
                          ),
                        ),
                        DropdownMenuItem<String>(
                          value: 'zh',
                          child: Text(
                            context.l10n.languageChinese,
                            style: TextStyle(color: AppTheme.expoBlack),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        final cubit = context.read<LocaleCubit>();
                        switch (value) {
                          case 'en':
                            cubit.setEnglishLocale();
                          case 'zh':
                            cubit.setChineseLocale();
                          default:
                            cubit.setSystemLocale();
                        }
                      },
                      decoration: InputDecoration(
                        labelText: context.l10n.settingsLanguageLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
