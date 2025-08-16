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
    this.activeByNote = {}; // noteNumber -> Set<AudioBufferSourceNode>
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

  // Update zones configuration from Flutter
  updateZonesConfig(zones) {
    if (!this.currentPresetConfig) this.currentPresetConfig = {};
    const sanitize = (z) => {
      const out = Object.assign({}, z || {});
      const clamp01 = (v) => Math.max(0, Math.min(1, Number(v)));
      out.minNote = Math.max(0, Math.min(127, Number(out.minNote ?? 0)));
      out.maxNote = Math.max(0, Math.min(127, Number(out.maxNote ?? 127)));
      if (out.maxNote < out.minNote) {
        const tmp = out.minNote; out.minNote = out.maxNote; out.maxNote = tmp;
      }
      out.baseNote = (out.baseNote || 'C').toString();
      out.volume = clamp01(out.volume ?? 1.0);
      out.probability = clamp01(out.probability ?? 1.0);
      return out;
    };
    if (Array.isArray(zones)) {
      this.currentPresetConfig.zones = zones.map(sanitize);
    } else {
      this.currentPresetConfig.zones = [];
    }
    return true;
  }

  playNote(noteNumber, velocity = 1.0) {
    if (!this.currentPreset) {
      console.warn("AuraSonixEngine: playNote ignored, no preset loaded");
      return;
    }

    const cfg = this.currentPresetConfig;
    const presetMap = this.PRESET_CONFIG[this.currentPreset] || {};

    // Apply scale filter if enabled
    if (cfg && cfg.midiConfig && cfg.midiConfig.scaleFilter && cfg.midiConfig.scaleFilter.enabled) {
      if (!this._notePassesScaleFilter(noteNumber, cfg.midiConfig.scaleFilter)) {
        console.log("AuraSonixEngine: note dropped by scale filter", { noteNumber });
        return;
      }
    }

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
    // Envelope parameters (seconds) from config, with sensible defaults
    const env = this._getEnvelope();
    // Start at near zero then A->D towards sustain
    const now = this.audioCtx.currentTime;
    const peak = Math.max(0, gain);
    const sustainLevel = Math.max(0, Math.min(1, env.sustain ?? 0.8));
    g.gain.cancelScheduledValues(now);
    g.gain.setValueAtTime(0.0001, now);
    g.gain.linearRampToValueAtTime(peak, now + (env.attack ?? 0.01));
    g.gain.linearRampToValueAtTime(peak * sustainLevel, now + (env.attack ?? 0.01) + (env.decay ?? 0.1));

    src.connect(g).connect(this.masterGain);
    src.start();
    this.activeSources.add(src);
    // Track by note for precise stop
    if (!this.activeByNote[noteNumber]) this.activeByNote[noteNumber] = new Set();
    src._gainNode = g; // attach for release handling
    this.activeByNote[noteNumber].add(src);
    src.onended = () => {
      this.activeSources.delete(src);
      const set = this.activeByNote[noteNumber];
      if (set) {
        set.delete(src);
        if (set.size === 0) delete this.activeByNote[noteNumber];
      }
    };
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
    const set = this.activeByNote[noteNumber];
    if (!set || set.size === 0) return;
    const env = this._getEnvelope();
    const rel = Math.max(0.0, env.release ?? 0.3);
    const now = this.audioCtx.currentTime;
    for (const src of Array.from(set)) {
      try {
        const g = src._gainNode;
        if (g) {
          g.gain.cancelScheduledValues(now);
          const current = g.gain.value;
          g.gain.setValueAtTime(current, now);
          g.gain.linearRampToValueAtTime(0.0001, now + rel);
        }
        src.stop(now + rel + 0.01);
      } catch (_) {}
    }
    delete this.activeByNote[noteNumber];
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

  enableMidi() {
    if (!navigator.requestMIDIAccess) {
      console.warn('AuraSonixEngine: Web MIDI API not supported');
      return false;
    }
    const onMessage = (event) => {
      const [status, data1, data2] = event.data;
      const command = status & 0xf0;
      // Note On
      if (command === 0x90 && data2 > 0) {
        const note = data1;
        const velocity = Math.max(0.0, Math.min(1.0, data2 / 127));
        this.playNote(note, velocity);
        return;
      }
      // Note Off (or Note On with velocity 0)
      if (command === 0x80 || (command === 0x90 && data2 === 0)) {
        const note = data1;
        this.stopNote(note);
      }
    };

    const attachInputs = (access) => {
      for (const input of access.inputs.values()) {
        input.onmidimessage = onMessage;
      }
      access.onstatechange = () => {
        for (const input of access.inputs.values()) {
          input.onmidimessage = onMessage;
        }
      };
    };

    navigator.requestMIDIAccess({ sysex: false })
      .then((access) => {
        attachInputs(access);
        console.log('AuraSonixEngine: MIDI enabled');
      })
      .catch((e) => {
        console.warn('AuraSonixEngine: MIDI failed', e);
      });
    return true;
  }

  _getEnvelope() {
    const cfg = this.currentPresetConfig;
    const chain = cfg && Array.isArray(cfg.effectsChain) ? cfg.effectsChain : [];
    const env = chain.find((e) => (e && (e.type === 'Envelope' || e.id === 'main-envelope')));
    const params = (env && env.parameters) || {};
    return {
      attack: Number(params.attack ?? 0.01),
      decay: Number(params.decay ?? 0.1),
      sustain: Number(params.sustain ?? 0.8),
      release: Number(params.release ?? 0.3),
    };
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

  _notePassesScaleFilter(noteNumber, scaleFilter) {
    const octave = Math.floor(noteNumber / 12) - 1;
    if (octave < scaleFilter.minOctave || octave > scaleFilter.maxOctave) {
      return false;
    }
    
    const noteInOctave = noteNumber % 12;
    const rootNote = this._getRootNoteValue(scaleFilter.rootNote);
    const relativeNote = (noteInOctave - rootNote + 12) % 12;
    
    switch (scaleFilter.scale) {
      case 'chromatic':
        return true;
      case 'pentatonic_major':
        return [0, 2, 4, 7, 9].includes(relativeNote);
      case 'pentatonic_minor':
        return [0, 3, 5, 7, 10].includes(relativeNote);
      case 'major':
        return [0, 2, 4, 5, 7, 9, 11].includes(relativeNote);
      case 'minor':
        return [0, 2, 3, 5, 7, 8, 10].includes(relativeNote);
      case 'dorian':
        return [0, 2, 3, 5, 7, 9, 10].includes(relativeNote);
      case 'mixolydian':
        return [0, 2, 4, 5, 7, 9, 10].includes(relativeNote);
      case 'lydian':
        return [0, 2, 4, 6, 7, 9, 11].includes(relativeNote);
      case 'phrygian':
        return [0, 1, 3, 5, 7, 8, 10].includes(relativeNote);
      case 'locrian':
        return [0, 1, 3, 5, 6, 8, 10].includes(relativeNote);
      default:
        return true;
    }
  }

  _getRootNoteValue(rootNote) {
    const noteValues = {
      'C': 0, 'C#': 1, 'D': 2, 'D#': 3, 'E': 4, 'F': 5,
      'F#': 6, 'G': 7, 'G#': 8, 'A': 9, 'A#': 10, 'B': 11
    };
    return noteValues[rootNote] || 0;
  }
}
window.AuraSonixEngine = AuraSonixEngine;
