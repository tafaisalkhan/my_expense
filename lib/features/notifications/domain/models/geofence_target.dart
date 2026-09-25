import 'package:myexpence/features/notifications/domain/models/location_notification.dart';

class GeofenceTarget {
  final String id;
  final String name;
  final LocationType locationType;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final bool isActive;

  const GeofenceTarget({
    required this.id,
    required this.name,
    required this.locationType,
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 200.0,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'locationType': locationType.name,
        'latitude': latitude,
        'longitude': longitude,
        'radiusMeters': radiusMeters,
        'isActive': isActive,
      };

  factory GeofenceTarget.fromJson(Map<String, dynamic> json) => GeofenceTarget(
        id: json['id'] as String,
        name: json['name'] as String,
        locationType: LocationType.fromCode(json['locationType'] as String),
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        radiusMeters: (json['radiusMeters'] as num?)?.toDouble() ?? 200.0,
        isActive: json['isActive'] as bool? ?? true,
      );

  GeofenceTarget copyWith({
    String? id,
    String? name,
    LocationType? locationType,
    double? latitude,
    double? longitude,
    double? radiusMeters,
    bool? isActive,
  }) {
    return GeofenceTarget(
      id: id ?? this.id,
      name: name ?? this.name,
      locationType: locationType ?? this.locationType,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      isActive: isActive ?? this.isActive,
    );
  }
}
