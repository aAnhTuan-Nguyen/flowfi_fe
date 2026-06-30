// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flowfi_database.dart';

// ignore_for_file: type=lint
class $LocalWalletRowsTable extends LocalWalletRows
    with TableInfo<$LocalWalletRowsTable, LocalWalletRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalWalletRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _walletTypeMeta = const VerificationMeta(
    'walletType',
  );
  @override
  late final GeneratedColumn<String> walletType = GeneratedColumn<String>(
    'wallet_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  @override
  late final GeneratedColumn<String> balance = GeneratedColumn<String>(
    'balance',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    walletType,
    balance,
    isDefault,
    clientId,
    version,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_wallet_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalWalletRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('wallet_type')) {
      context.handle(
        _walletTypeMeta,
        walletType.isAcceptableOrUnknown(data['wallet_type']!, _walletTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_walletTypeMeta);
    }
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    } else if (isInserting) {
      context.missing(_balanceMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalWalletRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalWalletRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      walletType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wallet_type'],
      )!,
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}balance'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $LocalWalletRowsTable createAlias(String alias) {
    return $LocalWalletRowsTable(attachedDatabase, alias);
  }
}

class LocalWalletRow extends DataClass implements Insertable<LocalWalletRow> {
  final String id;
  final String name;
  final String walletType;
  final String balance;
  final bool isDefault;
  final String? clientId;
  final int version;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  const LocalWalletRow({
    required this.id,
    required this.name,
    required this.walletType,
    required this.balance,
    required this.isDefault,
    this.clientId,
    required this.version,
    this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['wallet_type'] = Variable<String>(walletType);
    map['balance'] = Variable<String>(balance);
    map['is_default'] = Variable<bool>(isDefault);
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  LocalWalletRowsCompanion toCompanion(bool nullToAbsent) {
    return LocalWalletRowsCompanion(
      id: Value(id),
      name: Value(name),
      walletType: Value(walletType),
      balance: Value(balance),
      isDefault: Value(isDefault),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      version: Value(version),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory LocalWalletRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalWalletRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      walletType: serializer.fromJson<String>(json['walletType']),
      balance: serializer.fromJson<String>(json['balance']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      version: serializer.fromJson<int>(json['version']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'walletType': serializer.toJson<String>(walletType),
      'balance': serializer.toJson<String>(balance),
      'isDefault': serializer.toJson<bool>(isDefault),
      'clientId': serializer.toJson<String?>(clientId),
      'version': serializer.toJson<int>(version),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  LocalWalletRow copyWith({
    String? id,
    String? name,
    String? walletType,
    String? balance,
    bool? isDefault,
    Value<String?> clientId = const Value.absent(),
    int? version,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => LocalWalletRow(
    id: id ?? this.id,
    name: name ?? this.name,
    walletType: walletType ?? this.walletType,
    balance: balance ?? this.balance,
    isDefault: isDefault ?? this.isDefault,
    clientId: clientId.present ? clientId.value : this.clientId,
    version: version ?? this.version,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  LocalWalletRow copyWithCompanion(LocalWalletRowsCompanion data) {
    return LocalWalletRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      walletType: data.walletType.present
          ? data.walletType.value
          : this.walletType,
      balance: data.balance.present ? data.balance.value : this.balance,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      version: data.version.present ? data.version.value : this.version,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalWalletRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('walletType: $walletType, ')
          ..write('balance: $balance, ')
          ..write('isDefault: $isDefault, ')
          ..write('clientId: $clientId, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    walletType,
    balance,
    isDefault,
    clientId,
    version,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalWalletRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.walletType == this.walletType &&
          other.balance == this.balance &&
          other.isDefault == this.isDefault &&
          other.clientId == this.clientId &&
          other.version == this.version &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class LocalWalletRowsCompanion extends UpdateCompanion<LocalWalletRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> walletType;
  final Value<String> balance;
  final Value<bool> isDefault;
  final Value<String?> clientId;
  final Value<int> version;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const LocalWalletRowsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.walletType = const Value.absent(),
    this.balance = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.clientId = const Value.absent(),
    this.version = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalWalletRowsCompanion.insert({
    required String id,
    required String name,
    required String walletType,
    required String balance,
    this.isDefault = const Value.absent(),
    this.clientId = const Value.absent(),
    this.version = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       walletType = Value(walletType),
       balance = Value(balance);
  static Insertable<LocalWalletRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? walletType,
    Expression<String>? balance,
    Expression<bool>? isDefault,
    Expression<String>? clientId,
    Expression<int>? version,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (walletType != null) 'wallet_type': walletType,
      if (balance != null) 'balance': balance,
      if (isDefault != null) 'is_default': isDefault,
      if (clientId != null) 'client_id': clientId,
      if (version != null) 'version': version,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalWalletRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? walletType,
    Value<String>? balance,
    Value<bool>? isDefault,
    Value<String?>? clientId,
    Value<int>? version,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return LocalWalletRowsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      walletType: walletType ?? this.walletType,
      balance: balance ?? this.balance,
      isDefault: isDefault ?? this.isDefault,
      clientId: clientId ?? this.clientId,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (walletType.present) {
      map['wallet_type'] = Variable<String>(walletType.value);
    }
    if (balance.present) {
      map['balance'] = Variable<String>(balance.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalWalletRowsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('walletType: $walletType, ')
          ..write('balance: $balance, ')
          ..write('isDefault: $isDefault, ')
          ..write('clientId: $clientId, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalTagRowsTable extends LocalTagRows
    with TableInfo<$LocalTagRowsTable, LocalTagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTagRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    isDefault,
    clientId,
    version,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_tag_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalTagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTagRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $LocalTagRowsTable createAlias(String alias) {
    return $LocalTagRowsTable(attachedDatabase, alias);
  }
}

class LocalTagRow extends DataClass implements Insertable<LocalTagRow> {
  final String id;
  final String name;
  final String type;
  final bool isDefault;
  final String? clientId;
  final int version;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  const LocalTagRow({
    required this.id,
    required this.name,
    required this.type,
    required this.isDefault,
    this.clientId,
    required this.version,
    this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['is_default'] = Variable<bool>(isDefault);
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  LocalTagRowsCompanion toCompanion(bool nullToAbsent) {
    return LocalTagRowsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      isDefault: Value(isDefault),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      version: Value(version),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory LocalTagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTagRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      version: serializer.fromJson<int>(json['version']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'isDefault': serializer.toJson<bool>(isDefault),
      'clientId': serializer.toJson<String?>(clientId),
      'version': serializer.toJson<int>(version),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  LocalTagRow copyWith({
    String? id,
    String? name,
    String? type,
    bool? isDefault,
    Value<String?> clientId = const Value.absent(),
    int? version,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => LocalTagRow(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    isDefault: isDefault ?? this.isDefault,
    clientId: clientId.present ? clientId.value : this.clientId,
    version: version ?? this.version,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  LocalTagRow copyWithCompanion(LocalTagRowsCompanion data) {
    return LocalTagRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      version: data.version.present ? data.version.value : this.version,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTagRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('isDefault: $isDefault, ')
          ..write('clientId: $clientId, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    isDefault,
    clientId,
    version,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTagRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.isDefault == this.isDefault &&
          other.clientId == this.clientId &&
          other.version == this.version &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class LocalTagRowsCompanion extends UpdateCompanion<LocalTagRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<bool> isDefault;
  final Value<String?> clientId;
  final Value<int> version;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const LocalTagRowsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.clientId = const Value.absent(),
    this.version = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTagRowsCompanion.insert({
    required String id,
    required String name,
    required String type,
    this.isDefault = const Value.absent(),
    this.clientId = const Value.absent(),
    this.version = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type);
  static Insertable<LocalTagRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<bool>? isDefault,
    Expression<String>? clientId,
    Expression<int>? version,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (isDefault != null) 'is_default': isDefault,
      if (clientId != null) 'client_id': clientId,
      if (version != null) 'version': version,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTagRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<bool>? isDefault,
    Value<String?>? clientId,
    Value<int>? version,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return LocalTagRowsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      clientId: clientId ?? this.clientId,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTagRowsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('isDefault: $isDefault, ')
          ..write('clientId: $clientId, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalTransactionRowsTable extends LocalTransactionRows
    with TableInfo<$LocalTransactionRowsTable, LocalTransactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTransactionRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _walletIdMeta = const VerificationMeta(
    'walletId',
  );
  @override
  late final GeneratedColumn<String> walletId = GeneratedColumn<String>(
    'wallet_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<String> amount = GeneratedColumn<String>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionTypeMeta = const VerificationMeta(
    'transactionType',
  );
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
    'transaction_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionDateMeta = const VerificationMeta(
    'transactionDate',
  );
  @override
  late final GeneratedColumn<DateTime> transactionDate =
      GeneratedColumn<DateTime>(
        'transaction_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inputMethodMeta = const VerificationMeta(
    'inputMethod',
  );
  @override
  late final GeneratedColumn<String> inputMethod = GeneratedColumn<String>(
    'input_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _merchantNameMeta = const VerificationMeta(
    'merchantName',
  );
  @override
  late final GeneratedColumn<String> merchantName = GeneratedColumn<String>(
    'merchant_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPendingSyncMeta = const VerificationMeta(
    'isPendingSync',
  );
  @override
  late final GeneratedColumn<bool> isPendingSync = GeneratedColumn<bool>(
    'is_pending_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pending_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    walletId,
    tagId,
    title,
    description,
    amount,
    transactionType,
    transactionDate,
    status,
    inputMethod,
    merchantName,
    clientId,
    isPendingSync,
    version,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_transaction_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalTransactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('wallet_id')) {
      context.handle(
        _walletIdMeta,
        walletId.isAcceptableOrUnknown(data['wallet_id']!, _walletIdMeta),
      );
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
        _transactionTypeMeta,
        transactionType.isAcceptableOrUnknown(
          data['transaction_type']!,
          _transactionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionTypeMeta);
    }
    if (data.containsKey('transaction_date')) {
      context.handle(
        _transactionDateMeta,
        transactionDate.isAcceptableOrUnknown(
          data['transaction_date']!,
          _transactionDateMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('input_method')) {
      context.handle(
        _inputMethodMeta,
        inputMethod.isAcceptableOrUnknown(
          data['input_method']!,
          _inputMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_inputMethodMeta);
    }
    if (data.containsKey('merchant_name')) {
      context.handle(
        _merchantNameMeta,
        merchantName.isAcceptableOrUnknown(
          data['merchant_name']!,
          _merchantNameMeta,
        ),
      );
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    }
    if (data.containsKey('is_pending_sync')) {
      context.handle(
        _isPendingSyncMeta,
        isPendingSync.isAcceptableOrUnknown(
          data['is_pending_sync']!,
          _isPendingSyncMeta,
        ),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTransactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTransactionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      walletId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wallet_id'],
      ),
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount'],
      )!,
      transactionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_type'],
      )!,
      transactionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}transaction_date'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      inputMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}input_method'],
      )!,
      merchantName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant_name'],
      ),
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      ),
      isPendingSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pending_sync'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $LocalTransactionRowsTable createAlias(String alias) {
    return $LocalTransactionRowsTable(attachedDatabase, alias);
  }
}

class LocalTransactionRow extends DataClass
    implements Insertable<LocalTransactionRow> {
  final String id;
  final String? walletId;
  final String? tagId;
  final String title;
  final String? description;
  final String amount;
  final String transactionType;
  final DateTime? transactionDate;
  final String status;
  final String inputMethod;
  final String? merchantName;
  final String? clientId;
  final bool isPendingSync;
  final int version;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  const LocalTransactionRow({
    required this.id,
    this.walletId,
    this.tagId,
    required this.title,
    this.description,
    required this.amount,
    required this.transactionType,
    this.transactionDate,
    required this.status,
    required this.inputMethod,
    this.merchantName,
    this.clientId,
    required this.isPendingSync,
    required this.version,
    this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || walletId != null) {
      map['wallet_id'] = Variable<String>(walletId);
    }
    if (!nullToAbsent || tagId != null) {
      map['tag_id'] = Variable<String>(tagId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['amount'] = Variable<String>(amount);
    map['transaction_type'] = Variable<String>(transactionType);
    if (!nullToAbsent || transactionDate != null) {
      map['transaction_date'] = Variable<DateTime>(transactionDate);
    }
    map['status'] = Variable<String>(status);
    map['input_method'] = Variable<String>(inputMethod);
    if (!nullToAbsent || merchantName != null) {
      map['merchant_name'] = Variable<String>(merchantName);
    }
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    map['is_pending_sync'] = Variable<bool>(isPendingSync);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  LocalTransactionRowsCompanion toCompanion(bool nullToAbsent) {
    return LocalTransactionRowsCompanion(
      id: Value(id),
      walletId: walletId == null && nullToAbsent
          ? const Value.absent()
          : Value(walletId),
      tagId: tagId == null && nullToAbsent
          ? const Value.absent()
          : Value(tagId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      amount: Value(amount),
      transactionType: Value(transactionType),
      transactionDate: transactionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionDate),
      status: Value(status),
      inputMethod: Value(inputMethod),
      merchantName: merchantName == null && nullToAbsent
          ? const Value.absent()
          : Value(merchantName),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      isPendingSync: Value(isPendingSync),
      version: Value(version),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory LocalTransactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTransactionRow(
      id: serializer.fromJson<String>(json['id']),
      walletId: serializer.fromJson<String?>(json['walletId']),
      tagId: serializer.fromJson<String?>(json['tagId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      amount: serializer.fromJson<String>(json['amount']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
      transactionDate: serializer.fromJson<DateTime?>(json['transactionDate']),
      status: serializer.fromJson<String>(json['status']),
      inputMethod: serializer.fromJson<String>(json['inputMethod']),
      merchantName: serializer.fromJson<String?>(json['merchantName']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      isPendingSync: serializer.fromJson<bool>(json['isPendingSync']),
      version: serializer.fromJson<int>(json['version']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'walletId': serializer.toJson<String?>(walletId),
      'tagId': serializer.toJson<String?>(tagId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'amount': serializer.toJson<String>(amount),
      'transactionType': serializer.toJson<String>(transactionType),
      'transactionDate': serializer.toJson<DateTime?>(transactionDate),
      'status': serializer.toJson<String>(status),
      'inputMethod': serializer.toJson<String>(inputMethod),
      'merchantName': serializer.toJson<String?>(merchantName),
      'clientId': serializer.toJson<String?>(clientId),
      'isPendingSync': serializer.toJson<bool>(isPendingSync),
      'version': serializer.toJson<int>(version),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  LocalTransactionRow copyWith({
    String? id,
    Value<String?> walletId = const Value.absent(),
    Value<String?> tagId = const Value.absent(),
    String? title,
    Value<String?> description = const Value.absent(),
    String? amount,
    String? transactionType,
    Value<DateTime?> transactionDate = const Value.absent(),
    String? status,
    String? inputMethod,
    Value<String?> merchantName = const Value.absent(),
    Value<String?> clientId = const Value.absent(),
    bool? isPendingSync,
    int? version,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => LocalTransactionRow(
    id: id ?? this.id,
    walletId: walletId.present ? walletId.value : this.walletId,
    tagId: tagId.present ? tagId.value : this.tagId,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    amount: amount ?? this.amount,
    transactionType: transactionType ?? this.transactionType,
    transactionDate: transactionDate.present
        ? transactionDate.value
        : this.transactionDate,
    status: status ?? this.status,
    inputMethod: inputMethod ?? this.inputMethod,
    merchantName: merchantName.present ? merchantName.value : this.merchantName,
    clientId: clientId.present ? clientId.value : this.clientId,
    isPendingSync: isPendingSync ?? this.isPendingSync,
    version: version ?? this.version,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  LocalTransactionRow copyWithCompanion(LocalTransactionRowsCompanion data) {
    return LocalTransactionRow(
      id: data.id.present ? data.id.value : this.id,
      walletId: data.walletId.present ? data.walletId.value : this.walletId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      amount: data.amount.present ? data.amount.value : this.amount,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      status: data.status.present ? data.status.value : this.status,
      inputMethod: data.inputMethod.present
          ? data.inputMethod.value
          : this.inputMethod,
      merchantName: data.merchantName.present
          ? data.merchantName.value
          : this.merchantName,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      isPendingSync: data.isPendingSync.present
          ? data.isPendingSync.value
          : this.isPendingSync,
      version: data.version.present ? data.version.value : this.version,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTransactionRow(')
          ..write('id: $id, ')
          ..write('walletId: $walletId, ')
          ..write('tagId: $tagId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('transactionType: $transactionType, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('status: $status, ')
          ..write('inputMethod: $inputMethod, ')
          ..write('merchantName: $merchantName, ')
          ..write('clientId: $clientId, ')
          ..write('isPendingSync: $isPendingSync, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    walletId,
    tagId,
    title,
    description,
    amount,
    transactionType,
    transactionDate,
    status,
    inputMethod,
    merchantName,
    clientId,
    isPendingSync,
    version,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTransactionRow &&
          other.id == this.id &&
          other.walletId == this.walletId &&
          other.tagId == this.tagId &&
          other.title == this.title &&
          other.description == this.description &&
          other.amount == this.amount &&
          other.transactionType == this.transactionType &&
          other.transactionDate == this.transactionDate &&
          other.status == this.status &&
          other.inputMethod == this.inputMethod &&
          other.merchantName == this.merchantName &&
          other.clientId == this.clientId &&
          other.isPendingSync == this.isPendingSync &&
          other.version == this.version &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class LocalTransactionRowsCompanion
    extends UpdateCompanion<LocalTransactionRow> {
  final Value<String> id;
  final Value<String?> walletId;
  final Value<String?> tagId;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> amount;
  final Value<String> transactionType;
  final Value<DateTime?> transactionDate;
  final Value<String> status;
  final Value<String> inputMethod;
  final Value<String?> merchantName;
  final Value<String?> clientId;
  final Value<bool> isPendingSync;
  final Value<int> version;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const LocalTransactionRowsCompanion({
    this.id = const Value.absent(),
    this.walletId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.amount = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.status = const Value.absent(),
    this.inputMethod = const Value.absent(),
    this.merchantName = const Value.absent(),
    this.clientId = const Value.absent(),
    this.isPendingSync = const Value.absent(),
    this.version = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTransactionRowsCompanion.insert({
    required String id,
    this.walletId = const Value.absent(),
    this.tagId = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required String amount,
    required String transactionType,
    this.transactionDate = const Value.absent(),
    required String status,
    required String inputMethod,
    this.merchantName = const Value.absent(),
    this.clientId = const Value.absent(),
    this.isPendingSync = const Value.absent(),
    this.version = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       amount = Value(amount),
       transactionType = Value(transactionType),
       status = Value(status),
       inputMethod = Value(inputMethod);
  static Insertable<LocalTransactionRow> custom({
    Expression<String>? id,
    Expression<String>? walletId,
    Expression<String>? tagId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? amount,
    Expression<String>? transactionType,
    Expression<DateTime>? transactionDate,
    Expression<String>? status,
    Expression<String>? inputMethod,
    Expression<String>? merchantName,
    Expression<String>? clientId,
    Expression<bool>? isPendingSync,
    Expression<int>? version,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (walletId != null) 'wallet_id': walletId,
      if (tagId != null) 'tag_id': tagId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (amount != null) 'amount': amount,
      if (transactionType != null) 'transaction_type': transactionType,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (status != null) 'status': status,
      if (inputMethod != null) 'input_method': inputMethod,
      if (merchantName != null) 'merchant_name': merchantName,
      if (clientId != null) 'client_id': clientId,
      if (isPendingSync != null) 'is_pending_sync': isPendingSync,
      if (version != null) 'version': version,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTransactionRowsCompanion copyWith({
    Value<String>? id,
    Value<String?>? walletId,
    Value<String?>? tagId,
    Value<String>? title,
    Value<String?>? description,
    Value<String>? amount,
    Value<String>? transactionType,
    Value<DateTime?>? transactionDate,
    Value<String>? status,
    Value<String>? inputMethod,
    Value<String?>? merchantName,
    Value<String?>? clientId,
    Value<bool>? isPendingSync,
    Value<int>? version,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return LocalTransactionRowsCompanion(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      tagId: tagId ?? this.tagId,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      transactionType: transactionType ?? this.transactionType,
      transactionDate: transactionDate ?? this.transactionDate,
      status: status ?? this.status,
      inputMethod: inputMethod ?? this.inputMethod,
      merchantName: merchantName ?? this.merchantName,
      clientId: clientId ?? this.clientId,
      isPendingSync: isPendingSync ?? this.isPendingSync,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (walletId.present) {
      map['wallet_id'] = Variable<String>(walletId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(amount.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<DateTime>(transactionDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (inputMethod.present) {
      map['input_method'] = Variable<String>(inputMethod.value);
    }
    if (merchantName.present) {
      map['merchant_name'] = Variable<String>(merchantName.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (isPendingSync.present) {
      map['is_pending_sync'] = Variable<bool>(isPendingSync.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTransactionRowsCompanion(')
          ..write('id: $id, ')
          ..write('walletId: $walletId, ')
          ..write('tagId: $tagId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('transactionType: $transactionType, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('status: $status, ')
          ..write('inputMethod: $inputMethod, ')
          ..write('merchantName: $merchantName, ')
          ..write('clientId: $clientId, ')
          ..write('isPendingSync: $isPendingSync, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingSyncOperationRowsTable extends PendingSyncOperationRows
    with TableInfo<$PendingSyncOperationRowsTable, PendingSyncOperationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingSyncOperationRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entity,
    entityId,
    clientId,
    action,
    payloadJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_sync_operation_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingSyncOperationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_name')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity_name']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingSyncOperationRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingSyncOperationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_name'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      ),
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PendingSyncOperationRowsTable createAlias(String alias) {
    return $PendingSyncOperationRowsTable(attachedDatabase, alias);
  }
}

class PendingSyncOperationRow extends DataClass
    implements Insertable<PendingSyncOperationRow> {
  final int id;
  final String entity;
  final String? entityId;
  final String clientId;
  final String action;
  final String payloadJson;
  final DateTime createdAt;
  const PendingSyncOperationRow({
    required this.id,
    required this.entity,
    this.entityId,
    required this.clientId,
    required this.action,
    required this.payloadJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_name'] = Variable<String>(entity);
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<String>(entityId);
    }
    map['client_id'] = Variable<String>(clientId);
    map['action'] = Variable<String>(action);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PendingSyncOperationRowsCompanion toCompanion(bool nullToAbsent) {
    return PendingSyncOperationRowsCompanion(
      id: Value(id),
      entity: Value(entity),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      clientId: Value(clientId),
      action: Value(action),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
    );
  }

  factory PendingSyncOperationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingSyncOperationRow(
      id: serializer.fromJson<int>(json['id']),
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String?>(json['entityId']),
      clientId: serializer.fromJson<String>(json['clientId']),
      action: serializer.fromJson<String>(json['action']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String?>(entityId),
      'clientId': serializer.toJson<String>(clientId),
      'action': serializer.toJson<String>(action),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PendingSyncOperationRow copyWith({
    int? id,
    String? entity,
    Value<String?> entityId = const Value.absent(),
    String? clientId,
    String? action,
    String? payloadJson,
    DateTime? createdAt,
  }) => PendingSyncOperationRow(
    id: id ?? this.id,
    entity: entity ?? this.entity,
    entityId: entityId.present ? entityId.value : this.entityId,
    clientId: clientId ?? this.clientId,
    action: action ?? this.action,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
  );
  PendingSyncOperationRow copyWithCompanion(
    PendingSyncOperationRowsCompanion data,
  ) {
    return PendingSyncOperationRow(
      id: data.id.present ? data.id.value : this.id,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      action: data.action.present ? data.action.value : this.action,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingSyncOperationRow(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('clientId: $clientId, ')
          ..write('action: $action, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entity,
    entityId,
    clientId,
    action,
    payloadJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingSyncOperationRow &&
          other.id == this.id &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.clientId == this.clientId &&
          other.action == this.action &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt);
}

class PendingSyncOperationRowsCompanion
    extends UpdateCompanion<PendingSyncOperationRow> {
  final Value<int> id;
  final Value<String> entity;
  final Value<String?> entityId;
  final Value<String> clientId;
  final Value<String> action;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  const PendingSyncOperationRowsCompanion({
    this.id = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.action = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PendingSyncOperationRowsCompanion.insert({
    this.id = const Value.absent(),
    required String entity,
    this.entityId = const Value.absent(),
    required String clientId,
    required String action,
    required String payloadJson,
    required DateTime createdAt,
  }) : entity = Value(entity),
       clientId = Value(clientId),
       action = Value(action),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<PendingSyncOperationRow> custom({
    Expression<int>? id,
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? clientId,
    Expression<String>? action,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entity != null) 'entity_name': entity,
      if (entityId != null) 'entity_id': entityId,
      if (clientId != null) 'client_id': clientId,
      if (action != null) 'action': action,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PendingSyncOperationRowsCompanion copyWith({
    Value<int>? id,
    Value<String>? entity,
    Value<String?>? entityId,
    Value<String>? clientId,
    Value<String>? action,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
  }) {
    return PendingSyncOperationRowsCompanion(
      id: id ?? this.id,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      clientId: clientId ?? this.clientId,
      action: action ?? this.action,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entity.present) {
      map['entity_name'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingSyncOperationRowsCompanion(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('clientId: $clientId, ')
          ..write('action: $action, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataRowsTable extends SyncMetadataRows
    with TableInfo<$SyncMetadataRowsTable, SyncMetadataRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetadataRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncMetadataRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SyncMetadataRowsTable createAlias(String alias) {
    return $SyncMetadataRowsTable(attachedDatabase, alias);
  }
}

class SyncMetadataRow extends DataClass implements Insertable<SyncMetadataRow> {
  final String key;
  final String value;
  const SyncMetadataRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SyncMetadataRowsCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataRowsCompanion(key: Value(key), value: Value(value));
  }

  factory SyncMetadataRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SyncMetadataRow copyWith({String? key, String? value}) =>
      SyncMetadataRow(key: key ?? this.key, value: value ?? this.value);
  SyncMetadataRow copyWithCompanion(SyncMetadataRowsCompanion data) {
    return SyncMetadataRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadataRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SyncMetadataRowsCompanion extends UpdateCompanion<SyncMetadataRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SyncMetadataRowsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetadataRowsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SyncMetadataRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetadataRowsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SyncMetadataRowsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataRowsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$FlowFiDatabase extends GeneratedDatabase {
  _$FlowFiDatabase(QueryExecutor e) : super(e);
  $FlowFiDatabaseManager get managers => $FlowFiDatabaseManager(this);
  late final $LocalWalletRowsTable localWalletRows = $LocalWalletRowsTable(
    this,
  );
  late final $LocalTagRowsTable localTagRows = $LocalTagRowsTable(this);
  late final $LocalTransactionRowsTable localTransactionRows =
      $LocalTransactionRowsTable(this);
  late final $PendingSyncOperationRowsTable pendingSyncOperationRows =
      $PendingSyncOperationRowsTable(this);
  late final $SyncMetadataRowsTable syncMetadataRows = $SyncMetadataRowsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localWalletRows,
    localTagRows,
    localTransactionRows,
    pendingSyncOperationRows,
    syncMetadataRows,
  ];
}

typedef $$LocalWalletRowsTableCreateCompanionBuilder =
    LocalWalletRowsCompanion Function({
      required String id,
      required String name,
      required String walletType,
      required String balance,
      Value<bool> isDefault,
      Value<String?> clientId,
      Value<int> version,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$LocalWalletRowsTableUpdateCompanionBuilder =
    LocalWalletRowsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> walletType,
      Value<String> balance,
      Value<bool> isDefault,
      Value<String?> clientId,
      Value<int> version,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$LocalWalletRowsTableFilterComposer
    extends Composer<_$FlowFiDatabase, $LocalWalletRowsTable> {
  $$LocalWalletRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get walletType => $composableBuilder(
    column: $table.walletType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalWalletRowsTableOrderingComposer
    extends Composer<_$FlowFiDatabase, $LocalWalletRowsTable> {
  $$LocalWalletRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get walletType => $composableBuilder(
    column: $table.walletType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalWalletRowsTableAnnotationComposer
    extends Composer<_$FlowFiDatabase, $LocalWalletRowsTable> {
  $$LocalWalletRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get walletType => $composableBuilder(
    column: $table.walletType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$LocalWalletRowsTableTableManager
    extends
        RootTableManager<
          _$FlowFiDatabase,
          $LocalWalletRowsTable,
          LocalWalletRow,
          $$LocalWalletRowsTableFilterComposer,
          $$LocalWalletRowsTableOrderingComposer,
          $$LocalWalletRowsTableAnnotationComposer,
          $$LocalWalletRowsTableCreateCompanionBuilder,
          $$LocalWalletRowsTableUpdateCompanionBuilder,
          (
            LocalWalletRow,
            BaseReferences<
              _$FlowFiDatabase,
              $LocalWalletRowsTable,
              LocalWalletRow
            >,
          ),
          LocalWalletRow,
          PrefetchHooks Function()
        > {
  $$LocalWalletRowsTableTableManager(
    _$FlowFiDatabase db,
    $LocalWalletRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalWalletRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalWalletRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalWalletRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> walletType = const Value.absent(),
                Value<String> balance = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<String?> clientId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalWalletRowsCompanion(
                id: id,
                name: name,
                walletType: walletType,
                balance: balance,
                isDefault: isDefault,
                clientId: clientId,
                version: version,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String walletType,
                required String balance,
                Value<bool> isDefault = const Value.absent(),
                Value<String?> clientId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalWalletRowsCompanion.insert(
                id: id,
                name: name,
                walletType: walletType,
                balance: balance,
                isDefault: isDefault,
                clientId: clientId,
                version: version,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalWalletRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$FlowFiDatabase,
      $LocalWalletRowsTable,
      LocalWalletRow,
      $$LocalWalletRowsTableFilterComposer,
      $$LocalWalletRowsTableOrderingComposer,
      $$LocalWalletRowsTableAnnotationComposer,
      $$LocalWalletRowsTableCreateCompanionBuilder,
      $$LocalWalletRowsTableUpdateCompanionBuilder,
      (
        LocalWalletRow,
        BaseReferences<_$FlowFiDatabase, $LocalWalletRowsTable, LocalWalletRow>,
      ),
      LocalWalletRow,
      PrefetchHooks Function()
    >;
typedef $$LocalTagRowsTableCreateCompanionBuilder =
    LocalTagRowsCompanion Function({
      required String id,
      required String name,
      required String type,
      Value<bool> isDefault,
      Value<String?> clientId,
      Value<int> version,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$LocalTagRowsTableUpdateCompanionBuilder =
    LocalTagRowsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> type,
      Value<bool> isDefault,
      Value<String?> clientId,
      Value<int> version,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$LocalTagRowsTableFilterComposer
    extends Composer<_$FlowFiDatabase, $LocalTagRowsTable> {
  $$LocalTagRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalTagRowsTableOrderingComposer
    extends Composer<_$FlowFiDatabase, $LocalTagRowsTable> {
  $$LocalTagRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalTagRowsTableAnnotationComposer
    extends Composer<_$FlowFiDatabase, $LocalTagRowsTable> {
  $$LocalTagRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$LocalTagRowsTableTableManager
    extends
        RootTableManager<
          _$FlowFiDatabase,
          $LocalTagRowsTable,
          LocalTagRow,
          $$LocalTagRowsTableFilterComposer,
          $$LocalTagRowsTableOrderingComposer,
          $$LocalTagRowsTableAnnotationComposer,
          $$LocalTagRowsTableCreateCompanionBuilder,
          $$LocalTagRowsTableUpdateCompanionBuilder,
          (
            LocalTagRow,
            BaseReferences<_$FlowFiDatabase, $LocalTagRowsTable, LocalTagRow>,
          ),
          LocalTagRow,
          PrefetchHooks Function()
        > {
  $$LocalTagRowsTableTableManager(_$FlowFiDatabase db, $LocalTagRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTagRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTagRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalTagRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<String?> clientId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTagRowsCompanion(
                id: id,
                name: name,
                type: type,
                isDefault: isDefault,
                clientId: clientId,
                version: version,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String type,
                Value<bool> isDefault = const Value.absent(),
                Value<String?> clientId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTagRowsCompanion.insert(
                id: id,
                name: name,
                type: type,
                isDefault: isDefault,
                clientId: clientId,
                version: version,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalTagRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$FlowFiDatabase,
      $LocalTagRowsTable,
      LocalTagRow,
      $$LocalTagRowsTableFilterComposer,
      $$LocalTagRowsTableOrderingComposer,
      $$LocalTagRowsTableAnnotationComposer,
      $$LocalTagRowsTableCreateCompanionBuilder,
      $$LocalTagRowsTableUpdateCompanionBuilder,
      (
        LocalTagRow,
        BaseReferences<_$FlowFiDatabase, $LocalTagRowsTable, LocalTagRow>,
      ),
      LocalTagRow,
      PrefetchHooks Function()
    >;
typedef $$LocalTransactionRowsTableCreateCompanionBuilder =
    LocalTransactionRowsCompanion Function({
      required String id,
      Value<String?> walletId,
      Value<String?> tagId,
      required String title,
      Value<String?> description,
      required String amount,
      required String transactionType,
      Value<DateTime?> transactionDate,
      required String status,
      required String inputMethod,
      Value<String?> merchantName,
      Value<String?> clientId,
      Value<bool> isPendingSync,
      Value<int> version,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$LocalTransactionRowsTableUpdateCompanionBuilder =
    LocalTransactionRowsCompanion Function({
      Value<String> id,
      Value<String?> walletId,
      Value<String?> tagId,
      Value<String> title,
      Value<String?> description,
      Value<String> amount,
      Value<String> transactionType,
      Value<DateTime?> transactionDate,
      Value<String> status,
      Value<String> inputMethod,
      Value<String?> merchantName,
      Value<String?> clientId,
      Value<bool> isPendingSync,
      Value<int> version,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$LocalTransactionRowsTableFilterComposer
    extends Composer<_$FlowFiDatabase, $LocalTransactionRowsTable> {
  $$LocalTransactionRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get walletId => $composableBuilder(
    column: $table.walletId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagId => $composableBuilder(
    column: $table.tagId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inputMethod => $composableBuilder(
    column: $table.inputMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchantName => $composableBuilder(
    column: $table.merchantName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPendingSync => $composableBuilder(
    column: $table.isPendingSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalTransactionRowsTableOrderingComposer
    extends Composer<_$FlowFiDatabase, $LocalTransactionRowsTable> {
  $$LocalTransactionRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get walletId => $composableBuilder(
    column: $table.walletId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagId => $composableBuilder(
    column: $table.tagId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inputMethod => $composableBuilder(
    column: $table.inputMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchantName => $composableBuilder(
    column: $table.merchantName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPendingSync => $composableBuilder(
    column: $table.isPendingSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalTransactionRowsTableAnnotationComposer
    extends Composer<_$FlowFiDatabase, $LocalTransactionRowsTable> {
  $$LocalTransactionRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get walletId =>
      $composableBuilder(column: $table.walletId, builder: (column) => column);

  GeneratedColumn<String> get tagId =>
      $composableBuilder(column: $table.tagId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get inputMethod => $composableBuilder(
    column: $table.inputMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get merchantName => $composableBuilder(
    column: $table.merchantName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<bool> get isPendingSync => $composableBuilder(
    column: $table.isPendingSync,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$LocalTransactionRowsTableTableManager
    extends
        RootTableManager<
          _$FlowFiDatabase,
          $LocalTransactionRowsTable,
          LocalTransactionRow,
          $$LocalTransactionRowsTableFilterComposer,
          $$LocalTransactionRowsTableOrderingComposer,
          $$LocalTransactionRowsTableAnnotationComposer,
          $$LocalTransactionRowsTableCreateCompanionBuilder,
          $$LocalTransactionRowsTableUpdateCompanionBuilder,
          (
            LocalTransactionRow,
            BaseReferences<
              _$FlowFiDatabase,
              $LocalTransactionRowsTable,
              LocalTransactionRow
            >,
          ),
          LocalTransactionRow,
          PrefetchHooks Function()
        > {
  $$LocalTransactionRowsTableTableManager(
    _$FlowFiDatabase db,
    $LocalTransactionRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTransactionRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTransactionRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalTransactionRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> walletId = const Value.absent(),
                Value<String?> tagId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> amount = const Value.absent(),
                Value<String> transactionType = const Value.absent(),
                Value<DateTime?> transactionDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> inputMethod = const Value.absent(),
                Value<String?> merchantName = const Value.absent(),
                Value<String?> clientId = const Value.absent(),
                Value<bool> isPendingSync = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTransactionRowsCompanion(
                id: id,
                walletId: walletId,
                tagId: tagId,
                title: title,
                description: description,
                amount: amount,
                transactionType: transactionType,
                transactionDate: transactionDate,
                status: status,
                inputMethod: inputMethod,
                merchantName: merchantName,
                clientId: clientId,
                isPendingSync: isPendingSync,
                version: version,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> walletId = const Value.absent(),
                Value<String?> tagId = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                required String amount,
                required String transactionType,
                Value<DateTime?> transactionDate = const Value.absent(),
                required String status,
                required String inputMethod,
                Value<String?> merchantName = const Value.absent(),
                Value<String?> clientId = const Value.absent(),
                Value<bool> isPendingSync = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTransactionRowsCompanion.insert(
                id: id,
                walletId: walletId,
                tagId: tagId,
                title: title,
                description: description,
                amount: amount,
                transactionType: transactionType,
                transactionDate: transactionDate,
                status: status,
                inputMethod: inputMethod,
                merchantName: merchantName,
                clientId: clientId,
                isPendingSync: isPendingSync,
                version: version,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalTransactionRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$FlowFiDatabase,
      $LocalTransactionRowsTable,
      LocalTransactionRow,
      $$LocalTransactionRowsTableFilterComposer,
      $$LocalTransactionRowsTableOrderingComposer,
      $$LocalTransactionRowsTableAnnotationComposer,
      $$LocalTransactionRowsTableCreateCompanionBuilder,
      $$LocalTransactionRowsTableUpdateCompanionBuilder,
      (
        LocalTransactionRow,
        BaseReferences<
          _$FlowFiDatabase,
          $LocalTransactionRowsTable,
          LocalTransactionRow
        >,
      ),
      LocalTransactionRow,
      PrefetchHooks Function()
    >;
typedef $$PendingSyncOperationRowsTableCreateCompanionBuilder =
    PendingSyncOperationRowsCompanion Function({
      Value<int> id,
      required String entity,
      Value<String?> entityId,
      required String clientId,
      required String action,
      required String payloadJson,
      required DateTime createdAt,
    });
typedef $$PendingSyncOperationRowsTableUpdateCompanionBuilder =
    PendingSyncOperationRowsCompanion Function({
      Value<int> id,
      Value<String> entity,
      Value<String?> entityId,
      Value<String> clientId,
      Value<String> action,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
    });

class $$PendingSyncOperationRowsTableFilterComposer
    extends Composer<_$FlowFiDatabase, $PendingSyncOperationRowsTable> {
  $$PendingSyncOperationRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingSyncOperationRowsTableOrderingComposer
    extends Composer<_$FlowFiDatabase, $PendingSyncOperationRowsTable> {
  $$PendingSyncOperationRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingSyncOperationRowsTableAnnotationComposer
    extends Composer<_$FlowFiDatabase, $PendingSyncOperationRowsTable> {
  $$PendingSyncOperationRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PendingSyncOperationRowsTableTableManager
    extends
        RootTableManager<
          _$FlowFiDatabase,
          $PendingSyncOperationRowsTable,
          PendingSyncOperationRow,
          $$PendingSyncOperationRowsTableFilterComposer,
          $$PendingSyncOperationRowsTableOrderingComposer,
          $$PendingSyncOperationRowsTableAnnotationComposer,
          $$PendingSyncOperationRowsTableCreateCompanionBuilder,
          $$PendingSyncOperationRowsTableUpdateCompanionBuilder,
          (
            PendingSyncOperationRow,
            BaseReferences<
              _$FlowFiDatabase,
              $PendingSyncOperationRowsTable,
              PendingSyncOperationRow
            >,
          ),
          PendingSyncOperationRow,
          PrefetchHooks Function()
        > {
  $$PendingSyncOperationRowsTableTableManager(
    _$FlowFiDatabase db,
    $PendingSyncOperationRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingSyncOperationRowsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PendingSyncOperationRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PendingSyncOperationRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String?> entityId = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PendingSyncOperationRowsCompanion(
                id: id,
                entity: entity,
                entityId: entityId,
                clientId: clientId,
                action: action,
                payloadJson: payloadJson,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entity,
                Value<String?> entityId = const Value.absent(),
                required String clientId,
                required String action,
                required String payloadJson,
                required DateTime createdAt,
              }) => PendingSyncOperationRowsCompanion.insert(
                id: id,
                entity: entity,
                entityId: entityId,
                clientId: clientId,
                action: action,
                payloadJson: payloadJson,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingSyncOperationRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$FlowFiDatabase,
      $PendingSyncOperationRowsTable,
      PendingSyncOperationRow,
      $$PendingSyncOperationRowsTableFilterComposer,
      $$PendingSyncOperationRowsTableOrderingComposer,
      $$PendingSyncOperationRowsTableAnnotationComposer,
      $$PendingSyncOperationRowsTableCreateCompanionBuilder,
      $$PendingSyncOperationRowsTableUpdateCompanionBuilder,
      (
        PendingSyncOperationRow,
        BaseReferences<
          _$FlowFiDatabase,
          $PendingSyncOperationRowsTable,
          PendingSyncOperationRow
        >,
      ),
      PendingSyncOperationRow,
      PrefetchHooks Function()
    >;
typedef $$SyncMetadataRowsTableCreateCompanionBuilder =
    SyncMetadataRowsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SyncMetadataRowsTableUpdateCompanionBuilder =
    SyncMetadataRowsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SyncMetadataRowsTableFilterComposer
    extends Composer<_$FlowFiDatabase, $SyncMetadataRowsTable> {
  $$SyncMetadataRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetadataRowsTableOrderingComposer
    extends Composer<_$FlowFiDatabase, $SyncMetadataRowsTable> {
  $$SyncMetadataRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetadataRowsTableAnnotationComposer
    extends Composer<_$FlowFiDatabase, $SyncMetadataRowsTable> {
  $$SyncMetadataRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SyncMetadataRowsTableTableManager
    extends
        RootTableManager<
          _$FlowFiDatabase,
          $SyncMetadataRowsTable,
          SyncMetadataRow,
          $$SyncMetadataRowsTableFilterComposer,
          $$SyncMetadataRowsTableOrderingComposer,
          $$SyncMetadataRowsTableAnnotationComposer,
          $$SyncMetadataRowsTableCreateCompanionBuilder,
          $$SyncMetadataRowsTableUpdateCompanionBuilder,
          (
            SyncMetadataRow,
            BaseReferences<
              _$FlowFiDatabase,
              $SyncMetadataRowsTable,
              SyncMetadataRow
            >,
          ),
          SyncMetadataRow,
          PrefetchHooks Function()
        > {
  $$SyncMetadataRowsTableTableManager(
    _$FlowFiDatabase db,
    $SyncMetadataRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataRowsCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataRowsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetadataRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$FlowFiDatabase,
      $SyncMetadataRowsTable,
      SyncMetadataRow,
      $$SyncMetadataRowsTableFilterComposer,
      $$SyncMetadataRowsTableOrderingComposer,
      $$SyncMetadataRowsTableAnnotationComposer,
      $$SyncMetadataRowsTableCreateCompanionBuilder,
      $$SyncMetadataRowsTableUpdateCompanionBuilder,
      (
        SyncMetadataRow,
        BaseReferences<
          _$FlowFiDatabase,
          $SyncMetadataRowsTable,
          SyncMetadataRow
        >,
      ),
      SyncMetadataRow,
      PrefetchHooks Function()
    >;

class $FlowFiDatabaseManager {
  final _$FlowFiDatabase _db;
  $FlowFiDatabaseManager(this._db);
  $$LocalWalletRowsTableTableManager get localWalletRows =>
      $$LocalWalletRowsTableTableManager(_db, _db.localWalletRows);
  $$LocalTagRowsTableTableManager get localTagRows =>
      $$LocalTagRowsTableTableManager(_db, _db.localTagRows);
  $$LocalTransactionRowsTableTableManager get localTransactionRows =>
      $$LocalTransactionRowsTableTableManager(_db, _db.localTransactionRows);
  $$PendingSyncOperationRowsTableTableManager get pendingSyncOperationRows =>
      $$PendingSyncOperationRowsTableTableManager(
        _db,
        _db.pendingSyncOperationRows,
      );
  $$SyncMetadataRowsTableTableManager get syncMetadataRows =>
      $$SyncMetadataRowsTableTableManager(_db, _db.syncMetadataRows);
}
