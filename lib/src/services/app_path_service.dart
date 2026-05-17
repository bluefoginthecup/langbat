import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AppPathService {
  static const termImagesRelativeRoot = 'term_images';
  static const generatedAudioRelativeRoot = 'generated_audio';
  static const backupsRelativeRoot = 'backups';
  static String? _activeUserId;

  const AppPathService();

  static void setActiveUserId(String? userId) {
    final cleaned = userId?.trim();
    _activeUserId = cleaned == null || cleaned.isEmpty
        ? null
        : cleaned.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
  }

  Future<Directory> appSupportDirectory() {
    return getApplicationSupportDirectory();
  }

  Future<Directory> userSupportDirectory() async {
    final root = await appSupportDirectory();
    final userId = _activeUserId ?? 'local';
    final dir = Directory(p.join(root.path, 'users', userId));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> databaseFile() async {
    final dir = await userSupportDirectory();
    return File(p.join(dir.path, 'langbat.db'));
  }

  Future<Directory> termImagesRoot() async {
    final dir = await userSupportDirectory();
    final images = Directory(p.join(dir.path, termImagesRelativeRoot));
    if (!await images.exists()) {
      await images.create(recursive: true);
    }
    return images;
  }

  Future<Directory> generatedAudioRoot() async {
    final dir = await userSupportDirectory();
    final audio = Directory(p.join(dir.path, generatedAudioRelativeRoot));
    if (!await audio.exists()) {
      await audio.create(recursive: true);
    }
    return audio;
  }

  Future<Directory> backupsRoot() async {
    final dir = await userSupportDirectory();
    final backups = Directory(p.join(dir.path, backupsRelativeRoot));
    if (!await backups.exists()) {
      await backups.create(recursive: true);
    }
    return backups;
  }

  Future<File> resolveAppFile(String storedPath) async {
    if (p.isAbsolute(storedPath)) {
      return File(storedPath);
    }

    final dir = await userSupportDirectory();
    return File(p.joinAll([dir.path, ...p.posix.split(storedPath)]));
  }

  Future<String> normalizeToRelativePath(String absoluteOrRelativePath) async {
    if (!p.isAbsolute(absoluteOrRelativePath)) {
      return p.posix.joinAll(p.split(absoluteOrRelativePath));
    }

    final dir = await userSupportDirectory();
    if (p.equals(absoluteOrRelativePath, dir.path) ||
        p.isWithin(dir.path, absoluteOrRelativePath)) {
      return p.posix.joinAll(
        p.split(p.relative(absoluteOrRelativePath, from: dir.path)),
      );
    }

    return absoluteOrRelativePath;
  }
}
