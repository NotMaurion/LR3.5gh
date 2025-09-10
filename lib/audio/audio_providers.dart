import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'engine_selector.dart';
import '../services/storage_service.dart';
import '../state/lab_unlock_notifier.dart';
import 'audio_engine.dart';

final audioEngineProvider = Provider<AudioEngine>((ref) {
  final engine = createEngine();
  return engine;
});

// Lab tabs state (can be expanded later)
final labTabsProvider = Provider<List<String>>((ref) {
  return const ['Zones', 'Scales', 'Audio', 'Rules'];
});

// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// Persistent unlocking state for Lab
final isLabUnlockedProvider = StateNotifierProvider<LabUnlockNotifier, bool>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return LabUnlockNotifier(storageService);
});

// Tap counter for unlocking Lab from PlayerScreen logo
final labTapCounterProvider = StateProvider<int>((ref) => 0);


