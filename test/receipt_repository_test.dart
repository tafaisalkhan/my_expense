import 'package:flutter_test/flutter_test.dart';
import 'package:myexpence/core/database/app_database.dart';
import 'package:myexpence/features/receipts/data/repositories/receipt_repository_impl.dart';
import 'package:myexpence/features/receipts/domain/models/receipt.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database testDb;
  late SqliteReceiptRepository repository;

  setUp(() async {
    testDb = await openDatabase(
      inMemoryDatabasePath,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE receipts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            uuid TEXT UNIQUE NOT NULL,
            imagePath TEXT NOT NULL,
            rawOcrText TEXT,
            merchant TEXT,
            detectedTotal REAL,
            detectedDate TEXT,
            scanDate TEXT NOT NULL,
            fileHash TEXT,
            createdAt TEXT NOT NULL
          );
        ''');
      },
    );

    final mockAppDb = TestAppDatabase(testDb);
    repository = SqliteReceiptRepository(mockAppDb);
  });

  tearDown(() async {
    await testDb.close();
  });

  test('Save and retrieve shared receipt slip image details', () async {
    const uuidGen = Uuid();
    final nowStr = DateTime.now().toIso8601String();

    final receipt = Receipt(
      uuid: uuidGen.v4(),
      imagePath: '/storage/emulated/0/Download/exam_fee_slip.jpg',
      merchant: 'ABC School',
      detectedTotal: 8500.0,
      scanDate: '2026-09-24',
      createdAt: nowStr,
    );

    final saved = await repository.saveReceipt(receipt);
    expect(saved.id, isNotNull);

    final retrieved = await repository.getReceiptByUuid(saved.uuid);
    expect(retrieved?.merchant, equals('ABC School'));
    expect(retrieved?.detectedTotal, equals(8500.0));
    expect(retrieved?.imagePath, equals('/storage/emulated/0/Download/exam_fee_slip.jpg'));
  });
}

class TestAppDatabase implements AppDatabase {
  final Database db;
  TestAppDatabase(this.db);

  @override
  Future<Database> get database async => db;

  @override
  Future<void> clearAllData() async {}

  @override
  Future<void> close() async {}
}
