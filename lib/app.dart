import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/calculator/presentation/providers/settings_provider.dart';
import 'features/calculator/presentation/screens/cart_screen.dart';

class GrovesApp extends ConsumerWidget {
  const GrovesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'The Groves',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      home: const CartScreen(),
    );
  }
}
