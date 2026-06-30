import 'dart:convert';

import 'package:drift/drift.dart';

import '../../features/tags/domain/entities/tag.dart';
import '../../features/transactions/domain/entities/transaction.dart';
import '../../features/wallets/domain/entities/wallet.dart';
import '../finance/decimal_money.dart';
import '../finance/money_flow_type.dart';
import '../sync/pending_sync_operation.dart';
import 'flowfi_database.dart';

final class FlowFiLocalStore {
  FlowFiLocalStore(this._database);

  final FlowFiDatabase _database;

  Future<void> cacheWallets(List<Wallet> wallets) async {
    await _database.batch((batch) {
      batch.insertAllOnConflictUpdate(_database.localWalletRows, [
        for (final wallet in wallets)
          LocalWalletRowsCompanion.insert(
            id: wallet.id,
            name: wallet.name,
            walletType: wallet.type.apiValue,
            balance: wallet.balance,
            isDefault: Value(wallet.isDefault),
          ),
      ]);
    });
  }

  Future<List<Wallet>> readWallets() async {
    final rows =
        await (_database.select(_database.localWalletRows)..orderBy([
              (table) => OrderingTerm(
                expression: table.isDefault,
                mode: OrderingMode.desc,
              ),
              (table) => OrderingTerm.asc(table.name),
            ]))
            .get();
    return rows.map(_walletFromRow).toList(growable: false);
  }

  Future<void> cacheTags(List<Tag> tags) async {
    await _database.batch((batch) {
      batch.insertAllOnConflictUpdate(_database.localTagRows, [
        for (final tag in tags)
          LocalTagRowsCompanion.insert(
            id: tag.id,
            name: tag.name,
            type: tag.type.apiValue,
            isDefault: Value(tag.isDefault),
          ),
      ]);
    });
  }

  Future<List<Tag>> readTags() async {
    final rows = await (_database.select(
      _database.localTagRows,
    )..orderBy([(table) => OrderingTerm.asc(table.name)])).get();
    return rows.map(_tagFromRow).toList(growable: false);
  }

  Future<void> cacheTransactions(List<Transaction> transactions) async {
    await _database.batch((batch) {
      batch.insertAllOnConflictUpdate(_database.localTransactionRows, [
        for (final transaction in transactions)
          _transactionCompanion(transaction, isPendingSync: false),
      ]);
    });
  }

  Future<List<Transaction>> readTransactions() async {
    final rows =
        await (_database.select(_database.localTransactionRows)
              ..where((table) => table.deletedAt.isNull())
              ..orderBy([
                (table) => OrderingTerm(
                  expression: table.transactionDate,
                  mode: OrderingMode.desc,
                ),
              ]))
            .get();
    return rows.map(_transactionFromRow).toList(growable: false);
  }

  Future<Transaction> createPendingManualTransaction({
    required String clientId,
    required String walletId,
    required String tagId,
    required String title,
    required String amount,
    required MoneyFlowType type,
    required DateTime date,
    String? description,
    String? merchantName,
  }) async {
    final transaction = Transaction(
      id: clientId,
      clientId: clientId,
      walletId: walletId,
      tagId: tagId,
      title: title,
      description: description,
      amount: amount,
      type: type,
      date: date,
      status: TransactionStatus.confirmed,
      inputMethod: TransactionInputMethod.manual,
      merchantName: merchantName,
      isPendingSync: true,
    );
    final payload = <String, Object?>{
      'walletId': walletId,
      'tagId': tagId,
      'title': title,
      'amount': amount,
      'transactionType': type.apiValue,
      'transactionDate': date.toIso8601String(),
      'status': TransactionStatus.confirmed.apiValue,
      'inputMethod': TransactionInputMethod.manual.apiValue,
    };
    if (description != null) {
      payload['description'] = description;
    }
    if (merchantName != null) {
      payload['merchantName'] = merchantName;
    }
    await _database.transaction(() async {
      await _database
          .into(_database.localTransactionRows)
          .insertOnConflictUpdate(
            _transactionCompanion(transaction, isPendingSync: true),
          );
      await _applyLocalWalletBalance(
        walletId: walletId,
        amount: amount,
        type: type,
      );
      await _database
          .into(_database.pendingSyncOperationRows)
          .insert(
            PendingSyncOperationRowsCompanion.insert(
              entity: 'transactions',
              entityId: const Value.absent(),
              clientId: clientId,
              action: PendingSyncAction.create.apiValue,
              payloadJson: jsonEncode(payload),
              createdAt: DateTime.now(),
            ),
          );
    });
    return transaction;
  }

  Future<List<PendingSyncOperation>> readPendingOperations() async {
    final rows = await (_database.select(
      _database.pendingSyncOperationRows,
    )..orderBy([(table) => OrderingTerm.asc(table.createdAt)])).get();
    return rows
        .map((row) {
          final decoded = jsonDecode(row.payloadJson);
          return PendingSyncOperation(
            localId: row.id,
            entityName: row.entity,
            entityId: row.entityId,
            clientId: row.clientId,
            action: pendingSyncActionFromApi(row.action),
            payload: decoded is Map<String, Object?>
                ? decoded
                : Map<String, Object?>.from(decoded as Map),
          );
        })
        .toList(growable: false);
  }

  Future<int> countPendingOperations() async {
    final count = _database.pendingSyncOperationRows.id.count();
    final query = _database.selectOnly(_database.pendingSyncOperationRows)
      ..addColumns([count]);
    return await query.map((row) => row.read(count) ?? 0).getSingle();
  }

