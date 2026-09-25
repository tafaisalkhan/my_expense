class Budget {
  final int? id;
  final String uuid;
  final String period; // YYYY-MM
  final String? categoryId; // null = Total Monthly Budget
  final String? personId; // null = Household
  final double amount;
  final double warningThreshold; // e.g. 0.90 for 90%
  final String createdAt;
  final String updatedAt;

  const Budget({
    this.id,
    required this.uuid,
    required this.period,
    this.categoryId,
    this.personId,
    required this.amount,
    this.warningThreshold = 0.90,
    required this.createdAt,
    required this.updatedAt,
  });

  Budget copyWith({
    int? id,
    String? uuid,
    String? period,
    String? categoryId,
    String? personId,
    double? amount,
    double? warningThreshold,
    String? createdAt,
    String? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      period: period ?? this.period,
      categoryId: categoryId ?? this.categoryId,
      personId: personId ?? this.personId,
      amount: amount ?? this.amount,
      warningThreshold: warningThreshold ?? this.warningThreshold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'uuid': uuid,
      'period': period,
      'categoryId': categoryId,
      'personId': personId,
      'amount': amount,
      'warningThreshold': warningThreshold,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as int?,
      uuid: map['uuid'] as String,
      period: map['period'] as String,
      categoryId: map['categoryId'] as String?,
      personId: map['personId'] as String?,
      amount: (map['amount'] as num).toDouble(),
      warningThreshold: (map['warningThreshold'] as num?)?.toDouble() ?? 0.90,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
    );
  }
}
