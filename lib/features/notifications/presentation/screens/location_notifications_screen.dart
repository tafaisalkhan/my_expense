import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myexpence/core/theme/app_theme.dart';
import 'package:myexpence/features/notifications/domain/models/location_notification.dart';
import 'package:myexpence/features/notifications/presentation/providers/location_notification_providers.dart';

class LocationNotificationsScreen extends ConsumerStatefulWidget {
  const LocationNotificationsScreen({super.key});

  @override
  ConsumerState<LocationNotificationsScreen> createState() => _LocationNotificationsScreenState();
}

class _LocationNotificationsScreenState extends ConsumerState<LocationNotificationsScreen> {
  final _customPlaceController = TextEditingController();
  LocationType _selectedType = LocationType.petrolPump;

  @override
  void dispose() {
    _customPlaceController.dispose();
    super.dispose();
  }

  void _simulateLocationLeave(String placeName, LocationType type) async {
    final notifier = ref.read(locationNotificationProvider.notifier);
    final notif = await notifier.userLeftLocation(placeName: placeName, type: type);

    if (mounted) {
      if (notif == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔇 "$placeName" is Muted. No notification generated.'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📍 Triggered notification for leaving $placeName (${type.label})!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _showMapLocationPicker(BuildContext context) {
    context.push('/map-picker');
  }

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(locationNotificationProvider);
    final activeNotifs = notifState.activeNotifications;
    final mutedPlaces = notifState.mutedPlaces;
    final savedGeofences = notifState.savedGeofences;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Expense Reminders'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Header Card
            Card(
              color: AppTheme.primaryColor.withOpacity(0.08),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: AppTheme.primaryColor, size: 36),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Geofencing Location Reminders',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Prompts you after leaving Petrol Pump, Super Market, or Local Market to log expense details.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Daily End-of-Day Notification Card
            Card(
              color: Colors.indigo.withOpacity(0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.indigo.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.nights_stay, color: Colors.indigo, size: 28),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '🌙 Daily End-of-Day Expense Reminder',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.indigo),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Automated daily evening notification to remind you to log any left unrecorded expenses and approve or reject pending logs.',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.indigo,
                          side: BorderSide(color: Colors.indigo.shade300),
                        ),
                        onPressed: () {
                          ref.read(locationNotificationProvider.notifier).triggerManualDailyReminder();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🔔 Sent test End-of-Day Notification reminder!'),
                              backgroundColor: Colors.indigo,
                            ),
                          );
                        },
                        icon: const Icon(Icons.notifications_active, size: 16),
                        label: const Text('Test End-of-Day Notification Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Map Location Picker Trigger Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showMapLocationPicker(context),
                icon: const Icon(Icons.map),
                label: const Text('🗺️ Select Location on Map (Set Geofence)', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),

            // Quick Location Simulation Testing Panel
            Text(
              'Simulate Leaving Location',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.local_gas_station, size: 16),
                          label: const Text('Petrol Pump'),
                          onPressed: () => _simulateLocationLeave('Petrol Pump', LocationType.petrolPump),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.shopping_cart, size: 16),
                          label: const Text('Super Market'),
                          onPressed: () => _simulateLocationLeave('Super Market', LocationType.superMarket),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.storefront, size: 16),
                          label: const Text('Local Market'),
                          onPressed: () => _simulateLocationLeave('Local Market', LocationType.localMarket),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Custom Location Input Form
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _customPlaceController,
                          decoration: const InputDecoration(
                            hintText: 'e.g. City Fuel, Daily Super Mart',
                            labelText: 'Custom Place Name',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<LocationType>(
                                value: _selectedType,
                                isDense: true,
                                decoration: const InputDecoration(
                                  labelText: 'Category / Type',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                items: LocationType.values.map((t) {
                                  return DropdownMenuItem(value: t, child: Text(t.label, style: const TextStyle(fontSize: 12)));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedType = val);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                final name = _customPlaceController.text.trim();
                                if (name.isNotEmpty) {
                                  _simulateLocationLeave(name, _selectedType);
                                  _customPlaceController.clear();
                                }
                              },
                              icon: const Icon(Icons.send, size: 16),
                              label: const Text('Trigger'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Saved Map Geofences Section
            Text(
              'Saved Map Geofence Zones (${savedGeofences.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: savedGeofences.isEmpty
                    ? const Text('No geofences added yet. Tap "Select Location on Map" above to create geofenced zones.')
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: savedGeofences.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final geo = savedGeofences[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                              child: Icon(_getIconForType(geo.locationType), color: AppTheme.primaryColor),
                            ),
                            title: Text(geo.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              '${geo.locationType.label} (${geo.locationType.defaultCategoryName}) • ${geo.radiusMeters.round()}m radius',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Trigger Notification Reminder',
                                  onPressed: () => _simulateLocationLeave(geo.name, geo.locationType),
                                  icon: const Icon(Icons.notifications_active, size: 20, color: AppTheme.primaryColor),
                                ),
                                IconButton(
                                  tooltip: 'Remove Geofence Zone',
                                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                  onPressed: () {
                                    ref.read(locationNotificationProvider.notifier).deleteGeofenceTarget(geo.id);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Active Today Notifications Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Today's Active Reminders (${activeNotifs.length})",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    ref.read(locationNotificationProvider.notifier).triggerHourlyReminders();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Triggered hourly reminder check!')),
                    );
                  },
                  icon: const Icon(Icons.access_time, size: 16),
                  label: const Text('Hourly Check'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (activeNotifs.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.green, size: 40),
                        SizedBox(height: 8),
                        Text('No pending location reminders for today!'),
                        Text(
                          'Simulate leaving a place above to test smart geofencing notifications.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activeNotifs.length,
                itemBuilder: (context, index) {
                  final notif = activeNotifs[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                                child: Icon(_getIconForType(notif.locationType), color: AppTheme.primaryColor),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notif.placeName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${notif.locationType.label} (${notif.locationType.defaultCategoryName}) • Left today',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Chip(
                                label: Text(
                                  'Reminded ${notif.reminderCount}x',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: Colors.amber.withOpacity(0.2),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.grey[700],
                                  visualDensity: VisualDensity.compact,
                                ),
                                onPressed: () {
                                  ref.read(locationNotificationProvider.notifier).discardNotification(notif.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Cleared notification for ${notif.placeName}.')),
                                  );
                                },
                                icon: const Icon(Icons.close, size: 14),
                                label: const Text('Discard', style: TextStyle(fontSize: 12)),
                              ),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.orange[800],
                                  visualDensity: VisualDensity.compact,
                                ),
                                onPressed: () {
                                  ref.read(locationNotificationProvider.notifier).muteLocation(notif.placeName);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('🔇 Muted "${notif.placeName}". No future notifications will be sent.')),
                                  );
                                },
                                icon: const Icon(Icons.volume_off, size: 14),
                                label: const Text('Mute Place', style: TextStyle(fontSize: 12)),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  visualDensity: VisualDensity.compact,
                                ),
                                onPressed: () {
                                  ref.read(locationNotificationProvider.notifier).markLogged(notif.id);
                                  context.push('/add-expense');
                                },
                                icon: const Icon(Icons.add, size: 14),
                                label: const Text('Log Expense', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),

            // Muted Locations Manager Section
            Text(
              'Muted Locations (${mutedPlaces.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: mutedPlaces.isEmpty
                    ? const Text('No muted locations. Muting a place suppresses reminders permanently.')
                    : Column(
                        children: mutedPlaces.map((place) {
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.volume_off, color: Colors.orange),
                            title: Text(place, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: const Text('Muted • No notifications sent'),
                            trailing: TextButton(
                              onPressed: () {
                                ref.read(locationNotificationProvider.notifier).unmuteLocation(place);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Unmuted "$place".')),
                                );
                              },
                              child: const Text('Unmute'),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(LocationType type) {
    switch (type) {
      case LocationType.petrolPump:
        return Icons.local_gas_station;
      case LocationType.superMarket:
        return Icons.shopping_cart;
      case LocationType.localMarket:
        return Icons.storefront;
    }
  }
}

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.15)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 25) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 25) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


