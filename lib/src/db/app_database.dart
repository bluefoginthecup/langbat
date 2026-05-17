import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import '../services/app_path_service.dart';

part 'app_database.g.dart';

class Terms extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()(); // word | verb | sentence
  TextColumn get frontText => text()();
  TextColumn get backText => text().withDefault(const Constant(''))();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get frontLanguage => text().withDefault(const Constant('es-ES'))();
  TextColumn get backLanguage => text().withDefault(const Constant('ko-KR'))();
  TextColumn get imagePath => text().nullable()();
  TextColumn get audioFrontPath => text().nullable()();
  TextColumn get audioBackPath => text().nullable()();
  TextColumn get tagsJson => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get deletedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  List<Index> get indexes => [
        Index('idx_terms_type', 'type'),
        Index('idx_terms_front_text', 'frontText'),
        Index('idx_terms_deleted_at', 'deletedAt'),
      ];
}

class FlashcardSets extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get deletedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  List<Index> get indexes => [
        Index('idx_flashcard_sets_created_at', 'createdAt'),
        Index('idx_flashcard_sets_deleted_at', 'deletedAt'),
      ];
}

class FlashcardSetItems extends Table {
  TextColumn get id => text()();
  TextColumn get setId =>
      text().references(FlashcardSets, #id, onDelete: KeyAction.cascade)();
  TextColumn get termId =>
      text().references(Terms, #id, onDelete: KeyAction.cascade)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};

  List<Index> get indexes => [
        Index('idx_flashcard_set_items_set_id', 'setId'),
        Index('idx_flashcard_set_items_term_id', 'termId'),
      ];
}

class StudySessions extends Table {
  TextColumn get id => text()();
  TextColumn get setId => text().nullable()();
  TextColumn get startedAt => text()();
  TextColumn get endedAt => text().nullable()();
  IntColumn get cardsSeen => integer().withDefault(const Constant(0))();
  IntColumn get pointsEarned => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class StudyEvents extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId =>
      text().references(StudySessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get termId => text().nullable()();
  TextColumn get result => text().withDefault(const Constant('seen'))();
  TextColumn get shownAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class PointLogs extends Table {
  TextColumn get id => text()();
  IntColumn get amount => integer()();
  TextColumn get type => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class GardenCells extends Table {
  TextColumn get id => text()();
  IntColumn get row => integer()();
  IntColumn get col => integer()();
  TextColumn get itemType => text()();
  IntColumn get growth => integer().withDefault(const Constant(0))();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class InventoryItems extends Table {
  TextColumn get itemType => text()();
  IntColumn get count => integer().withDefault(const Constant(0))();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {itemType};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class MediaFiles extends Table {
  TextColumn get id => text()();
  TextColumn get ownerType => text()();
  TextColumn get ownerId => text()();
  TextColumn get role => text()(); // image | audio_front | audio_back
  TextColumn get relativePath => text()();
  IntColumn get sizeBytes => integer().withDefault(const Constant(0))();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Terms,
    FlashcardSets,
    FlashcardSetItems,
    StudySessions,
    StudyEvents,
    PointLogs,
    GardenCells,
    InventoryItems,
    AppSettings,
    MediaFiles,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_openConnection());

  static final AppDatabase instance = AppDatabase._();

  factory AppDatabase() => instance;

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final file = await const AppPathService().databaseFile();
    final parent = file.parent;
    if (!await parent.exists()) {
      await parent.create(recursive: true);
    }
    return NativeDatabase(File(file.path));
  });
}
