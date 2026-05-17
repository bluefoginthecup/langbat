import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'auth_service.dart';
import 'full_backup_service.dart';

class CloudBackupException implements Exception {
  const CloudBackupException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => cause == null ? message : '$message ($cause)';
}

class CloudBackupResult {
  const CloudBackupResult({
    required this.backupId,
    required this.storagePath,
    required this.zipFile,
    required this.totalSizeBytes,
  });

  final String backupId;
  final String storagePath;
  final File zipFile;
  final int totalSizeBytes;
}

class CloudBackupService {
  const CloudBackupService({
    required this.authService,
    this.fullBackupService = const FullBackupService(),
  });

  final AuthService authService;
  final FullBackupService fullBackupService;

  Future<CloudBackupResult> uploadFullBackup() async {
    final uid = authService.uid;
    if (uid == null) {
      throw const CloudBackupException('로그인 후 클라우드 백업을 사용할 수 있습니다.');
    }
    if (Firebase.apps.isEmpty) {
      throw const CloudBackupException('Firebase 초기화가 완료되지 않았습니다.');
    }

    final backup = await fullBackupService.createBackup();
    final manifest = backup.manifest;
    final backupId = manifest['backupId']?.toString() ?? '';
    if (backupId.isEmpty) {
      throw const CloudBackupException('백업 ID를 만들지 못했습니다.');
    }

    final fileName = backup.zipFile.uri.pathSegments.last;
    final storagePath = 'users/$uid/backups/$backupId/$fileName';
    final totalSizeBytes = manifest['totalSizeBytes'] is int
        ? manifest['totalSizeBytes'] as int
        : await backup.zipFile.length();

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('backups')
        .doc(backupId);

    try {
      await docRef.set({
        'app': 'langbat',
        'uid': uid,
        'backupId': backupId,
        'status': 'uploading',
        'storagePath': storagePath,
        'backupFormatVersion': manifest['backupFormatVersion'],
        'dbSchemaVersion': manifest['dbSchemaVersion'],
        'contentHash': manifest['contentHash'],
        'totalSizeBytes': totalSizeBytes,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await FirebaseStorage.instance.ref(storagePath).putFile(
            backup.zipFile,
            SettableMetadata(
              contentType: 'application/zip',
              customMetadata: {
                'app': 'langbat',
                'backupId': backupId,
              },
            ),
          );

      await docRef.set({
        'status': 'ready',
        'uploadedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return CloudBackupResult(
        backupId: backupId,
        storagePath: storagePath,
        zipFile: backup.zipFile,
        totalSizeBytes: totalSizeBytes,
      );
    } catch (e) {
      try {
        await docRef.set({
          'status': 'failed',
          'errorMessage': e.toString(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {
        // 권한/네트워크 오류에서는 실패 기록도 막힐 수 있으므로 원인을 그대로 전달한다.
      }
      throw CloudBackupException('클라우드 백업 업로드에 실패했습니다.', e);
    }
  }
}
