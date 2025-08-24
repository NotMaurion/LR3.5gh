import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../audio/audio_providers.dart';
import 'live_mode_provider.dart';

class ReverbSettings {
  final bool enabled;
  final double wet;
  final double dry;
  final double roomSize;
  final double dampening;
  final double preDelay;

  const ReverbSettings({
    this.enabled = false,
    this.wet = 0.3,
    this.dry = 0.7,
    this.roomSize = 0.5,
    this.dampening = 0.5,
    this.preDelay = 0.0,
  });

  ReverbSettings copyWith({
    bool? enabled,
    double? wet,
    double? dry,
    double? roomSize,
    double? dampening,
    double? preDelay,
  }) {
    return ReverbSettings(
      enabled: enabled ?? this.enabled,
      wet: wet ?? this.wet,
      dry: dry ?? this.dry,
      roomSize: roomSize ?? this.roomSize,
      dampening: dampening ?? this.dampening,
      preDelay: preDelay ?? this.preDelay,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'wet': wet,
      'dry': dry,
      'roomSize': roomSize,
      'dampening': dampening,
      'preDelay': preDelay,
    };
  }
}

class FilterSettings {
  final bool enabled;
  final double cutoff;
  final double resonance;
  final String type; // 'lpf', 'hpf', 'bpf'

  const FilterSettings({
    this.enabled = false,
    this.cutoff = 2000.0,
    this.resonance = 0.0,
    this.type = 'lpf',
  });

  FilterSettings copyWith({
    bool? enabled,
    double? cutoff,
    double? resonance,
    String? type,
  }) {
    return FilterSettings(
      enabled: enabled ?? this.enabled,
      cutoff: cutoff ?? this.cutoff,
      resonance: resonance ?? this.resonance,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'cutoff': cutoff,
      'resonance': resonance,
      'type': type,
    };
  }
}

class EnvelopeSettings {
  final bool enabled;
  final double attack;
  final double decay;
  final double sustain;
  final double release;

  const EnvelopeSettings({
    this.enabled = false,
    this.attack = 0.05,
    this.decay = 0.3,
    this.sustain = 0.7,
    this.release = 1.0,
  });

  EnvelopeSettings copyWith({
    bool? enabled,
    double? attack,
    double? decay,
    double? sustain,
    double? release,
  }) {
    return EnvelopeSettings(
      enabled: enabled ?? this.enabled,
      attack: attack ?? this.attack,
      decay: decay ?? this.decay,
      sustain: sustain ?? this.sustain,
      release: release ?? this.release,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'attack': attack,
      'decay': decay,
      'sustain': sustain,
      'release': release,
    };
  }
}

class SustainSettings {
  final bool enabled;
  final double duration; // Duration in seconds
  final double level; // Sustain level (0.0 to 1.0)
  final bool infinite; // Infinite sustain

  const SustainSettings({
    this.enabled = false,
    this.duration = 2.0,
    this.level = 0.8,
    this.infinite = false,
  });

  SustainSettings copyWith({
    bool? enabled,
    double? duration,
    double? level,
    bool? infinite,
  }) {
    return SustainSettings(
      enabled: enabled ?? this.enabled,
      duration: duration ?? this.duration,
      level: level ?? this.level,
      infinite: infinite ?? this.infinite,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'duration': duration,
      'level': level,
      'infinite': infinite,
    };
  }
}

class RandomnessSettings {
  final bool enabled;
  final double pitchVariation; // Pitch variation in semitones
  final double velocityVariation; // Velocity variation (0.0 to 1.0)
  final double timingVariation; // Timing variation in milliseconds
  final double sustainVariation; // Sustain duration variation

  const RandomnessSettings({
    this.enabled = false,
    this.pitchVariation = 0.1,
    this.velocityVariation = 0.2,
    this.timingVariation = 50.0,
    this.sustainVariation = 0.3,
  });

