import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import 'app_path_service.dart';
import 'backup_hash_service.dart';

class FullBackupResult {
  final File zipFile;
  final Map<String, Object?> manifest;

  const FullBackupResult({
    required this.zipFile,
    required this.manifest,
  });
}

class FullBackupService {
  static const backupFormatVersion = 1;
  static const _uuid = Uuid();

  const FullBackupService({
    this.paths = const AppPathService(),
    this.hashService = const BackupHashService(),
  });

  final AppPathService paths;
  final BackupHashService hashService;

  Future<FullBackupResult> createBackup() async {
    final backupId = _uuid.v4();
    final createdAt = DateTime.now().toUtc();
    final stamp = DateFormat('yyyyMMdd-HHmmss').format(createdAt.toLocal());
    final userDir = await paths.userSupportDirectory();
    final tempDir = Directory(p.join(userDir.path, 'backup_tmp', backupId));
    final backupsRoot = await paths.backupsRoot();

    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
    await tempDir.create(recursive: true);

    final dbBackup = File(p.join(tempDir.path, 'langbat.db'));
    final manifestFile = File(p.join(tempDir.path, 'manifest.json'));
    final zipFile = File(p.join(backupsRoot.path, 'langbat_backup_$stamp.zip'));
    if (await zipFile.exists()) {
      await zipFile.delete();
    }

    try {
      await _writeConsistentDatabaseBackup(dbBackup);

      final termImageHashes = await hashService.hashDirectoryFiles(
        root: await paths.termImagesRoot(),
        relativeRoot: AppPathService.termImagesRelativeRoot,
      );
      final audioHashes = await hashService.hashDirectoryFiles(
        root: await paths.generatedAudioRoot(),
        relativeRoot: AppPathService.generatedAudioRelativeRoot,
      );
      final dbHash = await hashService.hashFile(
        file: dbBackup,
        relativePath: 'langbat.db',
      );
      final contentHash = hashService.hashManifestContent({
        'database': dbHash.toJson(),
        'termImages': termImageHashes.map((hash) => hash.toJson()).toList(),
        'generatedAudio': audioHashes.map((hash) => hash.toJson()).toList(),
      });
      final totalSizeBytes = dbHash.sizeBytes +
          termImageHashes.fold<int>(0, (sum, hash) => sum + hash.sizeBytes) +
          audioHashes.fold<int>(0, (sum, hash) => sum + hash.sizeBytes);

      final manifest = <String, Object?>{
        'app': 'langbat',
        'backupId': backupId,
        'backupCreatedAt': createdAt.toIso8601String(),
        'backupFormatVersion': backupFormatVersion,
        'dbSchemaVersion': AppDatabase().schemaVersion,
        'contentHash': contentHash,
        'includedFolders': [
          AppPathService.termImagesRelativeRoot,
          AppPathService.generatedAudioRelativeRoot,
        ],
        'totalSizeBytes': totalSizeBytes,
        'database': dbHash.toJson(),
        'termImages': termImageHashes.map((hash) => hash.toJson()).toList(),
        'generatedAudio': audioHashes.map((hash) => hash.toJson()).toList(),
      };

      await manifestFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(manifest),
        flush: true,
      );
      await _writeZip(
        zipFile: zipFile,
        dbBackup: dbBackup,
        manifestFile: manifestFile,
      );

      return FullBackupResult(zipFile: zipFile, manifest: manifest);
    } finally {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  }

  Future<void> _writeConsistentDatabaseBackup(File dbBackup) async {
    final escapedPath = dbBackup.path.replaceAll("'", "''");
    await AppDatabase().customStatement("VACUUM INTO '$escapedPath'");
  }

  Future<void> _writeZip({
    required File zipFile,
    required File dbBackup,
    required File manifestFile,
  }) async {
    final encoder = ZipFileEncoder();
    encoder.create(zipFile.path, level: ZipFileEncoder.gzip);

    try {
      await encoder.addFile(dbBackup, 'langbat.db', ZipFileEncoder.gzip);
      await encoder.addFile(manifestFile, 'manifest.json', ZipFileEncoder.gzip);

      await _addDirectoryIfExists(
        encoder: encoder,
        root: await paths.termImagesRoot(),
        relativeRoot: AppPathService.termImagesRelativeRoot,
      );
      await _addDirectoryIfExists(
        encoder: encoder,
        root: await paths.generatedAudioRoot(),
        relativeRoot: AppPathService.generatedAudioRelativeRoot,
      );
    } finally {
      encoder.close();
    }
  }

  Future<void> _addDirectoryIfExists({
    required ZipFileEncoder encoder,
    required Directory root,
    required String relativeRoot,
  }) async {
    encoder.addArchiveFile(ArchiveFile.directory(relativeRoot));
    if (await root.exists()) {
      await encoder.addDirectory(
        root,
        includeDirName: true,
        level: ZipFileEncoder.gzip,
        followLinks: false,
      );
    }
  }
}
