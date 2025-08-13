import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _timerEndAction = 'Stops sounds';

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
              child: Image.asset(
                'assets/images/LiveRootsLogo.png',
                width: MediaQuery.of(context).size.width * 0.5,
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


