import 'dart:ui';

Map<String, dynamic> getMixinContext() => const {};

bool isInMixinApp() => false;

Locale? getMixinLocale() => null;

Locale getMixinLocaleOrPlatformLocale() => window.locale;
