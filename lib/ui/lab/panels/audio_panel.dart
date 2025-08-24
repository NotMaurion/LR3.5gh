import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/preset_io_service.dart';
import '../../../state/audio_effects_state.dart';
import '../../../state/scale_filter_state.dart';
import '../../../state/zones_state.dart';
import '../../../state/midi_rules_state.dart';
import '../../../state/active_preset_provider.dart';
import '../../../audio/audio_providers.dart';

class AudioPanel extends ConsumerWidget {
  const AudioPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectsState = ref.watch(audioEffectsProvider);
    final effectsNotifier = ref.read(audioEffectsProvider.notifier);
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
          const Text(
            'Audio & Preset Management',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          // Layer toggles
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
                Row(
                  children: const [
                    Icon(Icons.layers, color: Color(0xFF10D38F), size: 24),
                    SizedBox(width: 12),
                    Text('Layers', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    Row(children: [
                      Switch(
                        value: effectsState.layersEnabled.bass,
                        onChanged: (v) => effectsNotifier.setLayerEnabled('bass', v),
                        activeColor: const Color(0xFF10D38F),
                      ),
                      const Text('Bass', style: TextStyle(color: Colors.white)),
                    ]),
                    Row(children: [
                      Switch(
                        value: effectsState.layersEnabled.mid,
                        onChanged: (v) => effectsNotifier.setLayerEnabled('mid', v),
                        activeColor: const Color(0xFF10D38F),
                      ),
                      const Text('Mid', style: TextStyle(color: Colors.white)),
                    ]),
                    Row(children: [
                      Switch(
                        value: effectsState.layersEnabled.high,
                        onChanged: (v) => effectsNotifier.setLayerEnabled('high', v),
                        activeColor: const Color(0xFF10D38F),
                      ),
                      const Text('High', style: TextStyle(color: Colors.white)),
                    ]),
                    Row(children: [
                      Switch(
                        value: effectsState.layersEnabled.tex,
                        onChanged: (v) => effectsNotifier.setLayerEnabled('tex', v),
                        activeColor: const Color(0xFF10D38F),
                      ),
                      const Text('Tex', style: TextStyle(color: Colors.white)),
                    ]),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Export Section
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
                Row(
                  children: [
                    const Icon(
                      Icons.file_download,
                      color: Color(0xFF10D38F),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Export Current Preset',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Export the current preset configuration and audio files as a ZIP archive for sharing.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _exportCurrentPreset(context, ref),
                    icon: const Icon(Icons.download, color: Colors.white),
                    label: const Text(
                      'Export Preset',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10D38F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => _exportConfigJsonOnly(context, ref),
                    icon: const Icon(Icons.description, color: Color(0xFF10D38F), size: 18),
                    label: const Text('Export config.json only', style: TextStyle(color: Color(0xFF10D38F))),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Import Section
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
                Row(
                  children: [
                    const Icon(
                      Icons.file_upload,
                      color: Color(0xFF10D38F),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Import Preset',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Import a preset from a ZIP archive. The archive should contain config.json and audio files.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _importPreset(context, ref),
                    icon: const Icon(Icons.upload, color: Colors.white),
                    label: const Text(
                      'Import Preset',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10D38F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Custom Sounds Section
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
                Row(
                  children: [
                    const Icon(
                      Icons.music_note,
                      color: Color(0xFF10D38F),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Custom Sounds',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Load custom audio files (WAV, MP3, OGG) to create your own sound presets. Supports bass, mid, high, and texture layers.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                // Global Texture controls
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Texture (tex) layer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Row(children: [
                        const Text('Loop continuously', style: TextStyle(color: Colors.white70)),
                        const SizedBox(width: 8),
                        Switch(
                          value: true,
                          onChanged: (_) {},
                          activeColor: const Color(0xFF10D38F),
                        ),
                      ]),
                      _buildSliderSection(
                        context: context,
                        title: 'Texture LFO Rate (Hz)',
                        value: 0.2,
                        min: 0.05,
                        max: 2.0,
                        divisions: 195,
                        label: '0.20',
                        onChanged: (_) {},
                      ),
                      const SizedBox(height: 8),
                      _buildSliderSection(
                        context: context,
                        title: 'Texture LFO Depth',
                        value: 0.5,
                        min: 0.0,
                        max: 1.0,
                        divisions: 100,
                        label: '50%',
                        onChanged: (_) {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _loadCustomSound(context, ref, 'bass'),
                        icon: const Icon(Icons.music_note, color: Colors.white),
                        label: const Text(
                          'Load Bass',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10D38F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _loadCustomSound(context, ref, 'mid'),
                        icon: const Icon(Icons.music_note, color: Colors.white),
                        label: const Text(
                          'Load Mid',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10D38F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _loadCustomSound(context, ref, 'high'),
                        icon: const Icon(Icons.music_note, color: Colors.white),
                        label: const Text(
                          'Load High',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10D38F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _loadCustomSound(context, ref, 'tex'),
                        icon: const Icon(Icons.texture, color: Colors.white),
                        label: const Text(
                          'Load Texture',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10D38F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Audio Effects Section
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.graphic_eq,
                          color: Color(0xFF10D38F),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Audio Effects',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => effectsNotifier.resetAllEffects(),
                      icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
                      label: const Text('Reset', style: TextStyle(color: Colors.white, fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10D38F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Reverb Section
                _buildReverbSection(context, effectsState, effectsNotifier),
                const SizedBox(height: 16),
                
                // Filter Section
                _buildFilterSection(context, effectsState, effectsNotifier),
                const SizedBox(height: 16),
                
                // Envelope Section
                _buildEnvelopeSection(context, effectsState, effectsNotifier),
                const SizedBox(height: 16),
                
                // Sustain Section
                _buildSustainSection(context, effectsState, effectsNotifier),
                const SizedBox(height: 16),
                
                // Randomness Section
                _buildRandomnessSection(context, effectsState, effectsNotifier),
                const SizedBox(height: 16),
                
                // Simultaneous Notes Section
                _buildSimultaneousNotesSection(context, effectsState, effectsNotifier),
                const SizedBox(height: 16),
                
                // Global Volume Slider
                _buildSliderSection(
                  context: context,
                  title: 'Global Volume',
                  value: effectsState.globalVolume,
                  min: 0.0,
                  max: 1.0,
                  divisions: 100,
                  label: '${(effectsState.globalVolume * 100).round()}%',
                  onChanged: effectsNotifier.setGlobalVolume,
                ),
                
                const SizedBox(height: 16),
                
                // Audio Quality Dropdown
                _buildDropdownSection(
                  title: 'Audio Quality',
                  value: effectsState.audioQuality,
                  items: const ['Low', 'Medium', 'High'],
                  onChanged: effectsNotifier.setAudioQuality,
                ),
              ],
            ),
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

  Future<void> _exportCurrentPreset(BuildContext context, WidgetRef ref) async {
    try {
      final engine = ref.read(audioEngineProvider);
      final svc = const PresetIOService();
      final active = ref.read(activePresetProvider) ?? 'Current';

      // Build master config directly from providers to ensure completeness
      final safeCfg = _buildMasterConfig(ref, active);

      // Ask engine for any embedded custom audio data URLs
      Map<String, dynamic> embedded = <String, dynamic>{};
      try {
        // ignore: avoid_dynamic_calls
        embedded = await (engine as dynamic).getEmbeddedAudioDataUrls();
      } catch (_) {}
      final zipBytes = await svc.exportPresetZip(
        presetName: active,
        runtimeConfig: safeCfg,
        embeddedAudioDataUrls: Map<String, dynamic>.from(embedded),
      );
      // Ensure bytes are valid before download
      if (zipBytes.isEmpty) {
        throw Exception('Export failed: produced empty archive');
      }
      svc.downloadBytes(zipBytes, fileName: '${active}_preset.zip');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preset exported successfully!'),
            backgroundColor: Color(0xFF10D38F),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting preset: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportConfigJsonOnly(BuildContext context, WidgetRef ref) async {
    try {
      final active = ref.read(activePresetProvider) ?? 'Current';
      final safeCfg = _buildMasterConfig(ref, active);
      final jsonStr = const JsonEncoder.withIndent('  ').convert(safeCfg);
      final bytes = Uint8List.fromList(utf8.encode(jsonStr));
      const name = 'config.json';
      const svc = PresetIOService();
      svc.downloadBytes(bytes, fileName: name, contentType: 'application/json');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exported config.json')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting config.json: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Map<String, dynamic> _buildMasterConfig(WidgetRef ref, String name) {
    final effects = ref.read(audioEffectsProvider).toMap();
    final scale = ref.read(scaleFilterProvider).toJson();
    final zones = ref.read(zonesProvider).map((z) => z.toMap()).toList();
    final midi = ref.read(midiRulesProvider).toMap();

    final cfg = <String, dynamic>{
      'name': name.replaceAll('-', ' '),
      'metadata': {
        'author': 'LiveRoots Lab',
        'category': 'User',
        'tags': <String>[],
      },
      'audioFiles': {
        'bass': 'bass.wav',
        'mid': 'mid.wav',
        'high': 'high.wav',
        'tex': 'tex.wav',
      },
      'defaultZones': zones,
      'defaultScaleFilter': scale,
      'defaultAudioEffects': effects,
      'defaultMidiRules': midi,
      'configSource': 'exported from lab',
      'configName': 'config.json',
    };
    return PresetIOService.sanitizeConfig(cfg);
  }

  Widget _buildReverbSection(BuildContext context, AudioEffectsState state, AudioEffectsNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Switch(
                      value: state.reverb.enabled,
                      onChanged: notifier.setReverbEnabled,
                      activeColor: const Color(0xFF10D38F),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Reverb',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              if (state.reverb.enabled)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.tune, color: Color(0xFF10D38F)),
                  onSelected: notifier.applyReverbPreset,
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'Room', child: Text('Room')),
                    const PopupMenuItem(value: 'Hall', child: Text('Hall')),
                    const PopupMenuItem(value: 'Cathedral', child: Text('Cathedral')),
                    const PopupMenuItem(value: 'Plate', child: Text('Plate')),
                    const PopupMenuItem(value: 'Spring', child: Text('Spring')),
                    const PopupMenuItem(value: 'Chamber', child: Text('Chamber')),
                  ],
                ),
            ],
          ),
        ),
        if (state.reverb.enabled) ...[
          const SizedBox(height: 8),
          _buildSliderSection(
            context: context,
            title: 'Wet',
            value: state.reverb.wet,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            label: '${(state.reverb.wet * 100).round()}%',
            onChanged: notifier.setReverbWet,
          ),
          const SizedBox(height: 8),
          _buildSliderSection(
            context: context,
            title: 'Room Size',
            value: state.reverb.roomSize,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            label: '${(state.reverb.roomSize * 100).round()}%',
            onChanged: notifier.setReverbRoomSize,
          ),
          const SizedBox(height: 8),
          _buildSliderSection(
            context: context,
            title: 'Dampening',
            value: state.reverb.dampening,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            label: '${(state.reverb.dampening * 100).round()}%',
            onChanged: notifier.setReverbDampening,
          ),
          const SizedBox(height: 8),
          _buildSliderSection(
            context: context,
            title: 'Pre-Delay',
            value: state.reverb.preDelay,
            min: 0.0,
            max: 0.1,
            divisions: 100,
            label: '${(state.reverb.preDelay * 1000).round()}ms',
            onChanged: notifier.setReverbPreDelay,
          ),
        ],
      ],
    );
  }

  Widget _buildFilterSection(BuildContext context, AudioEffectsState state, AudioEffectsNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Switch(
                      value: state.filter.enabled,
                      onChanged: notifier.setFilterEnabled,
                      activeColor: const Color(0xFF10D38F),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Filter',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              if (state.filter.enabled)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.tune, color: Color(0xFF10D38F)),
                  onSelected: notifier.applyFilterPreset,
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'Low Pass', child: Text('Low Pass')),
                    const PopupMenuItem(value: 'High Pass', child: Text('High Pass')),
                    const PopupMenuItem(value: 'Band Pass', child: Text('Band Pass')),
                    const PopupMenuItem(value: 'Warm', child: Text('Warm')),
                    const PopupMenuItem(value: 'Bright', child: Text('Bright')),
                    const PopupMenuItem(value: 'Resonant', child: Text('Resonant')),
                  ],
                ),
            ],
          ),
        ),
        if (state.filter.enabled) ...[
          const SizedBox(height: 8),
          _buildDropdownSection(
            title: 'Type',
            value: state.filter.type.toUpperCase(),
            items: const ['LPF', 'HPF', 'BPF'],
            onChanged: (value) => notifier.setFilterType(value?.toLowerCase() ?? 'lpf'),
          ),
          const SizedBox(height: 8),
          _buildSliderSection(
            context: context,
            title: 'Cutoff',
            value: state.filter.cutoff,
            min: 20.0,
            max: 20000.0,
            divisions: 100,
            label: '${state.filter.cutoff.round()}Hz',
            onChanged: notifier.setFilterCutoff,
          ),
          const SizedBox(height: 8),
          _buildSliderSection(
            context: context,
            title: 'Resonance',
            value: state.filter.resonance,
            min: 0.0,
            max: 20.0,
            divisions: 100,
            label: '${state.filter.resonance.toStringAsFixed(1)}',
            onChanged: notifier.setFilterResonance,
          ),
        ],
      ],
    );
  }

  Widget _buildEnvelopeSection(BuildContext context, AudioEffectsState state, AudioEffectsNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Switch(
                      value: state.envelope.enabled,
                      onChanged: notifier.setEnvelopeEnabled,
                      activeColor: const Color(0xFF10D38F),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'ADSR Envelope',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              if (state.envelope.enabled)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.tune, color: Color(0xFF10D38F)),
                  onSelected: notifier.applyEnvelopePreset,
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'Piano', child: Text('Piano')),
                    const PopupMenuItem(value: 'Strings', child: Text('Strings')),
                    const PopupMenuItem(value: 'Percussion', child: Text('Percussion')),
                    const PopupMenuItem(value: 'Pad', child: Text('Pad')),
                    const PopupMenuItem(value: 'Lead', child: Text('Lead')),
                    const PopupMenuItem(value: 'Bass', child: Text('Bass')),
                  ],
                ),
            ],
          ),
        ),
        if (state.envelope.enabled) ...[
          const SizedBox(height: 8),
          _buildSliderSection(
            context: context,
            title: 'Attack',
            value: state.envelope.attack,
            min: 0.001,
            max: 2.0,
            divisions: 100,
            label: '${(state.envelope.attack * 1000).round()}ms',
            onChanged: notifier.setEnvelopeAttack,
          ),
          const SizedBox(height: 8),
          _buildSliderSection(
            context: context,
            title: 'Decay',
            value: state.envelope.decay,
            min: 0.001,
            max: 2.0,
            divisions: 100,
            label: '${(state.envelope.decay * 1000).round()}ms',
            onChanged: notifier.setEnvelopeDecay,
          ),
          const SizedBox(height: 8),
          _buildSliderSection(
            context: context,
            title: 'Sustain',
            value: state.envelope.sustain,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            label: '${(state.envelope.sustain * 100).round()}%',
            onChanged: notifier.setEnvelopeSustain,
          ),
          const SizedBox(height: 8),
          _buildSliderSection(
            context: context,
            title: 'Release',
            value: state.envelope.release,
            min: 0.001,
            max: 5.0,
            divisions: 100,
            label: '${(state.envelope.release * 1000).round()}ms',
            onChanged: notifier.setEnvelopeRelease,
          ),
        ],
      ],
    );
  }

  Widget _buildSustainSection(BuildContext context, AudioEffectsState state, AudioEffectsNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Switch(
                      value: state.sustain.enabled,
                      onChanged: notifier.setSustainEnabled,
                      activeColor: const Color(0xFF10D38F),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Sustain Control',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (state.sustain.enabled) ...[
          const SizedBox(height: 8),
          _buildSliderSection(
            context: context,
            title: 'Duration',
            value: state.sustain.duration,
            min: 0.1,
            max: 10.0,
            divisions: 100,
            label: '${state.sustain.duration.toStringAsFixed(1)}s',
            onChanged: notifier.setSustainDuration,
          ),
          const SizedBox(height: 8),
          _buildSliderSection(
            context: context,
            title: 'Level',
            value: state.sustain.level,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            label: '${(state.sustain.level * 100).round()}%',
            onChanged: notifier.setSustainLevel,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Switch(
                value: state.sustain.infinite,
                onChanged: notifier.setSustainInfinite,
                activeColor: const Color(0xFF10D38F),
              ),
              const SizedBox(width: 12),
              const Text(
                'Infinite Sustain',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildRandomnessSection(BuildContext context, AudioEffectsState state, AudioEffectsNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Switch(
                      value: state.randomness.enabled,
                      onChanged: notifier.setRandomnessEnabled,
                      activeColor: const Color(0xFF10D38F),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Randomness',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (state.randomness.enabled) ...[
          const SizedBox(height: 8),
          _buildSliderSection(
            context: context,
            title: 'Pitch Variation',
            value: state.randomness.pitchVariation,
            min: 0.0,
            max: 2.0,
            divisions: 100,
            label: '${state.randomness.pitchVariation.toStringAsFixed(2)} semitones',
            onChanged: notifier.setPitchVariation,
          ),
          const SizedBox(height: 8),
          _buildSliderSection(
            context: context,
            title: 'Velocity Variation',
            value: state.randomness.velocityVariation,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            label: '${(state.randomness.velocityVariation * 100).round()}%',
            onChanged: notifier.setVelocityVariation,
          ),
          const SizedBox(height: 8),
          _buildSliderSection(
            context: context,
            title: 'Timing Variation',
            value: state.randomness.timingVariation,
            min: 0.0,
            max: 200.0,
            divisions: 100,
            label: '${state.randomness.timingVariation.round()}ms',
            onChanged: notifier.setTimingVariation,
          ),
          const SizedBox(height: 8),
          _buildSliderSection(
            context: context,
            title: 'Sustain Variation',
            value: state.randomness.sustainVariation,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            label: '${(state.randomness.sustainVariation * 100).round()}%',
            onChanged: notifier.setSustainVariation,
          ),
        ],
      ],
    );
  }

  Widget _buildSimultaneousNotesSection(BuildContext context, AudioEffectsState state, AudioEffectsNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Switch(
                      value: state.simultaneousNotes.enabled,
                      onChanged: notifier.setSimultaneousNotesEnabled,
                      activeColor: const Color(0xFF10D38F),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Simultaneous Notes',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (state.simultaneousNotes.enabled) ...[
          const SizedBox(height: 8),
          _buildSliderSection(
            context: context,
            title: 'Max Notes',
            value: state.simultaneousNotes.maxNotes.toDouble(),
            min: 1.0,
            max: 32.0,
            divisions: 31,
            label: '${state.simultaneousNotes.maxNotes}',
            onChanged: (value) => notifier.setMaxNotes(value.round()),
          ),
          const SizedBox(height: 8),
          _buildSliderSection(
            context: context,
            title: 'Overlap Probability',
            value: state.simultaneousNotes.overlapProbability,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            label: '${(state.simultaneousNotes.overlapProbability * 100).round()}%',
            onChanged: notifier.setOverlapProbability,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Switch(
                value: state.simultaneousNotes.voiceStealing,
                onChanged: notifier.setVoiceStealing,
                activeColor: const Color(0xFF10D38F),
              ),
              const SizedBox(width: 12),
              const Text(
                'Voice Stealing',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildSliderSection(
            context: context,
            title: 'Voice Steal Threshold',
            value: state.simultaneousNotes.voiceStealThreshold,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            label: '${(state.simultaneousNotes.voiceStealThreshold * 100).round()}%',
            onChanged: notifier.setVoiceStealThreshold,
          ),
        ],
      ],
    );
  }

  Future<void> _loadCustomSound(BuildContext context, WidgetRef ref, String layer) async {
    try {
      final input = html.FileUploadInputElement();
      input.accept = '.wav,.mp3,.ogg,.aac,.flac,.m4a,.weba,.webm';
      input.click();
      await input.onChange.first;
      if (input.files == null || input.files!.isEmpty) return;
      final file = input.files!.first;

      // Read file as data URL so it can be decoded by the JS engine
      final reader = html.FileReader();
      final c = Completer<String>();
      reader.onLoad.listen((event) {
        final res = reader.result;
        if (res is String) {
          c.complete(res);
        } else {
          c.completeError('Failed to read file');
        }
      });
      reader.readAsDataUrl(file);
      final dataUrl = await c.future;

      final engine = ref.read(audioEngineProvider);
      // ignore: avoid_dynamic_calls
      final ok = await (engine as dynamic).loadCustomSound(layer, dataUrl) as bool;
      if (ok) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Custom $layer sound loaded'),
              backgroundColor: const Color(0xFF10D38F),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load custom sound in engine'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading custom sound: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importPreset(BuildContext context, WidgetRef ref) async {
    try {
      // Pick a .zip file
      final input = html.FileUploadInputElement();
      input.accept = '.zip';
      input.click();
      await input.onChange.first;
      if (input.files == null || input.files!.isEmpty) return;
      final file = input.files!.first;

      // Parse zip and load into engine
      const svc = PresetIOService();
      final bundle = await svc.importPresetZipAndParse(file: file);
      if (bundle == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid preset zip (no config.json/preset.config found)'), backgroundColor: Colors.red),
          );
        }
        return;
      }

      final engine = ref.read(audioEngineProvider);
      // ignore: avoid_dynamic_calls
      final ok = await (engine as dynamic).loadPresetFromBundle(bundle) as bool;
      if (ok) {
        final cfg = bundle['config'] as Map<String, dynamic>? ?? const {};
        final name = (cfg['metadata'] is Map && (cfg['metadata']['name'] is String))
            ? (cfg['metadata']['name'] as String)
            : (cfg['name'] as String? ?? 'Custom');
        // Update active preset label for Lab
        ref.read(activePresetProvider.notifier).setActivePreset(name.replaceAll(' ', '-'));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Preset imported: $name'), backgroundColor: const Color(0xFF10D38F)),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load imported preset in engine'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing preset: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
