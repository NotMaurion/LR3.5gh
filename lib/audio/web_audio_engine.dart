import 'dart:js_util' as js_util;
import 'dart:html' as html;

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
    if (_engineInstance == null) return;
    js_util.callMethod(_engineInstance, 'updateScaleFilter', [config]);
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


