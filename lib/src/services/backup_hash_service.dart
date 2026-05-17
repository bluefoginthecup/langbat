import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

class BackupFileHash {
  final String relativePath;
  final int sizeBytes;
  final String sha256;

  const BackupFileHash({
    required this.relativePath,
    required this.sizeBytes,
    required this.sha256,
  });

  Map<String, Object?> toJson() => {
        'relativePath': relativePath,
        'sizeBytes': sizeBytes,
        'sha256': sha256,
      };
}

class BackupHashService {
  const BackupHashService();

  Future<BackupFileHash> hashFile({
    required File file,
    required String relativePath,
  }) async {
    final bytes = await file.readAsBytes();
    return BackupFileHash(
      relativePath: relativePath,
      sizeBytes: bytes.length,
      sha256: sha256.convert(bytes).toString(),
    );
  }

  Future<List<BackupFileHash>> hashDirectoryFiles({
    required Directory root,
    required String relativeRoot,
  }) async {
    if (!await root.exists()) return const [];

    final hashes = <BackupFileHash>[];
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final relativePath = p.posix.joinAll([
        relativeRoot,
        ...p.split(p.relative(entity.path, from: root.path)),
      ]);
      hashes.add(await hashFile(file: entity, relativePath: relativePath));
    }

    hashes.sort((a, b) => a.relativePath.compareTo(b.relativePath));
    return hashes;
  }

  String hashManifestContent(Map<String, Object?> content) {
    final canonical = const JsonEncoder.withIndent('  ').convert(content);
    return sha256.convert(utf8.encode(canonical)).toString();
  }
}
