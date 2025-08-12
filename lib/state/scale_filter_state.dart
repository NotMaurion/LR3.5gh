import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  ScaleFilterNotifier()
      : super(const ScaleFilterState(
          enabled: true,
          root: 'C',
          mode: 'PENTATONIC_MAJOR',
          minOctave: 2,
          maxOctave: 6,
        ));

  void setEnabled(bool value) => state = state.copyWith(enabled: value);
  void setRoot(String value) => state = state.copyWith(root: value);
  void setMode(String value) => state = state.copyWith(mode: value);
  void setMinOctave(int value) => state = state.copyWith(minOctave: value);
  void setMaxOctave(int value) => state = state.copyWith(maxOctave: value);
}

final scaleFilterProvider =
    StateNotifierProvider<ScaleFilterNotifier, ScaleFilterState>((ref) {
  return ScaleFilterNotifier();
});


