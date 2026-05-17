import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import 'package:langbat/src/services/app_path_service.dart';

class GeneratedTtsAudio {
  final String relativePath;
  final String absolutePath;

  const GeneratedTtsAudio({
    required this.relativePath,
    required this.absolutePath,
  });
}

class ElevenLabsTtsService {
  const ElevenLabsTtsService({
    this.paths = const AppPathService(),
    http.Client? client,
  }) : _client = client;

  final AppPathService paths;
  final http.Client? _client;

  Future<GeneratedTtsAudio> generateAndStore({
    required String apiKey,
    required String voiceId,
    required String modelId,
    required String termId,
    required String side,
    required String text,
  }) async {
    final cleanedApiKey = apiKey.trim();
    final cleanedVoiceId = voiceId.trim();
    final cleanedText = text.trim();
    if (cleanedApiKey.isEmpty) {
      throw ArgumentError('ElevenLabs API key is empty.');
    }
    if (cleanedVoiceId.isEmpty) {
      throw ArgumentError('ElevenLabs voice id is empty.');
    }
    if (cleanedText.isEmpty) {
      throw ArgumentError('TTS text is empty.');
    }

    final client = _client ?? http.Client();
    final shouldClose = _client == null;
    try {
      final uri = Uri.https(
        'api.elevenlabs.io',
        '/v1/text-to-speech/$cleanedVoiceId',
      );
      final response = await client.post(
        uri,
        headers: {
          'xi-api-key': cleanedApiKey,
          'accept': 'audio/mpeg',
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'text': cleanedText,
          'model_id': modelId.trim().isEmpty ? 'eleven_flash_v2_5' : modelId,
          'voice_settings': {
            'stability': 0.55,
            'similarity_boost': 0.75,
          },
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'ElevenLabs TTS failed (${response.statusCode}): ${response.body}',
        );
      }

      final root = await paths.generatedAudioRoot();
      final dir = Directory(p.join(root.path, termId));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final file = File(p.join(dir.path, 'elevenlabs_$side.mp3'));
      await file.writeAsBytes(response.bodyBytes, flush: true);

      return GeneratedTtsAudio(
        relativePath: await paths.normalizeToRelativePath(file.path),
        absolutePath: file.path,
      );
    } finally {
      if (shouldClose) client.close();
    }
  }
}
