import 'package:myexpence/core/database/app_database.dart';
import 'package:myexpence/features/people/domain/models/person.dart';
import 'package:myexpence/features/people/domain/repositories/person_repository.dart';
import 'package:uuid/uuid.dart';

class SqlitePersonRepository implements IPersonRepository {
  final AppDatabase appDatabase;
  final Uuid _uuidGen = const Uuid();

  SqlitePersonRepository(this.appDatabase);

  @override
  Future<List<Person>> getAllPeople({bool activeOnly = true}) async {
    final db = await appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'people',
      where: activeOnly ? 'isActive = 1' : null,
      orderBy: 'id ASC',
    );
    return maps.map((map) => Person.fromMap(map)).toList();
  }

  @override
  Future<Person?> getPersonByUuid(String uuid) async {
    final db = await appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'people',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
    if (maps.isEmpty) return null;
    return Person.fromMap(maps.first);
  }

  @override
  Future<Person> addPerson(Person person) async {
    final db = await appDatabase.database;
    final now = DateTime.now().toIso8601String();
    final newUuid = person.uuid.isNotEmpty ? person.uuid : _uuidGen.v4();

    final personToInsert = person.copyWith(
      uuid: newUuid,
      createdAt: now,
      updatedAt: now,
    );

    final id = await db.insert('people', personToInsert.toMap());
    return personToInsert.copyWith(id: id);
  }

  @override
  Future<void> updatePerson(Person person) async {
    final db = await appDatabase.database;
    final now = DateTime.now().toIso8601String();
    final updated = person.copyWith(updatedAt: now);

    await db.update(
      'people',
      updated.toMap(),
      where: 'uuid = ?',
      whereArgs: [person.uuid],
    );
  }

  @override
  Future<void> deletePerson(String uuid) async {
    final db = await appDatabase.database;
    final now = DateTime.now().toIso8601String();

    await db.update(
      'people',
      {'isActive': 0, 'updatedAt': now},
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
  }
}
