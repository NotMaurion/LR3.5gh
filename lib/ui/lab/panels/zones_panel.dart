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
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final z = zones[index];
        return ZoneEditor(
          title: z.name,
          minNote: z.minNote,
          maxNote: z.maxNote,
          baseNote: z.baseNote,
          volume: z.volume,
          probability: z.probability,
          onMinChanged: (v) => notifier.setMin(index, v),
          onMaxChanged: (v) => notifier.setMax(index, v),
          onBaseChanged: (v) => notifier.setBase(index, v),
          onVolumeChanged: (v) => notifier.setVolume(index, v),
          onProbabilityChanged: (v) => notifier.setProbability(index, v),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemCount: zones.length,
    );
  }
}


