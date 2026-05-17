import 'package:drift/drift.dart';

import '../db/app_database.dart';

class GardenRepository {
  GardenRepository({AppDatabase? db}) : db = db ?? AppDatabase();

  final AppDatabase db;

  Future<List<GardenCell>> loadGardenCells() {
    return db.select(db.gardenCells).get();
  }

  Future<List<InventoryItem>> loadInventory() {
    return db.select(db.inventoryItems).get();
  }

  Future<void> upsertInventoryItem({
    required String itemType,
    required int count,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await db.into(db.inventoryItems).insertOnConflictUpdate(
          InventoryItemsCompanion.insert(
            itemType: itemType,
            count: Value(count),
            updatedAt: now,
          ),
        );
  }

  Future<void> upsertGardenCell({
    required int row,
    required int col,
    required String itemType,
    required int growth,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await db.into(db.gardenCells).insertOnConflictUpdate(
          GardenCellsCompanion.insert(
            id: '${row}_$col',
            row: row,
            col: col,
            itemType: itemType,
            growth: Value(growth),
            updatedAt: now,
          ),
        );
  }
}
