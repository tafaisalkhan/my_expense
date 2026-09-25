import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myexpence/core/providers/core_providers.dart';
import 'package:myexpence/core/theme/app_theme.dart';
import 'package:myexpence/features/people/domain/models/person.dart';
import 'package:uuid/uuid.dart';

final peopleListProvider = FutureProvider<List<Person>>((ref) async {
  final repo = ref.watch(personRepositoryProvider);
  return await repo.getAllPeople(activeOnly: true);
});

class PersonNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  PersonNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<Person> addPerson(Person person) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(personRepositoryProvider);
      final addedPerson = await repo.addPerson(person);
      ref.invalidate(peopleListProvider);
      state = const AsyncValue.data(null);
      return addedPerson;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updatePerson(Person person) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(personRepositoryProvider);
      await repo.updatePerson(person);
      ref.invalidate(peopleListProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deletePerson(String uuid) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(personRepositoryProvider);
      await repo.deletePerson(uuid);
      ref.invalidate(peopleListProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final personNotifierProvider = StateNotifierProvider<PersonNotifier, AsyncValue<void>>((ref) {
  return PersonNotifier(ref);
});

/// Helper dialog to add or edit family members anywhere in the app
Future<Person?> showAddPersonDialog(
  BuildContext context,
  WidgetRef ref, {
  Person? existingPerson,
  String? prefilledRelationship,
}) async {
  final nameController = TextEditingController(text: existingPerson?.name ?? '');
  final relationController = TextEditingController(text: existingPerson?.relationship ?? prefilledRelationship ?? '');
  final schoolController = TextEditingController(text: existingPerson?.schoolName ?? '');
  final gradeController = TextEditingController(text: existingPerson?.grade ?? '');
  final notesController = TextEditingController(text: existingPerson?.notes ?? '');

  const relationshipPresets = ['Self', 'Spouse', 'Son', 'Daughter', 'Father', 'Mother', 'Brother', 'Sister', 'Student', 'Other'];

  Person? createdPerson;

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          scrollable: true,
          title: Row(
            children: [
              const Icon(Icons.person_add, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  existingPerson == null ? 'Add Family Member' : 'Edit Family Member',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    hintText: 'e.g. Sara, Ahmed, Spouse',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                const Text('Relationship Presets:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: relationshipPresets.map((preset) {
                    final isSelected = relationController.text.trim().toLowerCase() == preset.toLowerCase();
                    return ChoiceChip(
                      label: Text(preset, style: const TextStyle(fontSize: 11)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          relationController.text = selected ? preset : '';
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: relationController,
                  decoration: const InputDecoration(
                    labelText: 'Custom Relationship',
                    hintText: 'e.g. Son, Wife, Father, Student',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: schoolController,
                  decoration: const InputDecoration(
                    labelText: 'School / College (Optional)',
                    hintText: 'e.g. City School, Grammar Academy',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: gradeController,
                  decoration: const InputDecoration(
                    labelText: 'Grade / Class (Optional)',
                    hintText: 'e.g. Grade 5, Class 10',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                final nowStr = DateTime.now().toIso8601String();
                final person = Person(
                  id: existingPerson?.id,
                  uuid: existingPerson?.uuid ?? const Uuid().v4(),
                  name: name,
                  relationship: relationController.text.trim().isNotEmpty ? relationController.text.trim() : null,
                  schoolName: schoolController.text.trim().isNotEmpty ? schoolController.text.trim() : null,
                  grade: gradeController.text.trim().isNotEmpty ? gradeController.text.trim() : null,
                  notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
                  createdAt: existingPerson?.createdAt ?? nowStr,
                  updatedAt: nowStr,
                );

                if (existingPerson == null) {
                  createdPerson = await ref.read(personNotifierProvider.notifier).addPerson(person);
                } else {
                  await ref.read(personNotifierProvider.notifier).updatePerson(person);
                  createdPerson = person;
                }

                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save Profile'),
            ),
          ],
        );
      },
    ),
  );

  return createdPerson;
}
