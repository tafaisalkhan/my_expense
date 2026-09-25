enum SubscriptionTier {
  free('FREE', 'Free Plan', 0.0, '\$'),
  premiumMonthly('PREMIUM_MONTHLY', 'Monthly Premium', 2.99, '\$'), // $2.99 / month
  premiumYearly('PREMIUM_YEARLY', 'Yearly Premium', 15.00, '\$'),   // $15.00 / year
  promo3Month('PREMIUM_PROMO_3M', '3-Month Free Premium (Promo Code)', 0.0, '\$');

  final String code;
  final String title;
  final double price;
  final String currencySymbol;

  const SubscriptionTier(this.code, this.title, this.price, this.currencySymbol);

  static SubscriptionTier fromCode(String code) {
    return SubscriptionTier.values.firstWhere(
      (e) => e.code == code,
      orElse: () => SubscriptionTier.free,
    );
  }

  String get formattedPrice => '$currencySymbol${price.toStringAsFixed(2)}';
}

class UserSubscription {
  final SubscriptionTier tier;
  final bool isActive;
  final String? expiryDateIso;
  final bool isTrial;

  const UserSubscription({
    this.tier = SubscriptionTier.free,
    this.isActive = false,
    this.expiryDateIso,
    this.isTrial = false,
  });

  bool get isPremium => (tier != SubscriptionTier.free) && isActive;

  UserSubscription copyWith({
    SubscriptionTier? tier,
    bool? isActive,
    String? expiryDateIso,
    bool? isTrial,
  }) {
    return UserSubscription(
      tier: tier ?? this.tier,
      isActive: isActive ?? this.isActive,
      expiryDateIso: expiryDateIso ?? this.expiryDateIso,
      isTrial: isTrial ?? this.isTrial,
    );
  }
}
