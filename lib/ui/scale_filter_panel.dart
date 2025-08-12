import 'package:flutter/material.dart';

class ScaleFilterPanel extends StatefulWidget {
  const ScaleFilterPanel({super.key});

  @override
  State<ScaleFilterPanel> createState() => _ScaleFilterPanelState();
}

class _ScaleFilterPanelState extends State<ScaleFilterPanel> {
  bool isFilterEnabled = true;
  String selectedRoot = 'C';
  String selectedMode = 'PENTATONIC_MAJOR';
  double minOctave = 2;
  double maxOctave = 6;

  static const List<String> noteRoots = <String>[
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',
  ];

  static const List<String> scaleModes = <String>[
    'CHROMATIC',
    'PENTATONIC_MAJOR',
    'PENTATONIC_MINOR',
    'MAJOR',
    'MINOR',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scale and Filter Configuration',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            // Enable Scale Filter
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enable Scale Filter'),
              value: isFilterEnabled,
              onChanged: (value) => setState(() => isFilterEnabled = value),
            ),
            const SizedBox(height: 8),

            // Scale Root and Mode
            Row(
              children: [
                Expanded(
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Scale Root',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedRoot,
                        isExpanded: true,
                        items: noteRoots
                            .map((r) => DropdownMenuItem<String>(
                                  value: r,
                                  child: Text(r),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => selectedRoot = value);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Scale Mode',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedMode,
                        isExpanded: true,
                        items: scaleModes
                            .map((m) => DropdownMenuItem<String>(
                                  value: m,
                                  child: Text(m),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => selectedMode = value);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            // Min Octave
            Row(
              children: [
                const SizedBox(
                  width: 100,
                  child: Text('Min Octave'),
                ),
                Expanded(
                  child: Slider(
                    min: -1,
                    max: 9,
                    divisions: 10,
                    value: minOctave.clamp(-1, maxOctave).toDouble(),
                    label: minOctave.toStringAsFixed(0),
                    onChanged: (value) {
                      setState(() => minOctave = value <= maxOctave ? value : maxOctave);
                    },
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(minOctave.toStringAsFixed(0)),
                )
              ],
            ),

            // Max Octave
            Row(
              children: [
                const SizedBox(
                  width: 100,
                  child: Text('Max Octave'),
                ),
                Expanded(
                  child: Slider(
                    min: -1,
                    max: 9,
                    divisions: 10,
                    value: maxOctave.clamp(minOctave, 9).toDouble(),
                    label: maxOctave.toStringAsFixed(0),
                    onChanged: (value) {
                      setState(() => maxOctave = value >= minOctave ? value : minOctave);
                    },
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(maxOctave.toStringAsFixed(0)),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}


