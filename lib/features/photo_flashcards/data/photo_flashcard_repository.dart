import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import 'package:langbat/features/photo_flashcards/data/photo_asset_service.dart';
import 'package:langbat/features/photo_flashcards/data/photo_flashcard_models.dart';
import 'package:langbat/src/db/app_database.dart';
import 'package:langbat/src/services/app_path_service.dart';

class PhotoFlashcardRepository {
  PhotoFlashcardRepository({
    AppDatabase? db,
    AppPathService? paths,
    PhotoAssetService? assetService,
  })  : db = db ?? AppDatabase(),
        paths = paths ?? const AppPathService(),
        assetService = assetService ?? const PhotoAssetService();

  static const type = 'photo_sentence';
  static const _uuid = Uuid();

  final AppDatabase db;
  final AppPathService paths;
  final PhotoAssetService assetService;

  Stream<List<PhotoFlashcardDeck>> watchDecks() {
    final query = db.select(db.flashcardSets)
      ..where((tbl) => tbl.deletedAt.isNull())
      ..orderBy([
        (tbl) => OrderingTerm(
              expression: tbl.updatedAt,
              mode: OrderingMode.desc,
            ),
      ]);

    return query.watch().asyncMap((sets) async {
      final decks = <PhotoFlashcardDeck>[];
      for (final set in sets) {
        final count = await _countPhotoCards(set.id);
        if (count == 0) continue;
        decks.add(
          PhotoFlashcardDeck(
            id: set.id,
            title: set.title,
            description: set.description,
            createdAt: DateTime.parse(set.createdAt),
            updatedAt: DateTime.parse(set.updatedAt),
            cardCount: count,
          ),
        );
      }
      return decks;
    });
  }

  Future<PhotoFlashcardDeck?> getDeck(String deckId) async {
    final row = await (db.select(db.flashcardSets)
          ..where((tbl) => tbl.id.equals(deckId) & tbl.deletedAt.isNull()))
        .getSingleOrNull();
    if (row == null) return null;

    return PhotoFlashcardDeck(
      id: row.id,
      title: row.title,
      description: row.description,
      createdAt: DateTime.parse(row.createdAt),
      updatedAt: DateTime.parse(row.updatedAt),
      cardCount: await _countPhotoCards(deckId),
    );
  }

