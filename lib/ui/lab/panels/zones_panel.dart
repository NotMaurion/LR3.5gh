import 'package:flutter/material.dart';

class ZonesPanel extends StatefulWidget {
  const ZonesPanel({super.key});

  @override
  State<ZonesPanel> createState() => _ZonesPanelState();
}

class _ZonesPanelState extends State<ZonesPanel> {
  // Temporary state for UI demonstration
  double _minNote = 0.0;
  double _maxNote = 127.0;
  String _baseNote = 'C';
  double _volume = 0.5;
  double _probability = 0.5;

  final List<String> _noteOptions = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Bass Zone',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Min Note Slider
          _buildSliderSection(
            title: 'Min Note',
            value: _minNote,
            min: 0.0,
            max: 127.0,
            divisions: 127,
            label: '${_minNote.round()}',
            onChanged: (value) {
              setState(() {
                _minNote = value;
                if (_minNote > _maxNote) {
                  _maxNote = _minNote;
                }
              });
            },
          ),
          const SizedBox(height: 20),

          // Max Note Slider
          _buildSliderSection(
            title: 'Max Note',
            value: _maxNote,
            min: 0.0,
            max: 127.0,
            divisions: 127,
            label: '${_maxNote.round()}',
            onChanged: (value) {
              setState(() {
                _maxNote = value;
                if (_maxNote < _minNote) {
                  _minNote = _maxNote;
                }
              });
            },
          ),
          const SizedBox(height: 20),

          // Base Note Dropdown
          _buildDropdownSection(
            title: 'Base Note',
            value: _baseNote,
            items: _noteOptions,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _baseNote = value;
                });
              }
            },
          ),
          const SizedBox(height: 20),

          // Volume Slider
          _buildSliderSection(
            title: 'Volume',
            value: _volume,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            label: '${(_volume * 100).round()}%',
            onChanged: (value) {
              setState(() {
                _volume = value;
              });
            },
          ),
          const SizedBox(height: 20),

          // Probability Slider
          _buildSliderSection(
            title: 'Probability',
            value: _probability,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            label: '${(_probability * 100).round()}%',
            onChanged: (value) {
              setState(() {
                _probability = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSection({
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
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10D38F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF10D38F),
            inactiveTrackColor: Colors.white24,
            thumbColor: const Color(0xFF10D38F),
            overlayColor: const Color(0xFF10D38F).withOpacity(0.2),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
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
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: const Color(0xFF0F0F1A),
              style: const TextStyle(color: Colors.white, fontSize: 16),
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


