import 'package:flutter/material.dart';

class LocaleProvider extends InheritedWidget {
  final Locale locale;
  final Function(Locale) setLocale;

  const LocaleProvider({
    Key? key,
    required this.locale,
    required this.setLocale,
    required Widget child,
  }) : super(key: key, child: child);

  static LocaleProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LocaleProvider>();
  }

  @override
  bool updateShouldNotify(LocaleProvider oldWidget) {
    return locale != oldWidget.locale;
  }
}
