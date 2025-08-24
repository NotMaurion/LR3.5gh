import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/scale_filter_state.dart';
import '../../../state/active_preset_provider.dart';

class ScalesPanel extends ConsumerWidget {
  const ScalesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaleState = ref.watch(scaleFilterProvider);
    final notifier = ref.read(scaleFilterProvider.notifier);
    final activePreset = ref.watch(activePresetProvider);

    if (activePreset == null) {
      return const Center(
        child: Text(
          'No preset selected. Please select a preset from the main screen.',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active preset indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF10D38F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF10D38F).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.music_note,
                  color: const Color(0xFF10D38F),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Fine-tuning: ${activePreset.replaceAll('-', ' ')}',
                  style: const TextStyle(
                    color: Color(0xFF10D38F),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Reset Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Scale & Filter Configuration',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  notifier.setEnabled(true);
                  notifier.setRoot('C');
                  notifier.setMode('PENTATONIC_MAJOR');
                  notifier.setMinOctave(2);
                  notifier.setMaxOctave(6);
                },
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'Reset',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10D38F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Enable Scale Filter Switch
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: SwitchListTile(
              title: const Text(
                'Enable Scale Filter',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'Filter notes to specific musical scales',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              value: scaleState.enabled,
              onChanged: notifier.setEnabled,
              activeColor: const Color(0xFF10D38F),
            ),
          ),
          const SizedBox(height: 16),
          
          if (scaleState.enabled) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Scale Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Scale Root Dropdown
                  _buildDropdownSection(
                    title: 'Scale Root',
                    value: scaleState.root,
                    items: const ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'],
                    onChanged: (value) {
                      if (value != null) {
                        notifier.setRoot(value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Scale Mode Dropdown
                  _buildDropdownSection(
                    title: 'Scale Mode',
                    value: scaleState.mode,
                    items: const [
                      'CHROMATIC',
                      'PENTATONIC_MAJOR',
                      'PENTATONIC_MINOR',
                      'MAJOR',
                      'MINOR',
                      'DORIAN',
                      'MIXOLYDIAN',
                      'LYDIAN',
                      'PHRYGIAN',
                      'LOCRIAN',
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        notifier.setMode(value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Min Octave Slider
                  _buildSliderSection(
                    context: context,
                    title: 'Min Octave',
                    value: scaleState.minOctave.toDouble(),
                    min: 0.0,
                    max: 10.0,
                    divisions: 10,
                    label: '${scaleState.minOctave}',
                    onChanged: (value) => notifier.setMinOctave(value.round()),
                  ),
                  const SizedBox(height: 16),
                  
                  // Max Octave Slider
                  _buildSliderSection(
                    context: context,
                    title: 'Max Octave',
                    value: scaleState.maxOctave.toDouble(),
                    min: 0.0,
                    max: 10.0,
                    divisions: 10,
                    label: '${scaleState.maxOctave}',
                    onChanged: (value) => notifier.setMaxOctave(value.round()),
                  ),
                ],
              ),
            ),
          ],
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
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                onChanged: onChanged,
                activeColor: const Color(0xFF10D38F),
                inactiveColor: Colors.white.withOpacity(0.3),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF10D38F),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            dropdownColor: const Color(0xFF1A1A2E),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            underline: Container(),
            isExpanded: true,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
