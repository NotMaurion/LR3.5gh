import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../audio/audio_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _timerEndAction = 'Stops sounds';
  int _tapCount = 0;
  static const List<String> _konamiSequence = <String>[
    'U','U','D','D','L','R','L','R','B','A'
  ];
  int _konamiIndex = 0;

  void _onLogoTap() {
    setState(() {
      _tapCount += 1;
    });
    if (_tapCount >= 7) {
      _tapCount = 0;
      _showKonamiOverlay();
    }
  }

  void _handleKonamiInput(String input, void Function(void Function()) setLocalState) {
    if (_konamiSequence[_konamiIndex] == input) {
      setLocalState(() => _konamiIndex += 1);
      if (_konamiIndex >= _konamiSequence.length) {
        ref.read(isLabUnlockedProvider.notifier).state = true;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lab unlocked!')),
        );
      }
    } else {
      setLocalState(() => _konamiIndex = 0);
    }
  }

  Future<void> _showKonamiOverlay() async {
    _konamiIndex = 0;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocalState) {
            return Dialog(
              backgroundColor: const Color(0xFF0F0F1A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Enter Konami Code',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${_konamiIndex}/${_konamiSequence.length}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
                          onPressed: () => _handleKonamiInput('U', setLocalState),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_left, color: Colors.white),
                          onPressed: () => _handleKonamiInput('L', setLocalState),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                          onPressed: () => _handleKonamiInput('D', setLocalState),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_right, color: Colors.white),
                          onPressed: () => _handleKonamiInput('R', setLocalState),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => _handleKonamiInput('B', setLocalState),
                          child: const Text('B'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () => _handleKonamiInput('A', setLocalState),
                          child: const Text('A'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF1A1A2E);
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _onLogoTap,
                child: Image.asset(
                  'assets/images/LiveRootsLogo.png',
                  width: MediaQuery.of(context).size.width * 0.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Cuando el temporizador termine:',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _timerEndAction,
                  dropdownColor: const Color(0xFF0F0F1A),
                  style: const TextStyle(color: Colors.white),
                  iconEnabledColor: Colors.white,
                  items: const [
                    DropdownMenuItem(
                      value: 'Stops sounds',
                      child: Text('Stops sounds'),
                    ),
                    DropdownMenuItem(
                      value: 'Close app',
                      child: Text('Close app'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _timerEndAction = v);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


