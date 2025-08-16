import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../audio/audio_providers.dart';

class ZoneConfig {
  final String name;
  final double minNote;
  final double maxNote;
  final String baseNote;
  final double volume;
  final double probability;

  const ZoneConfig({
    required this.name,
    required this.minNote,
    required this.maxNote,
    required this.baseNote,
    required this.volume,
    required this.probability,
  });

  ZoneConfig copyWith({
    String? name,
    double? minNote,
    double? maxNote,
    String? baseNote,
    double? volume,
    double? probability,
  }) {
    return ZoneConfig(
      name: name ?? this.name,
      minNote: minNote ?? this.minNote,
      maxNote: maxNote ?? this.maxNote,
      baseNote: baseNote ?? this.baseNote,
      volume: volume ?? this.volume,
      probability: probability ?? this.probability,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'minNote': minNote,
      'maxNote': maxNote,
      'baseNote': baseNote,
      'volume': volume,
      'probability': probability,
    };
  }
}

class ZonesNotifier extends StateNotifier<List<ZoneConfig>> {
  ZonesNotifier(this._ref) : super(_defaultZones);

  final Ref _ref;

  static const List<ZoneConfig> _defaultZones = [
    ZoneConfig(
      name: 'Bass',
      minNote: 0.0,
      maxNote: 47.0,
      baseNote: 'C',
      volume: 0.7,
      probability: 0.8,
    ),
    ZoneConfig(
      name: 'Mid',
      minNote: 48.0,
      maxNote: 83.0,
      baseNote: 'E',
      volume: 0.6,
      probability: 0.7,
    ),
    ZoneConfig(
      name: 'High',
      minNote: 84.0,
      maxNote: 107.0,
      baseNote: 'G',
      volume: 0.5,
      probability: 0.6,
    ),
    ZoneConfig(
      name: 'Tex',
      minNote: 108.0,
      maxNote: 127.0,
      baseNote: 'A',
      volume: 0.4,
      probability: 0.5,
    ),
  ];

  void updateZone(int index, ZoneConfig updatedZone) {
    if (index >= 0 && index < state.length) {
      state = [
        ...state.sublist(0, index),
        updatedZone,
        ...state.sublist(index + 1),
      ];
      _pushToEngine();
    }
  }

  void _pushToEngine() {
    try {
      final engine = _ref.read(audioEngineProvider);
      final zonesData = state.map((zone) => zone.toMap()).toList();
      (engine as dynamic).updateZonesConfig(zonesData);
    } catch (e) {
      print('ZonesNotifier: failed to push to engine: $e');
    }
  }

  void setMinNote(int index, double minNote) {
    if (index >= 0 && index < state.length) {
      final zone = state[index];
      final updatedZone = zone.copyWith(
        minNote: minNote,
        maxNote: minNote > zone.maxNote ? minNote : zone.maxNote,
      );
      updateZone(index, updatedZone);
    }
  }

  void setMaxNote(int index, double maxNote) {
    if (index >= 0 && index < state.length) {
      final zone = state[index];
      final updatedZone = zone.copyWith(
        maxNote: maxNote,
        minNote: maxNote < zone.minNote ? maxNote : zone.minNote,
      );
      updateZone(index, updatedZone);
    }
  }

  void setBaseNote(int index, String baseNote) {
    if (index >= 0 && index < state.length) {
      final zone = state[index];
      final updatedZone = zone.copyWith(baseNote: baseNote);
      updateZone(index, updatedZone);
    }
  }

  void setVolume(int index, double volume) {
    if (index >= 0 && index < state.length) {
      final zone = state[index];
      final updatedZone = zone.copyWith(volume: volume);
      updateZone(index, updatedZone);
    }
  }

  void setProbability(int index, double probability) {
    if (index >= 0 && index < state.length) {
      final zone = state[index];
      final updatedZone = zone.copyWith(probability: probability);
      updateZone(index, updatedZone);
    }
  }
}

// Provider global para el estado de las zonas
final zonesProvider = StateNotifierProvider<ZonesNotifier, List<ZoneConfig>>((ref) {
  return ZonesNotifier(ref);
});


