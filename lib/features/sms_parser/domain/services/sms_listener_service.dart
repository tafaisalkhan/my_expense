import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myexpence/features/sms_parser/domain/services/sms_parser_service.dart';
import 'package:myexpence/features/sms_parser/presentation/providers/sms_whitelist_provider.dart';

class SmsListenerService {
  static const _eventChannel = EventChannel('com.myexpense.app/sms_receiver');
  static const _methodChannel = MethodChannel('com.myexpense.app/sms_permissions');

  StreamSubscription? _subscription;

  /// Check whether RECEIVE_SMS and READ_SMS permissions are granted on Android
  static Future<bool> checkPermission() async {
    try {
      final bool hasPermission = await _methodChannel.invokeMethod('checkSmsPermission');
      return hasPermission;
    } catch (_) {
      return false;
    }
  }

  /// Request RECEIVE_SMS and READ_SMS permissions from user on Android
  static Future<bool> requestPermission() async {
    try {
      final bool requested = await _methodChannel.invokeMethod('requestSmsPermission');
      return requested;
    } catch (_) {
      return false;
    }
  }

  /// Start listening to incoming Android SMS broadcasts
  void startListening(WidgetRef ref, {required Function(SmsParseResult result) onWhitelistedSmsReceived}) {
    _subscription?.cancel();
    _subscription = _eventChannel.receiveBroadcastStream().listen((dynamic event) {
      if (event is Map) {
        final sender = event['sender'] as String? ?? '';
        final body = event['body'] as String? ?? '';

        if (sender.isNotEmpty && body.isNotEmpty) {
          final whitelist = ref.read(smsWhitelistProvider);
          final parsed = SmsParserService.parseSmsText(
            body,
            sender: sender,
            customAllowedSenders: whitelist,
          );

          // Only trigger automatic expense prompt if sender is in user whitelist
          if (parsed.isKnownSender) {
            onWhitelistedSmsReceived(parsed);
          }
        }
      }
    }, onError: (dynamic error) {
      // Handle stream errors silently
    });
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }
}

final smsListenerServiceProvider = Provider<SmsListenerService>((ref) {
  return SmsListenerService();
});
