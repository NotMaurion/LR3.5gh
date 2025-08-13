import 'package:flutter/material.dart';

class StyledPresetButton extends StatelessWidget {
  const StyledPresetButton({super.key, required this.label, required this.isActive, required this.onPressed});

  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final Color baseBorder = isActive ? const Color(0xFF10D38F) : Colors.white24;
    final List<BoxShadow> glow = isActive
        ? [
            BoxShadow(
              color: const Color(0xFF10D38F).withOpacity(0.45),
              blurRadius: 24,
              spreadRadius: 1,
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 16,
            ),
          ];

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: baseBorder, width: 1.5),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.06),
              Colors.white.withOpacity(0.02),
            ],
          ),
          boxShadow: glow,
        ),
        child: Row(
          children: [
            Icon(Icons.graphic_eq_rounded, color: Colors.white.withOpacity(0.9)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.9)),
          ],
        ),
      ),
    );
  }
}


