import '../audio_engine.dart';

class NoopAudioEngine implements AudioEngine {
  @override
  Future<void> init() async {}

  @override
  Future<bool> loadPreset(String presetName) async => true;

  @override
  void playNote(int noteNumber, {double velocity = 1.0}) {}

  @override
  void stopAll() {}

  @override
  void stopNote(int noteNumber) {}

  @override
  Future<List<String>> listPresets() async => const <String>[];

  @override
  void updateScaleFilterConfig(Map<String, dynamic> config) {}
}


