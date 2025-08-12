// AuraSonixEngine - initial scaffold
// PRESET_CONFIG drives preset folders in assets/audio/presets/[preset]/(bass.wav|mid.wav|high.wav|tex.wav)
class AuraSonixEngine {
  constructor() {
    this.PRESET_CONFIG = {
      // Example preset structure; add real presets via the add-preset task
      // "example": { bass: "assets/audio/presets/example/bass.wav", mid: "assets/audio/presets/example/mid.wav", high: "assets/audio/presets/example/high.wav", tex: "assets/audio/presets/example/tex.wav" },
      "Creative-Flow": {
        bass: "assets/audio/presets/Creative-Flow/bass.wav",
        mid: "assets/audio/presets/Creative-Flow/mid.wav",
        high: "assets/audio/presets/Creative-Flow/high.wav",
        tex: "assets/audio/presets/Creative-Flow/tex.wav"
      }
    };

    // Internal state placeholders
    this.currentPreset = null;
    this.PRESET_KEYS = [];
    this._recomputePresetKeys();
  }

  // Validate and set current preset; real engine should preload audio buffers
  loadPreset(presetName) {
    const preset = this.PRESET_CONFIG[presetName];
    if (!preset) {
      console.warn("AuraSonixEngine: preset not found:", presetName);
      this.currentPreset = null;
      return false;
    }
    this.currentPreset = presetName;
    console.log("AuraSonixEngine: preset loaded:", presetName, preset);
    return true;
  }

  _recomputePresetKeys() {
    this.PRESET_KEYS = Object.keys(this.PRESET_CONFIG || {});
  }

  playNote(noteNumber, velocity = 1.0) {
    if (!this.currentPreset) {
      console.warn("AuraSonixEngine: playNote ignored, no preset loaded");
      return;
    }
    // TODO: Hook WebAudio graph here
    console.log("AuraSonixEngine: playNote", { noteNumber, velocity, preset: this.currentPreset });
  }

  stopNote(noteNumber) {
    if (!this.currentPreset) return;
    // TODO: Stop specific note
    console.log("AuraSonixEngine: stopNote", { noteNumber, preset: this.currentPreset });
  }

  stopAll() {
    // TODO: Stop all voices
    console.log("AuraSonixEngine: stopAll");
  }
}
window.AuraSonixEngine = AuraSonixEngine;
