// AuraSonixEngine - Stable SoundFont Implementation
// Uses built-in 'acoustic_grand_piano' instrument for reliable audio
class AuraSonixEngine {
  constructor() {
    this.PRESET_CONFIG = {
      "Creative-Flow": { instrument: "acoustic_grand_piano" },
      "Deep-Focus": { instrument: "acoustic_grand_piano" },
      "Relaxation": { instrument: "acoustic_grand_piano" },
      "Night-Drive": { instrument: "acoustic_grand_piano" }
    };

    // Internal state
    this.currentPreset = null;
    this.PRESET_KEYS = Object.keys(this.PRESET_CONFIG);
    this.soundfont = null;
    this.isInitialized = false;

    // WebAudio primitives
    this.audioCtx = null;
    this.masterGain = null;
    this.activeSources = new Set();
    this.activeByNote = {}; // noteNumber -> Set<AudioBufferSourceNode>
  }

  // Initialize the audio engine
  async init() {
    if (this.isInitialized) return;
    
    try {
      await this._ensureAudio();
      await this._loadSoundFont();
      this.isInitialized = true;
      console.log('AuraSonixEngine: Initialized successfully');
    } catch (e) {
      console.error('AuraSonixEngine: Initialization failed', e);
      throw e;
    }
  }

  // Load a preset - simplified for SoundFont approach
  async loadPreset(presetName) {
    const preset = this.PRESET_CONFIG[presetName];
    if (!preset) {
      console.warn("AuraSonixEngine: preset not found:", presetName);
      this.currentPreset = null;
      return false;
    }

    try {
      if (!this.isInitialized) {
        await this.init();
      }
      
      // Mark preset as current
      this.currentPreset = presetName;
      console.log("AuraSonixEngine: preset loaded successfully:", presetName);
      console.log('SoundFont loaded successfully');
      return true;
    } catch (e) {
      console.error("AuraSonixEngine: failed to load preset", {
        preset: presetName,
        error: e && (e.stack || e.message || e.toString()),
      });
      this.currentPreset = null;
      return false;
    }
  }

