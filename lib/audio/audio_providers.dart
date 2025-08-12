import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio_engine.dart';
import 'engine_selector_io.dart' if (dart.library.js) 'engine_selector_web.dart';

final webAudioEngineProvider = FutureProvider<AudioEngine>((ref) async {
  final engine = createEngine();
  await engine.init();
  return engine;
});

final audioEngineProvider = Provider<AudioEngine?>((ref) {
  final asyncEngine = ref.watch(webAudioEngineProvider);
  return asyncEngine.maybeWhen(data: (engine) => engine, orElse: () => null);
});

final presetsProvider = FutureProvider<List<String>>((ref) async {
  final engine = ref.watch(audioEngineProvider);
  if (engine == null) return const <String>[];
  return engine.listPresets();
});


