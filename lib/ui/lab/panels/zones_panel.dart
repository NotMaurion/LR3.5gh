import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/zones_state.dart';
import '../../../state/active_preset_provider.dart';
import '../widgets/zone_editor.dart';

class ZonesPanel extends ConsumerWidget {
  const ZonesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zones = ref.watch(zonesProvider);
    final notifier = ref.read(zonesProvider.notifier);
    final activePreset = ref.watch(activePresetProvider);
    final isLoaded = notifier.isLoaded;

    if (activePreset == null) {
      return const Center(
        child: Text(
          'No preset selected. Please select a preset from the main screen.',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (!isLoaded) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading zone configuration...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
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
          const SizedBox(height: 20),
          for (int i = 0; i < zones.length; i++) ...[
            ZoneEditor(
              title: zones[i].name,
              minNote: zones[i].minNote,
              maxNote: zones[i].maxNote,
              baseNote: zones[i].baseNote,
              volume: zones[i].volume,
              probability: zones[i].probability,
              onMinChanged: (value) => notifier.setMinNote(i, value),
              onMaxChanged: (value) => notifier.setMaxNote(i, value),
              onBaseChanged: (value) => notifier.setBaseNote(i, value),
              onVolumeChanged: (value) => notifier.setVolume(i, value),
              onProbabilityChanged: (value) => notifier.setProbability(i, value),
            ),
            if (i < zones.length - 1) const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}


