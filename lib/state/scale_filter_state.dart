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

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'rootNote': root,
        'scale': mode.toLowerCase(),
        'minOctave': minOctave,
        'maxOctave': maxOctave,
      };

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
}

class ScaleFilterNotifier extends StateNotifier<ScaleFilterState> {
  ScaleFilterNotifier(this._ref)
      : super(const ScaleFilterState(
          enabled: true,
          root: 'C',
          mode: 'PENTATONIC_MAJOR',
          minOctave: 2,
          maxOctave: 6,
        ));

  final Ref _ref;

  void _push() {
    final engine = _ref.read(audioEngineProvider);
    try {
      // ignore: avoid_dynamic_calls
      (engine as dynamic).updateScaleFilterConfig(state.toJson());
    } catch (_) {}
  }

  void setEnabled(bool v) {
    state = state.copyWith(enabled: v);
    _push();
  }

  void setRoot(String v) {
    state = state.copyWith(root: v);
    _push();
  }

  void setMode(String v) {
    state = state.copyWith(mode: v);
    _push();
  }

  void setMinOctave(int v) {
    state = state.copyWith(minOctave: v);
    _push();
  }

  void setMaxOctave(int v) {
    state = state.copyWith(maxOctave: v);
    _push();
  }
}

final scaleFilterProvider =
    StateNotifierProvider<ScaleFilterNotifier, ScaleFilterState>((ref) {
  return ScaleFilterNotifier(ref);
});


