import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:langbat/src/services/auth_service.dart';
import 'package:langbat/src/services/cloud_backup_service.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future<void> _uploadCloudBackup(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      messenger.showSnackBar(
        const SnackBar(content: Text('클라우드 백업을 업로드하는 중입니다...')),
      );
      final result = await CloudBackupService(
        authService: AuthService(),
      ).uploadFullBackup();
      messenger.showSnackBar(
        SnackBar(content: Text('클라우드 백업 완료: ${result.backupId}')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('클라우드 백업 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('계정')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '로그인 정보',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      icon: Icons.email_outlined,
                      label: '이메일',
                      value: user?.email ?? '알 수 없음',
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.badge_outlined,
                      label: '사용자 ID',
                      value: user?.uid ?? '로그인 정보 없음',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '백업',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '현재 기기의 로컬 학습 데이터를 zip으로 묶어 Firebase에 업로드합니다.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: user == null
                          ? null
                          : () => _uploadCloudBackup(context),
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: const Text('클라우드 백업 업로드'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => FirebaseAuth.instance.signOut(),
              icon: const Icon(Icons.logout),
              label: const Text('로그아웃'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 2),
              SelectableText(value),
            ],
          ),
        ),
      ],
    );
  }
}
