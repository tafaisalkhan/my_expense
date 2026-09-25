import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myexpence/features/notifications/domain/models/geofence_target.dart';
import 'package:myexpence/features/notifications/domain/models/location_notification.dart';

class LocationNotificationState {
  final List<LocationVisitNotification> todayNotifications;
  final Set<String> mutedPlaces;
  final List<GeofenceTarget> savedGeofences;

  const LocationNotificationState({
    this.todayNotifications = const [],
    this.mutedPlaces = const {},
    this.savedGeofences = const [],
  });

  List<LocationVisitNotification> get activeNotifications =>
      todayNotifications.where((n) => n.isActive).toList();

  LocationNotificationState copyWith({
    List<LocationVisitNotification>? todayNotifications,
    Set<String>? mutedPlaces,
    List<GeofenceTarget>? savedGeofences,
  }) {
    return LocationNotificationState(
      todayNotifications: todayNotifications ?? this.todayNotifications,
      mutedPlaces: mutedPlaces ?? this.mutedPlaces,
      savedGeofences: savedGeofences ?? this.savedGeofences,
    );
  }
}

class LocationNotificationNotifier extends StateNotifier<LocationNotificationState> {
  LocationNotificationNotifier() : super(const LocationNotificationState()) {
    _init();
  }

  LocationNotificationState get currentState => state;

  static const String _prefKeyNotifs = 'location_notifications_v1';
  static const String _prefKeyMuted = 'location_muted_places_v1';
  static const String _prefKeyGeofences = 'location_geofences_v1';

  final FlutterLocalNotificationsPlugin _localNotifs = FlutterLocalNotificationsPlugin();

  Future<void> _init() async {
    await _initLocalNotifications();
    await loadNotifications();
  }

