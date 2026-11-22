import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';

/// Our strings plus Material / Cupertino / widgets strings for every supported language.
///
/// Don't use the generated `AppLocalizations.localizationsDelegates`: it still points at the
/// deprecated flutter_localizations delegates, which material_ui widgets don't read — the app
/// then crashes in Amharic with "No MaterialLocalizations found".
const List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates = [
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];
