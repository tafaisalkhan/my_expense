enum LocationType {
  petrolPump('Petrol Pump', 'cat_car', 'Fuel & Transport'),
  superMarket('Super Market', 'cat_food', 'Food & Groceries'),
  localMarket('Local Market', 'cat_food', 'Food & Groceries');

  final String label;
  final String defaultCategoryId;
  final String defaultCategoryName;

  const LocationType(this.label, this.defaultCategoryId, this.defaultCategoryName);

  static LocationType fromCode(String code) {
    final lower = code.toLowerCase();
    if (lower.contains('petrol') || lower.contains('fuel') || lower.contains('gas')) {
      return LocationType.petrolPump;
    }
    if (lower.contains('super') || lower.contains('mart') || lower.contains('mall')) {
      return LocationType.superMarket;
    }
    if (lower.contains('local') || lower.contains('market')) {
      return LocationType.localMarket;
    }
    return LocationType.values.firstWhere(
      (e) => e.name.toLowerCase() == lower,
      orElse: () => LocationType.superMarket,
    );
  }
}

class LocationVisitNotification {
  final String id;
  final String placeName;
  final LocationType locationType;
  final String visitDateIso; // YYYY-MM-DD
  final String leftAtIso; // Full ISO timestamp when user left
  final String lastRemindedAtIso;
  final int reminderCount;
  final bool isLogged;
  final bool isMuted;
  final bool isDiscarded;

  const LocationVisitNotification({
    required this.id,
    required this.placeName,
    required this.locationType,
    required this.visitDateIso,
    required this.leftAtIso,
    required this.lastRemindedAtIso,
    this.reminderCount = 1,
    this.isLogged = false,
    this.isMuted = false,
    this.isDiscarded = false,
  });

  bool get isExpired {
    final todayIso = DateTime.now().toIso8601String().split('T').first;
    return visitDateIso != todayIso;
  }

  bool get isActive => !isLogged && !isMuted && !isDiscarded && !isExpired;

  LocationVisitNotification copyWith({
    String? id,
    String? placeName,
    LocationType? locationType,
    String? visitDateIso,
    String? leftAtIso,
    String? lastRemindedAtIso,
    int? reminderCount,
    bool? isLogged,
    bool? isMuted,
    bool? isDiscarded,
  }) {
    return LocationVisitNotification(
      id: id ?? this.id,
      placeName: placeName ?? this.placeName,
      locationType: locationType ?? this.locationType,
      visitDateIso: visitDateIso ?? this.visitDateIso,
      leftAtIso: leftAtIso ?? this.leftAtIso,
      lastRemindedAtIso: lastRemindedAtIso ?? this.lastRemindedAtIso,
      reminderCount: reminderCount ?? this.reminderCount,
      isLogged: isLogged ?? this.isLogged,
      isMuted: isMuted ?? this.isMuted,
      isDiscarded: isDiscarded ?? this.isDiscarded,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'placeName': placeName,
        'locationType': locationType.name,
        'visitDateIso': visitDateIso,
        'leftAtIso': leftAtIso,
        'lastRemindedAtIso': lastRemindedAtIso,
        'reminderCount': reminderCount,
        'isLogged': isLogged,
        'isMuted': isMuted,
        'isDiscarded': isDiscarded,
      };

  factory LocationVisitNotification.fromJson(Map<String, dynamic> json) => LocationVisitNotification(
        id: json['id'] as String,
        placeName: json['placeName'] as String,
        locationType: LocationType.fromCode(json['locationType'] as String),
        visitDateIso: json['visitDateIso'] as String,
        leftAtIso: json['leftAtIso'] as String,
        lastRemindedAtIso: json['lastRemindedAtIso'] as String,
        reminderCount: json['reminderCount'] as int? ?? 1,
        isLogged: json['isLogged'] as bool? ?? false,
        isMuted: json['isMuted'] as bool? ?? false,
        isDiscarded: json['isDiscarded'] as bool? ?? false,
      );
}
