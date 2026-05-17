import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';

class StudyRepository {
  StudyRepository({AppDatabase? db}) : db = db ?? AppDatabase();

  final AppDatabase db;
  static const _uuid = Uuid();

  Future<void> addPointLog({
    required int amount,
    required String type,
    String description = '',
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await db.into(db.pointLogs).insert(
          PointLogsCompanion.insert(
            id: _uuid.v4(),
            amount: amount,
            type: type,
            description: Value(description),
            createdAt: now,
          ),
        );
  }

  Future<int> totalPoints() async {
    final amount = db.pointLogs.amount.sum();
    final query = db.selectOnly(db.pointLogs)..addColumns([amount]);
    final row = await query.getSingle();
    return row.read(amount) ?? 0;
  }

  Future<String> startSession({String? setId}) async {
    final id = _uuid.v4();
    await db.into(db.studySessions).insert(
          StudySessionsCompanion.insert(
            id: id,
            setId: Value(setId),
            startedAt: DateTime.now().toUtc().toIso8601String(),
          ),
        );
    return id;
  }

  Future<void> finishSession({
    required String sessionId,
    required int cardsSeen,
    required int pointsEarned,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await (db.update(db.studySessions)
          ..where((tbl) => tbl.id.equals(sessionId)))
        .write(
      StudySessionsCompanion(
        endedAt: Value(now),
        cardsSeen: Value(cardsSeen),
        pointsEarned: Value(pointsEarned),
      ),
    );
  }
}
