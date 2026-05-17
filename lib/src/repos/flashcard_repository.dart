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

  Future<LocalFlashcardSet?> getSet(String setId) async {
    final row = await (db.select(db.flashcardSets)
          ..where((tbl) => tbl.id.equals(setId) & tbl.deletedAt.isNull()))
        .getSingleOrNull();
    if (row == null) return null;

    return LocalFlashcardSet(
      id: row.id,
      title: row.title,
      description: row.description,
      createdAt: DateTime.parse(row.createdAt),
      updatedAt: DateTime.parse(row.updatedAt),
      itemCount: await _countItems(row.id),
    );
  }

  Future<void> updateSet({
    required String setId,
    required String title,
    String description = '',
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await (db.update(db.flashcardSets)..where((tbl) => tbl.id.equals(setId)))
        .write(
      FlashcardSetsCompanion(
        title: Value(title.trim().isEmpty ? '새 세트' : title.trim()),
        description: Value(description),
        updatedAt: Value(now),
      ),
    );
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

  Future<String> createSentenceSetFromPairs({
    required String title,
    String description = '',
    required List<MapEntry<String, String>> pairs,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final setId = _uuid.v4();

    await db.transaction(() async {
      await db.into(db.flashcardSets).insert(
            FlashcardSetsCompanion.insert(
              id: setId,
              title: title.trim().isEmpty ? '새 문장 세트' : title.trim(),
              description: Value(description),
              createdAt: now,
              updatedAt: now,
            ),
          );

      for (var index = 0; index < pairs.length; index += 1) {
        final pair = pairs[index];
        final termId = _uuid.v4();

        await db.into(db.terms).insert(
              TermsCompanion.insert(
                id: termId,
                type: 'sentence',
                frontText: pair.key,
                backText: Value(pair.value),
                frontLanguage: const Value('es-ES'),
                backLanguage: const Value('ko-KR'),
                createdAt: now,
                updatedAt: now,
              ),
            );

        await db.into(db.flashcardSetItems).insert(
              FlashcardSetItemsCompanion.insert(
                id: _uuid.v4(),
                setId: setId,
                termId: termId,
                sortOrder: Value(index),
                createdAt: now,
              ),
            );
      }
    });

    return setId;
  }

  Future<void> updateCardTerm({
    required String termId,
    required String frontText,
    required String backText,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await (db.update(db.terms)..where((tbl) => tbl.id.equals(termId))).write(
      TermsCompanion(
        frontText: Value(frontText.trim()),
        backText: Value(backText.trim()),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> removeCardsFromSet({
    required String setId,
    required Iterable<String> itemIds,
  }) async {
    final ids = itemIds.toList(growable: false);
    if (ids.isEmpty) return;

    await db.transaction(() async {
      await (db.delete(db.flashcardSetItems)
            ..where((tbl) => tbl.setId.equals(setId) & tbl.id.isIn(ids)))
          .go();
      final remaining = await loadCards(setId);
      for (var index = 0; index < remaining.length; index += 1) {
        await (db.update(db.flashcardSetItems)
              ..where(
                (tbl) =>
                    tbl.setId.equals(setId) &
                    tbl.id.equals(remaining[index].id),
              ))
            .write(FlashcardSetItemsCompanion(sortOrder: Value(index)));
      }
    });
  }

  Future<void> reorderCards({
    required String setId,
    required List<String> itemIds,
  }) async {
    await db.transaction(() async {
      for (var index = 0; index < itemIds.length; index += 1) {
        await (db.update(db.flashcardSetItems)
              ..where(
                (tbl) =>
                    tbl.setId.equals(setId) & tbl.id.equals(itemIds[index]),
              ))
            .write(FlashcardSetItemsCompanion(sortOrder: Value(index)));
      }
    });
  }

  Future<void> addSentenceCardToSet({
    required String setId,
    required String frontText,
    required String backText,
  }) async {
    await appendSentencePairsToSet(
      setId: setId,
      pairs: [MapEntry(frontText, backText)],
    );
  }

  Future<void> appendSentencePairsToSet({
    required String setId,
    required List<MapEntry<String, String>> pairs,
  }) async {
    if (pairs.isEmpty) return;

    final now = DateTime.now().toUtc().toIso8601String();
    final startOrder = await _countItems(setId);

    await db.transaction(() async {
      for (var index = 0; index < pairs.length; index += 1) {
        final pair = pairs[index];
        final termId = _uuid.v4();

        await db.into(db.terms).insert(
              TermsCompanion.insert(
                id: termId,
                type: 'sentence',
                frontText: pair.key.trim(),
                backText: Value(pair.value.trim()),
                frontLanguage: const Value('es-ES'),
                backLanguage: const Value('ko-KR'),
                createdAt: now,
                updatedAt: now,
              ),
            );

        await db.into(db.flashcardSetItems).insert(
              FlashcardSetItemsCompanion.insert(
                id: _uuid.v4(),
                setId: setId,
                termId: termId,
                sortOrder: Value(startOrder + index),
                createdAt: now,
              ),
            );
      }
    });
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
