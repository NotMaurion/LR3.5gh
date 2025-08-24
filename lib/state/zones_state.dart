  import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../audio/audio_providers.dart';

class ZoneConfig {
  final String name;
  final double minNote;
  final double maxNote;
  final String baseNote;
  final double volume;
  final double probability;
  // Texture controls per zone
  final bool textureEnabled;
  final bool textureLoop;
  final double textureLfoRateHz;
  final double textureLfoDepth;

  const ZoneConfig({
    required this.name,
    required this.minNote,
    required this.maxNote,
     required this.baseNote,
    required this.volume,
    required this.probability,
    this.textureEnabled = false,
    this.textureLoop = true,
    this.textureLfoRateHz = 0.2,
    this.textureLfoDepth = 0.5,
  });

  ZoneConfig copyWith({
    String? name,
    double? minNote,
    double? maxNote,
    String? baseNote,
    double? volume,
    double? probability,
    bool? textureEnabled,
    bool? textureLoop,
    double? textureLfoRateHz,
    double? textureLfoDepth,
  }) {
    return ZoneConfig(
      name: name ?? this.name,
      minNote: minNote ?? this.minNote,
      maxNote: maxNote ?? this.maxNote,
      baseNote: baseNote ?? this.baseNote,
      volume: volume ?? this.volume,
      probability: probability ?? this.probability,
      textureEnabled: textureEnabled ?? this.textureEnabled,
      textureLoop: textureLoop ?? this.textureLoop,
      textureLfoRateHz: textureLfoRateHz ?? this.textureLfoRateHz,
      textureLfoDepth: textureLfoDepth ?? this.textureLfoDepth,
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
      'texture': {
        'enabled': textureEnabled,
        'loop': textureLoop,
        'lfoRateHz': textureLfoRateHz,
        'lfoDepth': textureLfoDepth,
      }
    };
  }


}

class ZonesNotifier extends StateNotifier<List<ZoneConfig>> {
  ZonesNotifier(this._ref) : super(_defaultZones) {
    // Load current preset configuration from engine
    loadFromEngine();
  }

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  final Ref _ref;

  Future<void> loadFromEngine() async {
    final engine = _ref.read(audioEngineProvider);
    try {
      // ignore: avoid_dynamic_calls
      final zonesData = await (engine as dynamic).getCurrentZones();
      print('ZonesNotifier: received zones data from engine: $zonesData');
      print('ZonesNotifier: zonesData type: ${zonesData.runtimeType}');
      print('ZonesNotifier: zonesData length: ${zonesData?.length}');
      
      if (zonesData != null && zonesData.isNotEmpty) {
        print('ZonesNotifier: processing ${zonesData.length} zones');
        final zones = <ZoneConfig>[];
        
        for (int i = 0; i < zonesData.length; i++) {
          final zoneData = zonesData[i];
          print('ZonesNotifier: processing zone $i: $zoneData');
          print('ZonesNotifier: zone $i type: ${zoneData.runtimeType}');
          
          try {
            final zone = ZoneConfig(
              name: zoneData['name']?.toString() ?? 'Unknown',
              minNote: (zoneData['minNote'] ?? 0).toDouble(),
              maxNote: (zoneData['maxNote'] ?? 127).toDouble(),
              baseNote: zoneData['baseNote']?.toString() ?? 'C4',
              volume: (zoneData['volume'] ?? 1.0).toDouble(),
              probability: (zoneData['probability'] ?? 1.0).toDouble(),
              textureEnabled: zoneData['texture']?['enabled'] ?? false,
              textureLoop: zoneData['texture']?['loop'] ?? true,
              textureLfoRateHz: (zoneData['texture']?['lfoRateHz'] ?? 0.2).toDouble(),
              textureLfoDepth: (zoneData['texture']?['lfoDepth'] ?? 0.5).toDouble(),
            );
            zones.add(zone);
            print('ZonesNotifier: created zone $i: ${zone.name} with volume ${zone.volume}');
          } catch (e) {
            print('ZonesNotifier: error processing zone $i: $e');
          }
        }
        
        state = zones;
        _isLoaded = true;
        print('ZonesNotifier: loaded from engine - ${zones.length} zones with volumes: ${zones.map((z) => '${z.name}:${z.volume}').join(', ')}');
      } else {
        print('ZonesNotifier: no zones data received from engine');
        _isLoaded = true; // Mark as loaded even if no data
      }
    } catch (e) {
      print('ZonesNotifier: failed to load from engine: $e');
      print('ZonesNotifier: error stack trace: ${e.toString()}');
      _isLoaded = true; // Mark as loaded even on error
    }
    // Don't push back to engine - we just loaded from it
    // _pushToEngine();
  }

  static const List<ZoneConfig> _defaultZones = [
    ZoneConfig(
      name: 'Bass',
      minNote: 21.0,  // A0 (nota más baja del piano)
      maxNote: 43.0,  // G2
      baseNote: 'C2',
      volume: 0.7,
      probability: 0.8,
    ),
    ZoneConfig(
      name: 'Mid',
      minNote: 44.0,  // G#2
      maxNote: 67.0,  // G4
      baseNote: 'C4',
      volume: 0.6,
      probability: 0.7,
    ),
    ZoneConfig(
      name: 'High',
      minNote: 68.0,  // G#4
      maxNote: 87.0,  // C6 (nota más alta del piano)
      baseNote: 'C5',
      volume: 0.5,
      probability: 0.6,
    ),
    ZoneConfig(
      name: 'Tex',
      minNote: 21.0,  // A0 (rango completo para textura)
      maxNote: 87.0,  // C6
      baseNote: 'C3',
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
      print('ZonesNotifier: pushed to engine - $zonesData');
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


