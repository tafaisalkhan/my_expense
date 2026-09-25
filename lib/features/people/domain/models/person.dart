class Person {
  final int? id;
  final String uuid;
  final String name;
  final String? relationship;
  final String? nickname;
  final String? schoolName;
  final String? grade;
  final String? notes;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  const Person({
    this.id,
    required this.uuid,
    required this.name,
    this.relationship,
    this.nickname,
    this.schoolName,
    this.grade,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Person copyWith({
    int? id,
    String? uuid,
    String? name,
    String? relationship,
    String? nickname,
    String? schoolName,
    String? grade,
    String? notes,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
  }) {
    return Person(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      nickname: nickname ?? this.nickname,
      schoolName: schoolName ?? this.schoolName,
      grade: grade ?? this.grade,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'uuid': uuid,
      'name': name,
      'relationship': relationship,
      'nickname': nickname,
      'schoolName': schoolName,
      'grade': grade,
      'notes': notes,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      id: map['id'] as int?,
      uuid: map['uuid'] as String,
      name: map['name'] as String,
      relationship: map['relationship'] as String?,
      nickname: map['nickname'] as String?,
      schoolName: map['schoolName'] as String?,
      grade: map['grade'] as String?,
      notes: map['notes'] as String?,
      isActive: (map['isActive'] as int) == 1,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
    );
  }
}