  RandomnessSettings copyWith({
    bool? enabled,
    double? pitchVariation,
    double? velocityVariation,
    double? timingVariation,
    double? sustainVariation,
  }) {
    return RandomnessSettings(
      enabled: enabled ?? this.enabled,
      pitchVariation: pitchVariation ?? this.pitchVariation,
      velocityVariation: velocityVariation ?? this.velocityVariation,
      timingVariation: timingVariation ?? this.timingVariation,
      sustainVariation: sustainVariation ?? this.sustainVariation,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'pitchVariation': pitchVariation,
      'velocityVariation': velocityVariation,
      'timingVariation': timingVariation,
      'sustainVariation': sustainVariation,
    };
  }
}

class SimultaneousNotesSettings {
  final bool enabled;
  final int maxNotes; // Maximum simultaneous notes
  final double overlapProbability; // Probability of note overlap (0.0 to 1.0)
  final bool voiceStealing; // Enable voice stealing for old notes
  final double voiceStealThreshold; // Threshold for voice stealing

  const SimultaneousNotesSettings({
    this.enabled = false,
    this.maxNotes = 8,
    this.overlapProbability = 0.3,
    this.voiceStealing = true,
    this.voiceStealThreshold = 0.5,
  });

  SimultaneousNotesSettings copyWith({
    bool? enabled,
    int? maxNotes,
    double? overlapProbability,
    bool? voiceStealing,
    double? voiceStealThreshold,
  }) {
    return SimultaneousNotesSettings(
      enabled: enabled ?? this.enabled,
      maxNotes: maxNotes ?? this.maxNotes,
      overlapProbability: overlapProbability ?? this.overlapProbability,
      voiceStealing: voiceStealing ?? this.voiceStealing,
      voiceStealThreshold: voiceStealThreshold ?? this.voiceStealThreshold,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'maxNotes': maxNotes,
      'overlapProbability': overlapProbability,
      'voiceStealing': voiceStealing,
      'voiceStealThreshold': voiceStealThreshold,
    };
  }
}

class LayersEnabledSettings {
  final bool bass;
  final bool mid;
  final bool high;
  final bool tex;

  const LayersEnabledSettings({
    this.bass = true,
    this.mid = true,
    this.high = true,
    this.tex = true,
  });

  LayersEnabledSettings copyWith({
    bool? bass,
    bool? mid,
    bool? high,
    bool? tex,
  }) {
    return LayersEnabledSettings(
      bass: bass ?? this.bass,
      mid: mid ?? this.mid,
      high: high ?? this.high,
      tex: tex ?? this.tex,
    );
  }

  Map<String, dynamic> toMap() => {
        'bass': bass,
        'mid': mid,
        'high': high,
        'tex': tex,
      };
}

class AudioEffectsState {
  final ReverbSettings reverb;
  final FilterSettings filter;
  final EnvelopeSettings envelope;
  final SustainSettings sustain;
  final RandomnessSettings randomness;
  final SimultaneousNotesSettings simultaneousNotes;
  final double globalVolume;
  final String audioQuality;
  final LayersEnabledSettings layersEnabled;

  const AudioEffectsState({
    this.reverb = const ReverbSettings(
      enabled: true,
      wet: 0.6,
      dry: 0.4,
      roomSize: 0.9,
      dampening: 0.8,
      preDelay: 0.05,
    ),
    this.filter = const FilterSettings(),
    this.envelope = const EnvelopeSettings(
      enabled: true,
      attack: 0.1,
      decay: 0.2,
      sustain: 0.8,
      release: 1.0,
    ),
    this.sustain = const SustainSettings(
      enabled: true,
      duration: 3.0,
      level: 0.9,
      infinite: false,
    ),
    this.randomness = const RandomnessSettings(),
    this.simultaneousNotes = const SimultaneousNotesSettings(),
    this.globalVolume = 1.0,
    this.audioQuality = 'High',
    this.layersEnabled = const LayersEnabledSettings(),
  });

