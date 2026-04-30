// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ExplorationQueueTable extends ExplorationQueue
    with TableInfo<$ExplorationQueueTable, ExplorationQueueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExplorationQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _accuracyMeta =
      const VerificationMeta('accuracy');
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
      'accuracy', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<double> speed = GeneratedColumn<double>(
      'speed', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _recordedAtMeta =
      const VerificationMeta('recordedAt');
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
      'recorded_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, latitude, longitude, accuracy, speed, recordedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exploration_queue';
  @override
  VerificationContext validateIntegrity(
      Insertable<ExplorationQueueEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('accuracy')) {
      context.handle(_accuracyMeta,
          accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta));
    } else if (isInserting) {
      context.missing(_accuracyMeta);
    }
    if (data.containsKey('speed')) {
      context.handle(
          _speedMeta, speed.isAcceptableOrUnknown(data['speed']!, _speedMeta));
    } else if (isInserting) {
      context.missing(_speedMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
          _recordedAtMeta,
          recordedAt.isAcceptableOrUnknown(
              data['recorded_at']!, _recordedAtMeta));
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExplorationQueueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExplorationQueueEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude'])!,
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude'])!,
      accuracy: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}accuracy'])!,
      speed: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}speed'])!,
      recordedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}recorded_at'])!,
    );
  }

  @override
  $ExplorationQueueTable createAlias(String alias) {
    return $ExplorationQueueTable(attachedDatabase, alias);
  }
}

