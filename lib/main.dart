import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veggie_mart/core/router/app_router.dart';
import 'package:veggie_mart/core/network/network_provider.dart';
import 'package:veggie_mart/core/widgets/no_internet_screen.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Ignore if .env file is not found
  }

  // TEMP: Saving the token manually for testing purposes as requested
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    'auth_token',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjZhM2Y5NTgxZDgxZDJmODg2YmRhYjcwMCIsIm1vYmlsZV9ubyI6IjkxMjU4NTk2NTAiLCJleHAiOjE3ODMxNTAyMzl9.55mCM8u5GGdliWuR_lVnCc4Z7pAJ7vCEOMe-6E5WdgU',
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final networkStatus = ref.watch(networkProvider);

    return MaterialApp.router(
      title: 'Veggie mart',
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
              const Positioned.fill(
                child: NoInternetScreen(),
              ),
          ],
        );
      },
    );
  }
}
