import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'ui/home_screen.dart';
import 'ui/theme.dart';

class ImeApp extends StatelessWidget {
  const ImeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      // The first release targets Vietnamese users; English is kept ready.
      locale: const Locale('vi'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // Follows the light or dark setting of Windows / Android.
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const HomeScreen(),
    );
  }
}
