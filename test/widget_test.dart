import 'package:aqua_mates/locale_provider.dart';
import 'package:aqua_mates/login.dart';
import 'package:aqua_mates/main.dart';
import 'package:aqua_mates/theme_data.dart';
import 'package:aqua_mates/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('MyApp initializes with the correct theme and locale',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(lightTheme),
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    final themeProvider = Provider.of<ThemeProvider>(
        tester.element(find.byType(MyApp)),
        listen: false);

    expect(themeProvider.getTheme(), lightTheme);

    expect(find.byType(Login), findsOneWidget);
  });

  testWidgets('Locale can be changed', (WidgetTester tester) async {
    Locale initialLocale = const Locale('en');
    Locale newLocale = const Locale('ru');

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(lightTheme),
        child: LocaleProvider(
          locale: initialLocale,
          setLocale: (locale) {
            initialLocale = locale;
          },
          child: const MyApp(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(LocaleProvider.of(tester.element(find.byType(MyApp)))!.locale,
        initialLocale);

    final localeProvider =
        LocaleProvider.of(tester.element(find.byType(MyApp)))!;
    localeProvider.setLocale(newLocale);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(lightTheme),
        child: LocaleProvider(
          locale: newLocale,
          setLocale: localeProvider.setLocale,
          child: const MyApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(LocaleProvider.of(tester.element(find.byType(MyApp)))!.locale,
        newLocale);
  });

  testWidgets('Login widget displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(lightTheme),
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ru'),
          ],
          home: Login(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(Login), findsOneWidget);
    expect(
        find.text(AppLocalizations.of(tester.element(find.byType(Login)))!
            .welcomeBack),
        findsOneWidget);
    expect(
        find.byType(TextField), findsNWidgets(2)); // Email and Password fields
    expect(find.byType(ElevatedButton), findsOneWidget); // Sign In button
  });

  testWidgets('Login fields accept user input', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(lightTheme),
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ru'),
          ],
          home: Login(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.enterText(find.byType(TextField).last, 'password123');
    await tester.pumpAndSettle();

    expect(find.byType(TextField).first, findsOneWidget);
    expect(find.byType(TextField).last, findsOneWidget);
    expect(
        (tester
            .widget<TextField>(find.byType(TextField).first)
            .controller!
            .text),
        'test@example.com');
    expect(
        (tester
            .widget<TextField>(find.byType(TextField).last)
            .controller!
            .text),
        'password123');
  });
}