  AudioEffectsState copyWith({
    ReverbSettings? reverb,
    FilterSettings? filter,
    EnvelopeSettings? envelope,
    SustainSettings? sustain,
    RandomnessSettings? randomness,
    SimultaneousNotesSettings? simultaneousNotes,
    double? globalVolume,
    String? audioQuality,
    LayersEnabledSettings? layersEnabled,
  }) {
    return AudioEffectsState(
      reverb: reverb ?? this.reverb,
      filter: filter ?? this.filter,
      envelope: envelope ?? this.envelope,
      sustain: sustain ?? this.sustain,
      randomness: randomness ?? this.randomness,
      simultaneousNotes: simultaneousNotes ?? this.simultaneousNotes,
      globalVolume: globalVolume ?? this.globalVolume,
      audioQuality: audioQuality ?? this.audioQuality,
      layersEnabled: layersEnabled ?? this.layersEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reverb': reverb.toMap(),
      'filter': filter.toMap(),
      'envelope': envelope.toMap(),
      'sustain': sustain.toMap(),
      'randomness': randomness.toMap(),
      'simultaneousNotes': simultaneousNotes.toMap(),
      'globalVolume': globalVolume,
      'audioQuality': audioQuality,
      'layersEnabled': layersEnabled.toMap(),
    };
  }
}

class AudioEffectsNotifier extends StateNotifier<AudioEffectsState> {
  AudioEffectsNotifier(this._ref) : super(const AudioEffectsState()) {
    // Ensure engine has initial effects applied immediately
    _pushToEngine();
  }

  final Ref _ref;

  void setReverbEnabled(bool enabled) {
    state = state.copyWith(
      reverb: state.reverb.copyWith(enabled: enabled),
    );
    _pushToEngine();
  }

  void setReverbWet(double wet) {
    state = state.copyWith(
      reverb: state.reverb.copyWith(wet: wet),
    );
    _pushToEngine();
  }

  void setReverbDry(double dry) {
    state = state.copyWith(
      reverb: state.reverb.copyWith(dry: dry),
    );
    _pushToEngine();
  }

  void setReverbRoomSize(double roomSize) {
    state = state.copyWith(
      reverb: state.reverb.copyWith(roomSize: roomSize),
    );
    _pushToEngine();
  }

  void setReverbDampening(double dampening) {
    state = state.copyWith(
      reverb: state.reverb.copyWith(dampening: dampening),
    );
    _pushToEngine();
  }

  void setReverbPreDelay(double preDelay) {
    state = state.copyWith(
      reverb: state.reverb.copyWith(preDelay: preDelay),
    );
    _pushToEngine();
  }

  void setFilterEnabled(bool enabled) {
    state = state.copyWith(
      filter: state.filter.copyWith(enabled: enabled),
    );
    _pushToEngine();
  }

  void setFilterCutoff(double cutoff) {
    state = state.copyWith(
      filter: state.filter.copyWith(cutoff: cutoff),
    );
    _pushToEngine();
  }

  void setFilterResonance(double resonance) {
    state = state.copyWith(
      filter: state.filter.copyWith(resonance: resonance),
    );
    _pushToEngine();
  }

  void setFilterType(String type) {
    state = state.copyWith(
      filter: state.filter.copyWith(type: type),
    );
    _pushToEngine();
  }

  void setEnvelopeEnabled(bool enabled) {
    state = state.copyWith(
      envelope: state.envelope.copyWith(enabled: enabled),
    );
    _pushToEngine();
  }

  void setEnvelopeAttack(double attack) {
    state = state.copyWith(
      envelope: state.envelope.copyWith(attack: attack),
    );
    _pushToEngine();
  }

  void setEnvelopeDecay(double decay) {
    state = state.copyWith(
      envelope: state.envelope.copyWith(decay: decay),
    );
    _pushToEngine();
  }

  void setEnvelopeSustain(double sustain) {
    state = state.copyWith(
      envelope: state.envelope.copyWith(sustain: sustain),
    );
    _pushToEngine();
  }

  void setEnvelopeRelease(double release) {
    state = state.copyWith(
      envelope: state.envelope.copyWith(release: release),
    );
    _pushToEngine();
  }

  void setGlobalVolume(double volume) {
    state = state.copyWith(globalVolume: volume);
    _pushToEngine();
  }

  void setAudioQuality(String? quality) {
    if (quality != null) {
      state = state.copyWith(audioQuality: quality);
      _pushToEngine();
    }
  }

