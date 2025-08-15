import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

class LabUnlockNotifier extends StateNotifier<bool> {
  final StorageService _storageService;

  LabUnlockNotifier(this._storageService) : super(false) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    try {
      final isUnlocked = await _storageService.isLabUnlocked();
      state = isUnlocked;
    } catch (e) {
      // If there's an error loading, default to false
      state = false;
    }
  }

  Future<void> setUnlocked(bool unlocked) async {
    try {
      await _storageService.setLabUnlocked(unlocked);
      state = unlocked;
    } catch (e) {
      // Handle error - could log or show a message
      print('Error saving lab unlock state: $e');
    }
  }

  Future<void> unlock() async {
    await setUnlocked(true);
  }

  Future<void> lock() async {
    await setUnlocked(false);
  }
}
