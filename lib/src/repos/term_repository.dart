import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import 'local_models.dart';

class TermRepository {
  TermRepository({AppDatabase? db}) : db = db ?? AppDatabase();

  final AppDatabase db;
  static const _uuid = Uuid();

  Stream<List<LocalTerm>> watchTerms({String? type}) {
    final query = db.select(db.terms)
      ..where((tbl) => tbl.deletedAt.isNull())
      ..orderBy([
        (tbl) => OrderingTerm(
              expression: tbl.createdAt,
              mode: OrderingMode.desc,
            ),
      ]);

    if (type != null) {
      query.where((tbl) => tbl.type.equals(type));
    }

    return query.watch().map(
          (rows) => rows.map(LocalTerm.fromRow).toList(growable: false),
        );
  }

  Future<List<LocalTerm>> listTermsByIds(Iterable<String> ids) async {
    final idList = ids.toList(growable: false);
    if (idList.isEmpty) return const [];

    final rows = await (db.select(db.terms)
          ..where((tbl) => tbl.id.isIn(idList) & tbl.deletedAt.isNull()))
        .get();
    final byId = {
      for (final row in rows) row.id: LocalTerm.fromRow(row),
    };
    return idList
        .map((id) => byId[id])
        .whereType<LocalTerm>()
        .toList(growable: false);
  }

  Future<LocalTerm?> getTerm(String id) async {
    final row = await (db.select(db.terms)
          ..where((tbl) => tbl.id.equals(id) & tbl.deletedAt.isNull()))
        .getSingleOrNull();
    return row == null ? null : LocalTerm.fromRow(row);
  }

  Future<String> addTerm({
    String? id,
    required String type,
    required String frontText,
    String backText = '',
    String note = '',
    String frontLanguage = 'es-ES',
    String backLanguage = 'ko-KR',
    String? imagePath,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final termId = id ?? _uuid.v4();

    await db.into(db.terms).insert(
          TermsCompanion.insert(
            id: termId,
            type: type,
            frontText: frontText,
            backText: Value(backText),
            note: Value(note),
            frontLanguage: Value(frontLanguage),
            backLanguage: Value(backLanguage),
            imagePath: Value(imagePath),
            createdAt: now,
            updatedAt: now,
          ),
        );

    return termId;
  }

  Future<void> updateTerm({
    required String id,
    String? type,
    String? frontText,
    String? backText,
    String? note,
    String? frontLanguage,
    String? backLanguage,
    String? imagePath,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();

    await (db.update(db.terms)..where((tbl) => tbl.id.equals(id))).write(
      TermsCompanion(
        type: type == null ? const Value.absent() : Value(type),
        frontText: frontText == null ? const Value.absent() : Value(frontText),
        backText: backText == null ? const Value.absent() : Value(backText),
        note: note == null ? const Value.absent() : Value(note),
        frontLanguage:
            frontLanguage == null ? const Value.absent() : Value(frontLanguage),
        backLanguage:
            backLanguage == null ? const Value.absent() : Value(backLanguage),
        imagePath: imagePath == null ? const Value.absent() : Value(imagePath),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> softDeleteTerms(Iterable<String> ids) async {
    final idList = ids.toList(growable: false);
    if (idList.isEmpty) return;

    final deletedAt = DateTime.now().toUtc().toIso8601String();
    await (db.update(db.terms)..where((tbl) => tbl.id.isIn(idList))).write(
      TermsCompanion(deletedAt: Value(deletedAt), updatedAt: Value(deletedAt)),
    );
  }
}