  // Layer toggles
  void setLayerEnabled(String layer, bool enabled) {
    final le = state.layersEnabled;
    switch (layer) {
      case 'bass':
        state = state.copyWith(layersEnabled: le.copyWith(bass: enabled));
        break;
      case 'mid':
        state = state.copyWith(layersEnabled: le.copyWith(mid: enabled));
        break;
      case 'high':
        state = state.copyWith(layersEnabled: le.copyWith(high: enabled));
        break;
      case 'tex':
        state = state.copyWith(layersEnabled: le.copyWith(tex: enabled));
        break;
      default:
        return;
    }
    _pushToEngine();
  }

  void resetAllEffects() {
    state = const AudioEffectsState();
    _pushToEngine();
  }

  // Reverb presets
  void applyReverbPreset(String presetName) {
    ReverbSettings preset;
    switch (presetName) {
      case 'Room':
        preset = const ReverbSettings(
          enabled: true,
          wet: 0.3,
          dry: 0.7,
          roomSize: 0.3,
          dampening: 0.4,
          preDelay: 0.0,
        );
        break;
      case 'Hall':
        preset = const ReverbSettings(
          enabled: true,
          wet: 0.4,
          dry: 0.6,
          roomSize: 0.7,
          dampening: 0.6,
          preDelay: 0.02,
        );
        break;
      case 'Cathedral':
        preset = const ReverbSettings(
          enabled: true,
          wet: 0.6,
          dry: 0.4,
          roomSize: 0.9,
          dampening: 0.8,
          preDelay: 0.05,
        );
        break;
      case 'Plate':
        preset = const ReverbSettings(
          enabled: true,
          wet: 0.5,
          dry: 0.5,
          roomSize: 0.5,
          dampening: 0.3,
          preDelay: 0.01,
        );
        break;
      case 'Spring':
        preset = const ReverbSettings(
          enabled: true,
          wet: 0.4,
          dry: 0.6,
          roomSize: 0.4,
          dampening: 0.2,
          preDelay: 0.0,
        );
        break;
      case 'Chamber':
        preset = const ReverbSettings(
          enabled: true,
          wet: 0.35,
          dry: 0.65,
          roomSize: 0.4,
          dampening: 0.5,
          preDelay: 0.01,
        );
        break;
      default:
        return;
    }
    
    state = state.copyWith(reverb: preset);
    _pushToEngine();
  }

  // Filter presets
  void applyFilterPreset(String presetName) {
    FilterSettings preset;
    switch (presetName) {
      case 'Low Pass':
        preset = const FilterSettings(
          enabled: true,
          cutoff: 2000.0,
          resonance: 0.0,
          type: 'lpf',
        );
        break;
      case 'High Pass':
        preset = const FilterSettings(
          enabled: true,
          cutoff: 500.0,
          resonance: 0.0,
          type: 'hpf',
        );
        break;
      case 'Band Pass':
        preset = const FilterSettings(
          enabled: true,
          cutoff: 1000.0,
          resonance: 2.0,
          type: 'bpf',
        );
        break;
      case 'Warm':
        preset = const FilterSettings(
          enabled: true,
          cutoff: 3000.0,
          resonance: 1.5,
          type: 'lpf',
        );
        break;
      case 'Bright':
        preset = const FilterSettings(
          enabled: true,
          cutoff: 8000.0,
          resonance: 0.5,
          type: 'hpf',
        );
        break;
      case 'Resonant':
        preset = const FilterSettings(
          enabled: true,
          cutoff: 1500.0,
          resonance: 8.0,
          type: 'bpf',
        );
        break;
      default:
        return;
    }
    
    state = state.copyWith(filter: preset);
    _pushToEngine();
  }

