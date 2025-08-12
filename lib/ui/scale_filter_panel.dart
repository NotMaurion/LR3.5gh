import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/scale_filter_state.dart';

class ScaleFilterPanel extends ConsumerWidget {
  const ScaleFilterPanel({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(scaleFilterProvider);
    final notifier = ref.read(scaleFilterProvider.notifier);
    // TODO: connect to engine in next step
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
              value: state.enabled,
              onChanged: notifier.setEnabled,
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
                        value: state.root,
                        isExpanded: true,
                        items: noteRoots
                            .map((r) => DropdownMenuItem<String>(
                                  value: r,
                                  child: Text(r),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          notifier.setRoot(value);
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
                        value: state.mode,
                        isExpanded: true,
                        items: scaleModes
                            .map((m) => DropdownMenuItem<String>(
                                  value: m,
                                  child: Text(m),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          notifier.setMode(value);
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
                    value: state.minOctave.toDouble().clamp(-1, state.maxOctave.toDouble()),
                    label: state.minOctave.toString(),
                    onChanged: (value) {
                      notifier.setMinOctave(value.round());
                    },
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(state.minOctave.toString()),
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
                    value: state.maxOctave.toDouble().clamp(state.minOctave.toDouble(), 9),
                    label: state.maxOctave.toString(),
                    onChanged: (value) {
                      notifier.setMaxOctave(value.round());
                    },
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(state.maxOctave.toString()),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}


