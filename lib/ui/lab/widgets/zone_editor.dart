import 'package:flutter/material.dart';

class ZoneEditor extends StatelessWidget {
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

  final String title;
  final int minNote;
  final int maxNote;
  final String baseNote;
  final double volume;
  final double probability;
  final ValueChanged<int> onMinChanged;
  final ValueChanged<int> onMaxChanged;
  final ValueChanged<String> onBaseChanged;
  final ValueChanged<double> onVolumeChanged;
  final ValueChanged<double> onProbabilityChanged;

  static const List<String> _noteNames = <String>[
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _LabeledSlider(
            label: 'Min Note: $minNote',
            value: minNote.toDouble(),
            min: 0,
            max: 127,
            onChanged: (v) => onMinChanged(v.round()),
          ),
          _LabeledSlider(
            label: 'Max Note: $maxNote',
            value: maxNote.toDouble(),
            min: 0,
            max: 127,
            onChanged: (v) => onMaxChanged(v.round()),
          ),
          const SizedBox(height: 8),
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Base Note',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: baseNote,
                isExpanded: true,
                items: _noteNames.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
                onChanged: (v) => onBaseChanged(v ?? baseNote),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _LabeledSlider(
            label: 'Volume: ${volume.toStringAsFixed(2)}',
            value: volume,
            min: 0,
            max: 1,
            onChanged: onVolumeChanged,
          ),
          _LabeledSlider(
            label: 'Probability: ${probability.toStringAsFixed(2)}',
            value: probability,
            min: 0,
            max: 1,
            onChanged: onProbabilityChanged,
          ),
        ],
      ),
    );
  }
}

class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).round(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}


