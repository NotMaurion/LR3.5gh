import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../audio/audio_providers.dart';
import 'live_mode_provider.dart';

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
        'root': root,
        // Send uppercase to LAB UI, but engine expects lowercase; we'll normalize in engine
        'mode': mode,
        'minOctave': minOctave,
        'maxOctave': maxOctave,
        'behavior': 'snap', // default to snap so notes retune to scale
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
          enabled: true, // Enable scale filter by default
          root: 'C',
          mode: 'PENTATONIC_MAJOR',
          minOctave: 1, // Lower minimum octave
          maxOctave: 7, // Higher maximum octave
        )) {
    // Push initial state so effects are active without moving sliders
    _push();
  }

  final Ref _ref;

  Future<void> loadFromEngine() async {
    final engine = _ref.read(audioEngineProvider);
    try {
      // ignore: avoid_dynamic_calls
      final scaleFilterData = await (engine as dynamic).getCurrentScaleFilterConfig();
      print('ScaleFilterNotifier: received scale filter data from engine: $scaleFilterData');
      
      if (scaleFilterData != null) {
        final newState = ScaleFilterState(
          enabled: scaleFilterData['enabled'] ?? true,
          root: scaleFilterData['root']?.toString() ?? 'C',
          mode: scaleFilterData['mode']?.toString() ?? 'PENTATONIC_MAJOR',
          minOctave: scaleFilterData['minOctave'] ?? 1,
          maxOctave: scaleFilterData['maxOctave'] ?? 7,
        );
        state = newState;
        print('ScaleFilterNotifier: loaded from engine - ${state.toJson()}');
      } else {
        print('ScaleFilterNotifier: no scale filter data received from engine');
      }
    } catch (e) {
      print('ScaleFilterNotifier: failed to load from engine: $e');
    }
  }

  void _push() {
    final engine = _ref.read(audioEngineProvider);
    try {
      // ignore: avoid_dynamic_calls
      (engine as dynamic).updateScaleFilterConfig(state.toJson());
      print('ScaleFilterNotifier: pushed to engine - ${state.toJson()}');
    } catch (e) {
      print('ScaleFilterNotifier: failed to push to engine: $e');
    }
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


