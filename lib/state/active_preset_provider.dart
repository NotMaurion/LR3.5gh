import 'package:flutter_riverpod/flutter_riverpod.dart';

final activePresetProvider = StateNotifierProvider<ActivePresetNotifier, String?>((ref) {
  return ActivePresetNotifier();
});

class ActivePresetNotifier extends StateNotifier<String?> {
  ActivePresetNotifier() : super('Deep-Focus'); // Set default preset

  void setActivePreset(String presetName) {
    print('Setting active preset to: $presetName');
    state = presetName;
    print('Active preset is now: $state');
  }

  void clearActivePreset() {
    state = null;
  }
}