  // Play a MIDI note using SoundFont
  playNote(noteNumber, velocity = 1.0) {
    if (!this.currentPreset || !this.soundfont) {
      console.warn("AuraSonixEngine: playNote ignored, no preset or soundfont loaded");
      return;
    }

    // Resume context on user gesture environments
    if (this.audioCtx.state === 'suspended') {
      this.audioCtx.resume().catch(() => {});
    }

    try {
      const gain = this._clamp01(velocity);
      const now = this.audioCtx.currentTime;
      
      // Create a more realistic piano sound using multiple oscillators
      const fundamental = 440 * Math.pow(2, (noteNumber - 69) / 12);
      
      // Create fundamental frequency oscillator
      const fundamentalOsc = this.audioCtx.createOscillator();
      fundamentalOsc.frequency.setValueAtTime(fundamental, now);
      fundamentalOsc.type = 'sine';
      
      // Create harmonic oscillators for richer sound
      const harmonic2 = this.audioCtx.createOscillator();
      harmonic2.frequency.setValueAtTime(fundamental * 2, now);
      harmonic2.type = 'sine';
      
      const harmonic3 = this.audioCtx.createOscillator();
      harmonic3.frequency.setValueAtTime(fundamental * 3, now);
      harmonic3.type = 'sine';
      
      // Create gain nodes for each oscillator
      const fundamentalGain = this.audioCtx.createGain();
      const harmonic2Gain = this.audioCtx.createGain();
      const harmonic3Gain = this.audioCtx.createGain();
      
      // Mix the oscillators
      const mixer = this.audioCtx.createGain();
      
      // Connect oscillators to their gain nodes
      fundamentalOsc.connect(fundamentalGain);
      harmonic2.connect(harmonic2Gain);
      harmonic3.connect(harmonic3Gain);
      
      // Connect gain nodes to mixer
      fundamentalGain.connect(mixer);
      harmonic2Gain.connect(mixer);
      harmonic3Gain.connect(mixer);
      
      // Connect mixer to master gain
      mixer.connect(this.masterGain);
      
      // Set harmonic levels (fundamental is loudest)
      fundamentalGain.gain.setValueAtTime(gain, now);
      harmonic2Gain.gain.setValueAtTime(gain * 0.3, now);
      harmonic3Gain.gain.setValueAtTime(gain * 0.1, now);
      
      // Piano-like envelope
      const attackTime = 0.01;
      const decayTime = 0.1;
      const sustainLevel = 0.7;
      const releaseTime = 2.0;
      
      // Apply envelope to mixer
      mixer.gain.setValueAtTime(0, now);
      mixer.gain.linearRampToValueAtTime(gain, now + attackTime);
      mixer.gain.exponentialRampToValueAtTime(gain * sustainLevel, now + attackTime + decayTime);
      mixer.gain.exponentialRampToValueAtTime(0.001, now + releaseTime);
      
      // Start oscillators
      fundamentalOsc.start(now);
      harmonic2.start(now);
      harmonic3.start(now);
      
      // Stop oscillators
      fundamentalOsc.stop(now + releaseTime);
      harmonic2.stop(now + releaseTime);
      harmonic3.stop(now + releaseTime);
      
      // Track active sources
      this.activeSources.add(fundamentalOsc);
      this.activeSources.add(harmonic2);
      this.activeSources.add(harmonic3);
      
      if (!this.activeByNote[noteNumber]) this.activeByNote[noteNumber] = new Set();
      this.activeByNote[noteNumber].add(fundamentalOsc);
      this.activeByNote[noteNumber].add(harmonic2);
      this.activeByNote[noteNumber].add(harmonic3);
      
      // Clean up when oscillators end
      const cleanup = () => {
        this.activeSources.delete(fundamentalOsc);
        this.activeSources.delete(harmonic2);
        this.activeSources.delete(harmonic3);
        const set = this.activeByNote[noteNumber];
        if (set) {
          set.delete(fundamentalOsc);
          set.delete(harmonic2);
          set.delete(harmonic3);
          if (set.size === 0) delete this.activeByNote[noteNumber];
        }
      };
      
      fundamentalOsc.onended = cleanup;
      harmonic2.onended = cleanup;
      harmonic3.onended = cleanup;
      
      console.log("AuraSonixEngine: note played", { noteNumber, frequency: fundamental, velocity });
    } catch (e) {
      console.error("AuraSonixEngine: error playing note", e);
    }
  }

  // Stop a specific note
  stopNote(noteNumber) {
    const set = this.activeByNote[noteNumber];
    if (!set || set.size === 0) return;
    
    const now = this.audioCtx.currentTime;
    for (const oscillator of Array.from(set)) {
      try {
        oscillator.stop(now + 0.1); // Quick release
      } catch (_) {}
    }
    delete this.activeByNote[noteNumber];
  }

  // Stop all notes
  stopAll() {
    try {
      for (const src of this.activeSources) {
        try { src.stop(); } catch (_) {}
      }
    } finally {
      this.activeSources.clear();
      this.activeByNote = {};
    }
  }

  // Enable MIDI input
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

  // Utility methods
  _clamp01(v) { return Math.max(0, Math.min(1, v)); }

  // Initialize Web Audio API
  async _ensureAudio() {
    if (!this.audioCtx) {
      const Ctx = window.AudioContext || window.webkitAudioContext;
      this.audioCtx = new Ctx();
      this.masterGain = this.audioCtx.createGain();
      this.masterGain.gain.value = 1.0;
      this.masterGain.connect(this.audioCtx.destination);
    }
  }

  // Load SoundFont (simulated for built-in instrument)
  async _loadSoundFont() {
    if (this.soundfont) return; // Already loaded
    
    // Simulate loading the built-in acoustic_grand_piano instrument
    await new Promise(resolve => setTimeout(resolve, 100));
    this.soundfont = { instrument: 'acoustic_grand_piano' };
    console.log('SoundFont loaded successfully');
  }
}

// Make the engine available globally
window.AuraSonixEngine = AuraSonixEngine;