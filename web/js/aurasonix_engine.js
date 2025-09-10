// AuraSonixEngine - initial scaffold
// PRESET_CONFIG drives preset folders in assets/audio/presets/[preset]/(bass.wav|mid.wav|high.wav|tex.wav)
class AuraSonixEngine {
  constructor() {
    console.log("AuraSonixEngine: Constructor called - initializing audio engine");
    
    // Device detection and performance optimization
    this._detectDeviceCapabilities();
    
    this.PRESET_CONFIG = {
      "Creative-Flow": {
        bass: "assets/audio/presets/Creative-Flow/bass.wav",
        mid: "assets/audio/presets/Creative-Flow/mid.wav",
        high: "assets/audio/presets/Creative-Flow/high.wav",
        tex: "assets/audio/presets/Creative-Flow/tex.wav"
      },
      "Deep-Focus": {
        bass: "assets/audio/presets/Deep-Focus/bass.wav",
        mid: "assets/audio/presets/Deep-Focus/mid.wav",
        high: "assets/audio/presets/Deep-Focus/high.wav",
        tex: "assets/audio/presets/Deep-Focus/tex.wav"
      },
      "Relaxation": {
        bass: "assets/audio/presets/Relaxation/bass.wav",
        mid: "assets/audio/presets/Relaxation/mid.wav",
        high: "assets/audio/presets/Relaxation/high.wav",
        tex: "assets/audio/presets/Relaxation/tex.wav"
      },
      "Night-Drive": {
        bass: "assets/audio/presets/Night-Drive/bass.wav",
        mid: "assets/audio/presets/Night-Drive/mid.wav",
        high: "assets/audio/presets/Night-Drive/high.wav",
        tex: "assets/audio/presets/Night-Drive/tex.wav"
      },
      "Meditation": {
        bass: "assets/audio/presets/Meditation/bass.wav",
        mid: "assets/audio/presets/Meditation/mid.wav",
        high: "assets/audio/presets/Meditation/high.wav",
        tex: "assets/audio/presets/Meditation/tex.wav"
      },
      "Study": {
        bass: "assets/audio/presets/Study/bass.wav",
        mid: "assets/audio/presets/Study/mid.wav",
        high: "assets/audio/presets/Study/high.wav",
        tex: "assets/audio/presets/Study/tex.wav"
      },
      "Workout": {
        bass: "assets/audio/presets/Workout/bass.wav",
        mid: "assets/audio/presets/Workout/mid.wav",
        high: "assets/audio/presets/Workout/high.wav",
        tex: "assets/audio/presets/Workout/tex.wav"
      }
    };

    // Internal state placeholders
    this.currentPreset = null;
    this.PRESET_KEYS = [];
    this._recomputePresetKeys();

    // WebAudio primitives
    this.audioCtx = null;
    this.masterGain = null;
    // No longer needed for synthesizer architecture
    this.activeSources = new Set();
    this.activeByNote = {}; // noteNumber -> Set<AudioBufferSourceNode>
    this.activeByInputNote = {}; // original incoming MIDI note -> Set<AudioBufferSourceNode>
    
    // Performance optimization settings - more generous limits for better audio quality
    this.MAX_CONCURRENT_NOTES = Math.max(12, this.deviceCapabilities.maxConcurrentNotes);
    this.MAX_CONCURRENT_NOTES_PER_NOTE = Math.max(2, this.deviceCapabilities.maxConcurrentNotesPerNote);
    this.NOTE_CLEANUP_INTERVAL = 5000; // Less frequent cleanup to reduce CPU load
    this._lastCleanupTime = Date.now();
    
    // Audio context management for mobile
    this._audioContextResumeAttempts = 0;
    this._maxResumeAttempts = 3;
    this._resumeRetryDelay = 1000;
    
    // Buffer management for mobile
    this._bufferUnderrunProtection = true;
    this._preloadBuffers = new Map(); // Cache for frequently used buffers
    this._bufferCacheSize = this.deviceCapabilities.bufferCacheSize;
    
    // Polyphony management
    this.activeVoices = new Map(); // noteNumber -> { source, startTime, velocity, noteName }
    this.voiceCounter = 0; // For unique voice IDs
    this.polyphonyLimit = this.deviceCapabilities.polyphonyLimit;
    this.voiceStealingEnabled = true;
    this.stealOldest = true;
    this.releaseTime = 0.1; // Default release time for voice stealing
    
    // Default configuration
    this.currentPresetConfig = {};
    this.currentPresetConfig.zones = [];
    this.currentPresetConfig.scaleFilter = { 
      enabled: true, 
      mode: 'pentatonic', 
      root: 'C', 
      minOctave: 2, 
      maxOctave: 6 
    };
    this.currentPresetConfig.audioEffects = {
      reverb: { enabled: true, wet: 0.7, dry: 0.3, roomSize: 0.85, dampening: 0.7, preDelay: 0.05 },
      filter: { enabled: false, cutoff: 2000.0, resonance: 0.0, type: 'lpf' },
      envelope: { enabled: true, attack: 0.2, decay: 0.3, sustain: 0.8, release: 1.0 },
      sustain: { enabled: true, duration: 3.0, level: 0.9, infinite: false },
      randomness: { enabled: false, pitchVariation: 0.1, velocityVariation: 0.2, timingVariation: 50.0, sustainVariation: 0.3 },
      simultaneousNotes: { enabled: true, maxNotes: this.deviceCapabilities.maxSimultaneousNotes, overlapProbability: 0.3, voiceStealing: true, voiceStealThreshold: 0.5 },
      polyphony: { enabled: true, limit: this.deviceCapabilities.polyphonyLimit, voiceStealing: true, stealOldest: true, releaseTime: 0.1 },
      oscillator: { 
        enabled: true, 
        type: 'sine', 
        detune: 0, 
        harmonicContent: 0.5,
        filter: { frequency: 1200, Q: 0.7 }, // Global filter settings
        layers: {
          bass: { 
            type: 'sawtooth', 
            detune: -5, 
            harmonicContent: 0.8,
            filter: { frequency: 800, Q: 0.5 }
          },
          mid: { 
            type: 'triangle', 
            detune: 0, 
            harmonicContent: 0.5,
            filter: { frequency: 1200, Q: 0.7 }
          },
          high: { 
            type: 'sine', 
            detune: 5, 
            harmonicContent: 0.3,
            filter: { frequency: 2000, Q: 0.3 }
          },
          tex: { 
            type: 'square', 
            detune: 0, 
            harmonicContent: 0.7,
            filter: { frequency: 1500, Q: 0.8 }
          }
        }
      },
      globalVolume: 1.0,
      audioQuality: this.deviceCapabilities.audioQuality
    };
    this.currentPresetConfig.midiRules = {
      velocityRule: { enabled: false, minVelocity: 0.0, maxVelocity: 1.0, curve: 'linear' },
      noteTransformation: { enabled: false, transpose: 0, octaveShift: 0.0, harmonize: false, harmonyIntervals: [0, 7, 12] },
      arpeggiator: { enabled: false, pattern: 'up', rate: 8.0, octaves: 1, syncToTempo: false, gateLength: 0.5 },
      quantization: { enabled: false, grid: '1/16', strength: 0.8, swing: false, swingAmount: 0.5 },
      midiThru: false,
      recordMidi: false
    };
    
    // Keep track of any custom audio uploaded during runtime as data URLs
    this._embeddedAudioDataUrls = { bass: null, mid: null, high: null, tex: null };
    
    console.log("AuraSonixEngine: Constructor completed - engine ready");
    console.log("AuraSonixEngine: Device capabilities:", this.deviceCapabilities);
    console.log("AuraSonixEngine: Available presets:", this.PRESET_KEYS);
  }

  // Device capability detection for mobile optimization
  _detectDeviceCapabilities() {
    const userAgent = navigator.userAgent.toLowerCase();
    const isMobile = /mobile|android|iphone|ipad|ipod|blackberry|windows phone/i.test(userAgent);
    const isTablet = /tablet|ipad/i.test(userAgent);
    const isOldBrowser = /msie|trident/i.test(userAgent) || 
                        (userAgent.includes('chrome') && parseInt(userAgent.match(/chrome\/(\d+)/)?.[1] || '0') < 60) ||
                        (userAgent.includes('firefox') && parseInt(userAgent.match(/firefox\/(\d+)/)?.[1] || '0') < 55);
    
    // Check for hardware capabilities
    const hasTouch = 'ontouchstart' in window;
    const hasAccelerometer = 'DeviceMotionEvent' in window;
    const memoryInfo = navigator.deviceMemory || 4; // Default to 4GB if not available
    const hardwareConcurrency = navigator.hardwareConcurrency || 4; // Default to 4 cores
    
    // Determine device performance tier
    let performanceTier = 'high';
    if (isMobile || isOldBrowser || memoryInfo < 4 || hardwareConcurrency < 4) {
      performanceTier = 'low';
    } else if (memoryInfo < 8 || hardwareConcurrency < 8) {
      performanceTier = 'medium';
    }
    
    // Adjust settings based on performance tier
    const capabilities = {
      isMobile,
      isTablet,
      isOldBrowser,
      hasTouch,
      hasAccelerometer,
      memoryInfo,
      hardwareConcurrency,
      performanceTier,
      
      // Audio performance limits - more generous for better audio quality
      maxConcurrentNotes: performanceTier === 'low' ? 8 : performanceTier === 'medium' ? 12 : 16,
      maxConcurrentNotesPerNote: performanceTier === 'low' ? 2 : performanceTier === 'medium' ? 2 : 3,
      maxSimultaneousNotes: performanceTier === 'low' ? 4 : performanceTier === 'medium' ? 6 : 8,
      polyphonyLimit: performanceTier === 'low' ? 6 : performanceTier === 'medium' ? 10 : 14,
      
      // Buffer management
      bufferCacheSize: performanceTier === 'low' ? 2 : performanceTier === 'medium' ? 4 : 8,
      audioQuality: performanceTier === 'low' ? 'Low' : performanceTier === 'medium' ? 'Medium' : 'High',
      
      // Mobile-specific optimizations
      useLowLatencyMode: isMobile,
      enableBufferUnderrunProtection: isMobile || performanceTier === 'low',
      aggressiveCleanup: isMobile,
      
      // Sample rate optimization
      preferredSampleRate: isMobile ? 22050 : 44100, // Lower sample rate for mobile
      enableSampleRateConversion: isMobile
    };
    
    this.deviceCapabilities = capabilities;
    console.log("AuraSonixEngine: Device capabilities detected:", capabilities);
  }

  // Layer management methods removed - no longer needed for synthesizer architecture

  // Return a serializable snapshot of the current preset configuration
  getCurrentPresetConfig() {
    const name = this.currentPreset || (this.currentPresetConfig && this.currentPresetConfig.configName) || 'Custom';
    const cfg = this.currentPresetConfig || {};
    const audioFiles = (cfg.audioFiles && typeof cfg.audioFiles === 'object') ? cfg.audioFiles : { bass: 'bass.wav', mid: 'mid.wav', high: 'high.wav', tex: 'tex.wav' };
    // Build a plain JSON-safe snapshot – avoid passing engine IdentityMaps or symbols
    const clean = (v) => {
      if (v == null) return null;
      if (Array.isArray(v)) return v.map(clean);
      if (typeof v === 'number' || typeof v === 'string' || typeof v === 'boolean') return v;
      if (typeof v === 'object') {
        const out = {};
        Object.keys(v).forEach(k => { out[String(k)] = clean(v[k]); });
        return out;
      }
      return String(v);
    };
    const snapshot = clean({
      name,
      metadata: (cfg.metadata && typeof cfg.metadata === 'object') ? cfg.metadata : { author: 'AuraSonix', category: 'User', tags: [] },
      audioFiles,
      defaultZones: Array.isArray(cfg.zones) ? cfg.zones : (cfg.defaultZones || []),
      defaultScaleFilter: (cfg.scaleFilter && typeof cfg.scaleFilter === 'object') ? cfg.scaleFilter : (cfg.defaultScaleFilter || {}),
      defaultAudioEffects: (cfg.audioEffects && typeof cfg.audioEffects === 'object') ? cfg.audioEffects : (cfg.defaultAudioEffects || {}),
      defaultMidiRules: (cfg.midiRules && typeof cfg.midiRules === 'object') ? cfg.midiRules : (cfg.defaultMidiRules || {}),
      configSource: 'exported from runtime',
      configName: 'preset.config'
    });
    console.log('AuraSonixEngine: getCurrentPresetConfig ->', snapshot);
    return snapshot;
  }

