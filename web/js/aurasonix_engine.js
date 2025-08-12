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

    // WebAudio primitives
    this.audioCtx = null;
    this.masterGain = null;
    this.currentBuffers = { bass: null, mid: null, high: null, tex: null };
    this.activeSources = new Set();
  }

  // Validate and preload; returns false on any loading error
  async loadPreset(presetName) {
    const preset = this.PRESET_CONFIG[presetName];
    if (!preset) {
      console.warn("AuraSonixEngine: preset not found:", presetName);
      this.currentPreset = null;
      return false;
    }

    // Reset any previous state prior to loading
    this.currentPresetConfig = null;
    this.currentBuffers = { bass: null, mid: null, high: null, tex: null };

    try {
      // Optional config.json
      const folder = `assets/audio/presets/${presetName}`;
      const configUrl = `${folder}/config.json`;
      const resp = await fetch(configUrl, { cache: 'no-cache' });
      if (resp.status === 404) {
        this.currentPresetConfig = null;
        console.log("AuraSonixEngine: no config.json for", presetName);
      } else if (resp.ok) {
        this.currentPresetConfig = await resp.json();
        console.log("AuraSonixEngine: loaded config.json for", presetName, this.currentPresetConfig);
      } else {
        throw new Error(`config.json fetch failed with status ${resp.status}`);
      }

      await this._ensureAudio();
      // Load all four buffers; throws if any fail
      const loaded = await this._loadBuffersForPreset(presetName, preset);
      this.currentBuffers = loaded;

      // Only mark preset as current after successful load
      this.currentPreset = presetName;
      console.log("AuraSonixEngine: preset loaded and buffers ready:", presetName);
      return true;
    } catch (e) {
      console.error("AuraSonixEngine: failed to load preset", {
        preset: presetName,
        error: e && (e.stack || e.message || e.toString()),
      });
      // Ensure clean state
      this.currentPresetConfig = null;
      this.currentBuffers = { bass: null, mid: null, high: null, tex: null };
      this.currentPreset = null;
      return false;
    }
  }

  _recomputePresetKeys() {
    this.PRESET_KEYS = Object.keys(this.PRESET_CONFIG || {});
  }

  // Update scale filter settings from Flutter
  updateScaleFilter(newConfig) {
    if (!this.currentPresetConfig) {
      this.currentPresetConfig = { midiConfig: { scaleFilter: {} } };
    }
    if (!this.currentPresetConfig.midiConfig) {
      this.currentPresetConfig.midiConfig = {};
    }
    this.currentPresetConfig.midiConfig.scaleFilter = Object.assign(
      {},
      this.currentPresetConfig.midiConfig.scaleFilter || {},
      newConfig || {}
    );
    return true;
  }

  playNote(noteNumber, velocity = 1.0) {
    if (!this.currentPreset) {
      console.warn("AuraSonixEngine: playNote ignored, no preset loaded");
      return;
    }

    const cfg = this.currentPresetConfig;

    // Scale filter (early exit)
    const sf = cfg && cfg.midiConfig && cfg.midiConfig.scaleFilter;
    if (sf && sf.enabled === true) {
      const inScale = this._notePassesScaleFilter(noteNumber, sf);
      if (!inScale) {
        // Drop the note silently when outside the configured scale
        return;
      }
    }
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

    const buffer = this.currentBuffers && this.currentBuffers[sampleKey];
    if (!this.audioCtx || !buffer) {
      console.warn("AuraSonixEngine: buffer not ready", { sampleKey, sampleUrl });
      return;
    }

    // Resume context on user gesture environments
    if (this.audioCtx.state === 'suspended') {
      this.audioCtx.resume().catch(() => {});
    }

    const src = this.audioCtx.createBufferSource();
    src.buffer = buffer;
    const g = this.audioCtx.createGain();
    g.gain.value = gain;
    src.connect(g).connect(this.masterGain);
    src.start();
    this.activeSources.add(src);
    src.onended = () => this.activeSources.delete(src);
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

  _notePassesScaleFilter(noteNumber, scaleFilter) {
    const mode = (scaleFilter.scale || '').toLowerCase();
    const root = (scaleFilter.rootNote || 'C').toUpperCase();
    const minOct = Number.isFinite(scaleFilter.minOctave) ? scaleFilter.minOctave : -1;
    const maxOct = Number.isFinite(scaleFilter.maxOctave) ? scaleFilter.maxOctave : 9;

    const octave = this._midiOctave(noteNumber);
    if (octave < minOct || octave > maxOct) return false;

    const rootPc = this._rootToPitchClass(root);
    const notePc = noteNumber % 12;

    if (mode === 'pentatonic_major') {
      // Intervals relative to root: 0, 2, 4, 7, 9
      const allowed = new Set([
        rootPc,
        (rootPc + 2) % 12,
        (rootPc + 4) % 12,
        (rootPc + 7) % 12,
        (rootPc + 9) % 12,
      ]);
      return allowed.has(notePc);
    }

    // If unknown scale mode, allow note (non-blocking)
    return true;
  }

  _midiOctave(noteNumber) {
    // MIDI note 60 -> C4 (octave = 4). MIDI 0 -> C-1
    return Math.floor(noteNumber / 12) - 1;
  }

  _rootToPitchClass(rootNote) {
    // Support sharps and flats
    const map = {
      'C': 0, 'B#': 0,
      'C#': 1, 'DB': 1,
      'D': 2,
      'D#': 3, 'EB': 3,
      'E': 4, 'FB': 4,
      'F': 5, 'E#': 5,
      'F#': 6, 'GB': 6,
      'G': 7,
      'G#': 8, 'AB': 8,
      'A': 9,
      'A#': 10, 'BB': 10,
      'B': 11, 'CB': 11,
    };
    const key = rootNote.replace('♯', '#').replace('♭', 'B').toUpperCase();
    return map[key] ?? 0;
  }

  stopNote(noteNumber) {
    if (!this.currentPreset) return;
    // TODO: Stop specific note
    console.log("AuraSonixEngine: stopNote", { noteNumber, preset: this.currentPreset });
  }

  stopAll() {
    try {
      for (const src of this.activeSources) {
        try { src.stop(); } catch (_) {}
      }
    } finally {
      this.activeSources.clear();
    }
  }

  async _ensureAudio() {
    if (!this.audioCtx) {
      const Ctx = window.AudioContext || window.webkitAudioContext;
      this.audioCtx = new Ctx();
      this.masterGain = this.audioCtx.createGain();
      this.masterGain.gain.value = 1.0;
      this.masterGain.connect(this.audioCtx.destination);
    }
  }

  async _loadBuffersForPreset(presetName, presetMap) {
    const out = { bass: null, mid: null, high: null, tex: null };
    const entries = Object.entries(presetMap || {});
    for (const [key, url] of entries) {
      if (!url) throw new Error(`Missing URL for sample key ${key}`);
      out[key] = await this._loadAudioBuffer(url);
      if (!out[key]) throw new Error(`Decoded buffer is null for ${key}`);
    }
    return out;
  }

  async _loadAudioBuffer(url) {
    const resp = await fetch(url, { cache: 'no-cache' });
    if (!resp.ok) throw new Error(`HTTP ${resp.status} for ${url}`);
    const arr = await resp.arrayBuffer();
    return await new Promise((resolve, reject) => {
      try {
        this.audioCtx.decodeAudioData(arr, resolve, reject);
      } catch (e) {
        reject(e);
      }
    });
  }
}
window.AuraSonixEngine = AuraSonixEngine;
