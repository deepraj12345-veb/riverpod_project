import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veg_king/core/router/app_router.dart';
import 'package:veg_king/core/network/network_provider.dart';
import 'package:veg_king/core/widgets/no_internet_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:veg_king/l10n/app_localizations.dart';
import 'package:veg_king/presentation/providers/locale_provider.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // PROPERLY precache & decode logo into Flutter's ImageCache before runApp so there is ZERO white box delay!
  try {
    const imageProvider = AssetImage('assets/app-logo-square.png');
    final stream = imageProvider.resolve(ImageConfiguration.empty);
    final completer = Completer<void>();
    final listener = ImageStreamListener(
      (info, sync) => completer.complete(),
      onError: (err, stack) => completer.complete(),
    );
    stream.addListener(listener);
    await completer.future;
    stream.removeListener(listener);
  } catch (_) {}

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Ignore if .env file is not found
  }

  // TEMP: Saving the token manually for testing purposes as requested
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    'auth_token',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjZhM2Y5NTgxZDgxZDJmODg2YmRhYjcwMCIsIm1vYmlsZV9ubyI6IjkxMjU4NTk2NTAiLCJleHAiOjE3OTAwNTIwMDh9.FJthgQjbZd32y5SmWPFuY9sjOX5jJOF_0LDKX93ZDyk',
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final networkStatus = ref.watch(networkProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('hi'), // Hindi
      ],
      title: 'Veg king',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          elevation: 0,
        ),
      ),
      routerConfig: router,
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            if (networkStatus == NetworkStatus.offline)
              const Positioned.fill(child: NoInternetScreen()),
          ],
        );
      },
    );
  }
}
