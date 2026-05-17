import '../db/app_database.dart';

class SettingsRepository {
  SettingsRepository({AppDatabase? db}) : db = db ?? AppDatabase();

  final AppDatabase db;

  Future<String?> getString(String key) async {
    final row = await (db.select(db.appSettings)
          ..where((tbl) => tbl.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setString(String key, String value) async {
    await db.into(db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: key,
            value: value,
            updatedAt: DateTime.now().toUtc().toIso8601String(),
          ),
        );
  }
}
