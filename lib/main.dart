import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'features/calculator/data/local/cart_local_store.dart';
import 'features/calculator/data/local/hive_adapters.dart';
import 'features/calculator/data/local/history_local_store.dart';
import 'features/calculator/data/local/settings_local_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase (must be initialized before any Firebase service usage)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Hive local persistence
  await Hive.initFlutter();

  // Register Hive adapters
  registerHiveAdapters();

  // Open boxes (must be opened before any reads)
  await SettingsLocalStore.openBox();
  await CartLocalStore.openBox();
  await HistoryLocalStore.openBox();

  runApp(const ProviderScope(child: GrovesApp()));
}
