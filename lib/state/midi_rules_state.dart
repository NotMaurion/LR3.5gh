import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../audio/audio_providers.dart';

class VelocityRule {
  final bool enabled;
  final double minVelocity;
  final double maxVelocity;
  final String curve; // 'linear', 'exponential', 'logarithmic'

  const VelocityRule({
    this.enabled = false,
    this.minVelocity = 0.0,
    this.maxVelocity = 1.0,
    this.curve = 'linear',
  });

  VelocityRule copyWith({
    bool? enabled,
    double? minVelocity,
    double? maxVelocity,
    String? curve,
  }) {
    return VelocityRule(
      enabled: enabled ?? this.enabled,
      minVelocity: minVelocity ?? this.minVelocity,
      maxVelocity: maxVelocity ?? this.maxVelocity,
      curve: curve ?? this.curve,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'minVelocity': minVelocity,
      'maxVelocity': maxVelocity,
      'curve': curve,
    };
  }
}

class NoteTransformationRule {
  final bool enabled;
  final int transpose;
  final double octaveShift;
  final bool harmonize;
  final List<int> harmonyIntervals; // semitones

  const NoteTransformationRule({
    this.enabled = false,
    this.transpose = 0,
    this.octaveShift = 0.0,
    this.harmonize = false,
    this.harmonyIntervals = const [0, 7, 12], // unison, fifth, octave
  });

  NoteTransformationRule copyWith({
    bool? enabled,
    int? transpose,
    double? octaveShift,
    bool? harmonize,
    List<int>? harmonyIntervals,
  }) {
    return NoteTransformationRule(
      enabled: enabled ?? this.enabled,
      transpose: transpose ?? this.transpose,
      octaveShift: octaveShift ?? this.octaveShift,
      harmonize: harmonize ?? this.harmonize,
      harmonyIntervals: harmonyIntervals ?? this.harmonyIntervals,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'transpose': transpose,
      'octaveShift': octaveShift,
      'harmonize': harmonize,
      'harmonyIntervals': harmonyIntervals,
    };
  }
}

class ArpeggiatorRule {
  final bool enabled;
  final String pattern; // 'up', 'down', 'updown', 'random'
  final double rate; // notes per second
  final int octaves;
  final bool syncToTempo;
  final double gateLength; // percentage of note duration

  const ArpeggiatorRule({
    this.enabled = false,
    this.pattern = 'up',
    this.rate = 8.0,
    this.octaves = 1,
    this.syncToTempo = false,
    this.gateLength = 0.5,
  });

  ArpeggiatorRule copyWith({
    bool? enabled,
    String? pattern,
    double? rate,
    int? octaves,
    bool? syncToTempo,
    double? gateLength,
  }) {
    return ArpeggiatorRule(
      enabled: enabled ?? this.enabled,
      pattern: pattern ?? this.pattern,
      rate: rate ?? this.rate,
      octaves: octaves ?? this.octaves,
      syncToTempo: syncToTempo ?? this.syncToTempo,
      gateLength: gateLength ?? this.gateLength,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'pattern': pattern,
      'rate': rate,
      'octaves': octaves,
      'syncToTempo': syncToTempo,
      'gateLength': gateLength,
    };
  }
}

class QuantizationRule {
  final bool enabled;
  final String grid; // '1/4', '1/8', '1/16', '1/32'
  final double strength; // 0.0 to 1.0
  final bool swing;
  final double swingAmount; // 0.0 to 1.0

  const QuantizationRule({
    this.enabled = false,
    this.grid = '1/16',
    this.strength = 0.8,
    this.swing = false,
    this.swingAmount = 0.5,
  });

  QuantizationRule copyWith({
    bool? enabled,
    String? grid,
    double? strength,
    bool? swing,
    double? swingAmount,
  }) {
    return QuantizationRule(
      enabled: enabled ?? this.enabled,
      grid: grid ?? this.grid,
      strength: strength ?? this.strength,
      swing: swing ?? this.swing,
      swingAmount: swingAmount ?? this.swingAmount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'grid': grid,
      'strength': strength,
      'swing': swing,
      'swingAmount': swingAmount,
    };
  }
}

class MidiRulesState {
  final VelocityRule velocityRule;
  final NoteTransformationRule noteTransformation;
  final ArpeggiatorRule arpeggiator;
  final QuantizationRule quantization;
  final bool midiThru;
  final bool recordMidi;

  const MidiRulesState({
    this.velocityRule = const VelocityRule(),
    this.noteTransformation = const NoteTransformationRule(),
    this.arpeggiator = const ArpeggiatorRule(),
    this.quantization = const QuantizationRule(),
    this.midiThru = false,
    this.recordMidi = false,
  });

  MidiRulesState copyWith({
    VelocityRule? velocityRule,
    NoteTransformationRule? noteTransformation,
    ArpeggiatorRule? arpeggiator,
    QuantizationRule? quantization,
    bool? midiThru,
    bool? recordMidi,
  }) {
    return MidiRulesState(
      velocityRule: velocityRule ?? this.velocityRule,
      noteTransformation: noteTransformation ?? this.noteTransformation,
      arpeggiator: arpeggiator ?? this.arpeggiator,
      quantization: quantization ?? this.quantization,
      midiThru: midiThru ?? this.midiThru,
      recordMidi: recordMidi ?? this.recordMidi,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'velocityRule': velocityRule.toMap(),
      'noteTransformation': noteTransformation.toMap(),
      'arpeggiator': arpeggiator.toMap(),
      'quantization': quantization.toMap(),
      'midiThru': midiThru,
      'recordMidi': recordMidi,
    };
  }
}