  // Get current scale filter configuration for LAB UI
  getCurrentScaleFilter() {
    const cfg = this.currentPresetConfig || {};
    const scaleFilter = cfg.scaleFilter || {};
    return {
      enabled: scaleFilter.enabled !== false,
      root: scaleFilter.root || 'C',
      mode: (scaleFilter.mode || 'chromatic').toUpperCase(),
      minOctave: typeof scaleFilter.minOctave === 'number' ? scaleFilter.minOctave : 0,
      maxOctave: typeof scaleFilter.maxOctave === 'number' ? scaleFilter.maxOctave : 10,
      behavior: scaleFilter.behavior || 'snap'
    };
  }

  // Get current audio effects configuration for LAB UI
  getCurrentAudioEffects() {
    const cfg = this.currentPresetConfig || {};
    const effects = cfg.audioEffects || {};
    return {
      reverb: effects.reverb || {
        enabled: true,
        wet: 0.6,
        dry: 0.4,
        roomSize: 0.9,
        dampening: 0.8,
        preDelay: 0.05
      },
      filter: effects.filter || {
        enabled: false,
        cutoff: 2000.0,
        resonance: 0.0,
        type: 'lpf'
      },
      envelope: effects.envelope || {
        enabled: true,
        attack: 0.1,
        decay: 0.2,
        sustain: 0.8,
        release: 1.0
      },
      sustain: effects.sustain || {
        enabled: true,
        duration: 3.0,
        level: 0.9,
        infinite: false
      },
      randomness: effects.randomness || {
        enabled: false,
        pitchVariation: 0.1,
        velocityVariation: 0.2,
        timingVariation: 50.0,
        sustainVariation: 0.3
      },
      simultaneousNotes: effects.simultaneousNotes || {
        enabled: true,
        maxNotes: 8,
        overlapProbability: 0.3,
        voiceStealing: true,
        voiceStealThreshold: 0.5
      },
      polyphony: effects.polyphony || {
        enabled: true,
        limit: 12,
        voiceStealing: true,
        stealOldest: true,
        releaseTime: 0.1
      },
      globalVolume: effects.globalVolume || 1.0,
      audioQuality: effects.audioQuality || 'High',
      layersEnabled: effects.layersEnabled || {
        bass: true,
        mid: true,
        high: true,
        tex: true
      }
    };
  }

  // Get current zones configuration for LAB UI
  getCurrentZones() {
    const cfg = this.currentPresetConfig || {};
    const zones = cfg.zones || [];
    console.log('AuraSonixEngine: getCurrentZones called, zones from config:', zones);
    const result = zones.map(zone => ({
      name: zone.name || 'Unknown',
      minNote: typeof zone.minNote === 'number' ? zone.minNote : 0,
      maxNote: typeof zone.maxNote === 'number' ? zone.maxNote : 127,
      baseNote: zone.baseNote || 'C4',
      volume: typeof zone.volume === 'number' ? zone.volume : 1.0,
      probability: typeof zone.probability === 'number' ? zone.probability : 1.0,
      texture: zone.texture || {
        enabled: false,
        loop: true,
        lfoRateHz: 0.2,
        lfoDepth: 0.5
      }
    }));
    console.log('AuraSonixEngine: getCurrentZones returning:', result);
    return result;
  }

  // Load a single custom audio file for a given layer (bass|mid|high|tex)
  async loadCustomSound(layer, dataUrl) {
    try {
      await this._ensureAudio();
      const key = (layer || '').toLowerCase();
      if (!['bass','mid','high','tex'].includes(key)) {
        console.warn('AuraSonixEngine: loadCustomSound ignored for invalid layer', layer);
        return false;
      }
      if (!dataUrl || typeof dataUrl !== 'string') {
        console.warn('AuraSonixEngine: loadCustomSound missing dataUrl');
        return false;
      }
      const buffer = await this._decodeAudioBase64ToBuffer(dataUrl);
      if (!this.currentBuffers) this.currentBuffers = { bass: null, mid: null, high: null, tex: null };
      this.currentBuffers[key] = buffer;
      if (!this.currentPresetConfig) this.currentPresetConfig = {};
      if (!this.currentPresetConfig.audioFiles) this.currentPresetConfig.audioFiles = { bass: 'bass.wav', mid: 'mid.wav', high: 'high.wav', tex: 'tex.wav' };
      // Mark as custom so UI/exports can reason about it
      this.currentPresetConfig.audioFiles[key] = `custom-${key}.wav`;
      if (!this._embeddedAudioDataUrls) this._embeddedAudioDataUrls = { bass: null, mid: null, high: null, tex: null };
      this._embeddedAudioDataUrls[key] = dataUrl;
      this._ensureMinimumLayers();
      console.log('AuraSonixEngine: custom sound loaded for', key);
      return true;
    } catch (e) {
      console.error('AuraSonixEngine: failed to load custom sound', e && (e.stack || e.message || e.toString()));
      return false;
    }
  }

  // Expose any embedded custom audio (data URLs) so the app can export them
  getEmbeddedAudioDataUrls() {
    const copy = Object.assign({ bass: null, mid: null, high: null, tex: null }, this._embeddedAudioDataUrls || {});
    return copy;
  }

  // Load a preset from an in-memory bundle: { config: {...}, audioFiles: { bass: 'data:audio/wav;base64,...', mid: ..., high: ..., tex: ... } }
  async loadPresetFromBundle(bundle) {
    try {
      await this._ensureAudio();
      const config = bundle && bundle.config ? bundle.config : {};
      const files = bundle && bundle.audioFiles ? bundle.audioFiles : {};
      this.currentPresetConfig = {
        zones: Array.isArray(config.defaultZones) ? config.defaultZones : [],
        scaleFilter: config.defaultScaleFilter || { enabled: false, root: 'C', mode: 'chromatic', minOctave: 0, maxOctave: 10, behavior: 'snap' },
        audioEffects: config.defaultAudioEffects || {},
        audioFiles: config.audioFiles || { bass: 'bass.wav', mid: 'mid.wav', high: 'high.wav', tex: 'tex.wav' },
        metadata: config.metadata || {},
        configSource: 'loaded from in-memory bundle',
        configName: config.name || 'Custom'
      };
      this.currentPreset = this.currentPresetConfig.configName;

      const decodeOne = async (label, dataUrl) => {
        if (!dataUrl) return null;
        const buffer = await this._decodeAudioBase64ToBuffer(dataUrl);
        return buffer;
      };

      const buffers = {
        bass: await decodeOne('bass', files.bass),
        mid: await decodeOne('mid', files.mid),
        high: await decodeOne('high', files.high),
        tex: await decodeOne('tex', files.tex),
      };
      this.currentBuffers = buffers;
      // Store embedded data for export if provided
      this._embeddedAudioDataUrls = {
        bass: files.bass || null,
        mid: files.mid || null,
        high: files.high || null,
        tex: files.tex || null,
      };
      this._ensureMinimumLayers();
      console.log('AuraSonixEngine: preset bundle loaded and buffers ready:', this.currentPreset);
      return true;
    } catch (e) {
      console.error('AuraSonixEngine: failed to load preset from bundle', e && (e.stack || e.message || e.toString()));
      return false;
    }
  }

  async _decodeAudioBase64ToBuffer(dataUrl) {
    // Accept both pure base64 and full data URLs
    try {
      let base64 = dataUrl;
      const commaIdx = typeof dataUrl === 'string' ? dataUrl.indexOf(',') : -1;
      if (commaIdx > -1) {
        base64 = dataUrl.substring(commaIdx + 1);
      }
      const binaryString = atob(base64);
      const len = binaryString.length;
      const bytes = new Uint8Array(len);
      for (let i = 0; i < len; i++) {
        bytes[i] = binaryString.charCodeAt(i);
      }
      const arrayBuffer = bytes.buffer;
      return await this.audioCtx.decodeAudioData(arrayBuffer.slice(0));
    } catch (e) {
      console.error('AuraSonixEngine: failed to decode base64 audio', e && (e.stack || e.message || e.toString()));
      throw e;
    }
  }

  // Load preset configuration from config.json
  async _loadPresetConfig(presetName) {
    try {
      let configUrl = `assets/audio/presets/${presetName}/config.json`;
      console.log("AuraSonixEngine: loading config from:", configUrl);
      
      const response = await fetch(configUrl);
      if (!response.ok) {
        // Try lowercase directory fallback (e.g., Creative-Flow -> creative-flow)
        const lower = (presetName || '').toString().toLowerCase();
        const altUrl = `assets/audio/presets/${lower}/config.json`;
        console.warn("AuraSonixEngine: config.json not found, trying lowercase:", altUrl);
        const r2 = await fetch(altUrl);
        if (!r2.ok) {
          console.warn("AuraSonixEngine: config.json not found for preset:", presetName);
          return null;
        }
        const config2 = await r2.json();
        console.log("AuraSonixEngine: loaded config (lowercase) for preset:", presetName, config2);
        return config2;
      }
      
      const config = await response.json();
      console.log("AuraSonixEngine: loaded config for preset:", presetName, config);
      return config;
    } catch (error) {
      console.warn("AuraSonixEngine: error loading config for preset:", presetName, error);
      return null;
    }
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

    try {
      // Try to load config.json for this preset
      const config = await this._loadPresetConfig(presetName);
      
      // Use loaded config or fallback to defaults
      this.currentPresetConfig = {
        zones: config?.defaultZones || [],
        scaleFilter: config?.defaultScaleFilter || { 
          enabled: false, // DISABLE scale filter by default - no restrictions
          mode: 'chromatic', 
          root: 'C', 
          minOctave: 0, 
          maxOctave: 10 
        },
        audioEffects: config?.defaultAudioEffects || {
          reverb: { enabled: true, wet: 0.7, dry: 0.3, roomSize: 0.85, dampening: 0.7, preDelay: 0.05 },
          filter: { enabled: false, cutoff: 2000.0, resonance: 0.0, type: 'lpf' },
          envelope: { enabled: true, attack: 0.2, decay: 0.3, sustain: 0.8, release: 1.0 },
          sustain: { enabled: true, duration: 3.0, level: 0.9, infinite: false },
          randomness: { enabled: false, pitchVariation: 0.1, velocityVariation: 0.2, timingVariation: 50.0, sustainVariation: 0.3 },
          simultaneousNotes: { enabled: true, maxNotes: 8, overlapProbability: 0.3, voiceStealing: true, voiceStealThreshold: 0.5 },
          polyphony: { enabled: true, limit: 12, voiceStealing: true, stealOldest: true, releaseTime: 0.1 },
          globalVolume: 1.0,
          audioQuality: 'High'
        },
        midiRules: config?.defaultMidiRules || {
          velocityMapping: { enabled: true, minVelocity: 0.3, maxVelocity: 1.0, curve: 'linear' },
          noteTransformation: { enabled: false, transpose: 0, octaveShift: 0, harmonization: 'none' },
          arpeggiator: { enabled: false, pattern: 'up', rate: 0.5, octaves: 1 },
          quantization: { enabled: false, grid: '1/4', strength: 0.5 },
          randomness: { enabled: false, amount: 0.1, type: 'note' },
          simultaneousNotes: { enabled: true, maxNotes: 8, voiceStealing: true }
        }
      };
      
      // LAB parity: Use exactly what config.json provides, no overrides
      // Only apply defaults if config.json is missing or incomplete
      if (!config || !config.defaultAudioEffects) {
        console.log("AuraSonixEngine: No config.json found, using defaults");
      } else {
        console.log("AuraSonixEngine: Using exact values from config.json");
      }

      // LAB parity: do not apply preset-specific overrides. Use exactly what LAB provides.
      
      console.log("AuraSonixEngine: using config for preset:", presetName, {
        zones: this.currentPresetConfig.zones.length,
        zonesData: this.currentPresetConfig.zones,
        scaleFilter: this.currentPresetConfig.scaleFilter,
        audioEffects: this.currentPresetConfig.audioEffects,
        configSource: config ? 'loaded from config.json' : 'using defaults',
        configName: config?.name || 'no config'
      });

      await this._ensureAudio();
      // No need to load buffers for synthesizer architecture

      // Only mark preset as current after successful load
      this.currentPreset = presetName;
      console.log("AuraSonixEngine: preset loaded and buffers ready:", presetName);
      // Play a short demo note so sound is immediately audible
      try {
        const demoNote = 60; // C4
        const demoVel = 0.8;
        this.playNote(demoNote, demoVel);
        setTimeout(() => {
          try { this.stopNote(demoNote); } catch (_) {}
        }, 800);
      } catch (_) {}
      return true;
    } catch (e) {
      console.error("AuraSonixEngine: failed to load preset", {
        preset: presetName,
        error: e && (e.stack || e.message || e.toString()),
      });
      // Even if there's an error, try to continue with basic functionality
      console.log("AuraSonixEngine: continuing with basic preset functionality");
      // Attempt a short demo note if audio is available
      try {
        const demoNote = 60; // C4
        const demoVel = 0.6;
        this.playNote(demoNote, demoVel);
        setTimeout(() => {
          try { this.stopNote(demoNote); } catch (_) {}
        }, 600);
      } catch (_) {}
      return true;
    }
  }

