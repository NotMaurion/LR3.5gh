import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';

class PresetExportService {
  static Future<void> exportPreset({
    required String presetName,
    required Map<String, dynamic> config,
    required Map<String, Uint8List> audioFiles,
  }) async {
    try {
      // Create archive
      final archive = Archive();
      
      // Add config.json
      final configJson = jsonEncode(config);
      final configBytes = utf8.encode(configJson);
      final configFile = ArchiveFile('config.json', configBytes.length, configBytes);
      archive.addFile(configFile);
      
      // Add audio files
      for (final entry in audioFiles.entries) {
        final audioFile = ArchiveFile(entry.key, entry.value.length, entry.value);
        archive.addFile(audioFile);
      }
      
      // Encode to ZIP
      final zipData = ZipEncoder().encode(archive);
      if (zipData == null) {
        throw Exception('Failed to create ZIP archive');
      }
      
      // Create download
      final blob = html.Blob([zipData]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', '${presetName}_preset.zip')
        ..click();
      
      html.Url.revokeObjectUrl(url);
      
      debugPrint('Preset exported successfully: ${presetName}_preset.zip');
    } catch (e) {
      debugPrint('Error exporting preset: $e');
      rethrow;
    }
  }
  
  static Future<Map<String, dynamic>> importPreset() async {
    try {
      // Create file input
      final input = html.FileUploadInputElement()
        ..accept = '.zip'
        ..click();
      
      // Wait for file selection
      final completer = Completer<html.File>();
      input.onChange.listen((event) {
        final files = input.files;
        if (files != null && files.isNotEmpty) {
          completer.complete(files.first);
        } else {
          completer.completeError('No file selected');
        }
      });
      
      final file = await completer.future;
      
      // Read file
      final reader = html.FileReader();
      final completer2 = Completer<Uint8List>();
      
      reader.onLoad.listen((event) {
        final result = reader.result;
        if (result is Uint8List) {
          completer2.complete(result);
        } else {
          completer2.completeError('Failed to read file');
        }
      });
      
      reader.readAsArrayBuffer(file);
      final zipData = await completer2.future;
      
      // Decode ZIP
      final archive = ZipDecoder().decodeBytes(zipData);
      
      // Extract config.json
      final configFile = archive.findFile('config.json');
      if (configFile == null) {
        throw Exception('config.json not found in ZIP');
      }
      
      final configJson = utf8.decode(configFile.content as List<int>);
      final config = jsonDecode(configJson) as Map<String, dynamic>;
      
      // Extract audio files
      final audioFiles = <String, Uint8List>{};
      for (final file in archive.files) {
        if (file.name != 'config.json' && file.content != null) {
          audioFiles[file.name] = Uint8List.fromList(file.content as List<int>);
        }
      }
      
      debugPrint('Preset imported successfully: ${config['name'] ?? 'Unknown'}');
      
      return {
        'config': config,
        'audioFiles': audioFiles,
        'presetName': config['name'] ?? 'Imported Preset',
      };
    } catch (e) {
      debugPrint('Error importing preset: $e');
      rethrow;
    }
  }
  
  static bool isSupported() {
    return kIsWeb;
  }
}
