import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _labUnlockedKey = 'isLabUnlocked';
  
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  Future<bool> isLabUnlocked() async {
    await _ensureInitialized();
    return _prefs.getBool(_labUnlockedKey) ?? false;
  }

  Future<void> setLabUnlocked(bool unlocked) async {
    await _ensureInitialized();
    await _prefs.setBool(_labUnlockedKey, unlocked);
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  Future<void> close() async {
    // SharedPreferences doesn't need explicit closing
    _isInitialized = false;
  }
}
