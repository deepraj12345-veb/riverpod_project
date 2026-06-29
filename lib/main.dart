import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veggie_mart/core/router/app_router.dart';

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
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjZhM2Y5NTgxZDgxZDJmODg2YmRhYjcwMCIsIm1vYmlsZV9ubyI6IjkxMjU4NTk2NTAiLCJleHAiOjE3ODI2MzgzMzd9.LKR5VElTZARhEPydBtvnXTH3SrsjpIKDc4_BfdTm7ps'
  );
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Veggie mart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      routerConfig: router,
    );
  }
}
