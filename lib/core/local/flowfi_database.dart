import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'flowfi_database.g.dart';

class LocalWalletRows extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get walletType => text()();
  TextColumn get balance => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  TextColumn get clientId => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalTagRows extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  TextColumn get clientId => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalTransactionRows extends Table {
  TextColumn get id => text()();
  TextColumn get walletId => text().nullable()();
  TextColumn get tagId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get amount => text()();
  TextColumn get transactionType => text()();
  DateTimeColumn get transactionDate => dateTime().nullable()();
  TextColumn get status => text()();
  TextColumn get inputMethod => text()();
  TextColumn get merchantName => text().nullable()();
  TextColumn get clientId => text().nullable()();
  BoolColumn get isPendingSync =>
      boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PendingSyncOperationRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entity => text().named('entity_name')();
  TextColumn get entityId => text().nullable()();
  TextColumn get clientId => text()();
  TextColumn get action => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime()();
}

class SyncMetadataRows extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    LocalWalletRows,
    LocalTagRows,
    LocalTransactionRows,
    PendingSyncOperationRows,
    SyncMetadataRows,
  ],
)
class FlowFiDatabase extends _$FlowFiDatabase {
  FlowFiDatabase([QueryExecutor? executor])
    : super(executor ?? _openConnection());

  FlowFiDatabase.inMemory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'flowfi',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
