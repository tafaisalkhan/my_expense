import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myexpence/features/subscription/domain/models/subscription_plan.dart';

class SubscriptionNotifier extends StateNotifier<UserSubscription> {
  SubscriptionNotifier() : super(const UserSubscription()) {
    _loadSubscription();
  }

  static const String _prefKeyTier = 'user_sub_tier';
  static const String _prefKeyExpiry = 'user_sub_expiry';

  Future<void> _loadSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    final tierCode = prefs.getString(_prefKeyTier) ?? SubscriptionTier.free.code;
    final expiryIso = prefs.getString(_prefKeyExpiry);

    final tier = SubscriptionTier.fromCode(tierCode);
    bool active = false;

    if (tier != SubscriptionTier.free) {
      if (expiryIso != null) {
        final expiryDate = DateTime.tryParse(expiryIso);
        active = expiryDate != null && expiryDate.isAfter(DateTime.now());
      } else {
        active = true;
      }
    }

    state = UserSubscription(
      tier: tier,
      isActive: active,
      expiryDateIso: expiryIso,
    );
  }

  Future<void> subscribeMonthly() async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = DateTime.now().add(const Duration(days: 30)).toIso8601String();

    await prefs.setString(_prefKeyTier, SubscriptionTier.premiumMonthly.code);
    await prefs.setString(_prefKeyExpiry, expiry);

    state = UserSubscription(
      tier: SubscriptionTier.premiumMonthly,
      isActive: true,
      expiryDateIso: expiry,
    );
  }

  Future<void> subscribeYearly() async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = DateTime.now().add(const Duration(days: 365)).toIso8601String();

    await prefs.setString(_prefKeyTier, SubscriptionTier.premiumYearly.code);
    await prefs.setString(_prefKeyExpiry, expiry);

    state = UserSubscription(
      tier: SubscriptionTier.premiumYearly,
      isActive: true,
      expiryDateIso: expiry,
    );
  }

  Future<void> startFreeTrial() async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = DateTime.now().add(const Duration(days: 7)).toIso8601String();

    await prefs.setString(_prefKeyTier, SubscriptionTier.premiumMonthly.code);
    await prefs.setString(_prefKeyExpiry, expiry);

    state = UserSubscription(
      tier: SubscriptionTier.premiumMonthly,
      isActive: true,
      expiryDateIso: expiry,
      isTrial: true,
    );
  }

  Future<bool> redeemPromoCode(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return false;

    final prefs = await SharedPreferences.getInstance();
    // 3 Months = 90 days of full Premium access
    final expiry = DateTime.now().add(const Duration(days: 90)).toIso8601String();

    await prefs.setString(_prefKeyTier, SubscriptionTier.promo3Month.code);
    await prefs.setString(_prefKeyExpiry, expiry);

    state = UserSubscription(
      tier: SubscriptionTier.promo3Month,
      isActive: true,
      expiryDateIso: expiry,
      isTrial: true,
    );

    return true;
  }

  Future<void> cancelSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKeyTier);
    await prefs.remove(_prefKeyExpiry);

    state = const UserSubscription(
      tier: SubscriptionTier.free,
      isActive: false,
    );
  }
}

final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, UserSubscription>((ref) {
  return SubscriptionNotifier();
});

final isPremiumUserProvider = Provider<bool>((ref) {
  final sub = ref.watch(subscriptionProvider);
  return sub.isPremium;
});
