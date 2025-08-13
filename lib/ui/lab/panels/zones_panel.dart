import 'package:flutter/material.dart';

class ZonesPanel extends StatefulWidget {
  const ZonesPanel({super.key});

  @override
  State<ZonesPanel> createState() => _ZonesPanelState();
}

class _ZonesPanelState extends State<ZonesPanel> {
  double _minNote = 24; // C2
  double _maxNote = 47; // B2
  String _baseNote = 'C';
  double _volume = 0.85;
  double _probability = 1.0;

  static const List<String> _noteNames = <String>[
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bass Zone', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          // Min Note / Max Note
          _LabeledSlider(
            label: 'Min Note: ${_minNote.round()}',
            value: _minNote,
            min: 0,
            max: 127,
            onChanged: (v) => setState(() => _minNote = v <= _maxNote ? v : _maxNote),
          ),
          _LabeledSlider(
            label: 'Max Note: ${_maxNote.round()}',
            value: _maxNote,
            min: 0,
            max: 127,
            onChanged: (v) => setState(() => _maxNote = v >= _minNote ? v : _minNote),
          ),
          const SizedBox(height: 8),

          // Base Note
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Base Note',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _baseNote,
                isExpanded: true,
                items: _noteNames
                    .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                    .toList(),
                onChanged: (v) => setState(() => _baseNote = v ?? _baseNote),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Volume
          _LabeledSlider(
            label: 'Volume: ${_volume.toStringAsFixed(2)}',
            value: _volume,
            min: 0,
            max: 1,
            onChanged: (v) => setState(() => _volume = v),
          ),

          // Probability
          _LabeledSlider(
            label: 'Probability: ${_probability.toStringAsFixed(2)}',
            value: _probability,
            min: 0,
            max: 1,
            onChanged: (v) => setState(() => _probability = v),
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