  Future<void> _initLocalNotifications() async {
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);
      await _localNotifs.initialize(initSettings);
      final androidImplementation = _localNotifs
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }
      await scheduleDailyEndOfDayReminder();
    } catch (_) {}
  }

  Future<void> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Load Muted Places
    final mutedList = prefs.getStringList(_prefKeyMuted) ?? [];
    final mutedPlaces = mutedList.map((e) => e.toUpperCase()).toSet();

    // 2. Load Notifications & Filter Previous Day Expiry
    final todayIso = DateTime.now().toIso8601String().split('T').first;
    final jsonListStr = prefs.getString(_prefKeyNotifs);

    List<LocationVisitNotification> notifications = [];
    if (jsonListStr != null) {
      try {
        final List raw = jsonDecode(jsonListStr);
        notifications = raw
            .map((item) => LocationVisitNotification.fromJson(item))
            .where((n) => n.visitDateIso == todayIso)
            .toList();
      } catch (_) {}
    }

    // 3. Load Saved Map Geofences
    final geofencesJsonStr = prefs.getString(_prefKeyGeofences);
    List<GeofenceTarget> geofences = [];
    if (geofencesJsonStr != null) {
      try {
        final List rawGeo = jsonDecode(geofencesJsonStr);
        geofences = rawGeo.map((item) => GeofenceTarget.fromJson(item)).toList();
      } catch (_) {}
    }

    state = state.copyWith(
      todayNotifications: notifications,
      mutedPlaces: mutedPlaces,
      savedGeofences: geofences,
    );

    await _saveToPrefs();
  }

  /// Adds a map-selected geofence zone target
  Future<void> addGeofenceTarget(GeofenceTarget target) async {
    final updated = [...state.savedGeofences.where((g) => g.id != target.id), target];
    state = state.copyWith(savedGeofences: updated);

    final prefs = await SharedPreferences.getInstance();
    final raw = updated.map((e) => e.toJson()).toList();
    await prefs.setString(_prefKeyGeofences, jsonEncode(raw));
  }

  /// Removes a saved geofence zone
  Future<void> deleteGeofenceTarget(String id) async {
    final updated = state.savedGeofences.where((g) => g.id != id).toList();
    state = state.copyWith(savedGeofences: updated);

    final prefs = await SharedPreferences.getInstance();
    final raw = updated.map((e) => e.toJson()).toList();
    await prefs.setString(_prefKeyGeofences, jsonEncode(raw));
  }

  /// Triggers when user LEAVES a commercial location or map geofence zone
  Future<LocationVisitNotification?> userLeftLocation({
    required String placeName,
    required LocationType type,
  }) async {
    final upperPlace = placeName.trim().toUpperCase();

    if (state.mutedPlaces.contains(upperPlace)) {
      return null;
    }

    final now = DateTime.now();
    final todayIso = now.toIso8601String().split('T').first;
    final nowIso = now.toIso8601String();

    final notifId = 'loc_${type.name}_${now.millisecondsSinceEpoch}';

    final notif = LocationVisitNotification(
      id: notifId,
      placeName: placeName.trim(),
      locationType: type,
      visitDateIso: todayIso,
      leftAtIso: nowIso,
      lastRemindedAtIso: nowIso,
      reminderCount: 1,
      isLogged: false,
      isMuted: false,
      isDiscarded: false,
    );

    final updated = [...state.todayNotifications, notif];
    state = state.copyWith(todayNotifications: updated);
    await _saveToPrefs();

    await _sendPushNotification(notif);

    return notif;
  }

  Future<void> triggerHourlyReminders() async {
    final now = DateTime.now();
    final todayIso = now.toIso8601String().split('T').first;

    final updated = <LocationVisitNotification>[];

    for (final notif in state.todayNotifications) {
      if (notif.visitDateIso == todayIso && notif.isActive) {
        final lastReminded = DateTime.tryParse(notif.lastRemindedAtIso) ?? now;
        final hoursDiff = now.difference(lastReminded).inHours;

        if (hoursDiff >= 1) {
          final nextNotif = notif.copyWith(
            reminderCount: notif.reminderCount + 1,
            lastRemindedAtIso: now.toIso8601String(),
          );
          updated.add(nextNotif);
          await _sendPushNotification(nextNotif);
        } else {
          updated.add(notif);
        }
      } else if (!notif.isExpired) {
        updated.add(notif);
      }
    }

    state = state.copyWith(todayNotifications: updated);
    await _saveToPrefs();
  }

  Future<void> muteLocation(String placeName) async {
    final upperPlace = placeName.trim().toUpperCase();
    final updatedMuted = {...state.mutedPlaces, upperPlace};

    final updatedNotifs = state.todayNotifications.map((n) {
      if (n.placeName.trim().toUpperCase() == upperPlace) {
        return n.copyWith(isMuted: true);
      }
      return n;
    }).toList();

    state = state.copyWith(
      mutedPlaces: updatedMuted,
      todayNotifications: updatedNotifs,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKeyMuted, updatedMuted.toList());
    await _saveToPrefs();
  }

  Future<void> unmuteLocation(String placeName) async {
    final upperPlace = placeName.trim().toUpperCase();
    final updatedMuted = state.mutedPlaces.where((p) => p != upperPlace).toSet();

    state = state.copyWith(mutedPlaces: updatedMuted);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKeyMuted, updatedMuted.toList());
  }

  Future<void> discardNotification(String id) async {
    final updatedNotifs = state.todayNotifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isDiscarded: true);
      }
      return n;
    }).toList();

    state = state.copyWith(todayNotifications: updatedNotifs);
    await _saveToPrefs();
  }

  Future<void> markLogged(String id) async {
    final updatedNotifs = state.todayNotifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isLogged: true);
      }
      return n;
    }).toList();

    state = state.copyWith(todayNotifications: updatedNotifs);
    await _saveToPrefs();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = state.todayNotifications.map((e) => e.toJson()).toList();
    await prefs.setString(_prefKeyNotifs, jsonEncode(raw));
  }

  Future<void> _sendPushNotification(LocationVisitNotification notif) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'location_reminders_channel',
        'Location Reminders',
        channelDescription: 'Expense logging notifications after leaving Mart, Petrol Pump, Hospital, or Mall.',
        importance: Importance.high,
        priority: Priority.high,
      );
      const details = NotificationDetails(android: androidDetails);

      final title = '📍 Left ${notif.placeName} (${notif.locationType.label})';
      final body = 'Did you make a purchase at ${notif.placeName}? Tap to log expense details.'
          '${notif.reminderCount > 1 ? ' (Hourly reminder #${notif.reminderCount})' : ''}';

      await _localNotifs.show(
        notif.id.hashCode,
        title,
        body,
        details,
      );
    } catch (_) {}
  }

  Future<void> scheduleDailyEndOfDayReminder() async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'daily_end_of_day_channel',
        'End of Day Expense Reminders',
        channelDescription: 'Daily evening reminder to add left expenses and approve or reject pending logs.',
        importance: Importance.high,
        priority: Priority.high,
      );
      const details = NotificationDetails(android: androidDetails);

      await _localNotifs.periodicallyShow(
        8888,
        '🌙 Daily End of Day Expense Check',
        'Have any left expenses for today? Open MyExpense to add them or approve/reject pending items.',
        RepeatInterval.daily,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {}
  }

  Future<void> triggerManualDailyReminder() async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'daily_end_of_day_channel',
        'End of Day Expense Reminders',
        channelDescription: 'Daily evening reminder to add left expenses and approve or reject pending logs.',
        importance: Importance.high,
        priority: Priority.high,
      );
      const details = NotificationDetails(android: androidDetails);

      await _localNotifs.show(
        9999,
        '🌙 Daily End of Day Expense Check',
        'Don\'t forget to add any left expenses for today, or review approve/reject pending receipts!',
        details,
      );
    } catch (_) {}
  }
}

final locationNotificationProvider =
    StateNotifierProvider<LocationNotificationNotifier, LocationNotificationState>((ref) {
  return LocationNotificationNotifier();
});