class MidiRulesNotifier extends StateNotifier<MidiRulesState> {
  MidiRulesNotifier(this._ref) : super(const MidiRulesState()) {
    // Push initial MIDI rules so they are active immediately
    _pushToEngine();
  }

  final Ref _ref;

  // Velocity Rule Methods
  void setVelocityEnabled(bool enabled) {
    state = state.copyWith(
      velocityRule: state.velocityRule.copyWith(enabled: enabled),
    );
    _pushToEngine();
  }

  void setVelocityRange(double min, double max) {
    state = state.copyWith(
      velocityRule: state.velocityRule.copyWith(
        minVelocity: min,
        maxVelocity: max,
      ),
    );
    _pushToEngine();
  }

  void setVelocityCurve(String? curve) {
    if (curve != null) {
      state = state.copyWith(
        velocityRule: state.velocityRule.copyWith(curve: curve),
      );
      _pushToEngine();
    }
  }

  // Note Transformation Methods
  void setNoteTransformationEnabled(bool enabled) {
    state = state.copyWith(
      noteTransformation: state.noteTransformation.copyWith(enabled: enabled),
    );
    _pushToEngine();
  }

  void setTranspose(int transpose) {
    state = state.copyWith(
      noteTransformation: state.noteTransformation.copyWith(transpose: transpose),
    );
    _pushToEngine();
  }

  void setOctaveShift(double shift) {
    state = state.copyWith(
      noteTransformation: state.noteTransformation.copyWith(octaveShift: shift),
    );
    _pushToEngine();
  }

  void setHarmonize(bool harmonize) {
    state = state.copyWith(
      noteTransformation: state.noteTransformation.copyWith(harmonize: harmonize),
    );
    _pushToEngine();
  }

  void setHarmonyIntervals(List<int> intervals) {
    state = state.copyWith(
      noteTransformation: state.noteTransformation.copyWith(harmonyIntervals: intervals),
    );
    _pushToEngine();
  }

  // Arpeggiator Methods
  void setArpeggiatorEnabled(bool enabled) {
    state = state.copyWith(
      arpeggiator: state.arpeggiator.copyWith(enabled: enabled),
    );
    _pushToEngine();
  }

  void setArpeggiatorPattern(String? pattern) {
    if (pattern != null) {
      state = state.copyWith(
        arpeggiator: state.arpeggiator.copyWith(pattern: pattern),
      );
      _pushToEngine();
    }
  }

  void setArpeggiatorRate(double rate) {
    state = state.copyWith(
      arpeggiator: state.arpeggiator.copyWith(rate: rate),
    );
    _pushToEngine();
  }

  void setArpeggiatorOctaves(int octaves) {
    state = state.copyWith(
      arpeggiator: state.arpeggiator.copyWith(octaves: octaves),
    );
    _pushToEngine();
  }

  void setArpeggiatorSync(bool sync) {
    state = state.copyWith(
      arpeggiator: state.arpeggiator.copyWith(syncToTempo: sync),
    );
    _pushToEngine();
  }

  void setArpeggiatorGateLength(double gateLength) {
    state = state.copyWith(
      arpeggiator: state.arpeggiator.copyWith(gateLength: gateLength),
    );
    _pushToEngine();
  }

  // Quantization Methods
  void setQuantizationEnabled(bool enabled) {
    state = state.copyWith(
      quantization: state.quantization.copyWith(enabled: enabled),
    );
    _pushToEngine();
  }

  void setQuantizationGrid(String? grid) {
    if (grid != null) {
      state = state.copyWith(
        quantization: state.quantization.copyWith(grid: grid),
      );
      _pushToEngine();
    }
  }

  void setQuantizationStrength(double strength) {
    state = state.copyWith(
      quantization: state.quantization.copyWith(strength: strength),
    );
    _pushToEngine();
  }

  void setSwing(bool swing) {
    state = state.copyWith(
      quantization: state.quantization.copyWith(swing: swing),
    );
    _pushToEngine();
  }

  void setSwingAmount(double amount) {
    state = state.copyWith(
      quantization: state.quantization.copyWith(swingAmount: amount),
    );
    _pushToEngine();
  }

  // General MIDI Methods
  void setMidiThru(bool thru) {
    state = state.copyWith(midiThru: thru);
    _pushToEngine();
  }

  void setRecordMidi(bool record) {
    state = state.copyWith(recordMidi: record);
    _pushToEngine();
  }

  void resetAllRules() {
    state = const MidiRulesState();
    _pushToEngine();
  }

  void _pushToEngine() {
    try {
      final engine = _ref.read(audioEngineProvider);
      final rulesData = state.toMap();
      (engine as dynamic).updateMidiRules(rulesData);
    } catch (e) {
      print('MidiRulesNotifier: failed to push to engine: $e');
    }
  }
}

final midiRulesProvider = StateNotifierProvider<MidiRulesNotifier, MidiRulesState>((ref) {
  return MidiRulesNotifier(ref);
});
