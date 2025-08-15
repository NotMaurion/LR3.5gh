import 'package:flutter/material.dart';

class ZoneEditor extends StatelessWidget {
  final String title;
  final double minNote;
  final double maxNote;
  final String baseNote;
  final double volume;
  final double probability;
  final ValueChanged<double> onMinChanged;
  final ValueChanged<double> onMaxChanged;
  final ValueChanged<String> onBaseChanged;
  final ValueChanged<double> onVolumeChanged;
  final ValueChanged<double> onProbabilityChanged;

  const ZoneEditor({
    super.key,
    required this.title,
    required this.minNote,
    required this.maxNote,
    required this.baseNote,
    required this.volume,
    required this.probability,
    required this.onMinChanged,
    required this.onMaxChanged,
    required this.onBaseChanged,
    required this.onVolumeChanged,
    required this.onProbabilityChanged,
  });

  final List<String> _noteOptions = const [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Min Note Slider
          _buildSliderSection(
            context: context,
            title: 'Min Note',
            value: minNote,
            min: 0.0,
            max: 127.0,
            divisions: 127,
            label: '${minNote.round()}',
            onChanged: onMinChanged,
          ),
          const SizedBox(height: 16),

          // Max Note Slider
          _buildSliderSection(
            context: context,
            title: 'Max Note',
            value: maxNote,
            min: 0.0,
            max: 127.0,
            divisions: 127,
            label: '${maxNote.round()}',
            onChanged: onMaxChanged,
          ),
          const SizedBox(height: 16),

          // Base Note Dropdown
          _buildDropdownSection(
            title: 'Base Note',
            value: baseNote,
            items: _noteOptions,
            onChanged: (value) {
              if (value != null) {
                onBaseChanged(value);
              }
            },
          ),
          const SizedBox(height: 16),

          // Volume Slider
          _buildSliderSection(
            context: context,
            title: 'Volume',
            value: volume,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            label: '${(volume * 100).round()}%',
            onChanged: onVolumeChanged,
          ),
          const SizedBox(height: 16),

          // Probability Slider
          _buildSliderSection(
            context: context,
            title: 'Probability',
            value: probability,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            label: '${(probability * 100).round()}%',
            onChanged: onProbabilityChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSection({
    required BuildContext context,
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF10D38F),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF10D38F),
            inactiveTrackColor: Colors.white24,
            thumbColor: const Color(0xFF10D38F),
            overlayColor: const Color(0xFF10D38F).withOpacity(0.2),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownSection({
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: const Color(0xFF0F0F1A),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              iconEnabledColor: Colors.white,
              isExpanded: true,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
