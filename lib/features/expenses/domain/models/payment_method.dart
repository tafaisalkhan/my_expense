enum PaymentMethod {
  cash('Cash', 'Cash'),
  debitCard('Debit Card', 'Debit Card'),
  creditCard('Credit Card', 'Credit Card'),
  bankTransfer('Bank Transfer', 'Bank Transfer'),
  mobileWallet('Mobile Wallet', 'Mobile Wallet'),
  other('Other', 'Other');

  final String code;
  final String label;

  const PaymentMethod(this.code, this.label);

  static PaymentMethod fromCode(String code) {
    return PaymentMethod.values.firstWhere(
      (e) => e.code == code,
      orElse: () => PaymentMethod.cash,
    );
  }
}

enum ExpenseStatus {
  paid('PAID', 'Paid'),
  approved('APPROVED', 'Approved'),
  pending('PENDING', 'Pending Approval'),
  due('DUE', 'Due / Obligation'),
  planned('PLANNED', 'Planned'),
  skipped('SKIPPED', 'Skipped'),
  cancelled('CANCELLED', 'Cancelled');

  final String code;
  final String label;

  const ExpenseStatus(this.code, this.label);

  static ExpenseStatus fromCode(String code) {
    return ExpenseStatus.values.firstWhere(
      (e) => e.code.toUpperCase() == code.toUpperCase(),
      orElse: () => ExpenseStatus.paid,
    );
  }
}
