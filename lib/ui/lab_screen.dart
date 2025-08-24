import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../audio/audio_providers.dart';
import '../state/active_preset_provider.dart';
import '../state/live_mode_provider.dart';
import '../state/scale_filter_state.dart';
import '../state/zones_state.dart';
import '../services/preset_io_service.dart';
import 'dart:html' as html;
import 'lab/panels/zones_panel.dart';
import 'lab/panels/scales_panel.dart';
import 'lab/panels/audio_panel.dart';
import 'lab/panels/rules_panel.dart';

class LabScreen extends ConsumerWidget {
  const LabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access the global audio engine if needed
    final _ = ref.watch(audioEngineProvider);
    final tabs = ref.watch(labTabsProvider);
    final activePreset = ref.watch(activePresetProvider);
    final isLiveMode = ref.watch(liveModeProvider);
    final liveModeNotifier = ref.read(liveModeProvider.notifier);
    
    // Refresh state from engine when LAB is opened
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(scaleFilterProvider.notifier).loadFromEngine();
      await ref.read(zonesProvider.notifier).loadFromEngine();
    });
    
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Preset Laboratory'),
              if (activePreset != null)
                Text(
                  'Fine-tuning: ${activePreset.replaceAll('-', ' ')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          ),
          actions: [
            // Import
            IconButton(
              tooltip: 'Import preset (.zip) as preset.config',
              icon: const Icon(Icons.file_open),
              onPressed: () async {
                final input = html.FileUploadInputElement();
                input.accept = '.zip';
                input.click();
                await input.onChange.first;
                if (input.files == null || input.files!.isEmpty) return;
                final file = input.files!.first;
                final svc = const PresetIOService();
                final bundle = await svc.importPresetZipAndParse(file: file);
                if (bundle != null) {
                  final engine = ref.read(audioEngineProvider);
                  // ignore: avoid_dynamic_calls
                  await (engine as dynamic).loadPresetFromBundle(bundle);
                }
              },
            ),
            // Export
            IconButton(
              tooltip: 'Export current preset as preset.config (zip)',
              icon: const Icon(Icons.file_download),
              onPressed: () async {
                final active = ref.read(activePresetProvider) ?? 'Custom';
                final engine = ref.read(audioEngineProvider);
                try {
                  // ignore: avoid_dynamic_calls
                  final cfg = await (engine as dynamic).getCurrentPresetConfig();
                  final svc = const PresetIOService();
                  final zipBytes = await svc.exportPresetZip(
                    presetName: active,
                    runtimeConfig: cfg,
                  );
                  svc.downloadBytes(zipBytes, fileName: 'preset.config');
                } catch (_) {}
              },
            ),
            // Live Mode Toggle Button
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  liveModeNotifier.toggleLiveMode();
                },
                icon: Icon(
                  isLiveMode ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  size: 16,
                ),
                label: Text(
                  isLiveMode ? 'LIVE' : 'OFF',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLiveMode ? const Color(0xFF10D38F) : Colors.grey[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
          bottom: _StyledTabBar(tabs: tabs),
        ),
        body: TabBarView(
          children: [
            const ZonesPanel(),
            const ScalesPanel(),
            const AudioPanel(),
            const RulesPanel(),
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


