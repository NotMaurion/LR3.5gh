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
  async loadPreset(presetName) {
    const preset = this.PRESET_CONFIG[presetName];
    if (!preset) {
      console.warn("AuraSonixEngine: preset not found:", presetName);
      this.currentPreset = null;
      return false;
    }
    this.currentPreset = presetName;
    console.log("AuraSonixEngine: preset loaded:", presetName, preset);

    // Try to load advanced config.json next to wavs
    const folder = `assets/audio/presets/${presetName}`;
    const configUrl = `${folder}/config.json`;
    try {
      const resp = await fetch(configUrl, { cache: 'no-cache' });
      if (resp.ok) {
        this.currentPresetConfig = await resp.json();
        console.log("AuraSonixEngine: loaded config.json for", presetName, this.currentPresetConfig);
      } else {
        this.currentPresetConfig = null;
        console.log("AuraSonixEngine: no config.json for", presetName);
      }
    } catch (e) {
      this.currentPresetConfig = null;
      console.warn("AuraSonixEngine: error fetching config.json", e);
    }

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

    const cfg = this.currentPresetConfig;
    const presetMap = this.PRESET_CONFIG[this.currentPreset] || {};

    let selectedZone = null;
    let sampleKey = null; // one of bass|mid|high|tex

    if (cfg && Array.isArray(cfg.zones) && cfg.zones.length > 0) {
      selectedZone = this._selectZoneForNote(cfg.zones, noteNumber);
      if (selectedZone) {
        // probability gate (default 1.0)
        const prob = typeof selectedZone.probability === 'number' ? selectedZone.probability : 1.0;
        if (!this._passProbability(prob)) {
          console.log("AuraSonixEngine: note dropped by probability gate", { noteNumber, prob });
          return;
        }
        sampleKey = this._resolveSampleKey(selectedZone.sample);
      }
    }

    // Fallback mapping by pitch range if no zone matched
    if (!sampleKey) {
      if (noteNumber < 48) sampleKey = 'bass';
      else if (noteNumber < 72) sampleKey = 'mid';
      else if (noteNumber < 96) sampleKey = 'high';
      else sampleKey = 'tex';
    }

    const sampleUrl = presetMap[sampleKey];
    const globalVol = cfg && typeof cfg.globalVolume === 'number' ? cfg.globalVolume : 1.0;
    const zoneVol = selectedZone && typeof selectedZone.volume === 'number' ? selectedZone.volume : 1.0;
    const gain = this._clamp01(globalVol * zoneVol * this._clamp01(velocity));

    // TODO: Hook WebAudio graph here with sampleUrl and gain
    console.log("AuraSonixEngine: playNote", {
      noteNumber,
      velocity,
      preset: this.currentPreset,
      sampleKey,
      sampleUrl,
      gain,
      zone: selectedZone ? selectedZone.name || sampleKey : null,
      configLoaded: !!cfg,
    });
  }

  _selectZoneForNote(zones, noteNumber) {
    // Select first zone where note is within [minNote, maxNote]
    for (const z of zones) {
      const min = typeof z.minNote === 'number' ? z.minNote : 0;
      const max = typeof z.maxNote === 'number' ? z.maxNote : 127;
      if (noteNumber >= min && noteNumber <= max) return z;
    }
    return null;
  }

  _resolveSampleKey(sampleFileName) {
    if (!sampleFileName || typeof sampleFileName !== 'string') return null;
    const base = sampleFileName.toLowerCase();
    if (base.includes('bass')) return 'bass';
    if (base.includes('mid')) return 'mid';
    if (base.includes('high')) return 'high';
    if (base.includes('tex')) return 'tex';
    return null;
  }

  _passProbability(prob) {
    const p = Number.isFinite(prob) ? Math.max(0, Math.min(1, prob)) : 1.0;
    return Math.random() <= p;
  }

  _clamp01(v) { return Math.max(0, Math.min(1, v)); }

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
