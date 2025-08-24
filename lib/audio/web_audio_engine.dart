import 'dart:js_util' as js_util;
import 'dart:html' as html;
import 'dart:convert';

import 'audio_engine.dart';

class WebAudioEngine implements AudioEngine {
  dynamic _engineInstance;

  @override
  Future<void> init() async {
    // Ensure script is present
    final engineCtor = js_util.getProperty(html.window, 'AuraSonixEngine');
    if (engineCtor == null) {
      throw StateError('AuraSonixEngine JS not found. Ensure web/js/aurasonix_engine.js is loaded in index.html');
    }
    _engineInstance = js_util.callConstructor(engineCtor, const []);
  }

  @override
  Future<bool> loadPreset(String presetName) async {
    if (_engineInstance == null) {
      await init();
    }
    final result = js_util.callMethod(_engineInstance, 'loadPreset', [presetName]);
    return (result is bool) ? result : false;
  }

  Future<Map<String, dynamic>> getCurrentPresetConfig() async {
    if (_engineInstance == null) {
      await init();
    }
    final obj = js_util.callMethod(_engineInstance, 'getCurrentPresetConfig', const []);
    // Convert JS object to a Dart map recursively
    final dartified = js_util.dartify(obj);
    return Map<String, dynamic>.from(dartified as Map);
  }

  Future<bool> loadPresetFromBundle(Map<String, dynamic> bundle) async {
    if (_engineInstance == null) {
      await init();
    }
    final result = js_util.callMethod(_engineInstance, 'loadPresetFromBundle', [js_util.jsify(bundle)]);
    return (result is bool) ? result : false;
  }

  // Load a single custom sound (base64/data URL) into a layer (bass|mid|high|tex)
  Future<bool> loadCustomSound(String layer, String dataUrl) async {
    if (_engineInstance == null) {
      await init();
    }
    final result = js_util.callMethod(_engineInstance, 'loadCustomSound', [layer, dataUrl]);
    return (result is bool) ? result : false;
  }

  // Retrieve any embedded audio data URLs currently held by the engine for export
  Future<Map<String, dynamic>> getEmbeddedAudioDataUrls() async {
    if (_engineInstance == null) {
      await init();
    }
    final obj = js_util.callMethod(_engineInstance, 'getEmbeddedAudioDataUrls', const []);
    final dartified = js_util.dartify(obj);
    return Map<String, dynamic>.from(dartified as Map);
  }

  Future<Map<String, dynamic>> getCurrentScaleFilter() async {
    if (_engineInstance == null) {
      await init();
    }
    final obj = js_util.callMethod(_engineInstance, 'getCurrentScaleFilter', const []);
    final dartified = js_util.dartify(obj);
    return Map<String, dynamic>.from(dartified as Map);
  }

  Future<List<Map<String, dynamic>>> getCurrentZones() async {
    if (_engineInstance == null) {
      await init();
    }
    final obj = js_util.callMethod(_engineInstance, 'getCurrentZones', const []);
    final dartified = js_util.dartify(obj);
    final list = dartified as List;
    return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  @override
  void playNote(int noteNumber, {double velocity = 1.0}) {
    if (_engineInstance == null) return;
    js_util.callMethod(_engineInstance, 'playNote', [noteNumber, velocity]);
  }

  @override
  void stopNote(int noteNumber) {
    if (_engineInstance == null) return;
    js_util.callMethod(_engineInstance, 'stopNote', [noteNumber]);
  }

  @override
  void stopAll() {
    if (_engineInstance == null) return;
    js_util.callMethod(_engineInstance, 'stopAll', const []);
  }

  @override
  void updateScaleFilterConfig(Map<String, dynamic> config) {
    if (_engineInstance == null) {
      // Initialize first, then apply
      init().then((_) {
        try {
          js_util.callMethod(_engineInstance, 'updateScaleFilter', [js_util.jsify(config)]);
        } catch (_) {}
      });
      return;
    }
    try {
      js_util.callMethod(_engineInstance, 'updateScaleFilter', [js_util.jsify(config)]);
    } catch (_) {}
  }

  @override
  void updateZonesConfig(List<Map<String, dynamic>> zones) {
    if (_engineInstance == null) {
      init().then((_) {
        try {
          js_util.callMethod(_engineInstance, 'updateZonesConfig', [js_util.jsify(zones)]);
        } catch (_) {}
      });
      return;
    }
    try {
      js_util.callMethod(_engineInstance, 'updateZonesConfig', [js_util.jsify(zones)]);
    } catch (_) {}
  }

  @override
  void updateAudioEffects(Map<String, dynamic> effects) {
    if (_engineInstance == null) {
      init().then((_) {
        try {
          js_util.callMethod(_engineInstance, 'updateAudioEffects', [js_util.jsify(effects)]);
        } catch (_) {}
      });
      return;
    }
    try {
      js_util.callMethod(_engineInstance, 'updateAudioEffects', [js_util.jsify(effects)]);
    } catch (_) {}
  }

  @override
  void updateMidiRules(Map<String, dynamic> rules) {
    if (_engineInstance == null) {
      init().then((_) {
        try {
          js_util.callMethod(_engineInstance, 'updateMidiRules', [js_util.jsify(rules)]);
        } catch (_) {}
      });
      return;
    }
    try {
      js_util.callMethod(_engineInstance, 'updateMidiRules', [js_util.jsify(rules)]);
    } catch (_) {}
  }

  @override
  Future<List<String>> listPresets() async {
    if (_engineInstance == null) {
      await init();
    }
    try {
      final keys = js_util.getProperty(_engineInstance, 'PRESET_KEYS');
      if (keys is List) {
        return keys.map((e) => e.toString()).toList();
      }
    } catch (_) {
      // ignore and fall through
    }
    return const <String>[];
  }

  @override
  Future<void> play() async {
    if (_engineInstance == null) {
      await init();
    }
    try {
      js_util.callMethod(_engineInstance, 'enableMidi', const []);
    } catch (_) {}
  }
}


