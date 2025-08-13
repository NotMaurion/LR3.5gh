import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'engine_selector.dart';

final audioEngineProvider = Provider<Object>((ref) {
  final engine = createEngine();
  return engine;
});


