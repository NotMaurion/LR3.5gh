import 'package:flutter_riverpod/flutter_riverpod.dart';

final liveModeProvider = StateNotifierProvider<LiveModeNotifier, bool>((ref) {
  return LiveModeNotifier();
});

class LiveModeNotifier extends StateNotifier<bool> {
  LiveModeNotifier() : super(true); // Live mode enabled by default

  void toggleLiveMode() {
    state = !state;
  }

  void setLiveMode(bool enabled) {
    state = enabled;
  }
}
