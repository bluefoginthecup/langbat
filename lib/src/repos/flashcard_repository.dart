import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../services/app_path_service.dart';
import 'local_models.dart';

class FlashcardRepository {
  FlashcardRepository({
    AppDatabase? db,
    AppPathService? paths,
  })  : db = db ?? AppDatabase(),
        paths = paths ?? const AppPathService();

  final AppDatabase db;
  final AppPathService paths;
  static const _uuid = Uuid();

  Stream<List<LocalFlashcardSet>> watchSets() {
    final query = db.select(db.flashcardSets)
      ..where((tbl) => tbl.deletedAt.isNull())
      ..orderBy([
        (tbl) => OrderingTerm(
              expression: tbl.createdAt,
              mode: OrderingMode.desc,
            ),
      ]);

    return query.watch().asyncMap((rows) async {
      final sets = <LocalFlashcardSet>[];
      for (final row in rows) {
        final count = await _countItems(row.id);
        sets.add(
          LocalFlashcardSet(
            id: row.id,
            title: row.title,
            description: row.description,
            createdAt: DateTime.parse(row.createdAt),
            updatedAt: DateTime.parse(row.updatedAt),
            itemCount: count,
          ),
        );
      }
      return sets;
    });
  }

  Future<String> createSetFromTerms({
    required String title,
    String description = '',
    required List<String> termIds,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final setId = _uuid.v4();

    await db.transaction(() async {
      await db.into(db.flashcardSets).insert(
            FlashcardSetsCompanion.insert(
              id: setId,
              title: title.trim().isEmpty ? '새 세트' : title.trim(),
              description: Value(description),
              createdAt: now,
              updatedAt: now,
            ),
          );

      for (var index = 0; index < termIds.length; index += 1) {
        await db.into(db.flashcardSetItems).insert(
              FlashcardSetItemsCompanion.insert(
                id: _uuid.v4(),
                setId: setId,
                termId: termIds[index],
                sortOrder: Value(index),
                createdAt: now,
              ),
            );
      }
    });

    return setId;
  }

  Future<List<LocalFlashcard>> loadCards(String setId) async {
    final query = db.select(db.flashcardSetItems).join([
      innerJoin(db.terms, db.terms.id.equalsExp(db.flashcardSetItems.termId)),
    ])
      ..where(db.flashcardSetItems.setId.equals(setId))
      ..orderBy([
        OrderingTerm(
          expression: db.flashcardSetItems.sortOrder,
          mode: OrderingMode.asc,
        ),
      ]);

    final rows = await query.get();
    final cards = <LocalFlashcard>[];
    for (final row in rows) {
      final item = row.readTable(db.flashcardSetItems);
      final term = row.readTable(db.terms);
      var imageUrl = '';
      final imagePath = term.imagePath;
      if (imagePath != null && imagePath.isNotEmpty) {
        imageUrl = (await paths.resolveAppFile(imagePath)).path;
      }
      cards.add(LocalFlashcard(
        id: item.id,
        termId: term.id,
        text: term.frontText,
        meaning: term.backText,
        order: item.sortOrder,
        imageUrl: imageUrl,
      ));
    }
    return cards;
  }

  Future<void> softDeleteSets(Iterable<String> ids) async {
    final idList = ids.toList(growable: false);
    if (idList.isEmpty) return;

    final deletedAt = DateTime.now().toUtc().toIso8601String();
    await (db.update(db.flashcardSets)..where((tbl) => tbl.id.isIn(idList)))
        .write(
      FlashcardSetsCompanion(
        deletedAt: Value(deletedAt),
        updatedAt: Value(deletedAt),
      ),
    );
  }

  Future<int> _countItems(String setId) async {
    final count = db.flashcardSetItems.id.count();
    final query = db.selectOnly(db.flashcardSetItems)
      ..addColumns([count])
      ..where(db.flashcardSetItems.setId.equals(setId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }
}
