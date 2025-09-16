import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'audio/audio_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: LiveRootsApp()));
}

class LiveRootsApp extends StatelessWidget {
  const LiveRootsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFF0F0F23),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
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
  String? _selectedPreset;
  bool _isLoading = false;
  bool _audioEngineReady = false;

  final List<String> _presets = [
    'Creative-Flow',
    'Deep-Focus', 
    'Relaxation',
    'Night-Drive'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize audio engine on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAudioEngine();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initializeAudioEngine() async {
    try {
      final engine = ref.read(audioEngineProvider);
      await (engine as dynamic).init();
      setState(() {
        _audioEngineReady = true;
      });
      print('Audio engine initialized successfully');
    } catch (e) {
      print('Error initializing audio engine: $e');
    }
  }

  Future<void> _selectPreset(String preset) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final engine = ref.read(audioEngineProvider);
      final success = await (engine as dynamic).loadPreset(preset);
      
      if (success) {
        setState(() {
          _selectedPreset = preset;
        });
        print('Preset loaded successfully: $preset');
      } else {
        print('Failed to load preset: $preset');
      }
    } catch (e) {
      print('Error loading preset: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: SafeArea(
        child: Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent && _selectedPreset != null) {
              // Test audio with keyboard input
              if (event.logicalKey.keyLabel == 'Space') {
                try {
                  final engine = ref.read(audioEngineProvider);
                  (engine as dynamic).playNote(60, 0.5); // Play middle C
                  print('Keyboard test note played: Middle C (note 60)');
                } catch (e) {
                  print('Error playing keyboard test note: $e');
                }
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
          child: Column(
            children: [
              // Large central LiveRoots Lab logo
              Expanded(
                flex: 3,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF10D38F),
                              Color(0xFF0BA870),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10D38F).withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 8,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'LiveRoots\nLab',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF0B2D24),
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
              
              // Select Preset title
              Column(
                children: [
                  const Text(
                    'Select Preset',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _audioEngineReady ? const Color(0xFF10D38F) : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _audioEngineReady ? 'Audio Engine Ready' : 'Initializing Audio...',
                        style: TextStyle(
                          color: _audioEngineReady ? const Color(0xFF10D38F) : Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Preset list with radio buttons
              Expanded(
                flex: 4,
                child: ListView.builder(
                  itemCount: _presets.length,
                  itemBuilder: (context, index) {
                    final preset = _presets[index];
                    final isSelected = _selectedPreset == preset;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFF10D38F).withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected 
                              ? const Color(0xFF10D38F)
                              : Colors.white.withOpacity(0.15),
                          width: 2,
                        ),
                      ),
                      child: RadioListTile<String>(
                        value: preset,
                        groupValue: _selectedPreset,
                        onChanged: _isLoading ? null : (value) {
                          if (value != null) {
                            _selectPreset(value);
                          }
                        },
                        activeColor: const Color(0xFF10D38F),
                        title: Text(
                          preset.replaceAll('-', ' '),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            letterSpacing: -0.3,
                          ),
                        ),
                        secondary: isSelected
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10D38F),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF10D38F).withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'ACTIVE',
                                  style: TextStyle(
                                    color: Color(0xFF0B2D24),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Loading indicator
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10D38F)),
                    strokeWidth: 3,
                  ),
                ),
              
              // Test audio button (for debugging)
              if (_selectedPreset != null)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            final engine = ref.read(audioEngineProvider);
                            (engine as dynamic).playNote(60, 0.5); // Play middle C
                            print('Test note played: Middle C (note 60)');
                          } catch (e) {
                            print('Error playing test note: $e');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10D38F),
                          foregroundColor: const Color(0xFF0B2D24),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Test Audio',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      'Press SPACE or click Test Audio to play a note',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              
              // Bottom spacing
              const SizedBox(height: 40),
            ],
          ),
        ),
        ),
      ),
    );
  }
}