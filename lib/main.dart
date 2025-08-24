import 'package:flutter/material.dart';
import 'dart:async';
import 'theme/app_theme.dart';
import 'widgets/styled_preset_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'audio/audio_providers.dart';
import 'ui/lab_screen.dart';
import 'ui/settings_screen.dart';
import 'services/storage_service.dart';
import 'state/active_preset_provider.dart';
import 'state/audio_effects_state.dart';
import 'state/scale_filter_state.dart';
import 'state/zones_state.dart';
import 'state/midi_rules_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage service
  final storageService = StorageService();
  await storageService.initialize();
  
  runApp(ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(storageService),
    ],
    child: const LiveRootsApp(),
  ));
}

class LiveRootsApp extends StatelessWidget {
  const LiveRootsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const PlayerScreen(),
    );
  }
}

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  bool _initializing = false;
  bool _initialized = false;
  Timer? _sleepTimer;
  DateTime? _sleepEndsAt;

  Future<void> _ensureInit(Object engine) async {
    if (_initialized || _initializing) return;
    setState(() => _initializing = true);
    await (engine as dynamic).init();
    // After engine init, push current LAB state immediately so sound matches LAB from the start
    try {
      final effects = ref.read(audioEffectsProvider).toMap();
      // Ensure filter.enabled defaults to false unless explicitly set
      if (effects['filter'] is Map && (effects['filter']['enabled'] == null)) {
        effects['filter']['enabled'] = false;
      }
      final scale = ref.read(scaleFilterProvider).toJson();
      final zones = ref.read(zonesProvider).map((z) => z.toMap()).toList();
      final midi = ref.read(midiRulesProvider).toMap();

      (engine as dynamic).updateAudioEffects(effects);
      (engine as dynamic).updateScaleFilterConfig(scale);
      (engine as dynamic).updateZonesConfig(zones);
      (engine as dynamic).updateMidiRules(midi);
    } catch (_) {}
    setState(() {
      _initializing = false;
      _initialized = true;
    });
  }

  void _showTimerSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0F0F1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sleep timer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _TimerChip(label: '15m', minutes: 15, onSelect: _startSleepTimer),
                  _TimerChip(label: '30m', minutes: 30, onSelect: _startSleepTimer),
                  _TimerChip(label: '45m', minutes: 45, onSelect: _startSleepTimer),
                  _TimerChip(label: '60m', minutes: 60, onSelect: _startSleepTimer),
                  _TimerChip(label: 'Cancel', minutes: 0, onSelect: (_) => _cancelSleepTimer()),
                ],
              ),
              const SizedBox(height: 8),
              if (_sleepEndsAt != null)
                Text('Ends in ${_formatRemaining()}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _startSleepTimer(int minutes) {
    if (!mounted) return;
    Navigator.of(context).pop();
    if (minutes <= 0) {
      _cancelSleepTimer();
      return;
    }
    _sleepTimer?.cancel();
    _sleepEndsAt = DateTime.now().add(Duration(minutes: minutes));
    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_sleepEndsAt == null) return;
      if (DateTime.now().isAfter(_sleepEndsAt!)) {
        _cancelSleepTimer();
        // Stop engine
        final engine = ref.read(audioEngineProvider);
        (engine as dynamic).stopAll();
      } else {
        setState(() {});
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Timer set for ${minutes}m'),
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }

  void _cancelSleepTimer({bool showSnackBar = true}) {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepEndsAt = null;
    if (showSnackBar && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Timer canceled'), duration: Duration(milliseconds: 1000)),
      );
    }
    setState(() {});
  }

  String _formatRemaining() {
    if (_sleepEndsAt == null) return '';
    final diff = _sleepEndsAt!.difference(DateTime.now());
    final m = diff.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = diff.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF1A1A2E);
    const accent = Color(0xFF10D38F);
    final size = MediaQuery.of(context).size;
    final engine = ref.watch(audioEngineProvider);
    // Prime the engine with Lab defaults so sound matches LAB immediately
    // Reading these providers triggers their notifiers to push initial configs
    ref.watch(audioEffectsProvider);
    ref.watch(scaleFilterProvider);
    ref.watch(zonesProvider);
    ref.watch(midiRulesProvider);
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(''),
        actions: [
          if (ref.watch(isLabUnlockedProvider))
            IconButton(
              icon: const Icon(Icons.science),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LabScreen()),
                );
              },
            ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              SizedBox(
                width: size.width,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/LiveRootsLogo.png',
                      width: size.width * 0.55,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              if (_initializing)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              _PresetList(
                presets: const ['Deep-Focus', 'Creative-Flow', 'Relaxation', 'Night-Drive', 'Meditation', 'Study', 'Workout'],
                engine: engine,
                onAnyPress: () => _ensureInit(engine),
              ),

              SizedBox(height: size.height * 0.12),

              // Bottom controls (Play enables MIDI listener; Stop stops all)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _showTimerSheet,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const _CircleControl(icon: Icons.timer_outlined),
                        if (_sleepEndsAt != null)
                          Positioned(
                            bottom: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10D38F).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _formatRemaining(),
                                style: const TextStyle(color: Colors.white70, fontSize: 10),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  GestureDetector(
                    onTap: () async {
                      await _ensureInit(engine);
                      await (engine as dynamic).play();
                    },
                    child: const _CircleControl(icon: Icons.play_arrow_rounded, primary: true),
                  ),
                  const SizedBox(width: 32),
                  GestureDetector(
                    onTap: () async {
                      await _ensureInit(engine);
                      (engine as dynamic).stopAll();
                      // Cancel any active sleep timer
                      _cancelSleepTimer(showSnackBar: false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Stopped'),
                            duration: Duration(milliseconds: 800),
                          ),
                        );
                      }
                    },
                    child: const _CircleControl(icon: Icons.stop_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetList extends ConsumerStatefulWidget {
  const _PresetList({
    required this.presets, 
    required this.engine, 
    required this.onAnyPress,
  });
  final List<String> presets;
  final Object engine;
  final Future<void> Function() onAnyPress;

  @override
  ConsumerState<_PresetList> createState() => _PresetListState();
}

class _PresetListState extends ConsumerState<_PresetList> {
  String? _activePreset;

  @override
  void initState() {
    super.initState();
    // Set the first preset as active immediately
    if (widget.presets.isNotEmpty) {
      _activePreset = widget.presets.first;
    }
    // Load the first preset by default
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.presets.isNotEmpty) {
        await widget.onAnyPress();
        final ok = await (widget.engine as dynamic).loadPreset(widget.presets.first) as bool;
        if (ok) {
          setState(() {
            _activePreset = widget.presets.first;
          });
          // Also set in provider for Lab
          ref.read(activePresetProvider.notifier).setActivePreset(widget.presets.first);
          print('Active preset set to: ${widget.presets.first}');
          // Re-apply LAB state after preset is loaded so it matches LAB immediately
          try {
            final effects = ref.read(audioEffectsProvider).toMap();
            final scale = ref.read(scaleFilterProvider).toJson();
            final zones = ref.read(zonesProvider).map((z) => z.toMap()).toList();
            final midi = ref.read(midiRulesProvider).toMap();
            (widget.engine as dynamic).updateAudioEffects(effects);
            (widget.engine as dynamic).updateScaleFilterConfig(scale);
            (widget.engine as dynamic).updateZonesConfig(zones);
            (widget.engine as dynamic).updateMidiRules(midi);
          } catch (_) {}
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the active preset from the provider
    final activePresetFromProvider = ref.watch(activePresetProvider);
    print('Current active preset (provider): $activePresetFromProvider');
    
    return Column(
      children: [
        for (final p in widget.presets) ...[
          StyledPresetButton(
            label: p.replaceAll('-', ' '),
            isActive: activePresetFromProvider == p,
            comingSoon: const {
              'Night-Drive': true,
              'Relaxation': true,
              'Study': true,
              'Workout': true,
            }[p] == true,
            onPressed: () async {
              if (const {
                'Night-Drive': true,
                'Relaxation': true,
                'Study': true,
                'Workout': true,
              }[p] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color(0xFF0F0F1A),
                    content: Text(
                      'Coming soon',
                      style: TextStyle(color: Colors.white70),
                    ),
                    duration: Duration(milliseconds: 1200),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              print('Button pressed for preset: $p');
              await widget.onAnyPress();
              // Set active preset immediately for UI feedback
              ref.read(activePresetProvider.notifier).setActivePreset(p);
              print('Active preset set to: $p');
              
              // ignore: avoid_dynamic_calls
              final ok = await (widget.engine as dynamic).loadPreset(p) as bool;
              if (ok) {
                print('Preset loaded successfully: $p');
                // Ensure LAB processing is re-applied right after preset load
                try {
                  final effects = ref.read(audioEffectsProvider).toMap();
                  final scale = ref.read(scaleFilterProvider).toJson();
                  final zones = ref.read(zonesProvider).map((z) => z.toMap()).toList();
                  final midi = ref.read(midiRulesProvider).toMap();
                  (widget.engine as dynamic).updateAudioEffects(effects);
                  (widget.engine as dynamic).updateScaleFilterConfig(scale);
                  (widget.engine as dynamic).updateZonesConfig(zones);
                  (widget.engine as dynamic).updateMidiRules(midi);
                } catch (_) {}
              } else {
                print('Failed to load preset: $p');
              }
            },
          ),
          const SizedBox(height: 12),
        ]
      ],
    );
  }
}

class _CircleControl extends StatelessWidget {
  const _CircleControl({required this.icon, this.primary = false});
  final IconData icon;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final color = primary ? const Color(0xFF10D38F) : Colors.white24;
    final iconColor = primary ? const Color(0xFF0B2D24) : Colors.white;
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: primary ? const Color(0xFF10D38F).withOpacity(0.45) : Colors.black.withOpacity(0.25),
            blurRadius: 20,
          ),
        ],
      ),
      child: Icon(icon, size: 32, color: iconColor),
    );
  }
}

class _TimerChip extends StatelessWidget {
  const _TimerChip({required this.label, required this.minutes, required this.onSelect});
  final String label;
  final int minutes;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onSelect(minutes),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF10D38F),
        foregroundColor: const Color(0xFF0B2D24),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
