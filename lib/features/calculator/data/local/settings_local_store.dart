import 'package:hive/hive.dart';

class SettingsLocalStore {
  static const String boxName = 'groves_settings';
  static Box<dynamic>? _box;

  static Future<void> openBox() async {
    _box ??= await Hive.openBox<dynamic>(boxName);
  }

  static Box<dynamic> get box {
    final b = _box;
    if (b == null) {
      throw StateError('Settings box not opened.');
    }
    return b;
  }
}