  Future<void> markTransactionCreatesSynced(
    Iterable<SyncedTransactionCreate> creates,
  ) async {
    final items = creates.toList(growable: false);
    if (items.isEmpty) {
      return;
    }
    await _database.transaction(() async {
      for (final item in items) {
        final serverRow = await (_database.select(
          _database.localTransactionRows,
        )..where((row) => row.id.equals(item.entityId))).getSingleOrNull();
        final pendingRow =
            await (_database.select(_database.localTransactionRows)
                  ..where(
                    (row) =>
                        row.id.equals(item.clientId) |
                        row.clientId.equals(item.clientId),
                  )
                  ..limit(1))
                .getSingleOrNull();

        if (pendingRow != null) {
          await _database
              .into(_database.localTransactionRows)
              .insertOnConflictUpdate(
                _transactionCompanionFromRow(
                  pendingRow,
                  id: item.entityId,
                  clientId: item.clientId,
                  isPendingSync: false,
                ),
              );
          if (pendingRow.id != item.entityId) {
            await (_database.delete(
              _database.localTransactionRows,
            )..where((row) => row.id.equals(pendingRow.id))).go();
          }
        } else if (serverRow != null) {
          await (_database.update(
            _database.localTransactionRows,
          )..where((row) => row.id.equals(item.entityId))).write(
            LocalTransactionRowsCompanion(
              clientId: Value(item.clientId),
              isPendingSync: const Value(false),
            ),
          );
        }

        await (_database.delete(
          _database.pendingSyncOperationRows,
        )..where((row) => row.id.equals(item.localOperationId))).go();
      }
    });
  }

  Future<void> markOperationsSynced(Iterable<int> localIds) async {
    final ids = localIds.toList(growable: false);
    if (ids.isEmpty) {
      return;
    }
    await (_database.delete(
      _database.pendingSyncOperationRows,
    )..where((row) => row.id.isIn(ids))).go();
  }

  Future<String> readOrCreateDeviceId(String Function() createId) async {
    const key = 'deviceId';
    final existing = await (_database.select(
      _database.syncMetadataRows,
    )..where((table) => table.key.equals(key))).getSingleOrNull();
    if (existing != null) {
      return existing.value;
    }
    final deviceId = createId();
    await _database
        .into(_database.syncMetadataRows)
        .insertOnConflictUpdate(
          SyncMetadataRowsCompanion.insert(key: key, value: deviceId),
        );
    return deviceId;
  }

  Future<void> _applyLocalWalletBalance({
    required String walletId,
    required String amount,
    required MoneyFlowType type,
  }) async {
    final wallet = await (_database.select(
      _database.localWalletRows,
    )..where((row) => row.id.equals(walletId))).getSingleOrNull();
    if (wallet == null) {
      return;
    }
    await (_database.update(
      _database.localWalletRows,
    )..where((row) => row.id.equals(walletId))).write(
      LocalWalletRowsCompanion(
        balance: Value(
          applyTransactionEffect(
            balance: wallet.balance,
            amount: amount,
            type: type,
          ),
        ),
      ),
    );
  }
}

final class SyncedTransactionCreate {
  const SyncedTransactionCreate({
    required this.localOperationId,
    required this.clientId,
    required this.entityId,
  });

  final int localOperationId;
  final String clientId;
  final String entityId;
}

LocalTransactionRowsCompanion _transactionCompanion(
  Transaction transaction, {
  required bool isPendingSync,
}) {
  return LocalTransactionRowsCompanion.insert(
    id: transaction.id,
    walletId: Value(transaction.walletId),
    tagId: Value(transaction.tagId),
    title: transaction.title,
    description: Value(transaction.description),
    amount: transaction.amount,
    transactionType: transaction.type.apiValue,
    transactionDate: Value(transaction.date),
    status: transaction.status.apiValue,
    inputMethod: transaction.inputMethod.apiValue,
    merchantName: Value(transaction.merchantName),
    clientId: Value(transaction.clientId ?? transaction.id),
    isPendingSync: Value(isPendingSync),
  );
}

LocalTransactionRowsCompanion _transactionCompanionFromRow(
  LocalTransactionRow row, {
  required String id,
  required String clientId,
  required bool isPendingSync,
}) {
  return LocalTransactionRowsCompanion.insert(
    id: id,
    walletId: Value(row.walletId),
    tagId: Value(row.tagId),
    title: row.title,
    description: Value(row.description),
    amount: row.amount,
    transactionType: row.transactionType,
    transactionDate: Value(row.transactionDate),
    status: row.status,
    inputMethod: row.inputMethod,
    merchantName: Value(row.merchantName),
    clientId: Value(clientId),
    isPendingSync: Value(isPendingSync),
    version: Value(row.version),
    updatedAt: Value(row.updatedAt),
    deletedAt: Value(row.deletedAt),
  );
}

Wallet _walletFromRow(LocalWalletRow row) {
  return Wallet(
    id: row.id,
    name: row.name,
    type: walletTypeFromApi(row.walletType),
    balance: row.balance,
    isDefault: row.isDefault,
  );
}

Tag _tagFromRow(LocalTagRow row) {
  return Tag(
    id: row.id,
    name: row.name,
    type: moneyFlowTypeFromApi(row.type),
    isDefault: row.isDefault,
  );
}

Transaction _transactionFromRow(LocalTransactionRow row) {
  return Transaction(
    id: row.id,
    clientId: row.clientId,
    walletId: row.walletId,
    tagId: row.tagId,
    title: row.title,
    description: row.description,
    amount: row.amount,
    type: moneyFlowTypeFromApi(row.transactionType),
    date: row.transactionDate,
    status: transactionStatusFromApi(row.status),
    inputMethod: transactionInputMethodFromApi(row.inputMethod),
    merchantName: row.merchantName,
    isPendingSync: row.isPendingSync,
  );
}
