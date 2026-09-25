import 'package:flutter_test/flutter_test.dart';
import 'package:myexpence/features/subscription/domain/models/subscription_plan.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Step 1: User starts on Free tier by default', () async {
    const defaultSub = UserSubscription();
    expect(defaultSub.tier, equals(SubscriptionTier.free));
    expect(defaultSub.isPremium, isFalse);
  });

  test('Step 2: User starts 7-Day Free Trial unlocking Premium features', () async {
    final trialExpiry = DateTime.now().add(const Duration(days: 7)).toIso8601String();
    final trialSub = UserSubscription(
      tier: SubscriptionTier.premiumMonthly,
      isActive: true,
      expiryDateIso: trialExpiry,
      isTrial: true,
    );

    expect(trialSub.isTrial, isTrue);
    expect(trialSub.isPremium, isTrue);
    expect(trialSub.tier, equals(SubscriptionTier.premiumMonthly));
  });

  test('Step 3: Trial expires and falls back to Free tier until paid subscription', () async {
    final expiredTrialDate = DateTime.now().subtract(const Duration(days: 1)).toIso8601String();
    final expiredDate = DateTime.tryParse(expiredTrialDate);
    final isActive = expiredDate != null && expiredDate.isAfter(DateTime.now());

    final expiredSub = UserSubscription(
      tier: SubscriptionTier.premiumMonthly,
      isActive: isActive,
      expiryDateIso: expiredTrialDate,
      isTrial: true,
    );

    expect(expiredSub.isPremium, isFalse);

    // Paid subscription after trial
    final paidExpiry = DateTime.now().add(const Duration(days: 30)).toIso8601String();
    final paidSub = UserSubscription(
      tier: SubscriptionTier.premiumMonthly,
      isActive: true,
      expiryDateIso: paidExpiry,
      isTrial: false,
    );

    expect(paidSub.isPremium, isTrue);
    expect(paidSub.isTrial, isFalse);
    expect(paidSub.tier.price, equals(2.99));
  });

  test('Step 4: User redeems promo code unlocking all features for 3 Months (90 Days)', () async {
    final promoExpiry = DateTime.now().add(const Duration(days: 90)).toIso8601String();
    final promoSub = UserSubscription(
      tier: SubscriptionTier.promo3Month,
      isActive: true,
      expiryDateIso: promoExpiry,
      isTrial: true,
    );

    expect(promoSub.isPremium, isTrue);
    expect(promoSub.tier, equals(SubscriptionTier.promo3Month));
    final expiryParsed = DateTime.parse(promoSub.expiryDateIso!);
    final diffInDays = expiryParsed.difference(DateTime.now()).inDays;
    expect(diffInDays, greaterThanOrEqualTo(89));
  });
}
