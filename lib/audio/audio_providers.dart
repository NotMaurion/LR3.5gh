import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'engine_selector.dart';

final audioEngineProvider = Provider<Object>((ref) {
  final engine = createEngine();
  return engine;
});

// Lab tabs state (can be expanded later)
final labTabsProvider = Provider<List<String>>((ref) {
  return const ['Zones', 'Scales', 'Audio', 'Rules'];
});

// Persistent unlocking state for Lab (can be wired to local storage later)
final isLabUnlockedProvider = StateProvider<bool>((ref) => false);

// Tap counter for unlocking Lab from PlayerScreen logo
final labTapCounterProvider = StateProvider<int>((ref) => 0);