  Future<String> createDeckFromPhotos({
    required String title,
    String description = '',
    required List<XFile> photos,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final deckId = _uuid.v4();

    await db.into(db.flashcardSets).insert(
          FlashcardSetsCompanion.insert(
            id: deckId,
            title: title.trim().isEmpty ? '사진 플래시카드' : title.trim(),
            description: Value(description),
            createdAt: now,
            updatedAt: now,
          ),
        );

    await addPhotosToDeck(deckId: deckId, photos: photos);
    return deckId;
  }

  Future<void> addPhotosToDeck({
    required String deckId,
    required List<XFile> photos,
  }) async {
    if (photos.isEmpty) return;

    final startOrder = await _countItems(deckId);
    final now = DateTime.now().toUtc().toIso8601String();

    for (var index = 0; index < photos.length; index += 1) {
      final termId = _uuid.v4();
      final stored = await assetService.storePhoto(
        termId: termId,
        source: photos[index],
      );

      await db.transaction(() async {
        await db.into(db.terms).insert(
              TermsCompanion.insert(
                id: termId,
                type: type,
                frontText: '',
                backText: const Value(''),
                frontLanguage: const Value('es-ES'),
                backLanguage: const Value('ko-KR'),
                imagePath: Value(stored.imagePath),
                tagsJson: Value(jsonEncode({
                  'thumbnailPath': stored.thumbnailPath,
                })),
                createdAt: now,
                updatedAt: now,
              ),
            );

        await db.into(db.flashcardSetItems).insert(
              FlashcardSetItemsCompanion.insert(
                id: _uuid.v4(),
                setId: deckId,
                termId: termId,
                sortOrder: Value(startOrder + index),
                createdAt: now,
              ),
            );
      });
    }

    await (db.update(db.flashcardSets)..where((tbl) => tbl.id.equals(deckId)))
        .write(FlashcardSetsCompanion(updatedAt: Value(now)));
  }

  Future<void> updateDeck({
    required String deckId,
    required String title,
    String description = '',
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await (db.update(db.flashcardSets)..where((tbl) => tbl.id.equals(deckId)))
        .write(
      FlashcardSetsCompanion(
        title: Value(title.trim().isEmpty ? '사진 플래시카드' : title.trim()),
        description: Value(description),
        updatedAt: Value(now),
      ),
    );
  }

  Future<List<PhotoFlashcard>> loadCards(String deckId) async {
    final query = db.select(db.flashcardSetItems).join([
      innerJoin(db.terms, db.terms.id.equalsExp(db.flashcardSetItems.termId)),
    ])
      ..where(
        db.flashcardSetItems.setId.equals(deckId) &
            db.terms.deletedAt.isNull() &
            db.terms.type.equals(type),
      )
      ..orderBy([
        OrderingTerm(
          expression: db.flashcardSetItems.sortOrder,
          mode: OrderingMode.asc,
        ),
      ]);

    final rows = await query.get();
    final cards = <PhotoFlashcard>[];
    for (final row in rows) {
      final item = row.readTable(db.flashcardSetItems);
      final term = row.readTable(db.terms);
      final imagePath = term.imagePath;
      final thumbPath = _thumbnailPathFromTags(term.tagsJson);
      cards.add(
        PhotoFlashcard(
          itemId: item.id,
          termId: term.id,
          spanishText: term.frontText,
          koreanText: term.backText,
          imagePath: imagePath,
          imageAbsolutePath: imagePath == null
              ? null
              : (await paths.resolveAppFile(imagePath)).path,
          thumbnailPath: thumbPath,
          thumbnailAbsolutePath: thumbPath == null
              ? null
              : (await paths.resolveAppFile(thumbPath)).path,
          order: item.sortOrder,
          createdAt: DateTime.parse(term.createdAt),
          updatedAt: DateTime.parse(term.updatedAt),
        ),
      );
    }
    return cards;
  }

  Future<void> updateCardText({
    required String termId,
    required String spanishText,
    required String koreanText,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await (db.update(db.terms)..where((tbl) => tbl.id.equals(termId))).write(
      TermsCompanion(
        frontText: Value(spanishText.trim()),
        backText: Value(koreanText.trim()),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> removeCardsFromDeck({
    required String deckId,
    required Iterable<String> itemIds,
  }) async {
    final ids = itemIds.toList(growable: false);
    if (ids.isEmpty) return;
    await (db.delete(db.flashcardSetItems)
          ..where((tbl) => tbl.setId.equals(deckId) & tbl.id.isIn(ids)))
        .go();
  }

  Future<int> _countPhotoCards(String deckId) async {
    final count = db.flashcardSetItems.id.count();
    final query = db.selectOnly(db.flashcardSetItems).join([
      innerJoin(db.terms, db.terms.id.equalsExp(db.flashcardSetItems.termId)),
    ])
      ..addColumns([count])
      ..where(
        db.flashcardSetItems.setId.equals(deckId) &
            db.terms.type.equals(type) &
            db.terms.deletedAt.isNull(),
      );
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<int> _countItems(String deckId) async {
    final count = db.flashcardSetItems.id.count();
    final query = db.selectOnly(db.flashcardSetItems)
      ..addColumns([count])
      ..where(db.flashcardSetItems.setId.equals(deckId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  String? _thumbnailPathFromTags(String? tagsJson) {
    if (tagsJson == null || tagsJson.isEmpty) return null;
    try {
      final decoded = jsonDecode(tagsJson);
      if (decoded is! Map<String, dynamic>) return null;
      final value = decoded['thumbnailPath'];
      return value is String && value.isNotEmpty ? value : null;
    } catch (_) {
      return null;
    }
  }
}