class ExplorationQueueEntry extends DataClass
    implements Insertable<ExplorationQueueEntry> {
  final int id;
  final double latitude;
  final double longitude;
  final double accuracy;
  final double speed;
  final DateTime recordedAt;
  const ExplorationQueueEntry(
      {required this.id,
      required this.latitude,
      required this.longitude,
      required this.accuracy,
      required this.speed,
      required this.recordedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['accuracy'] = Variable<double>(accuracy);
    map['speed'] = Variable<double>(speed);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    return map;
  }

  ExplorationQueueCompanion toCompanion(bool nullToAbsent) {
    return ExplorationQueueCompanion(
      id: Value(id),
      latitude: Value(latitude),
      longitude: Value(longitude),
      accuracy: Value(accuracy),
      speed: Value(speed),
      recordedAt: Value(recordedAt),
    );
  }

  factory ExplorationQueueEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExplorationQueueEntry(
      id: serializer.fromJson<int>(json['id']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      accuracy: serializer.fromJson<double>(json['accuracy']),
      speed: serializer.fromJson<double>(json['speed']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'accuracy': serializer.toJson<double>(accuracy),
      'speed': serializer.toJson<double>(speed),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
    };
  }

  ExplorationQueueEntry copyWith(
          {int? id,
          double? latitude,
          double? longitude,
          double? accuracy,
          double? speed,
          DateTime? recordedAt}) =>
      ExplorationQueueEntry(
        id: id ?? this.id,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        accuracy: accuracy ?? this.accuracy,
        speed: speed ?? this.speed,
        recordedAt: recordedAt ?? this.recordedAt,
      );
  ExplorationQueueEntry copyWithCompanion(ExplorationQueueCompanion data) {
    return ExplorationQueueEntry(
      id: data.id.present ? data.id.value : this.id,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      speed: data.speed.present ? data.speed.value : this.speed,
      recordedAt:
          data.recordedAt.present ? data.recordedAt.value : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExplorationQueueEntry(')
          ..write('id: $id, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('accuracy: $accuracy, ')
          ..write('speed: $speed, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, latitude, longitude, accuracy, speed, recordedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExplorationQueueEntry &&
          other.id == this.id &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.accuracy == this.accuracy &&
          other.speed == this.speed &&
          other.recordedAt == this.recordedAt);
}

class ExplorationQueueCompanion extends UpdateCompanion<ExplorationQueueEntry> {
  final Value<int> id;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double> accuracy;
  final Value<double> speed;
  final Value<DateTime> recordedAt;
  const ExplorationQueueCompanion({
    this.id = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.speed = const Value.absent(),
    this.recordedAt = const Value.absent(),
  });
  ExplorationQueueCompanion.insert({
    this.id = const Value.absent(),
    required double latitude,
    required double longitude,
    required double accuracy,
    required double speed,
    required DateTime recordedAt,
  })  : latitude = Value(latitude),
        longitude = Value(longitude),
        accuracy = Value(accuracy),
        speed = Value(speed),
        recordedAt = Value(recordedAt);
  static Insertable<ExplorationQueueEntry> custom({
    Expression<int>? id,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? accuracy,
    Expression<double>? speed,
    Expression<DateTime>? recordedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (accuracy != null) 'accuracy': accuracy,
      if (speed != null) 'speed': speed,
      if (recordedAt != null) 'recorded_at': recordedAt,
    });
  }

  ExplorationQueueCompanion copyWith(
      {Value<int>? id,
      Value<double>? latitude,
      Value<double>? longitude,
      Value<double>? accuracy,
      Value<double>? speed,
      Value<DateTime>? recordedAt}) {
    return ExplorationQueueCompanion(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      speed: speed ?? this.speed,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (speed.present) {
      map['speed'] = Variable<double>(speed.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExplorationQueueCompanion(')
          ..write('id: $id, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('accuracy: $accuracy, ')
          ..write('speed: $speed, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }
}

class $CachedFogAreasTable extends CachedFogAreas
    with TableInfo<$CachedFogAreasTable, CachedFogArea> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedFogAreasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _exploredAtMeta =
      const VerificationMeta('exploredAt');
  @override
  late final GeneratedColumn<String> exploredAt = GeneratedColumn<String>(
      'explored_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, latitude, longitude, exploredAt, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_fog_areas';
  @override
  VerificationContext validateIntegrity(Insertable<CachedFogArea> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('explored_at')) {
      context.handle(
          _exploredAtMeta,
          exploredAt.isAcceptableOrUnknown(
              data['explored_at']!, _exploredAtMeta));
    } else if (isInserting) {
      context.missing(_exploredAtMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedFogArea map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedFogArea(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude'])!,
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude'])!,
      exploredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}explored_at'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $CachedFogAreasTable createAlias(String alias) {
    return $CachedFogAreasTable(attachedDatabase, alias);
  }
}

class CachedFogArea extends DataClass implements Insertable<CachedFogArea> {
  final int id;
  final double latitude;
  final double longitude;
  final String exploredAt;
  final DateTime cachedAt;
  const CachedFogArea(
      {required this.id,
      required this.latitude,
      required this.longitude,
      required this.exploredAt,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['explored_at'] = Variable<String>(exploredAt);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedFogAreasCompanion toCompanion(bool nullToAbsent) {
    return CachedFogAreasCompanion(
      id: Value(id),
      latitude: Value(latitude),
      longitude: Value(longitude),
      exploredAt: Value(exploredAt),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedFogArea.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedFogArea(
      id: serializer.fromJson<int>(json['id']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      exploredAt: serializer.fromJson<String>(json['exploredAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'exploredAt': serializer.toJson<String>(exploredAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedFogArea copyWith(
          {int? id,
          double? latitude,
          double? longitude,
          String? exploredAt,
          DateTime? cachedAt}) =>
      CachedFogArea(
        id: id ?? this.id,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        exploredAt: exploredAt ?? this.exploredAt,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  CachedFogArea copyWithCompanion(CachedFogAreasCompanion data) {
    return CachedFogArea(
      id: data.id.present ? data.id.value : this.id,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      exploredAt:
          data.exploredAt.present ? data.exploredAt.value : this.exploredAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedFogArea(')
          ..write('id: $id, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('exploredAt: $exploredAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, latitude, longitude, exploredAt, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedFogArea &&
          other.id == this.id &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.exploredAt == this.exploredAt &&
          other.cachedAt == this.cachedAt);
}

class CachedFogAreasCompanion extends UpdateCompanion<CachedFogArea> {
  final Value<int> id;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> exploredAt;
  final Value<DateTime> cachedAt;
  const CachedFogAreasCompanion({
    this.id = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.exploredAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  CachedFogAreasCompanion.insert({
    this.id = const Value.absent(),
    required double latitude,
    required double longitude,
    required String exploredAt,
    required DateTime cachedAt,
  })  : latitude = Value(latitude),
        longitude = Value(longitude),
        exploredAt = Value(exploredAt),
        cachedAt = Value(cachedAt);
  static Insertable<CachedFogArea> custom({
    Expression<int>? id,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? exploredAt,
    Expression<DateTime>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (exploredAt != null) 'explored_at': exploredAt,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  CachedFogAreasCompanion copyWith(
      {Value<int>? id,
      Value<double>? latitude,
      Value<double>? longitude,
      Value<String>? exploredAt,
      Value<DateTime>? cachedAt}) {
    return CachedFogAreasCompanion(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      exploredAt: exploredAt ?? this.exploredAt,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (exploredAt.present) {
      map['explored_at'] = Variable<String>(exploredAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedFogAreasCompanion(')
          ..write('id: $id, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('exploredAt: $exploredAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ExplorationQueueTable explorationQueue =
      $ExplorationQueueTable(this);
  late final $CachedFogAreasTable cachedFogAreas = $CachedFogAreasTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [explorationQueue, cachedFogAreas];
}

typedef $$ExplorationQueueTableCreateCompanionBuilder
    = ExplorationQueueCompanion Function({
  Value<int> id,
  required double latitude,
  required double longitude,
  required double accuracy,
  required double speed,
  required DateTime recordedAt,
});
typedef $$ExplorationQueueTableUpdateCompanionBuilder
    = ExplorationQueueCompanion Function({
  Value<int> id,
  Value<double> latitude,
  Value<double> longitude,
  Value<double> accuracy,
  Value<double> speed,
  Value<DateTime> recordedAt,
});

class $$ExplorationQueueTableFilterComposer
    extends Composer<_$AppDatabase, $ExplorationQueueTable> {
  $$ExplorationQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get accuracy => $composableBuilder(
      column: $table.accuracy, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get speed => $composableBuilder(
      column: $table.speed, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnFilters(column));
}

class $$ExplorationQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $ExplorationQueueTable> {
  $$ExplorationQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get accuracy => $composableBuilder(
      column: $table.accuracy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get speed => $composableBuilder(
      column: $table.speed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnOrderings(column));
}

class $$ExplorationQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExplorationQueueTable> {
  $$ExplorationQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<double> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => column);
}

class $$ExplorationQueueTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExplorationQueueTable,
    ExplorationQueueEntry,
    $$ExplorationQueueTableFilterComposer,
    $$ExplorationQueueTableOrderingComposer,
    $$ExplorationQueueTableAnnotationComposer,
    $$ExplorationQueueTableCreateCompanionBuilder,
    $$ExplorationQueueTableUpdateCompanionBuilder,
    (
      ExplorationQueueEntry,
      BaseReferences<_$AppDatabase, $ExplorationQueueTable,
          ExplorationQueueEntry>
    ),
    ExplorationQueueEntry,
    PrefetchHooks Function()> {
  $$ExplorationQueueTableTableManager(
      _$AppDatabase db, $ExplorationQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExplorationQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExplorationQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExplorationQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<double> latitude = const Value.absent(),
            Value<double> longitude = const Value.absent(),
            Value<double> accuracy = const Value.absent(),
            Value<double> speed = const Value.absent(),
            Value<DateTime> recordedAt = const Value.absent(),
          }) =>
              ExplorationQueueCompanion(
            id: id,
            latitude: latitude,
            longitude: longitude,
            accuracy: accuracy,
            speed: speed,
            recordedAt: recordedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required double latitude,
            required double longitude,
            required double accuracy,
            required double speed,
            required DateTime recordedAt,
          }) =>
              ExplorationQueueCompanion.insert(
            id: id,
            latitude: latitude,
            longitude: longitude,
            accuracy: accuracy,
            speed: speed,
            recordedAt: recordedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ExplorationQueueTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExplorationQueueTable,
    ExplorationQueueEntry,
    $$ExplorationQueueTableFilterComposer,
    $$ExplorationQueueTableOrderingComposer,
    $$ExplorationQueueTableAnnotationComposer,
    $$ExplorationQueueTableCreateCompanionBuilder,
    $$ExplorationQueueTableUpdateCompanionBuilder,
    (
      ExplorationQueueEntry,
      BaseReferences<_$AppDatabase, $ExplorationQueueTable,
          ExplorationQueueEntry>
    ),
    ExplorationQueueEntry,
    PrefetchHooks Function()>;
typedef $$CachedFogAreasTableCreateCompanionBuilder = CachedFogAreasCompanion
    Function({
  Value<int> id,
  required double latitude,
  required double longitude,
  required String exploredAt,
  required DateTime cachedAt,
});
typedef $$CachedFogAreasTableUpdateCompanionBuilder = CachedFogAreasCompanion
    Function({
  Value<int> id,
  Value<double> latitude,
  Value<double> longitude,
  Value<String> exploredAt,
  Value<DateTime> cachedAt,
});

class $$CachedFogAreasTableFilterComposer
    extends Composer<_$AppDatabase, $CachedFogAreasTable> {
  $$CachedFogAreasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exploredAt => $composableBuilder(
      column: $table.exploredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$CachedFogAreasTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedFogAreasTable> {
  $$CachedFogAreasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exploredAt => $composableBuilder(
      column: $table.exploredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedFogAreasTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedFogAreasTable> {
  $$CachedFogAreasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get exploredAt => $composableBuilder(
      column: $table.exploredAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedFogAreasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedFogAreasTable,
    CachedFogArea,
    $$CachedFogAreasTableFilterComposer,
    $$CachedFogAreasTableOrderingComposer,
    $$CachedFogAreasTableAnnotationComposer,
    $$CachedFogAreasTableCreateCompanionBuilder,
    $$CachedFogAreasTableUpdateCompanionBuilder,
    (
      CachedFogArea,
      BaseReferences<_$AppDatabase, $CachedFogAreasTable, CachedFogArea>
    ),
    CachedFogArea,
    PrefetchHooks Function()> {
  $$CachedFogAreasTableTableManager(
      _$AppDatabase db, $CachedFogAreasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedFogAreasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedFogAreasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedFogAreasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<double> latitude = const Value.absent(),
            Value<double> longitude = const Value.absent(),
            Value<String> exploredAt = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
          }) =>
              CachedFogAreasCompanion(
            id: id,
            latitude: latitude,
            longitude: longitude,
            exploredAt: exploredAt,
            cachedAt: cachedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required double latitude,
            required double longitude,
            required String exploredAt,
            required DateTime cachedAt,
          }) =>
              CachedFogAreasCompanion.insert(
            id: id,
            latitude: latitude,
            longitude: longitude,
            exploredAt: exploredAt,
            cachedAt: cachedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedFogAreasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedFogAreasTable,
    CachedFogArea,
    $$CachedFogAreasTableFilterComposer,
    $$CachedFogAreasTableOrderingComposer,
    $$CachedFogAreasTableAnnotationComposer,
    $$CachedFogAreasTableCreateCompanionBuilder,
    $$CachedFogAreasTableUpdateCompanionBuilder,
    (
      CachedFogArea,
      BaseReferences<_$AppDatabase, $CachedFogAreasTable, CachedFogArea>
    ),
    CachedFogArea,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ExplorationQueueTableTableManager get explorationQueue =>
      $$ExplorationQueueTableTableManager(_db, _db.explorationQueue);
  $$CachedFogAreasTableTableManager get cachedFogAreas =>
      $$CachedFogAreasTableTableManager(_db, _db.cachedFogAreas);
}
