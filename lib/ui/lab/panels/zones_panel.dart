import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/zones_state.dart';
import '../widgets/zone_editor.dart';

class ZonesPanel extends ConsumerWidget {
  const ZonesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zones = ref.watch(zonesProvider);
    final notifier = ref.read(zonesProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
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


