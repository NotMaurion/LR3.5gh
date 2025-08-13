import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'widgets/styled_preset_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'audio/audio_providers.dart';
import 'ui/lab_screen.dart';
import 'ui/settings_screen.dart';

void main() {
  runApp(const ProviderScope(child: LiveRootsApp()));
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

  Future<void> _ensureInit(Object engine) async {
    if (_initialized || _initializing) return;
    setState(() => _initializing = true);
    await (engine as dynamic).init();
    setState(() {
      _initializing = false;
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF1A1A2E);
    const accent = Color(0xFF10D38F);
    final size = MediaQuery.of(context).size;
    final engine = ref.watch(audioEngineProvider);
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
                presets: const ['Creative-Flow', 'Deep-Focus', 'Relaxation', 'Night-Drive'],
                engine: engine,
                onAnyPress: () => _ensureInit(engine),
              ),

              SizedBox(height: size.height * 0.12),

              // Bottom controls (Play enables MIDI listener; Stop stops all)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _CircleControl(icon: Icons.timer_outlined),
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

class _PresetList extends StatefulWidget {
  const _PresetList({required this.presets, required this.engine, required this.onAnyPress});
  final List<String> presets;
  final Object engine;
  final Future<void> Function() onAnyPress;

  @override
  State<_PresetList> createState() => _PresetListState();
}

class _PresetListState extends State<_PresetList> {
  String? _active;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final p in widget.presets) ...[
          StyledPresetButton(
            label: p.replaceAll('-', ' '),
            isActive: _active == p,
            onPressed: () async {
              await widget.onAnyPress();
              // ignore: avoid_dynamic_calls
              final ok = await (widget.engine as dynamic).loadPreset(p) as bool;
              if (ok) setState(() => _active = p);
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
