import 'package:flowfi_fe/core/finance/money_flow_type.dart';
import 'package:flowfi_fe/features/ai_processing/data/models/image_transaction_import_model.dart';
import 'package:flowfi_fe/features/transactions/domain/entities/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps image transaction import response into domain data', () {
    final model = ImageTransactionImportModel.fromJson({
      'aiRequestId': 'request-1',
      'aiResultId': 'result-1',
      'imageUrl': 'local://receipt.jpg',
      'analysis': {
        'imageType': 'RECEIPT',
        'confidence': 0.93,
        'warnings': ['low light'],
      },
      'createdTransactions': [
        {
          'tagCreated': true,
          'transaction': {
            'id': 'transaction-1',
            'walletId': 'wallet-1',
            'tagId': 'tag-1',
            'title': 'Purchase at Winmart',
            'description': 'Receipt total',
            'amount': '125000.00',
            'transactionType': 'Expense',
            'transactionDate': '2026-06-26T10:00:00.000Z',
            'inputMethod': 'OCR',
            'status': 'Draft',
            'merchantName': 'Winmart',
          },
        },
      ],
    });

    final result = model.toDomain();

    expect(result.aiRequestId, 'request-1');
    expect(result.aiResultId, 'result-1');
    expect(result.imageUrl, 'local://receipt.jpg');
    expect(result.imageType, 'RECEIPT');
    expect(result.confidence, '0.93');
    expect(result.warnings, ['low light']);
    expect(result.createdTransactions, hasLength(1));
    expect(result.createdTransactions.single.tagCreated, isTrue);
    expect(result.createdTransactions.single.transaction.amount, '125000.00');
    expect(
      result.createdTransactions.single.transaction.type,
      MoneyFlowType.expense,
    );
    expect(
      result.createdTransactions.single.transaction.inputMethod,
      TransactionInputMethod.ocr,
    );
    expect(
      result.createdTransactions.single.transaction.status,
      TransactionStatus.draft,
    );
  });
}
