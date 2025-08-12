import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../audio/audio_providers.dart';

class ScaleFilterState {
  final bool enabled;
  final String root;
  final String mode;
  final int minOctave;
  final int maxOctave;

  const ScaleFilterState({
    required this.enabled,
    required this.root,
    required this.mode,
    required this.minOctave,
    required this.maxOctave,
  });

  ScaleFilterState copyWith({
    bool? enabled,
    String? root,
    String? mode,
    int? minOctave,
    int? maxOctave,
  }) => ScaleFilterState(
        enabled: enabled ?? this.enabled,
        root: root ?? this.root,
        mode: mode ?? this.mode,
        minOctave: minOctave ?? this.minOctave,
        maxOctave: maxOctave ?? this.maxOctave,
      );

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'rootNote': root,
        'scale': mode.toLowerCase(),
        'minOctave': minOctave,
        'maxOctave': maxOctave,
      };
}

class ScaleFilterNotifier extends StateNotifier<ScaleFilterState> {
  final Ref _ref;
  ScaleFilterNotifier(this._ref)
      : super(const ScaleFilterState(
          enabled: true,
          root: 'C',
          mode: 'PENTATONIC_MAJOR',
          minOctave: 2,
          maxOctave: 6,
        ));

  void _pushToEngine(ScaleFilterState s) {
    final engine = _ref.read(audioEngineProvider);
    engine?.updateScaleFilterConfig(s.toJson());
  }

  void setEnabled(bool value) {
    final next = state.copyWith(enabled: value);
    state = next;
    _pushToEngine(next);
  }

  void setRoot(String value) {
    final next = state.copyWith(root: value);
    state = next;
    _pushToEngine(next);
  }

  void setMode(String value) {
    final next = state.copyWith(mode: value);
    state = next;
    _pushToEngine(next);
  }

  void setMinOctave(int value) {
    final next = state.copyWith(minOctave: value);
    state = next;
    _pushToEngine(next);
  }

  void setMaxOctave(int value) {
    final next = state.copyWith(maxOctave: value);
    state = next;
    _pushToEngine(next);
  }
}

final scaleFilterProvider =
    StateNotifierProvider<ScaleFilterNotifier, ScaleFilterState>((ref) {
  return ScaleFilterNotifier(ref);
});


