import 'package:isar/isar.dart';
import '../data/app_settings.dart';

class StorageService {
  static const String _labUnlockedKey = 'isLabUnlocked';
  
  late Isar _isar;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _isar = await Isar.open([AppSettingsSchema], directory: '');
    _isInitialized = true;
  }

  Future<bool> isLabUnlocked() async {
    await _ensureInitialized();
    
    final settings = await _isar.appSettings
        .filter()
        .keyEqualTo(_labUnlockedKey)
        .findFirst();
    
    return settings?.value == 'true';
  }

  Future<void> setLabUnlocked(bool unlocked) async {
    await _ensureInitialized();
    
    final value = unlocked ? 'true' : 'false';
    final settings = AppSettings(key: _labUnlockedKey, value: value);
    
    await _isar.writeTxn(() async {
      await _isar.appSettings.put(settings);
    });
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  Future<void> close() async {
    if (_isInitialized) {
      await _isar.close();
      _isInitialized = false;
    }
  }
}
