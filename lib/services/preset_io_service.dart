import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

class PresetIOService {
  const PresetIOService();

  // Sanitize any runtime object into a JSON-encodable structure
  static dynamic _sanitizeForJson(dynamic value) {
    if (value == null) return null;
    if (value is num || value is bool || value is String) return value;
    if (value is Uint8List) return base64Encode(value);
    if (value is List) return value.map(_sanitizeForJson).toList();
    if (value is Map) {
      final out = <String, dynamic>{};
      value.forEach((key, val) {
        final safeKey = (key is String) ? key : (key?.toString() ?? 'null');
        out[safeKey] = _sanitizeForJson(val);
      });
      return out;
    }
    if (value is Iterable) return value.map(_sanitizeForJson).toList();
    try {
      // Try common toJson convention
      final dynamic jsonVal = (value as dynamic).toJson?.call();
      if (jsonVal != null) return _sanitizeForJson(jsonVal);
    } catch (_) {}
    // Fallback: string representation
    return value.toString();
  }

  static Map<String, dynamic> sanitizeConfig(Map<String, dynamic> cfg) {
    final sanitized = _sanitizeForJson(cfg);
    if (sanitized is Map) {
      return Map<String, dynamic>.from(sanitized as Map);
    }
    return <String, dynamic>{};
  }

  Future<Uint8List> exportPresetZip({
    required String presetName,
    required Map<String, dynamic> runtimeConfig,
    Map<String, dynamic>? embeddedAudioDataUrls,
  }) async {
    // runtimeConfig should be the same shape as config.json content
    final Archive archive = Archive();

    // 1) Add config.json (master runtime config)
    final safeConfig = sanitizeConfig(runtimeConfig);
    final configJson = jsonEncode(safeConfig);
    final configBytes = utf8.encode(configJson);
    archive.addFile(ArchiveFile('config.json', configBytes.length, configBytes));

    // 2) Embed audio files
    // Priority: embeddedAudioDataUrls (runtime custom uploads) -> assets fallback
    const audioFiles = ['bass.wav', 'mid.wav', 'high.wav', 'tex.wav'];

    // Helper: decode a data URL to bytes
    Uint8List? _decodeDataUrl(String? dataUrl) {
      if (dataUrl == null || dataUrl.isEmpty) return null;
      try {
        final comma = dataUrl.indexOf(',');
        final base64 = comma >= 0 ? dataUrl.substring(comma + 1) : dataUrl;
        final bytes = base64Decode(base64);
        return Uint8List.fromList(bytes);
      } catch (_) {
        return null;
      }
    }

    // Attempt to add embedded custom audio first
    if (embeddedAudioDataUrls != null && embeddedAudioDataUrls.isNotEmpty) {
      final mapping = <String, String>{
        'bass': 'bass.wav',
        'mid': 'mid.wav',
        'high': 'high.wav',
        'tex': 'tex.wav',
      };
      for (final entry in mapping.entries) {
        final bytes = _decodeDataUrl(embeddedAudioDataUrls[entry.key] as String?);
        if (bytes != null && bytes.isNotEmpty) {
          archive.addFile(ArchiveFile('audio/${entry.value}', bytes.length, bytes));
        }
      }
    }

    // Fallback to assets for any missing layers
    final base = 'assets/audio/presets/$presetName/';
    for (final file in audioFiles) {
      final alreadyPresent = archive.files.any((f) => f.isFile && f.name == 'audio/$file');
      if (alreadyPresent) continue;
      try {
        final data = await rootBundle.load(base + file);
        archive.addFile(ArchiveFile('audio/$file', data.lengthInBytes, data.buffer.asUint8List()));
      } catch (_) {
        // optional; ignore missing files
      }
    }

    final bytes = ZipEncoder().encode(archive);
    return Uint8List.fromList(bytes ?? const <int>[]);
  }

