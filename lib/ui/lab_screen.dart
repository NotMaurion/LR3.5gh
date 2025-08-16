import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../audio/audio_providers.dart';
import 'lab/panels/zones_panel.dart';
import 'lab/panels/scales_panel.dart';

class LabScreen extends ConsumerWidget {
  const LabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access the global audio engine if needed
    final _ = ref.watch(audioEngineProvider);
    final tabs = ref.watch(labTabsProvider);
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: const Text('Preset Laboratory'),
          bottom: _StyledTabBar(tabs: tabs),
        ),
        body: TabBarView(
          children: [
            const ZonesPanel(),
            const ScalesPanel(),
            const Center(child: Text('Audio')),
            const Center(child: Text('Rules')),
          ],
        ),
      ),
    );
  }
}

class _StyledTabBar extends StatelessWidget implements PreferredSizeWidget {
  const _StyledTabBar({required this.tabs});
  final List<String> tabs;

  @override
  Widget build(BuildContext context) {
    const Color accent = Color(0xFFFFC107); // bright gold/orange
    return TabBar(
      isScrollable: true,
      indicatorColor: accent,
      labelColor: accent,
      unselectedLabelColor: Colors.grey,
      indicatorWeight: 3,
      tabs: [
        for (final t in tabs) Tab(text: t),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


