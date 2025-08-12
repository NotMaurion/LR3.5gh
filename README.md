# LiveRoots (LR3.5)

Flutter app with MCP V4 architecture and hybrid audio engine.

## Preset structure
Assets must follow strictly:

```
assets/audio/presets/[PresetName]/
  bass.wav
  mid.wav
  high.wav
  tex.wav
```

JS config lives in `web/js/aurasonix_engine.js` under `this.PRESET_CONFIG`.

## Dev flow
- GitFlow: branches `main`, `develop`, `feature/*`.
- Conventional Commits for messages.

## Getting Started
- Flutter 3.29.x stable
- `flutter pub get`
- `flutter run -d chrome`
