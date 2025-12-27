import 'package:hive/hive.dart';

import '../repositories/history_repository.dart';

class HistoryLocalStore {
  static const String boxName = 'groves_history';
  static Box<dynamic>? _box;

  static Future<void> openBox() async {
    _box ??= await Hive.openBox<dynamic>(boxName);
  }

  static Box<dynamic> get box {
    final b = _box;
    if (b == null) {
      throw StateError('History box not opened.');
    }
    return b;
  }

  static const String historyKey = 'history_entries';

  static List<HistoryEntry> loadHistory() {
    final raw = box.get(historyKey);
    if (raw is List) {
      return raw.cast<HistoryEntry>();
    }
    return <HistoryEntry>[];
  }

  static Future<void> saveHistory(List<HistoryEntry> entries) async {
    await box.put(historyKey, entries);
  }

  static Future<void> clear() async {
    await box.delete(historyKey);
  }
}
