import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../session/session_store.dart';

class LocaleState extends Equatable {
  const LocaleState({this.locale});

  final Locale? locale;

  @override
  List<Object?> get props => [locale?.languageCode];
}

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit({required SessionStore sessionStore})
    : _sessionStore = sessionStore,
      super(const LocaleState());

  final SessionStore _sessionStore;

  Future<void> restoreLocale() async {
    final code = await _sessionStore.readPreferredLocaleCode();
    emit(LocaleState(locale: _localeFromCode(code)));
  }

  Future<void> setSystemLocale() async {
    await _sessionStore.savePreferredLocaleCode(null);
    emit(const LocaleState());
  }

  Future<void> setEnglishLocale() async {
    await _sessionStore.savePreferredLocaleCode('en');
    emit(const LocaleState(locale: Locale('en')));
  }

  Future<void> setChineseLocale() async {
    await _sessionStore.savePreferredLocaleCode('zh');
    emit(const LocaleState(locale: Locale('zh')));
  }

  Locale? _localeFromCode(String? code) {
    return switch (code) {
      'en' => const Locale('en'),
      'zh' => const Locale('zh'),
      _ => null,
    };
  }
}
