import 'package:flutter_test/flutter_test.dart';
import 'package:myexpence/features/expenses/domain/models/expense_classification.dart';
import 'package:myexpence/features/sms_parser/domain/services/sms_parser_service.dart';

void main() {
  group('SMS Transaction Parser Tests', () {
    test('Parses bank SMS with debited amount and vendor', () {
      const sms = 'Your A/C 4589 debited by Rs 2,500.00 at POS SHELL PETROL PUMP on 24-SEP-26. Avail Bal: Rs 14,200.';
      final result = SmsParserService.parseSmsText(sms);

      expect(result.amount, 2500.00);
      expect(result.merchant?.toUpperCase().contains('SHELL'), true);
      expect(result.suggestedCategoryId, 'cat_transport');
    });

    test('Parses grocery supermarket SMS and assigns Required classification', () {
      const sms = 'Paid Rs 4,890.50 at METRO GROCERY SUPERMARKET on 24/09/2026';
      final result = SmsParserService.parseSmsText(sms);

      expect(result.amount, 4890.50);
      expect(result.suggestedCategoryId, 'cat_groceries');
      expect(result.classification, ExpenseClassification.required);
    });

    test('Parses restaurant food SMS and assigns Optional classification', () {
      const sms = 'Transaction of Rs 1,200 at KFC RESTAURANT on 24-09-2026. Ref: 998811';
      final result = SmsParserService.parseSmsText(sms);

      expect(result.amount, 1200.00);
      expect(result.suggestedCategoryId, 'cat_food');
      expect(result.classification, ExpenseClassification.optional);
    });

    test('Handles dollar amounts accurately', () {
      const sms = 'Paid \$45.00 to Starbucks Cafe via Apple Pay';
      final result = SmsParserService.parseSmsText(sms);

      expect(result.amount, 45.00);
      expect(result.suggestedCategoryId, 'cat_food');
    });

    test('Validates whitelisted bank sender ID accurately', () {
      const sms = 'Your A/C debited by Rs 1,500 at POS SHELL PETROL PUMP';
      final result = SmsParserService.parseSmsText(sms, sender: 'MeezanBank', customAllowedSenders: ['MeezanBank']);

      expect(result.sender, 'MeezanBank');
      expect(result.isKnownSender, true);
      expect(result.senderValidationMessage?.contains('Verified'), true);
    });

    test('Flags unverified sender with warning validation message', () {
      const sms = 'Your account debited by Rs 5,000 at Random Shop';
      final result = SmsParserService.parseSmsText(sms, sender: '+923999999999');

      expect(result.sender, '+923999999999');
      expect(result.isKnownSender, false);
      expect(result.senderValidationMessage?.contains('Warning'), true);
    });

    test('Extracts embedded sender from raw SMS text header', () {
      const sms = 'From: Easypaisa\nPaid Rs 500 to Mobile Topup on 24-09-2026';
      final result = SmsParserService.parseSmsText(sms, customAllowedSenders: ['Easypaisa']);

      expect(result.sender?.toLowerCase(), 'easypaisa');
      expect(result.isKnownSender, true);
    });

    test('Parses TOTAL PARCO Petrol Pump PKR Debit Card SMS accurately', () {
      const sms = 'Dear Client, PKR 3,000.00 have been paid at TOTAL PARCO on 21-09-26 using Debit Card no. 53119xxxxxxxx6733.';
      final result = SmsParserService.parseSmsText(sms);

      expect(result.amount, 3000.00);
      expect(result.merchant?.toUpperCase(), 'TOTAL PARCO');
      expect(result.suggestedCategoryId, 'cat_transport');
    });

    test('Parses CHASE PLUS Superstore PKR Debit Card SMS accurately', () {
      const sms = 'Dear Client, PKR 5,051.00 have been paid at CHASE PLUS on 18-09-26 using Debit Card no. 53119xxxxxxxx6733.';
      final result = SmsParserService.parseSmsText(sms);

      expect(result.amount, 5051.00);
      expect(result.merchant?.toUpperCase(), 'CHASE PLUS');
      expect(result.suggestedCategoryId, 'cat_groceries');
      expect(result.classification, ExpenseClassification.required);
    });
  });
}
