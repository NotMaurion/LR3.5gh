import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../audio/audio_providers.dart';

class ZoneConfig {
  ZoneConfig({
    required this.name,
    required this.minNote,
    required this.maxNote,
    required this.baseNote,
    required this.volume,
    required this.probability,
  });

  final String name;
  final int minNote;
  final int maxNote;
  final String baseNote;
  final double volume;
  final double probability;

  ZoneConfig copyWith({
    String? name,
    int? minNote,
    int? maxNote,
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

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'minNote': minNote,
        'maxNote': maxNote,
        'baseNote': baseNote,
        'volume': volume,
        'probability': probability,
      };
}

class ZonesNotifier extends StateNotifier<List<ZoneConfig>> {
  ZonesNotifier(this._ref)
      : super(<ZoneConfig>[
          ZoneConfig(name: 'Bass', minNote: 24, maxNote: 47, baseNote: 'C', volume: 0.85, probability: 1.0),
          ZoneConfig(name: 'Mid', minNote: 48, maxNote: 71, baseNote: 'C', volume: 0.85, probability: 1.0),
          ZoneConfig(name: 'High', minNote: 72, maxNote: 95, baseNote: 'C', volume: 0.85, probability: 1.0),
          ZoneConfig(name: 'Tex', minNote: 0, maxNote: 127, baseNote: 'C', volume: 0.5, probability: 0.5),
        ]);

  final Ref _ref;

  void _pushToEngine() {
    final engine = _ref.read(audioEngineProvider);
    try {
      // ignore: avoid_dynamic_calls
      (engine as dynamic).updateZonesConfig(state.map((z) => z.toJson()).toList());
    } catch (_) {}
  }

  void _updateAt(int index, ZoneConfig Function(ZoneConfig) transform) {
    final list = List<ZoneConfig>.from(state);
    list[index] = transform(list[index]);
    state = list;
    _pushToEngine();
  }

  void setMin(int index, int value) {
    _updateAt(index, (z) {
      final v = value.clamp(0, 127);
      final newMin = v <= z.maxNote ? v : z.maxNote;
      return z.copyWith(minNote: newMin);
    });
  }

  void setMax(int index, int value) {
    _updateAt(index, (z) {
      final v = value.clamp(0, 127);
      final newMax = v >= z.minNote ? v : z.minNote;
      return z.copyWith(maxNote: newMax);
    });
  }

  void setBase(int index, String value) {
    _updateAt(index, (z) => z.copyWith(baseNote: value));
  }

  void setVolume(int index, double value) {
    _updateAt(index, (z) => z.copyWith(volume: value.clamp(0.0, 1.0)));
  }

  void setProbability(int index, double value) {
    _updateAt(index, (z) => z.copyWith(probability: value.clamp(0.0, 1.0)));
  }
}

final zonesProvider = StateNotifierProvider<ZonesNotifier, List<ZoneConfig>>(
  (ref) => ZonesNotifier(ref),
);


