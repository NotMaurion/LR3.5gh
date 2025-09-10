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
  void updateZonesConfig(List<Map<String, dynamic>> zones);
  void updateAudioEffects(Map<String, dynamic> effects);
  void updateMidiRules(Map<String, dynamic> rules);
  Future<void> play();
  // Export helpers
  Future<Map<String, dynamic>> getCurrentPresetConfig();
  Future<bool> loadPresetFromBundle(Map<String, dynamic> bundle);
  Future<bool> loadCustomSound(String layer, String dataUrl);
  Future<Map<String, dynamic>> getEmbeddedAudioDataUrls();
  Future<Map<String, dynamic>> getCurrentScaleFilter();
  Future<List<Map<String, dynamic>>> getCurrentZones();
  Future<Map<String, dynamic>> getCurrentAudioEffects();
}