  _recomputePresetKeys() {
    this.PRESET_KEYS = Object.keys(this.PRESET_CONFIG || {});
  }

  // Update scale filter settings from Flutter (normalized keys)
  updateScaleFilter(newConfig) {
    if (!this.currentPresetConfig) {
      this.currentPresetConfig = {};
    }

    const defaultScaleFilter = {
      enabled: false,
      root: 'C',
      mode: 'chromatic',
      minOctave: 0,
      maxOctave: 10,
      behavior: 'snap' // default to non-destructive quantization
    };

    const incoming = Object.assign({}, newConfig || {});
    // Normalize potential legacy keys
    if (incoming.rootNote && !incoming.root) incoming.root = incoming.rootNote;
    if (incoming.scale && !incoming.mode) incoming.mode = incoming.scale;

    // Normalize mode to lowercase
    if (typeof incoming.mode === 'string') incoming.mode = incoming.mode.toLowerCase();

    this.currentPresetConfig.scaleFilter = Object.assign(
      {},
      defaultScaleFilter,
      this.currentPresetConfig.scaleFilter || {},
      incoming
    );

    console.log("AuraSonixEngine: scale filter updated", {
      newConfig,
      currentFilter: this.currentPresetConfig.scaleFilter,
      enabled: this.currentPresetConfig.scaleFilter.enabled,
      root: this.currentPresetConfig.scaleFilter.root,
      mode: this.currentPresetConfig.scaleFilter.mode,
      octaveRange: `${this.currentPresetConfig.scaleFilter.minOctave}-${this.currentPresetConfig.scaleFilter.maxOctave}`
    });
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
      console.log("AuraSonixEngine: zones config updated", {
        zonesCount: zones.length,
        zones: this.currentPresetConfig.zones.map(z => ({
          name: z.name,
          range: `${z.minNote}-${z.maxNote}`,
          baseNote: z.baseNote,
          volume: z.volume,
          probability: z.probability
        }))
      });
    } else {
      this.currentPresetConfig.zones = [];
    }
    return true;
  }

  async playNote(noteNumber, velocity = 1.0) {
    console.log("AuraSonixEngine: playNote called", { noteNumber, velocity });
    if (!this.currentPreset) {
      console.warn("AuraSonixEngine: playNote ignored, no preset loaded");
      return;
    }

    // Ensure audio context is running (especially important for mobile)
    await this._ensureAudioContextRunning();

    // Performance optimization: Clean up orphaned sources periodically
    this._cleanupOrphanedSources();

    // Less aggressive buffer management - only check when we're close to limits
    if (this._isBufferStressed()) {
      // Only drop notes if we're really at the limit
      if (this.activeSources.size >= this.MAX_CONCURRENT_NOTES) {
        this._dropOldestNotes(1);
      }
    }

    // Polyphony management: Check if we can play this voice
    if (!this._canPlayVoice(noteNumber)) {
      // Try to steal oldest voice to make room
      this._stealOldestVoice();
      
      // Check again after stealing
      if (!this._canPlayVoice(noteNumber)) {
        console.warn(`AuraSonixEngine: Cannot play note ${noteNumber}, polyphony limit reached and voice stealing failed`);
        return;
      }
    }

    // Performance optimization: Check if we can play this note (legacy check)
    if (!this._canPlayNote(noteNumber)) {
      // Try to steal oldest voice to make room
      this._stealOldestVoice();
      
      // Check again after stealing
      if (!this._canPlayNote(noteNumber)) {
        // Last resort: force emergency cleanup and try one more time
        console.warn(`AuraSonixEngine: Buffer still saturated after voice stealing, forcing emergency cleanup`);
        this._emergencyBufferCleanup();
        
        // Wait a tiny bit for cleanup to complete
        await new Promise(resolve => setTimeout(resolve, 10));
        
        // Final check
        if (!this._canPlayNote(noteNumber)) {
          console.warn(`AuraSonixEngine: Cannot play note ${noteNumber}, buffer saturated even after emergency cleanup`);
          return;
        }
      }
    }

    const cfg = this.currentPresetConfig;
    const rawInputNote = noteNumber; // keep original to stop correctly later
    const presetMap = this.PRESET_CONFIG[this.currentPreset] || {};

    // Apply pitch quantization: snap to nearest note within the selected scale
    if (cfg && cfg.scaleFilter && cfg.scaleFilter.enabled) {
      // Normalize mode string (uppercase from LAB)
      if (typeof cfg.scaleFilter.mode === 'string') {
        cfg.scaleFilter.mode = cfg.scaleFilter.mode.toLowerCase();
      }
      const quantized = this._snapNoteToScale(noteNumber, cfg.scaleFilter);
      if (quantized !== null && Number.isFinite(quantized)) {
        noteNumber = quantized;
        console.log(`AuraSonixEngine: pitch quantized from ${rawInputNote} to ${noteNumber}`);
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
        // Map zone name to sample key
        sampleKey = this._mapZoneNameToSample(selectedZone.name);
        // Only log occasionally to avoid spam
        if (Math.random() < 0.1) {
          console.log("AuraSonixEngine: zone selected", { noteNumber, zoneName: selectedZone.name, sampleKey, volume: selectedZone.volume, probability: selectedZone.probability });
        }
      }
    }

    // Fallback mapping by pitch range if no zone matched
    if (!sampleKey) {
      // Prefer mid as default tonal center, then bass/high, then texture
      if (noteNumber >= 44 && noteNumber <= 67) sampleKey = 'mid';
      else if (noteNumber < 44) sampleKey = 'bass';
      else if (noteNumber <= 87) sampleKey = 'high';
      else sampleKey = 'tex';
    }

    const effects = this.currentPresetConfig && this.currentPresetConfig.audioEffects ? this.currentPresetConfig.audioEffects : {};
    const layersEnabled = (effects && effects.layersEnabled) ? effects.layersEnabled : { bass: true, mid: true, high: true, tex: true };

    // Determine if we should play all layers (Chromatic means "hear everything")
    const scaleFilter = (cfg && cfg.scaleFilter) ? cfg.scaleFilter : null;
    const modeIsChromatic = !!(scaleFilter && typeof scaleFilter.mode === 'string' && scaleFilter.mode.toLowerCase() === 'chromatic');
    const playAllLayers = modeIsChromatic === true;

    // Build list of layers to trigger - simplified for synthesizer
    let layersToPlay = [];
    if (playAllLayers) {
      // Play all enabled layers
      for (const k of ['bass','mid','high','tex']) {
        if (layersEnabled[k] !== false) {
          layersToPlay.push(k);
        }
      }
    } else {
      // Single-layer behavior
      if (!layersEnabled[sampleKey]) {
        // Find first enabled layer as fallback
        for (const k of ['bass','mid','high','tex']) {
          if (layersEnabled[k] !== false) {
            sampleKey = k;
            break;
          }
        }
      }
      layersToPlay = [sampleKey];
    }

    let globalVol = 1.0;
    try {
      if (cfg && cfg.audioEffects && typeof cfg.audioEffects.globalVolume === 'number') {
        globalVol = cfg.audioEffects.globalVolume;
      } else if (cfg && typeof cfg.globalVolume === 'number') {
        // legacy/root fallback
        globalVol = cfg.globalVolume;
      }
    } catch (_) {}
    const zoneVol = selectedZone && typeof selectedZone.volume === 'number' ? selectedZone.volume : 1.0;
    const baseGain = this._clamp01(globalVol * zoneVol * this._clamp01(velocity));

    if (!this.audioCtx) {
      console.warn("AuraSonixEngine: audioCtx not ready");
      return;
    }

    // Resume context on user gesture environments
    if (this.audioCtx.state === 'suspended') {
      this.audioCtx.resume().catch(() => {});
    }

    // Prepare common settings
    const layerPitchRanges = {
      bass: { min: -12, max: 12 },
      mid: { min: -24, max: 24 },
      high: { min: -36, max: 36 },
      tex: { min: -48, max: 48 }
    };

    // Apply randomness and sustain settings once at note level
    const randomnessResult = this._applyRandomness(noteNumber, velocity, 0);
    const sustainResult = this._applySustainSettings(randomnessResult.noteNumber, randomnessResult.velocity);

    // Apply MIDI rules
    let finalVelocity = sustainResult.velocity;
    let finalNoteNumbers = [sustainResult.noteNumber];
    if (cfg && cfg.midiRules) {
      const rules = cfg.midiRules;
      if (rules.velocityRule && rules.velocityRule.enabled) {
        finalVelocity = this._applyVelocityMapping(velocity, rules.velocityRule);
      }
      if (rules.noteTransformation && rules.noteTransformation.enabled) {
        finalNoteNumbers = this._applyNoteTransformation(noteNumber, rules.noteTransformation);
      }
    }

    // For each transformed note, trigger the selected layers
    for (const tNote of finalNoteNumbers) {
      for (const layer of layersToPlay) {
        // For synth engine, we don't need buffers - just create oscillators directly
        // Determine base note per layer or zone
        let baseNoteValue = null;
        if (selectedZone && selectedZone.baseNote && selectedZone.baseNote.length > 1) {
          baseNoteValue = this._parseNoteToMidi(selectedZone.baseNote);
        } else {
          if (layer === 'bass') baseNoteValue = 36;      // C2
          else if (layer === 'mid') baseNoteValue = 60;  // C4
          else if (layer === 'high') baseNoteValue = 72; // C5
          else baseNoteValue = 48;                       // C3
        }

        let semitoneDifference = tNote - baseNoteValue;
        const range = layerPitchRanges[layer] || layerPitchRanges.mid;
        semitoneDifference = Math.max(range.min, Math.min(range.max, semitoneDifference));
        const playbackRate = Math.pow(2, semitoneDifference / 12);

        const isTexture = (layer === 'tex');
        const layerGain = baseGain; // could weight per-layer if needed

        // Fire and track by original input note to ensure proper stop
        const oscillator = this._playSingleNote(tNote, finalVelocity, null, playbackRate, layerGain, cfg, isTexture, layer);
        if (!this.activeByInputNote[rawInputNote]) this.activeByInputNote[rawInputNote] = new Set();
        this.activeByInputNote[rawInputNote].add(oscillator);
      }
    }
  }

  // Pitch quantization: snap incoming note to nearest allowed pitch within scale
  _snapNoteToScale(noteNumber, scaleFilter) {
    const root = (this._getRootNoteValue(scaleFilter.root || 'C') + 12) % 12;
    const mode = (scaleFilter.mode || 'chromatic').toLowerCase();
    const sets = {
      chromatic: [0,1,2,3,4,5,6,7,8,9,10,11],
      pentatonic: [0,2,4,7,9],
      pentatonic_major: [0,2,4,7,9],
      pentatonic_minor: [0,3,5,7,10],
      major: [0,2,4,5,7,9,11],
      minor: [0,2,3,5,7,8,10],
      dorian: [0,2,3,5,7,9,10],
      mixolydian: [0,2,4,5,7,9,10],
      lydian: [0,2,4,6,7,9,11],
      phrygian: [0,1,3,5,7,8,10],
      locrian: [0,1,3,5,6,8,10]
    };
    const allowed = sets[mode] || sets.chromatic;
    const noteInOct = noteNumber % 12;
    const rel = (noteInOct - root + 12) % 12;
    
    // If note is already in scale, return it
    if (allowed.includes(rel)) return noteNumber;
    
    // Find nearest allowed interval within octave range
    let best = noteNumber; 
    let bestDist = 999;
    const minOctave = scaleFilter.minOctave || 0;
    const maxOctave = scaleFilter.maxOctave || 10;
    
    for (const step of allowed) {
      const targetRel = (root + step) % 12;
      
      // Try octaves within the allowed range
      for (let oct = minOctave; oct <= maxOctave; oct++) {
        const cand = oct * 12 + targetRel;
        const d = Math.abs(cand - noteNumber);
        if (d < bestDist) { 
          best = cand; 
          bestDist = d; 
        }
      }
    }
    
    // If no valid note found in range, find the closest one outside range
    if (bestDist === 999) {
      for (const step of allowed) {
        const targetRel = (root + step) % 12;
        // Try same octave
        let cand = noteNumber - rel + step;
        let d = Math.abs(cand - noteNumber);
        if (d < bestDist) { best = cand; bestDist = d; }
        // Try neighbouring octaves too
        cand = noteNumber - rel + step + 12; d = Math.abs(cand - noteNumber);
        if (d < bestDist) { best = cand; bestDist = d; }
        cand = noteNumber - rel + step - 12; d = Math.abs(cand - noteNumber);
        if (d < bestDist) { best = cand; bestDist = d; }
      }
    }
    
    return best;
  }

  _playSingleNote(noteNumber, velocity, buffer, playbackRate, gain, cfg, isTexture = false, sampleKey = null) {
    try {
      // Create two oscillators for richer sound
      const oscillator1 = this.audioCtx.createOscillator();
      const oscillator2 = this.audioCtx.createOscillator();
      
      // Calculate frequency from MIDI note number
      const frequency = this._midiToFrequency(noteNumber);
      oscillator1.frequency.setValueAtTime(frequency, this.audioCtx.currentTime);
      oscillator2.frequency.setValueAtTime(frequency, this.audioCtx.currentTime);
      
      // Set oscillator type based on preset or layer
      const oscillatorType = this._getOscillatorType(sampleKey, cfg);
      oscillator1.type = oscillatorType;
      oscillator2.type = oscillatorType;
      
      // Apply detune if configured
      const detune = this._getOscillatorDetune(sampleKey, cfg);
      if (detune !== 0) {
        oscillator1.detune.setValueAtTime(detune, this.audioCtx.currentTime);
      }
      
      // Add 7 cents detune to second oscillator for chorus effect
      oscillator2.detune.setValueAtTime(detune + 7, this.audioCtx.currentTime);
      
      // Performance optimization: Add creation timestamp for voice stealing
      oscillator1._creationTime = Date.now();
      oscillator1._startTime = this.audioCtx.currentTime;
      oscillator2._creationTime = Date.now();
      oscillator2._startTime = this.audioCtx.currentTime;
      
      // Start both oscillators immediately for better timing
      oscillator1.start();
      oscillator2.start();
      
      // Reduced logging to improve performance - only log occasionally
      if (Math.random() < 0.05) { // Log only 5% of the time
        console.log("AuraSonixEngine: playing dual synth note", {
          noteNumber,
          noteName: this._getNoteName(noteNumber),
          frequency: frequency.toFixed(2),
          oscillatorType,
          velocity,
          presetName: this.currentPreset,
          detune1: detune,
          detune2: detune + 7
        });
      }
      
      // Create BiquadFilterNode for smoothing the oscillator signal
      const filter = this.audioCtx.createBiquadFilter();
      filter.type = 'lowpass';
      
      // Configure filter based on layer and preset configuration
      const filterConfig = this._getFilterConfig(sampleKey, cfg);
      filter.frequency.setValueAtTime(filterConfig.frequency, this.audioCtx.currentTime);
      filter.Q.setValueAtTime(filterConfig.Q, this.audioCtx.currentTime);
      
      // Create LFO (Low Frequency Oscillator) for filter modulation
      const lfo = this.audioCtx.createOscillator();
      lfo.type = 'sine';
      
      // Get LFO configuration from preset
      const lfoConfig = this._getLFOConfig(sampleKey, cfg);
      lfo.frequency.setValueAtTime(lfoConfig.rate, this.audioCtx.currentTime);
      
      // Create LFO gain node to control modulation depth
      const lfoGain = this.audioCtx.createGain();
      lfoGain.gain.setValueAtTime(lfoConfig.depth, this.audioCtx.currentTime);
      
      // Connect LFO -> LFO Gain -> Filter Frequency
      lfo.connect(lfoGain);
      lfoGain.connect(filter.frequency);
      
      // Start the LFO
      lfo.start();
      
      // Connect both oscillators -> filter -> effects chain
      oscillator1.connect(filter);
      oscillator2.connect(filter);
      
      // Apply audio effects chain and get the final node
      const currentEffects = this.currentPresetConfig && this.currentPresetConfig.audioEffects ? this.currentPresetConfig.audioEffects : {};
      const finalNode = this._createEffectsChain(filter, currentEffects, gain, isTexture, noteNumber);

      // LAB parity: do not auto-apply an extra ADSR if disabled. Always add a tail gain for stop control only.
      const tailGain = this.audioCtx.createGain();
      tailGain.gain.setValueAtTime(1.0, this.audioCtx.currentTime);
      finalNode.connect(tailGain);
      tailGain.connect(this.masterGain);
      
      // Store reference to tailGain for both oscillators
      oscillator1._gainNode = tailGain;
      oscillator2._gainNode = tailGain;
      
      // Apply sustain settings if enabled
      if (!isTexture) {
        if (currentEffects && currentEffects.sustain && currentEffects.sustain.enabled) {
          const sustain = currentEffects.sustain;
          if (sustain.infinite) {
            // Infinite sustain: do not schedule auto-stop
            console.log('AuraSonixEngine: infinite sustain enabled for note', noteNumber);
          } else if (sustain.duration > 0) {
            // Schedule a graceful stop with a short fade
            const stopTime = this.audioCtx.currentTime + sustain.duration;
            try {
              const g = tailGain;
              if (g) {
                g.gain.setValueAtTime(g.gain.value, stopTime);
                g.gain.linearRampToValueAtTime(0.0001, stopTime + 0.08);
              }
              oscillator1.stop(stopTime + 0.1);
              oscillator2.stop(stopTime + 0.1);
              lfo.stop(stopTime + 0.1);
            } catch (e) {
              console.warn('AuraSonixEngine: failed to schedule stop for sustain:', e);
            }
          }
        }
      }
      
      // Polyphony management: Add voice to active voices tracking (use oscillator1 as primary)
      this._addVoice(noteNumber, oscillator1, velocity);
      
      // Performance optimization: Track active sources with better cleanup
      this.activeSources.add(oscillator1);
      this.activeSources.add(oscillator2);
      this.activeSources.add(lfo);
      // Track by note for precise stop
      if (!this.activeByNote[noteNumber]) this.activeByNote[noteNumber] = new Set();
      this.activeByNote[noteNumber].add(oscillator1);
      this.activeByNote[noteNumber].add(oscillator2);
      this.activeByNote[noteNumber].add(lfo);
      
      // Handle cleanup when either oscillator ends
      let cleanupCount = 0;
      const cleanup = () => {
        cleanupCount++;
        if (cleanupCount === 2) {
          // Both oscillators ended, clean up
          this._removeVoice(noteNumber);
          this.activeSources.delete(oscillator1);
          this.activeSources.delete(oscillator2);
          this.activeSources.delete(lfo);
          const set = this.activeByNote[noteNumber];
          if (set) {
            set.delete(oscillator1);
            set.delete(oscillator2);
            set.delete(lfo);
            if (set.size === 0) delete this.activeByNote[noteNumber];
          }
          // Also remove from any activeByInputNote buckets
          try {
            for (const key of Object.keys(this.activeByInputNote)) {
              const s = this.activeByInputNote[key];
              if (s && s.has(oscillator1)) {
                s.delete(oscillator1);
                s.delete(oscillator2);
                s.delete(lfo);
                if (s.size === 0) delete this.activeByInputNote[key];
              }
            }
          } catch (_) {}
        }
      };
      
      oscillator1.onended = cleanup;
      oscillator2.onended = cleanup;
      
      return oscillator1; // Return primary oscillator for compatibility
    } catch (e) {
      console.error('AuraSonixEngine: Failed to play synth note', noteNumber, ':', e);
      return null;
    }
  }

  // Convert MIDI note number to frequency in Hz
  _midiToFrequency(noteNumber) {
    // MIDI note 69 (A4) = 440 Hz
    // Formula: f = 440 * 2^((n-69)/12)
    return 440 * Math.pow(2, (noteNumber - 69) / 12);
  }

  // Get oscillator type based on layer/preset
  _getOscillatorType(sampleKey, cfg) {
    // Default oscillator types for different layers
    const layerTypes = {
      bass: 'sawtooth',    // Rich harmonics for bass
      mid: 'triangle',      // Smooth for mid range
      high: 'sine',        // Pure tone for high frequencies
      tex: 'square'         // Textural for texture layer
    };

    // Check if preset has custom oscillator configuration
    if (cfg && cfg.audioEffects && cfg.audioEffects.oscillator) {
      const oscillatorConfig = cfg.audioEffects.oscillator;
      
      // Check for layer-specific configuration first
      if (oscillatorConfig.layers && oscillatorConfig.layers[sampleKey]) {
        return oscillatorConfig.layers[sampleKey].type || layerTypes[sampleKey] || 'sine';
      }
      
      // Fall back to global oscillator type
      return oscillatorConfig.type || layerTypes[sampleKey] || 'sine';
    }

    // Use layer-based type
    return layerTypes[sampleKey] || 'sine';
  }

  // Get oscillator detune based on layer/preset
  _getOscillatorDetune(sampleKey, cfg) {
    // Check if preset has custom oscillator configuration
    if (cfg && cfg.audioEffects && cfg.audioEffects.oscillator) {
      const oscillatorConfig = cfg.audioEffects.oscillator;
      
      // Check for layer-specific configuration first
      if (oscillatorConfig.layers && oscillatorConfig.layers[sampleKey]) {
        return oscillatorConfig.layers[sampleKey].detune || 0;
      }
      
      // Fall back to global oscillator detune
      return oscillatorConfig.detune || 0;
    }

    // Default no detune
    return 0;
  }

  // Get filter configuration based on layer/preset
  _getFilterConfig(sampleKey, cfg) {
    // Default filter configurations for different layers
    const layerFilters = {
      bass: { frequency: 800, Q: 0.5 },    // Lower cutoff for bass
      mid: { frequency: 1200, Q: 0.7 },    // Medium cutoff for mid range
      high: { frequency: 2000, Q: 0.3 },   // Higher cutoff for high frequencies
      tex: { frequency: 1500, Q: 0.8 }     // Medium-high cutoff for texture
    };

    // Check if preset has custom filter configuration
    if (cfg && cfg.audioEffects && cfg.audioEffects.oscillator) {
      const oscillatorConfig = cfg.audioEffects.oscillator;
      
      // Check for layer-specific filter configuration first
      if (oscillatorConfig.layers && oscillatorConfig.layers[sampleKey] && oscillatorConfig.layers[sampleKey].filter) {
        const layerFilter = oscillatorConfig.layers[sampleKey].filter;
        return {
          frequency: layerFilter.frequency || layerFilters[sampleKey].frequency,
          Q: layerFilter.Q || layerFilters[sampleKey].Q
        };
      }
      
      // Fall back to global oscillator filter configuration
      if (oscillatorConfig.filter) {
        return {
          frequency: oscillatorConfig.filter.frequency || layerFilters[sampleKey].frequency,
          Q: oscillatorConfig.filter.Q || layerFilters[sampleKey].Q
        };
      }
    }

    // Use layer-based filter configuration
    return layerFilters[sampleKey] || layerFilters.mid;
  }

  _getLFOConfig(sampleKey, cfg) {
    // Default LFO configurations for different layers
    const layerLFOs = {
      bass: { rate: 0.3, depth: 200 },    // Slow, subtle modulation for bass
      mid: { rate: 0.5, depth: 300 },     // Medium speed and depth for mid range
      high: { rate: 0.8, depth: 150 },   // Faster, lighter modulation for high frequencies
      tex: { rate: 1.2, depth: 400 }     // Fast, deep modulation for texture
    };

    // Check if preset has custom LFO configuration
    if (cfg && cfg.audioEffects && cfg.audioEffects.oscillator) {
      const oscillatorConfig = cfg.audioEffects.oscillator;
      
      // Check for layer-specific LFO configuration first
      if (oscillatorConfig.layers && oscillatorConfig.layers[sampleKey] && oscillatorConfig.layers[sampleKey].lfo) {
        const layerLFO = oscillatorConfig.layers[sampleKey].lfo;
        return {
          rate: layerLFO.rate || layerLFOs[sampleKey].rate,
          depth: layerLFO.depth || layerLFOs[sampleKey].depth
        };
      }
      
      // Fall back to global oscillator LFO configuration
      if (oscillatorConfig.lfo) {
        return {
          rate: oscillatorConfig.lfo.rate || layerLFOs[sampleKey].rate,
          depth: oscillatorConfig.lfo.depth || layerLFOs[sampleKey].depth
        };
      }
    }

    // Use layer-based LFO configuration
    return layerLFOs[sampleKey] || layerLFOs.mid;
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

  _mapZoneNameToSample(zoneName) {
    if (!zoneName || typeof zoneName !== 'string') return null;
    const name = zoneName.toLowerCase();
    if (name === 'bass') return 'bass';
    if (name === 'mid') return 'mid';
    if (name === 'high') return 'high';
    if (name === 'tex') return 'tex';
    return null;
  }

  _passProbability(prob) {
    const p = Number.isFinite(prob) ? Math.max(0, Math.min(1, prob)) : 1.0;
    return Math.random() <= p;
  }

  _clamp01(v) { return Math.max(0, Math.min(1, v)); }

  stopNote(noteNumber) {
    // Polyphony management: Release voice with proper ADSR
    this._releaseVoice(noteNumber);
    
    // Prefer stopping by original input mapping to avoid killing other voices that snapped to the same pitch
    const set = this.activeByInputNote[noteNumber] || this.activeByNote[noteNumber];
    if (!set || set.size === 0) return;
    let rel = 0.08;
    try {
      const fx = this.currentPresetConfig && this.currentPresetConfig.audioEffects ? this.currentPresetConfig.audioEffects : {};
      if (fx.envelope && fx.envelope.enabled) {
        rel = Math.max(0.001, fx.envelope.release || 0.1);
      }
    } catch (_) {}
    const now = this.audioCtx.currentTime;
    for (const oscillator of Array.from(set)) {
      try {
        const g = oscillator._gainNode;
        if (g) {
          g.gain.cancelScheduledValues(now);
          const current = g.gain.value;
          g.gain.setValueAtTime(current, now);
          g.gain.linearRampToValueAtTime(0.0001, now + rel);
        }
        // Safe stop for oscillator
        try { oscillator.stop(now + rel + 0.05); } catch (_) {}
      } catch (e) {
        console.warn('AuraSonixEngine: error stopping synth note', noteNumber, ':', e);
      }
    }
    delete this.activeByNote[noteNumber];
  }

  stopAll() {
    try {
      // Polyphony management: Clear all active voices
      this.activeVoices.clear();
      this.voiceCounter = 0;
      
      for (const oscillator of this.activeSources) {
        try { 
          // Oscillators don't have playbackState, just stop them directly
          oscillator.stop(); 
        } catch (e) {
          console.warn('AuraSonixEngine: error stopping oscillator:', e);
        }
      }
    } finally {
      this.activeSources.clear();
      this.activeByNote = {};
    }
  }

  play() {
    // Resume audio context if suspended
    if (this.audioCtx && this.audioCtx.state === 'suspended') {
      this.audioCtx.resume();
    }
    console.log('AuraSonixEngine: play() called');
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
    const audioEffects = cfg?.audioEffects;
    
    // Use new audio effects configuration if available
    if (audioEffects?.envelope?.enabled) {
      const env = audioEffects.envelope;
      return {
        attack: Number(env.attack ?? 0.05),
        decay: Number(env.decay ?? 0.3),
        sustain: Number(env.sustain ?? 0.8),
        release: Number(env.release ?? 1.0),
      };
    }
    
    // Fallback to old configuration
    const chain = cfg && Array.isArray(cfg.effectsChain) ? cfg.effectsChain : [];
    const env = chain.find((e) => (e && (e.type === 'Envelope' || e.id === 'main-envelope')));
    const params = (env && env.parameters) || {};
    return {
      attack: Number(params.attack ?? 0.05),
      decay: Number(params.decay ?? 0.3),
      sustain: Number(params.sustain ?? 0.8),
      release: Number(params.release ?? 1.0),
    };
  }

  async _ensureAudio() {
    console.log("AuraSonixEngine: _ensureAudio called");
    if (!this.audioCtx) {
      console.log("AuraSonixEngine: Creating new AudioContext");
      const Ctx = window.AudioContext || window.webkitAudioContext;
      
      // Create AudioContext with device-optimized settings
      const audioContextOptions = {
        latencyHint: this.deviceCapabilities.useLowLatencyMode ? 'interactive' : 'balanced',
        sampleRate: this.deviceCapabilities.preferredSampleRate
      };
      
      try {
        this.audioCtx = new Ctx(audioContextOptions);
        console.log("AuraSonixEngine: AudioContext created with options:", audioContextOptions);
      } catch (e) {
        console.warn("AuraSonixEngine: Failed to create AudioContext with options, using defaults:", e);
        this.audioCtx = new Ctx();
      }
      
      this.masterGain = this.audioCtx.createGain();
      this.masterGain.gain.value = 1.0;
      this.masterGain.connect(this.audioCtx.destination);
      
      // Set up audio context resume handling for mobile
      this._setupAudioContextResumeHandling();
      
      console.log("AuraSonixEngine: AudioContext created successfully");
      console.log("AuraSonixEngine: Sample rate:", this.audioCtx.sampleRate);
      console.log("AuraSonixEngine: State:", this.audioCtx.state);
    } else {
      console.log("AuraSonixEngine: AudioContext already exists");
    }
  }

  // Set up audio context resume handling for mobile devices
  _setupAudioContextResumeHandling() {
    if (!this.audioCtx) return;
    
    // Handle audio context suspension (common on mobile)
    this.audioCtx.addEventListener('statechange', () => {
      console.log("AuraSonixEngine: AudioContext state changed to:", this.audioCtx.state);
      
      if (this.audioCtx.state === 'suspended') {
        console.log("AuraSonixEngine: AudioContext suspended, will attempt resume on next user interaction");
      }
    });
    
    // Resume audio context on user interaction
    const resumeOnInteraction = async () => {
      if (this.audioCtx && this.audioCtx.state === 'suspended') {
        try {
          await this.audioCtx.resume();
          console.log("AuraSonixEngine: AudioContext resumed successfully");
          this._audioContextResumeAttempts = 0;
        } catch (e) {
          console.warn("AuraSonixEngine: Failed to resume AudioContext:", e);
          this._audioContextResumeAttempts++;
          
          if (this._audioContextResumeAttempts < this._maxResumeAttempts) {
            setTimeout(resumeOnInteraction, this._resumeRetryDelay);
          }
        }
      }
    };
    
    // Add event listeners for user interaction
    const interactionEvents = ['touchstart', 'touchend', 'mousedown', 'keydown', 'click'];
    interactionEvents.forEach(eventType => {
      document.addEventListener(eventType, resumeOnInteraction, { once: true, passive: true });
    });
  }

  // Ensure audio context is running before playing
  async _ensureAudioContextRunning() {
    if (!this.audioCtx) {
      await this._ensureAudio();
    }
    
    if (this.audioCtx.state === 'suspended') {
      try {
        await this.audioCtx.resume();
        console.log("AuraSonixEngine: AudioContext resumed for playback");
      } catch (e) {
        console.warn("AuraSonixEngine: Failed to resume AudioContext:", e);
        // Continue anyway, the browser might handle it
      }
    }
  }


  _createDummyBuffer(layer) {
    const sampleRate = this.audioCtx.sampleRate;
    const duration = this.deviceCapabilities.isMobile ? 0.5 : 1.0; // Shorter duration for mobile
    const length = sampleRate * duration;
    
    // Create different tones for each layer with distinct frequencies
    const frequencies = {
      bass: 110,    // A2 - Low frequency
      mid: 440,     // A4 - Medium frequency
      high: 880,    // A5 - High frequency
      tex: 220      // A3 - Texture frequency
    };
    
    const freq = frequencies[layer] || 440;
    const buffer = this.audioCtx.createBuffer(1, length, sampleRate);
    const channelData = buffer.getChannelData(0);
    
    // Generate a simple sine wave with different amplitude for each layer
    const amplitudes = {
      bass: 0.4,
      mid: 0.3,
      high: 0.2,
      tex: 0.25
    };
    
    const amplitude = amplitudes[layer] || 0.3;
    
    for (let i = 0; i < length; i++) {
      const sample = Math.sin(2 * Math.PI * freq * i / sampleRate) * amplitude;
      channelData[i] = sample;
    }
    
    console.log(`AuraSonixEngine: created dummy buffer for ${layer}`, {
      frequency: freq,
      amplitude: amplitude,
      duration: duration,
      sampleRate: sampleRate,
      deviceType: this.deviceCapabilities.performanceTier
    });
    
    return buffer;
  }

  // Sample rate conversion for mobile devices
  _convertSampleRate(buffer, targetSampleRate) {
    if (!this.deviceCapabilities.enableSampleRateConversion || buffer.sampleRate === targetSampleRate) {
      return buffer;
    }
    
    try {
      const ratio = targetSampleRate / buffer.sampleRate;
      const newLength = Math.round(buffer.length * ratio);
      const newBuffer = this.audioCtx.createBuffer(buffer.numberOfChannels, newLength, targetSampleRate);
      
      for (let channel = 0; channel < buffer.numberOfChannels; channel++) {
        const oldData = buffer.getChannelData(channel);
        const newData = newBuffer.getChannelData(channel);
        
        for (let i = 0; i < newLength; i++) {
          const oldIndex = i / ratio;
          const oldIndexFloor = Math.floor(oldIndex);
          const oldIndexCeil = Math.min(oldIndexFloor + 1, oldData.length - 1);
          const fraction = oldIndex - oldIndexFloor;
          
          // Linear interpolation
          newData[i] = oldData[oldIndexFloor] * (1 - fraction) + oldData[oldIndexCeil] * fraction;
        }
      }
      
      console.log(`AuraSonixEngine: Converted sample rate from ${buffer.sampleRate} to ${targetSampleRate}`);
      return newBuffer;
    } catch (e) {
      console.warn('AuraSonixEngine: Sample rate conversion failed, using original buffer:', e);
      return buffer;
    }
  }

  // Get preset-specific modifier to make sounds different
  _getPresetModifier() {
    const presetName = this.currentPreset || 'default';
    
    switch (presetName) {
      case 'Deep-Focus':
        return {
          type: 'deep',
          frequencyShift: 0.8,  // Lower frequencies
          amplitudeMod: 1.2,    // Slightly louder
          harmonicContent: 0.3  // Add harmonics
        };
      case 'Creative-Flow':
        return {
          type: 'bright',
          frequencyShift: 1.2,  // Higher frequencies
          amplitudeMod: 0.9,    // Slightly quieter
          harmonicContent: 0.7  // More harmonics
        };
      default:
        return {
          type: 'neutral',
          frequencyShift: 1.0,
          amplitudeMod: 1.0,
          harmonicContent: 0.5
        };
    }
  }

  // Apply preset-specific effects to audio samples
  _applyPresetEffects(sample, index, sampleRate, modifier) {
    let modifiedSample = sample;
    
    // Apply frequency shift (simulated by phase modulation)
    const phaseShift = (index / sampleRate) * (modifier.frequencyShift - 1) * 0.1;
    modifiedSample = Math.sin(2 * Math.PI * 440 * (index / sampleRate + phaseShift)) * 0.3;
    
    // Apply amplitude modification
    modifiedSample *= modifier.amplitudeMod;
    
    // Add harmonic content
    if (modifier.harmonicContent > 0) {
      const harmonic1 = Math.sin(2 * Math.PI * 440 * 2 * index / sampleRate) * 0.1 * modifier.harmonicContent;
      const harmonic2 = Math.sin(2 * Math.PI * 440 * 3 * index / sampleRate) * 0.05 * modifier.harmonicContent;
      modifiedSample += harmonic1 + harmonic2;
    }
    
    // Apply preset-specific filtering
    if (modifier.type === 'deep') {
      // Low-pass filter effect for deep focus
      modifiedSample *= Math.exp(-index / (sampleRate * 0.1));
    } else if (modifier.type === 'bright') {
      // High-pass filter effect for creative flow
      modifiedSample *= (1 - Math.exp(-index / (sampleRate * 0.05)));
    }
    
    return Math.max(-1, Math.min(1, modifiedSample)); // Clamp to valid range
  }

  async _loadAudioBuffer(url) {
    try {
      // Add timeout for mobile devices
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), this.deviceCapabilities.isMobile ? 10000 : 5000);
      
      const resp = await fetch(url, { 
        cache: 'no-cache',
        signal: controller.signal
      });
      
      clearTimeout(timeoutId);
      
      if (!resp.ok) throw new Error(`HTTP ${resp.status} for ${url}`);
      const arr = await resp.arrayBuffer();
      
      return await new Promise((resolve, reject) => {
        try {
          // Add timeout for audio decoding
          const decodeTimeout = setTimeout(() => {
            reject(new Error('Audio decode timeout'));
          }, this.deviceCapabilities.isMobile ? 8000 : 4000);
          
          this.audioCtx.decodeAudioData(arr, 
            (buffer) => {
              clearTimeout(decodeTimeout);
              resolve(buffer);
            }, 
            (error) => {
              clearTimeout(decodeTimeout);
              reject(error);
            }
          );
        } catch (e) {
          reject(e);
        }
      });
    } catch (e) {
      console.error('AuraSonixEngine: Failed to load audio buffer:', url, e);
      throw e;
    }
  }

  _notePassesScaleFilter(noteNumber, scaleFilter) {
    const octave = Math.floor(noteNumber / 12) - 1;
    if (octave < scaleFilter.minOctave || octave > scaleFilter.maxOctave) {
      // Drop silently in gate behavior; avoid spam
      return false;
    }
    
    const noteInOctave = noteNumber % 12;
    const rootNote = this._getRootNoteValue(scaleFilter.root || 'C');
    const relativeNote = (noteInOctave - rootNote + 12) % 12;
    
    let passes = false;
    switch (scaleFilter.mode) {
      case 'chromatic':
        passes = true;
        break;
      case 'pentatonic':
      case 'pentatonic_major':
        passes = [0, 2, 4, 7, 9].includes(relativeNote);
        break;
      case 'pentatonic_minor':
        passes = [0, 3, 5, 7, 10].includes(relativeNote);
        break;
      case 'major':
        passes = [0, 2, 4, 5, 7, 9, 11].includes(relativeNote);
        break;
      case 'minor':
        passes = [0, 2, 3, 5, 7, 8, 10].includes(relativeNote);
        break;
      case 'dorian':
        passes = [0, 2, 3, 5, 7, 9, 10].includes(relativeNote);
        break;
      case 'mixolydian':
        passes = [0, 2, 4, 5, 7, 9, 10].includes(relativeNote);
        break;
      case 'lydian':
        passes = [0, 2, 4, 6, 7, 9, 11].includes(relativeNote);
        break;
      case 'phrygian':
        passes = [0, 1, 3, 5, 7, 8, 10].includes(relativeNote);
        break;
      case 'locrian':
        passes = [0, 1, 3, 5, 6, 8, 10].includes(relativeNote);
        break;
      default:
        passes = true;
        break;
    }
    
    // no logging for non-passing; keep console quiet
    
    return passes;
  }

  _getRootNoteValue(rootNote) {
    const noteValues = {
      'C': 0, 'C#': 1, 'D': 2, 'D#': 3, 'E': 4, 'F': 5,
      'F#': 6, 'G': 7, 'G#': 8, 'A': 9, 'A#': 10, 'B': 11
    };
    return noteValues[rootNote] || 0;
  }

  _getNoteName(noteNumber) {
    const noteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    const octave = Math.floor(noteNumber / 12) - 1;
    const noteInOctave = noteNumber % 12;
    return `${noteNames[noteInOctave]}${octave}`;
  }

  // Parse strings like 'C4', 'G#3' to MIDI note numbers (C-1 = 0, C0 = 12, C4 = 60)
  _parseNoteToMidi(noteStr) {
    try {
      if (!noteStr || typeof noteStr !== 'string' || noteStr.length < 2) return null;
      const m = noteStr.toUpperCase().match(/^([A-G])(#?)(-?\d+)$/);
      if (!m) return null;
      const letter = m[1];
      const sharp = m[2] === '#';
      const octave = parseInt(m[3], 10);
      const baseVals = { 'C':0, 'D':2, 'E':4, 'F':5, 'G':7, 'A':9, 'B':11 };
      let val = baseVals[letter];
      if (val == null) return null;
      if (sharp) val += 1;
      const midi = (octave + 1) * 12 + val;
      return Math.max(0, Math.min(127, midi));
    } catch (_) {
      return null;
    }
  }

  // Get the appropriate sample key (bass, mid, high, tex) for a given note
  _getSampleKeyForNote(noteNumber, zones) {
    if (!zones || zones.length === 0) {
      // Fallback mapping if no zones defined
      if (noteNumber < 44) return 'bass';
      if (noteNumber < 68) return 'mid';
      if (noteNumber < 88) return 'high';
      return 'tex';
    }

    // Find the zone that contains this note
    for (const zone of zones) {
      if (noteNumber >= zone.minNote && noteNumber <= zone.maxNote) {
        // Map zone name to sample key
        const zoneName = zone.name ? zone.name.toLowerCase() : '';
        if (zoneName.includes('bass')) return 'bass';
        if (zoneName.includes('mid')) return 'mid';
        if (zoneName.includes('high')) return 'high';
        if (zoneName.includes('tex')) return 'tex';
        
        // Default mapping based on note range
        if (noteNumber < 44) return 'bass';
        if (noteNumber < 68) return 'mid';
        if (noteNumber < 88) return 'high';
        return 'tex';
      }
    }

    // Fallback if note doesn't match any zone
    if (noteNumber < 44) return 'bass';
    if (noteNumber < 68) return 'mid';
    if (noteNumber < 88) return 'high';
    return 'tex';
  }

  // Update audio effects from Flutter
  updateAudioEffects(effects) {
    if (!this.currentPresetConfig) this.currentPresetConfig = {};
    this.currentPresetConfig.audioEffects = effects;
    console.log("AuraSonixEngine: audio effects updated", effects);
  }

  // Apply randomness to note parameters
  _applyRandomness(noteNumber, velocity, timing) {
    const effects = this.currentPresetConfig?.audioEffects;
    if (!effects?.randomness?.enabled) {
      return { noteNumber, velocity, timing };
    }

    const randomness = effects.randomness;
    let newNoteNumber = noteNumber;
    let newVelocity = velocity;
    let newTiming = timing;

    // Apply pitch variation
    if (randomness.pitchVariation > 0) {
      const pitchVariation = (Math.random() - 0.5) * 2 * randomness.pitchVariation;
      newNoteNumber = Math.max(0, Math.min(127, noteNumber + pitchVariation));
    }

    // Apply velocity variation
    if (randomness.velocityVariation > 0) {
      const velocityVariation = (Math.random() - 0.5) * 2 * randomness.velocityVariation;
      newVelocity = Math.max(0, Math.min(1, velocity + velocityVariation));
    }

    // Apply timing variation
    if (randomness.timingVariation > 0) {
      const timingVariation = (Math.random() - 0.5) * 2 * randomness.timingVariation;
      newTiming = Math.max(0, timing + timingVariation);
    }

    return { noteNumber: newNoteNumber, velocity: newVelocity, timing: newTiming };
  }

  // Check if we can play more simultaneous notes
  _canPlaySimultaneousNote() {
    const effects = this.currentPresetConfig?.audioEffects;
    if (!effects?.simultaneousNotes?.enabled) {
      return true; // No limit if not enabled
    }

    const settings = effects.simultaneousNotes;
    const currentNotes = Object.keys(this.activeByNote).length;
    
    if (currentNotes >= settings.maxNotes) {
      // Check if we should steal a voice
      if (settings.voiceStealing) {
        return this._shouldStealVoice();
      }
      return false;
    }

    return true;
  }

  // Determine if we should steal a voice based on threshold
  _shouldStealVoice() {
    const effects = this.currentPresetConfig?.audioEffects;
    if (!effects?.simultaneousNotes?.enabled) return false;

    const threshold = effects.simultaneousNotes.voiceStealThreshold;
    return Math.random() < threshold;
  }

  // Steal the oldest voice
  _stealOldestVoice() {
    if (Object.keys(this.activeByNote).length === 0) return;

    // Find the oldest note (first in the object)
    const oldestNote = Object.keys(this.activeByNote)[0];
    this.stopNote(parseInt(oldestNote));
  }

  // Apply sustain settings to note
  _applySustainSettings(noteNumber, velocity) {
    const effects = this.currentPresetConfig?.audioEffects;
    if (!effects?.sustain?.enabled) {
      return { noteNumber, velocity };
    }

    const sustain = effects.sustain;
    
    // If infinite sustain is enabled, we'll handle this in the note playing logic
    if (sustain.infinite) {
      // The note will be held indefinitely until manually stopped
      console.log('AuraSonixEngine: infinite sustain enabled for note', noteNumber);
    }

    return { noteNumber, velocity };
  }

  // Update MIDI rules from Flutter
  updateMidiRules(rules) {
    if (!this.currentPresetConfig) this.currentPresetConfig = {};
    this.currentPresetConfig.midiRules = rules;
    console.log("AuraSonixEngine: MIDI rules updated", rules);
  }

  // Apply velocity mapping
  _applyVelocityMapping(velocity, velocityRule) {
    if (!velocityRule.enabled) return velocity;
    
    let mappedVelocity = velocity;
    const range = velocityRule.maxVelocity - velocityRule.minVelocity;
    mappedVelocity = velocityRule.minVelocity + (velocity * range);
    
    switch (velocityRule.curve) {
      case 'exponential':
        mappedVelocity = Math.pow(mappedVelocity, 2);
        break;
      case 'logarithmic':
        mappedVelocity = Math.log(mappedVelocity + 1) / Math.log(2);
        break;
      default: // linear
        break;
    }
    
    return Math.max(0, Math.min(1, mappedVelocity));
  }

  // Apply note transformation
  _applyNoteTransformation(noteNumber, transformation) {
    if (!transformation.enabled) return [noteNumber];
    
    let transformedNotes = [noteNumber];
    
    // Apply transpose
    if (transformation.transpose !== 0) {
      transformedNotes = transformedNotes.map(note => note + transformation.transpose);
    }
    
    // Apply octave shift
    if (transformation.octaveShift !== 0) {
      const octaveShift = Math.round(transformation.octaveShift * 12);
      transformedNotes = transformedNotes.map(note => note + octaveShift);
    }
    
    // Apply harmonization
    if (transformation.harmonize && transformation.harmonyIntervals) {
      const originalNotes = [...transformedNotes];
      transformation.harmonyIntervals.forEach(interval => {
        if (interval !== 0) { // Skip unison
          originalNotes.forEach(note => {
            transformedNotes.push(note + interval);
          });
        }
      });
    }
    
    return transformedNotes;
  }

  // Create audio effects chain
  _createEffectsChain(source, effects, gain, isTexture = false, noteNumber = 60) {
    let currentNode = source;
    // Texture LFO (tremolo) before other effects - simplified to reduce glitches
    if (isTexture) {
      const tremoloGain = this.audioCtx.createGain();
      // Use simpler, more stable LFO settings
      const lfoRate = 0.1; // Slower LFO to reduce glitches
      const lfoDepth = 0.3; // Reduced depth for smoother modulation
      
      const lfo = this.audioCtx.createOscillator();
      lfo.type = 'sine';
      lfo.frequency.setValueAtTime(lfoRate, this.audioCtx.currentTime);
      const lfoAmp = this.audioCtx.createGain();
      lfoAmp.gain.setValueAtTime(lfoDepth, this.audioCtx.currentTime);
      lfo.connect(lfoAmp);
      lfoAmp.connect(tremoloGain.gain);
      lfo.start();
      currentNode.connect(tremoloGain);
      currentNode = tremoloGain;
    }
    
    // Apply envelope if enabled
    if (effects.envelope && effects.envelope.enabled) {
      const envelope = effects.envelope;
      const gainNode = this.audioCtx.createGain();
      
      const now = this.audioCtx.currentTime;
      gainNode.gain.setValueAtTime(0, now);
      gainNode.gain.linearRampToValueAtTime(gain, now + envelope.attack);
      gainNode.gain.linearRampToValueAtTime(gain * envelope.sustain, now + envelope.attack + envelope.decay);
      // Use exponential ramp for smoother release
      gainNode.gain.setTargetAtTime(0, now + envelope.attack + envelope.decay, envelope.release / 3);
      
      currentNode.connect(gainNode);
      currentNode = gainNode;
    }
    
    // Apply filter if enabled
    if (effects.filter && effects.filter.enabled === true) {
      const filter = effects.filter;
      const filterNode = this.audioCtx.createBiquadFilter();
      const typeMap = { lpf: 'lowpass', hpf: 'highpass', bpf: 'bandpass' };
      const type = (filter.type || 'lpf').toString().toLowerCase();
      filterNode.type = typeMap[type] || 'lowpass';
      filterNode.frequency.setValueAtTime(Math.max(20, Math.min(20000, filter.cutoff || 2000)), this.audioCtx.currentTime);
      filterNode.Q.setValueAtTime(Math.max(0, filter.resonance || 0), this.audioCtx.currentTime);
      console.log('AuraSonixEngine: filter applied', { type: filterNode.type, cutoff: filterNode.frequency.value, q: filterNode.Q.value });
      currentNode.connect(filterNode);
      currentNode = filterNode;
    }
    
    // Apply reverb if enabled
    if (effects.reverb && effects.reverb.enabled) {
      const reverb = effects.reverb;
      const wetGain = this.audioCtx.createGain();
      const dryGain = this.audioCtx.createGain();

      wetGain.gain.setValueAtTime(Math.max(0, Math.min(1, reverb.wet)) * gain, this.audioCtx.currentTime);
      dryGain.gain.setValueAtTime(Math.max(0, Math.min(1, reverb.dry ?? (1 - reverb.wet))) * gain, this.audioCtx.currentTime);

      // Build reverb nodes (separate input and output)
      const rv = this._createReverbEffectNodes(reverb);

      // Wet path: source -> wetGain -> reverb.input -> reverb.output -> master
      currentNode.connect(wetGain);
      wetGain.connect(rv.input);
      rv.output.connect(this.masterGain);

      // Dry path: source -> dryGain -> master
      currentNode.connect(dryGain);
      dryGain.connect(this.masterGain);

      // Continue returning the dry/current node for further processing
      // (reverb wet path is already routed to master)
      return currentNode;
    }
    
    // Return the final node for further processing
    return currentNode;
  }

  // Create reverb effect nodes with distinct input and output
  _createReverbEffectNodes(reverb) {
    const input = this.audioCtx.createGain();
    const preDelay = this.audioCtx.createDelay();
    preDelay.delayTime.setValueAtTime(Math.max(0, reverb.preDelay || 0), this.audioCtx.currentTime);

    // Simple impulse response-based reverb using Convolver
    const convolver = this.audioCtx.createConvolver();
    convolver.normalize = true;
    convolver.buffer = this._generateImpulseResponse(1.5 + (reverb.roomSize || 0) * 2.0,  // length seconds
                                                     2.0 - (reverb.dampening || 0) * 1.5); // decay

    const out = this.audioCtx.createGain();
    out.gain.setValueAtTime(1.0, this.audioCtx.currentTime);

    input.connect(preDelay);
    preDelay.connect(convolver);
    convolver.connect(out);

    return { input, output: out };
  }

  _generateImpulseResponse(lengthSeconds, decay) {
    const sr = this.audioCtx.sampleRate;
    const length = Math.floor(sr * Math.max(0.1, Math.min(6.0, lengthSeconds)));
    const impulse = this.audioCtx.createBuffer(2, length, sr);
    for (let ch = 0; ch < 2; ch++) {
      const channelData = impulse.getChannelData(ch);
      for (let i = 0; i < length; i++) {
        const t = i / sr;
        // Exponential decay noise impulse
        channelData[i] = (Math.random() * 2 - 1) * Math.pow(1 - t / (lengthSeconds || 1), Math.max(0.1, decay));
      }
    }
    return impulse;
  }

  // Update scale filter configuration from Flutter
  updateScaleFilterConfig(config) {
    if (!this.currentPresetConfig) this.currentPresetConfig = {};
    this.currentPresetConfig.scaleFilter = config;
    console.log("AuraSonixEngine: scale filter updated", config);
    console.log("AuraSonixEngine: current config after update", this.currentPresetConfig);
  }

  // Update audio effects configuration from Flutter
  updateAudioEffects(effects) {
    if (!this.currentPresetConfig) this.currentPresetConfig = {};
    this.currentPresetConfig.audioEffects = effects;
    console.log("AuraSonixEngine: audio effects updated", effects);
    console.log("AuraSonixEngine: current config after update", this.currentPresetConfig);
  }

  // Update zones configuration from Flutter
  updateZones(zones) {
    if (!this.currentPresetConfig) this.currentPresetConfig = {};
    this.currentPresetConfig.zones = zones;
    console.log("AuraSonixEngine: zones updated", zones);
    console.log("AuraSonixEngine: current config after update", this.currentPresetConfig);
  }

  // Performance optimization: Check if we can play a new note
  _canPlayNote(noteNumber) {
    const totalActiveNotes = this.activeSources.size;
    const notesForThisNote = this.activeByNote[noteNumber] ? this.activeByNote[noteNumber].size : 0;
    
    // Emergency buffer management - only if we're way over limit
    if (totalActiveNotes > this.MAX_CONCURRENT_NOTES * 1.5) {
      console.warn(`AuraSonixEngine: Emergency buffer cleanup - ${totalActiveNotes} voices active, limit is ${this.MAX_CONCURRENT_NOTES}`);
      this._emergencyBufferCleanup();
      return false; // Force a retry after cleanup
    }
    
    // Check total concurrent notes limit
    if (totalActiveNotes >= this.MAX_CONCURRENT_NOTES) {
      return false;
    }
    
    // Check per-note limit
    if (notesForThisNote >= this.MAX_CONCURRENT_NOTES_PER_NOTE) {
      return false;
    }
    
    return true;
  }

  // Emergency buffer cleanup when we're way over limits
  _emergencyBufferCleanup() {
    console.warn('AuraSonixEngine: Performing emergency oscillator cleanup');
    
    // Stop all oscillators immediately
    const oscillatorsToStop = Array.from(this.activeSources);
    for (const oscillator of oscillatorsToStop) {
      try {
        oscillator.stop();
      } catch (e) {
        console.warn('AuraSonixEngine: Failed to stop oscillator during emergency cleanup:', e);
      }
    }
    
    // Clear all tracking
    this.activeSources.clear();
    this.activeByNote = {};
    this.activeByInputNote = {};
    this.activeVoices.clear();
    
    console.warn(`AuraSonixEngine: Emergency cleanup completed - stopped ${oscillatorsToStop.length} oscillators`);
  }

  // Graceful note dropping - drop oldest notes when buffer is stressed
  _dropOldestNotes(count = 1) {
    if (this.activeSources.size === 0) return;
    
    // Sort oscillators by creation time
    const sortedOscillators = Array.from(this.activeSources).sort((a, b) => {
      return (a._creationTime || 0) - (b._creationTime || 0);
    });
    
    // Drop the oldest oscillators
    const oscillatorsToDrop = sortedOscillators.slice(0, count);
    for (const oscillator of oscillatorsToDrop) {
      try {
        oscillator.stop();
        this.activeSources.delete(oscillator);
        
        // Remove from note tracking
        for (const [noteNum, sources] of Object.entries(this.activeByNote)) {
          if (sources.has(oscillator)) {
            sources.delete(oscillator);
            if (sources.size === 0) {
              delete this.activeByNote[noteNum];
            }
            break;
          }
        }
        
        // Remove from input note tracking
        for (const [inputNote, sources] of Object.entries(this.activeByInputNote)) {
          if (sources.has(oscillator)) {
            sources.delete(oscillator);
            if (sources.size === 0) {
              delete this.activeByInputNote[inputNote];
            }
            break;
          }
        }
      } catch (e) {
        console.warn('AuraSonixEngine: Failed to drop oscillator:', e);
      }
    }
  }

  // Performance optimization: Steal oldest voice if needed
  _stealOldestVoice() {
    if (this.activeSources.size === 0) return;
    
    // Find the oldest oscillator by creation time
    let oldestOscillator = null;
    let oldestTime = Date.now();
    let oldestNoteNumber = null;
    
    for (const oscillator of this.activeSources) {
      if (oscillator._creationTime && oscillator._creationTime < oldestTime) {
        oldestTime = oscillator._creationTime;
        oldestOscillator = oscillator;
        // Find which note this oscillator belongs to
        for (const [noteNum, sources] of Object.entries(this.activeByNote)) {
          if (sources.has(oscillator)) {
            oldestNoteNumber = parseInt(noteNum);
            break;
          }
        }
      }
    }
    
    if (oldestOscillator) {
      try {
        // Stop the oscillator immediately
        oldestOscillator.stop();
        
        // Remove from tracking
        this.activeSources.delete(oldestOscillator);
        if (oldestNoteNumber && this.activeByNote[oldestNoteNumber]) {
          this.activeByNote[oldestNoteNumber].delete(oldestOscillator);
          if (this.activeByNote[oldestNoteNumber].size === 0) {
            delete this.activeByNote[oldestNoteNumber];
          }
        }
        
        // Also remove from polyphony tracking
        this._removeVoice(oldestNoteNumber);
      } catch (e) {
        console.warn('AuraSonixEngine: Failed to stop oldest oscillator:', e);
      }
    }
  }

  // Performance optimization: Clean up orphaned oscillators periodically
  _cleanupOrphanedSources() {
    const now = Date.now();
    if (now - this._lastCleanupTime < this.NOTE_CLEANUP_INTERVAL) return;
    
    this._lastCleanupTime = now;
    let cleanedCount = 0;
    
    // Remove oscillators that have been running too long (oscillators don't have duration like buffers)
    for (const oscillator of this.activeSources) {
      if (oscillator._startTime) {
        const runningTime = now - oscillator._startTime;
        const maxRunningTime = this.deviceCapabilities.aggressiveCleanup ? 30000 : 60000; // 30s or 60s max
        if (runningTime > maxRunningTime) {
          try {
            oscillator.stop();
            this.activeSources.delete(oscillator);
            cleanedCount++;
          } catch (e) {
            console.warn('AuraSonixEngine: Failed to cleanup orphaned oscillator:', e);
          }
        }
      }
    }
    
    // Less aggressive cleanup to prevent audio glitches
    if (this.deviceCapabilities.aggressiveCleanup) {
      // Only force cleanup if we have way too many oscillators
      if (this.activeSources.size > this.MAX_CONCURRENT_NOTES * 2.0) {
        const oscillatorsToRemove = Array.from(this.activeSources).slice(0, Math.floor(this.activeSources.size * 0.2));
        for (const oscillator of oscillatorsToRemove) {
          try {
            oscillator.stop();
            this.activeSources.delete(oscillator);
            cleanedCount++;
          } catch (e) {
            console.warn('AuraSonixEngine: Failed to cleanup oscillator during aggressive cleanup:', e);
          }
        }
      }
    }
    
    if (cleanedCount > 0) {
      console.log(`AuraSonixEngine: Cleaned up ${cleanedCount} orphaned oscillators`);
    }
  }

  // Preemptive voice stealing to prevent buffer saturation - disabled for better audio quality
  _preemptiveVoiceStealing() {
    // Disabled preemptive voice stealing as it was causing audio glitches
    // Voice stealing will only happen when we actually hit the limit
    return;
  }

  // Check if buffer is under stress and should reject new notes
  _isBufferStressed() {
    const totalActiveNotes = this.activeSources.size;
    
    // Only consider buffer stressed when we're at 90% capacity or higher
    return totalActiveNotes >= this.MAX_CONCURRENT_NOTES * 0.9;
  }

  // Performance monitoring: Get current performance stats
  getPerformanceStats() {
    const stats = {
      totalActiveSources: this.activeSources.size,
      maxConcurrentNotes: this.MAX_CONCURRENT_NOTES,
      maxConcurrentNotesPerNote: this.MAX_CONCURRENT_NOTES_PER_NOTE,
      activeNotesByNote: {},
      bufferSaturation: this.activeSources.size >= this.MAX_CONCURRENT_NOTES,
      lastCleanupTime: this._lastCleanupTime,
      audioContextState: this.audioCtx ? this.audioCtx.state : 'not_initialized'
    };
    
    // Count active sources per note
    for (const [noteNumber, sources] of Object.entries(this.activeByNote)) {
      stats.activeNotesByNote[noteNumber] = sources.size;
    }
    
    return stats;
  }

  // Performance optimization: Adjust limits based on device performance
  adjustPerformanceLimits(deviceType = 'auto') {
    const limits = {
      'low': { maxConcurrent: 8, maxPerNote: 2 },
      'medium': { maxConcurrent: 16, maxPerNote: 3 },
      'high': { maxConcurrent: 32, maxPerNote: 4 },
      'auto': { maxConcurrent: 16, maxPerNote: 3 } // Default
    };
    
    const newLimits = limits[deviceType] || limits.auto;
    this.MAX_CONCURRENT_NOTES = newLimits.maxConcurrent;
    this.MAX_CONCURRENT_NOTES_PER_NOTE = newLimits.maxPerNote;
    
    console.log(`AuraSonixEngine: Adjusted performance limits for ${deviceType}:`, newLimits);
  }

  // Polyphony management: Get current polyphony settings from config
  _getPolyphonySettings() {
    const effects = this.currentPresetConfig?.audioEffects || {};
    const polyphony = effects.polyphony || {};
    
    return {
      enabled: polyphony.enabled !== false,
      limit: polyphony.limit || this.polyphonyLimit,
      voiceStealing: polyphony.voiceStealing !== false,
      stealOldest: polyphony.stealOldest !== false,
      releaseTime: polyphony.releaseTime || this.releaseTime
    };
  }

  // Polyphony management: Check if we can play a new voice
  _canPlayVoice(noteNumber) {
    const settings = this._getPolyphonySettings();
    
    if (!settings.enabled) {
      return true; // Polyphony disabled, allow all voices
    }
    
    const currentVoices = this.activeVoices.size;
    const limit = settings.limit;
    
    if (currentVoices < limit) {
      return true; // Under limit, can play
    }
    
    // At limit, check if voice stealing is enabled
    if (settings.voiceStealing) {
      console.log(`AuraSonixEngine: Polyphony limit reached (${currentVoices}/${limit}), will steal voice`);
      return false; // Will steal voice
    }
    
    console.log(`AuraSonixEngine: Polyphony limit reached (${currentVoices}/${limit}), voice stealing disabled`);
    return false; // Cannot play
  }

  // Polyphony management: Steal oldest voice with proper release
  _stealOldestVoice() {
    const settings = this._getPolyphonySettings();
    
    if (this.activeVoices.size === 0) return;
    
    let oldestVoice = null;
    let oldestTime = Date.now();
    
    // Find the oldest voice
    for (const [noteNumber, voice] of this.activeVoices.entries()) {
      if (voice.startTime < oldestTime) {
        oldestTime = voice.startTime;
        oldestVoice = { noteNumber, voice };
      }
    }
    
    if (oldestVoice) {
      const { noteNumber, voice } = oldestVoice;
      console.log(`AuraSonixEngine: Stealing oldest voice (note ${noteNumber}, started at ${new Date(oldestTime).toISOString()})`);
      
      // Apply proper release with ADSR
      this._releaseVoice(noteNumber, settings.releaseTime);
    }
  }

  // Polyphony management: Release voice with proper ADSR
  _releaseVoice(noteNumber, releaseTime = 0.1) {
    const voice = this.activeVoices.get(noteNumber);
    if (!voice) return;
    
    try {
      const { source: oscillator } = voice;
      
      // Apply release envelope
      if (oscillator._gainNode) {
        const currentGain = oscillator._gainNode.gain.value;
        const releaseStart = this.audioCtx.currentTime;
        const releaseEnd = releaseStart + releaseTime;
        
        // Set up release curve
        oscillator._gainNode.gain.setValueAtTime(currentGain, releaseStart);
        oscillator._gainNode.gain.linearRampToValueAtTime(0.001, releaseEnd);
        
        // Stop the oscillator after release
        oscillator.stop(releaseEnd + 0.01);
      } else {
        // Fallback: immediate stop
        oscillator.stop();
      }
      
      // Remove from active voices
      this.activeVoices.delete(noteNumber);
      
      console.log(`AuraSonixEngine: Released voice for note ${noteNumber} with ${releaseTime}s release`);
    } catch (e) {
      console.warn(`AuraSonixEngine: Failed to release voice for note ${noteNumber}:`, e);
      // Force remove from active voices
      this.activeVoices.delete(noteNumber);
    }
  }

  // Polyphony management: Add voice to active voices
  _addVoice(noteNumber, oscillator, velocity) {
    const voiceId = ++this.voiceCounter;
    const noteName = this._getNoteName(noteNumber);
    
    this.activeVoices.set(noteNumber, {
      source: oscillator,
      startTime: Date.now(),
      velocity,
      noteName,
      voiceId
    });
    
    console.log(`AuraSonixEngine: Added voice ${voiceId} for note ${noteNumber} (${noteName}) at velocity ${velocity}`);
  }

  // Polyphony management: Remove voice from active voices
  _removeVoice(noteNumber) {
    const voice = this.activeVoices.get(noteNumber);
    if (voice) {
      console.log(`AuraSonixEngine: Removed voice ${voice.voiceId} for note ${noteNumber} (${voice.noteName})`);
      this.activeVoices.delete(noteNumber);
    }
  }

  // Polyphony monitoring: Get current polyphony stats
  getPolyphonyStats() {
    const settings = this._getPolyphonySettings();
    const activeVoices = Array.from(this.activeVoices.entries()).map(([noteNumber, voice]) => ({
      noteNumber,
      noteName: voice.noteName,
      velocity: voice.velocity,
      voiceId: voice.voiceId,
      startTime: voice.startTime,
      age: Date.now() - voice.startTime
    }));
    
    return {
      enabled: settings.enabled,
      limit: settings.limit,
      currentVoices: this.activeVoices.size,
      voiceStealing: settings.voiceStealing,
      stealOldest: settings.stealOldest,
      releaseTime: settings.releaseTime,
      activeVoices: activeVoices.sort((a, b) => a.startTime - b.startTime), // Oldest first
      voiceCounter: this.voiceCounter
    };
  }
}
window.AuraSonixEngine = AuraSonixEngine;
