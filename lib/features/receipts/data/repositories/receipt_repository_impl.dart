import 'package:sqflite/sqflite.dart';
import 'package:myexpence/core/database/app_database.dart';
import 'package:myexpence/features/receipts/domain/models/receipt.dart';
import 'package:myexpence/features/receipts/domain/repositories/receipt_repository.dart';
import 'package:uuid/uuid.dart';

class SqliteReceiptRepository implements IReceiptRepository {
  final AppDatabase appDatabase;
  final Uuid _uuidGen = const Uuid();

  SqliteReceiptRepository(this.appDatabase);

  @override
  Future<Receipt> saveReceipt(Receipt receipt) async {
    final db = await appDatabase.database;
    final now = DateTime.now().toIso8601String();
    final newUuid = receipt.uuid.isNotEmpty ? receipt.uuid : _uuidGen.v4();

    final toInsert = Receipt(
      uuid: newUuid,
      imagePath: receipt.imagePath,
      rawOcrText: receipt.rawOcrText,
      merchant: receipt.merchant,
      detectedTotal: receipt.detectedTotal,
      detectedDate: receipt.detectedDate,
      scanDate: receipt.scanDate.isNotEmpty ? receipt.scanDate : now,
      fileHash: receipt.fileHash,
      createdAt: now,
    );

    final id = await db.insert('receipts', toInsert.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return Receipt.fromMap({...toInsert.toMap(), 'id': id});
  }

  @override
  Future<Receipt?> getReceiptByUuid(String uuid) async {
    final db = await appDatabase.database;
    final maps = await db.query(
      'receipts',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
    if (maps.isEmpty) return null;
    return Receipt.fromMap(maps.first);
  }

  @override
  Future<List<Receipt>> getAllReceipts() async {
    final db = await appDatabase.database;
    final maps = await db.query('receipts', orderBy: 'createdAt DESC');
    return maps.map((map) => Receipt.fromMap(map)).toList();
  }
}
