import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/midi_rules_state.dart';
import '../../../state/active_preset_provider.dart';

class RulesPanel extends ConsumerWidget {
  const RulesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesState = ref.watch(midiRulesProvider);
    final rulesNotifier = ref.read(midiRulesProvider.notifier);
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MIDI Processing Rules',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => rulesNotifier.resetAllRules(),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Reset All', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10D38F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Velocity Rule Section
          _buildVelocitySection(context, rulesState, rulesNotifier),
          const SizedBox(height: 16),

          // Note Transformation Section
          _buildNoteTransformationSection(context, rulesState, rulesNotifier),
          const SizedBox(height: 16),

          // Arpeggiator Section
          _buildArpeggiatorSection(context, rulesState, rulesNotifier),
          const SizedBox(height: 16),

          // Quantization Section
          _buildQuantizationSection(context, rulesState, rulesNotifier),
          const SizedBox(height: 16),

          // General MIDI Settings
          _buildGeneralMidiSection(context, rulesState, rulesNotifier),
        ],
      ),
    );
  }

  Widget _buildVelocitySection(BuildContext context, MidiRulesState state, MidiRulesNotifier notifier) {
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
          Row(
            children: [
              const Icon(Icons.speed, color: Color(0xFF10D38F), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Velocity Mapping',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Enable Velocity Mapping', style: TextStyle(color: Colors.white)),
            value: state.velocityRule.enabled,
            onChanged: notifier.setVelocityEnabled,
            activeColor: const Color(0xFF10D38F),
          ),
          if (state.velocityRule.enabled) ...[
            const SizedBox(height: 8),
            _buildSliderSection(
              context: context,
              title: 'Min Velocity',
              value: state.velocityRule.minVelocity,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              label: '${(state.velocityRule.minVelocity * 100).round()}%',
              onChanged: (value) => notifier.setVelocityRange(value, state.velocityRule.maxVelocity),
            ),
            const SizedBox(height: 8),
            _buildSliderSection(
              context: context,
              title: 'Max Velocity',
              value: state.velocityRule.maxVelocity,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              label: '${(state.velocityRule.maxVelocity * 100).round()}%',
              onChanged: (value) => notifier.setVelocityRange(state.velocityRule.minVelocity, value),
            ),
            const SizedBox(height: 8),
            _buildDropdownSection(
              title: 'Curve',
              value: state.velocityRule.curve,
              items: const ['linear', 'exponential', 'logarithmic'],
              onChanged: notifier.setVelocityCurve,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoteTransformationSection(BuildContext context, MidiRulesState state, MidiRulesNotifier notifier) {
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
          Row(
            children: [
              const Icon(Icons.transform, color: Color(0xFF10D38F), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Note Transformation',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Enable Note Transformation', style: TextStyle(color: Colors.white)),
            value: state.noteTransformation.enabled,
            onChanged: notifier.setNoteTransformationEnabled,
            activeColor: const Color(0xFF10D38F),
          ),
          if (state.noteTransformation.enabled) ...[
            const SizedBox(height: 8),
            _buildSliderSection(
              context: context,
              title: 'Transpose',
              value: state.noteTransformation.transpose.toDouble(),
              min: -12.0,
              max: 12.0,
              divisions: 24,
              label: '${state.noteTransformation.transpose} semitones',
              onChanged: (value) => notifier.setTranspose(value.round()),
            ),
            const SizedBox(height: 8),
            _buildSliderSection(
              context: context,
              title: 'Octave Shift',
              value: state.noteTransformation.octaveShift,
              min: -2.0,
              max: 2.0,
              divisions: 8,
              label: '${state.noteTransformation.octaveShift.toStringAsFixed(1)} octaves',
              onChanged: notifier.setOctaveShift,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Harmonize', style: TextStyle(color: Colors.white)),
              value: state.noteTransformation.harmonize,
              onChanged: notifier.setHarmonize,
              activeColor: const Color(0xFF10D38F),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildArpeggiatorSection(BuildContext context, MidiRulesState state, MidiRulesNotifier notifier) {
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
          Row(
            children: [
              const Icon(Icons.repeat, color: Color(0xFF10D38F), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Arpeggiator',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Enable Arpeggiator', style: TextStyle(color: Colors.white)),
            value: state.arpeggiator.enabled,
            onChanged: notifier.setArpeggiatorEnabled,
            activeColor: const Color(0xFF10D38F),
          ),
          if (state.arpeggiator.enabled) ...[
            const SizedBox(height: 8),
            _buildDropdownSection(
              title: 'Pattern',
              value: state.arpeggiator.pattern,
              items: const ['up', 'down', 'updown', 'random'],
              onChanged: notifier.setArpeggiatorPattern,
            ),
            const SizedBox(height: 8),
            _buildSliderSection(
              context: context,
              title: 'Rate',
              value: state.arpeggiator.rate,
              min: 0.1,
              max: 32.0,
              divisions: 100,
              label: '${state.arpeggiator.rate.toStringAsFixed(1)} notes/sec',
              onChanged: notifier.setArpeggiatorRate,
            ),
            const SizedBox(height: 8),
            _buildSliderSection(
              context: context,
              title: 'Octaves',
              value: state.arpeggiator.octaves.toDouble(),
              min: 1.0,
              max: 4.0,
              divisions: 3,
              label: '${state.arpeggiator.octaves}',
              onChanged: (value) => notifier.setArpeggiatorOctaves(value.round()),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Sync to Tempo', style: TextStyle(color: Colors.white)),
              value: state.arpeggiator.syncToTempo,
              onChanged: notifier.setArpeggiatorSync,
              activeColor: const Color(0xFF10D38F),
            ),
            const SizedBox(height: 8),
            _buildSliderSection(
              context: context,
              title: 'Gate Length',
              value: state.arpeggiator.gateLength,
              min: 0.1,
              max: 1.0,
              divisions: 90,
              label: '${(state.arpeggiator.gateLength * 100).round()}%',
              onChanged: notifier.setArpeggiatorGateLength,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuantizationSection(BuildContext context, MidiRulesState state, MidiRulesNotifier notifier) {
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
          Row(
            children: [
              const Icon(Icons.grid_on, color: Color(0xFF10D38F), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Quantization',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Enable Quantization', style: TextStyle(color: Colors.white)),
            value: state.quantization.enabled,
            onChanged: notifier.setQuantizationEnabled,
            activeColor: const Color(0xFF10D38F),
          ),
          if (state.quantization.enabled) ...[
            const SizedBox(height: 8),
            _buildDropdownSection(
              title: 'Grid',
              value: state.quantization.grid,
              items: const ['1/4', '1/8', '1/16', '1/32'],
              onChanged: notifier.setQuantizationGrid,
            ),
            const SizedBox(height: 8),
            _buildSliderSection(
              context: context,
              title: 'Strength',
              value: state.quantization.strength,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              label: '${(state.quantization.strength * 100).round()}%',
              onChanged: notifier.setQuantizationStrength,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Swing', style: TextStyle(color: Colors.white)),
              value: state.quantization.swing,
              onChanged: notifier.setSwing,
              activeColor: const Color(0xFF10D38F),
            ),
            if (state.quantization.swing) ...[
              const SizedBox(height: 8),
              _buildSliderSection(
                context: context,
                title: 'Swing Amount',
                value: state.quantization.swingAmount,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                label: '${(state.quantization.swingAmount * 100).round()}%',
                onChanged: notifier.setSwingAmount,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildGeneralMidiSection(BuildContext context, MidiRulesState state, MidiRulesNotifier notifier) {
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
          Row(
            children: [
              const Icon(Icons.settings, color: Color(0xFF10D38F), size: 20),
              const SizedBox(width: 8),
              const Text(
                'General MIDI Settings',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('MIDI Thru', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Pass through MIDI to other devices', style: TextStyle(color: Colors.white70)),
            value: state.midiThru,
            onChanged: notifier.setMidiThru,
            activeColor: const Color(0xFF10D38F),
          ),
          SwitchListTile(
            title: const Text('Record MIDI', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Record incoming MIDI data', style: TextStyle(color: Colors.white70)),
            value: state.recordMidi,
            onChanged: notifier.setRecordMidi,
            activeColor: const Color(0xFF10D38F),
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
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10D38F),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
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
              fontSize: 14,
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
