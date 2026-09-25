import 'package:myexpence/features/receipts/domain/models/receipt.dart';

abstract class IReceiptRepository {
  Future<Receipt> saveReceipt(Receipt receipt);
  Future<Receipt?> getReceiptByUuid(String uuid);
  Future<List<Receipt>> getAllReceipts();
}
