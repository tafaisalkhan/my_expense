import 'package:myexpence/features/people/domain/models/person.dart';

abstract class IPersonRepository {
  Future<List<Person>> getAllPeople({bool activeOnly = true});
  Future<Person?> getPersonByUuid(String uuid);
  Future<Person> addPerson(Person person);
  Future<void> updatePerson(Person person);
  Future<void> deletePerson(String uuid);
}