  void downloadBytes(Uint8List data, {String fileName = 'preset.config', String? contentType}) {
    // Infer content type from extension if not provided
    String resolvedType = contentType ?? 'application/octet-stream';
    final lower = fileName.toLowerCase();
    if (contentType == null) {
      if (lower.endsWith('.zip')) {
        resolvedType = 'application/zip';
      } else if (lower.endsWith('.json')) {
        resolvedType = 'application/json';
      } else if (lower.endsWith('.wav')) {
        resolvedType = 'audio/wav';
      } else if (lower.endsWith('.mp3')) {
        resolvedType = 'audio/mpeg';
      }
    }

    // Primary: Blob + object URL
    try {
      final blob = html.Blob([data], resolvedType);
      final url = html.Url.createObjectUrlFromBlob(blob);
      try {
        final anchor = html.AnchorElement(href: url)
          ..download = fileName
          ..style.display = 'none'
          ..rel = 'noopener';
        html.document.body?.children.add(anchor);
        anchor.click();
        anchor.remove();
      } catch (_) {
        // Attempt opening in a new tab if click is blocked
        try {
          html.window.open(url, '_blank');
        } catch (_) {}
      } finally {
        // Revoke after a short delay to ensure the browser has consumed the URL
        Future<void>.delayed(const Duration(seconds: 2)).then((_) {
          try { html.Url.revokeObjectUrl(url); } catch (_) {}
        });
      }
      return;
    } catch (_) {
      // Continue to data URI fallback
    }

    // Fallback: data URI (base64). Some browsers may block large data URIs.
    try {
      final b64 = base64Encode(data);
      final href = 'data:$resolvedType;base64,$b64';
      final anchor = html.AnchorElement(href: href)
        ..download = fileName
        ..style.display = 'none'
        ..rel = 'noopener';
      html.document.body?.children.add(anchor);
      anchor.click();
      anchor.remove();
    } catch (_) {
      // Last resort: open data URI in a new tab
      try {
        final b64 = base64Encode(data);
        html.window.open('data:$resolvedType;base64,$b64', '_blank');
      } catch (_) {}
    }
  }

  Future<Map<String, dynamic>?> importPresetZipAndParse({required html.File file}) async {
    final reader = html.FileReader();
    final completer = Completer<Map<String, dynamic>?>();
    reader.onError.listen((_) => completer.complete(null));
    reader.onLoadEnd.listen((_) async {
      try {
        final data = reader.result as Uint8List?;
        if (data == null) return completer.complete(null);
        final archive = ZipDecoder().decodeBytes(data);

        // Locate config
        ArchiveFile? configEntry = archive.files.firstWhere(
          (f) => f.name == 'preset.config' || f.name.endsWith('/preset.config') || f.name.endsWith('/config.json') || f.name == 'config.json',
          orElse: () => ArchiveFile('none', 0, const <int>[]),
        );
        if (configEntry.isFile && configEntry.size > 0) {
          final configText = utf8.decode(configEntry.content as List<int>);
          final config = jsonDecode(configText) as Map<String, dynamic>;

          // Collect audio entries into data URLs for in-memory load
          String? toDataUrl(ArchiveFile f) {
            if (!f.isFile || f.size == 0) return null;
            final bytes = Uint8List.fromList(f.content as List<int>);
            final base64 = base64Encode(bytes);
            return 'data:audio/wav;base64,$base64';
          }

          String? getAudio(String name) {
            final entry = archive.files.firstWhere(
              (f) => f.name.endsWith('/$name') || f.name == name,
              orElse: () => ArchiveFile('none', 0, const <int>[]),
            );
            return entry.isFile ? toDataUrl(entry) : null;
          }

          final bundle = <String, dynamic>{
            'config': config,
            'audioFiles': {
              'bass': getAudio('bass.wav'),
              'mid': getAudio('mid.wav'),
              'high': getAudio('high.wav'),
              'tex': getAudio('tex.wav'),
            }
          };
          return completer.complete(bundle);
        }
        completer.complete(null);
      } catch (_) {
        completer.complete(null);
      }
    });
    reader.readAsArrayBuffer(file);
    return completer.future;
  }
}


