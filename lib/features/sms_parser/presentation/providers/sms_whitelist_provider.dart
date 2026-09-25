import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myexpence/features/sms_parser/domain/services/sms_parser_service.dart';

class SmsWhitelistNotifier extends StateNotifier<List<String>> {
  static const String _keyWhitelist = 'sms_whitelisted_senders';

  SmsWhitelistNotifier() : super(SmsParserService.defaultAllowedSenders) {
    _loadWhitelist();
  }

  Future<void> _loadWhitelist() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_keyWhitelist);
    if (saved != null) {
      state = saved;
    } else {
      state = const [];
    }
  }

  Future<void> addSender(String sender) async {
    final clean = sender.trim();
    if (clean.isEmpty) return;
    if (!state.any((s) => s.toLowerCase() == clean.toLowerCase())) {
      final updated = [...state, clean];
      state = updated;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keyWhitelist, updated);
    }
  }

  Future<void> removeSender(String sender) async {
    final updated = state.where((s) => s.toLowerCase() != sender.toLowerCase()).toList();
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyWhitelist, updated);
  }

  Future<void> resetToDefaults() async {
    state = const [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyWhitelist, const []);
  }
}

final smsWhitelistProvider = StateNotifierProvider<SmsWhitelistNotifier, List<String>>((ref) {
  return SmsWhitelistNotifier();
});