  // Envelope presets
  void applyEnvelopePreset(String presetName) {
    EnvelopeSettings preset;
    switch (presetName) {
      case 'Piano':
        preset = const EnvelopeSettings(
          enabled: true,
          attack: 0.01,
          decay: 0.1,
          sustain: 0.7,
          release: 0.3,
        );
        break;
      case 'Strings':
        preset = const EnvelopeSettings(
          enabled: true,
          attack: 0.1,
          decay: 0.2,
          sustain: 0.8,
          release: 1.0,
        );
        break;
      case 'Percussion':
        preset = const EnvelopeSettings(
          enabled: true,
          attack: 0.001,
          decay: 0.05,
          sustain: 0.1,
          release: 0.1,
        );
        break;
      case 'Pad':
        preset = const EnvelopeSettings(
          enabled: true,
          attack: 0.5,
          decay: 0.3,
          sustain: 0.9,
          release: 2.0,
        );
        break;
      case 'Lead':
        preset = const EnvelopeSettings(
          enabled: true,
          attack: 0.05,
          decay: 0.1,
          sustain: 0.6,
          release: 0.2,
        );
        break;
      case 'Bass':
        preset = const EnvelopeSettings(
          enabled: true,
          attack: 0.02,
          decay: 0.15,
          sustain: 0.8,
          release: 0.4,
        );
        break;
      default:
        return;
    }
    
    state = state.copyWith(envelope: preset);
    _pushToEngine();
  }

  // Sustain methods
  void setSustainEnabled(bool enabled) {
    state = state.copyWith(sustain: state.sustain.copyWith(enabled: enabled));
    _pushToEngine();
  }

  void setSustainDuration(double duration) {
    state = state.copyWith(sustain: state.sustain.copyWith(duration: duration));
    _pushToEngine();
  }

  void setSustainLevel(double level) {
    state = state.copyWith(sustain: state.sustain.copyWith(level: level));
    _pushToEngine();
  }

  void setSustainInfinite(bool infinite) {
    state = state.copyWith(sustain: state.sustain.copyWith(infinite: infinite));
    _pushToEngine();
  }

  // Randomness methods
  void setRandomnessEnabled(bool enabled) {
    state = state.copyWith(randomness: state.randomness.copyWith(enabled: enabled));
    _pushToEngine();
  }

  void setPitchVariation(double variation) {
    state = state.copyWith(randomness: state.randomness.copyWith(pitchVariation: variation));
    _pushToEngine();
  }

  void setVelocityVariation(double variation) {
    state = state.copyWith(randomness: state.randomness.copyWith(velocityVariation: variation));
    _pushToEngine();
  }

  void setTimingVariation(double variation) {
    state = state.copyWith(randomness: state.randomness.copyWith(timingVariation: variation));
    _pushToEngine();
  }

  void setSustainVariation(double variation) {
    state = state.copyWith(randomness: state.randomness.copyWith(sustainVariation: variation));
    _pushToEngine();
  }

  // Simultaneous Notes methods
  void setSimultaneousNotesEnabled(bool enabled) {
    state = state.copyWith(simultaneousNotes: state.simultaneousNotes.copyWith(enabled: enabled));
    _pushToEngine();
  }

  void setMaxNotes(int maxNotes) {
    state = state.copyWith(simultaneousNotes: state.simultaneousNotes.copyWith(maxNotes: maxNotes));
    _pushToEngine();
  }

  void setOverlapProbability(double probability) {
    state = state.copyWith(simultaneousNotes: state.simultaneousNotes.copyWith(overlapProbability: probability));
    _pushToEngine();
  }

  void setVoiceStealing(bool enabled) {
    state = state.copyWith(simultaneousNotes: state.simultaneousNotes.copyWith(voiceStealing: enabled));
    _pushToEngine();
  }

  void setVoiceStealThreshold(double threshold) {
    state = state.copyWith(simultaneousNotes: state.simultaneousNotes.copyWith(voiceStealThreshold: threshold));
    _pushToEngine();
  }

  void _pushToEngine() {
    try {
      final engine = _ref.read(audioEngineProvider);
      final effectsData = state.toMap();
      (engine as dynamic).updateAudioEffects(effectsData);
      print('AudioEffectsNotifier: pushed to engine - $effectsData');
    } catch (e) {
      print('AudioEffectsNotifier: failed to push to engine: $e');
    }
  }
}

final audioEffectsProvider = StateNotifierProvider<AudioEffectsNotifier, AudioEffectsState>((ref) {
  return AudioEffectsNotifier(ref);
});
