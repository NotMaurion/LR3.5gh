// AudioEngine interface per MCP V4.1
// Decouples UI from platform-specific audio implementations

abstract class AudioEngine {
  Future<void> init();
  Future<bool> loadPreset(String presetName);
  void playNote(int noteNumber, {double velocity = 1.0});
  void stopNote(int noteNumber);
  void stopAll();
  Future<List<String>> listPresets();
  void updateScaleFilterConfig(Map<String, dynamic> config);
}


