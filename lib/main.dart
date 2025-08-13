import 'package:flutter/material.dart';

void main() {
  runApp(const LiveRootsApp());
}

class LiveRootsApp extends StatelessWidget {
  const LiveRootsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const PlayerScreen(),
    );
  }
}

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF1A1A2E);
    const accent = Color(0xFF10D38F);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: background,
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
                      'images/Logo Live Roots Lab blanco fondo transparente-01.png',
                      width: size.width * 0.55,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Preset buttons
              _PresetButton(text: 'Creative Flow', active: true, glowColor: accent),
              const SizedBox(height: 12),
              const _PresetButton(text: 'Deep Focus'),
              const SizedBox(height: 12),
              const _PresetButton(text: 'Relaxation'),
              const SizedBox(height: 12),
              const _PresetButton(text: 'Night Drive'),

              SizedBox(height: size.height * 0.12),

              // Bottom controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _CircleControl(icon: Icons.timer_outlined),
                  SizedBox(width: 32),
                  _CircleControl(icon: Icons.play_arrow_rounded, primary: true),
                  SizedBox(width: 32),
                  _CircleControl(icon: Icons.stop_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  const _PresetButton({required this.text, this.active = false, this.glowColor});
  final String text;
  final bool active;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.white.withOpacity(0.08);
    final borderColor = active ? (glowColor ?? const Color(0xFF10D38F)) : Colors.white24;
    final shadow = active
        ? [
            BoxShadow(
              color: (glowColor ?? const Color(0xFF10D38F)).withOpacity(0.45),
              blurRadius: 24,
              spreadRadius: 1,
            )
          ]
        : [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 16,
            )
          ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: shadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Icon(Icons.graphic_eq_rounded, color: Colors.white.withOpacity(0.9)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.9)),
        ],
      ),
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
