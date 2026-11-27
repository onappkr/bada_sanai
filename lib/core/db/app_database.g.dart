// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PointsTable extends Points with TableInfo<$PointsTable, Point> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PointsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Genre?, String> genre =
      GeneratedColumn<String>(
        'genre',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Genre?>($PointsTable.$convertergenren);
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PointSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PointSource>($PointsTable.$convertersource);
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
    lat,
    lng,
    genre,
    memo,
    source,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'points';
  @override
  VerificationContext validateIntegrity(
    Insertable<Point> instance, {
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
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
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
  Point map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Point(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      )!,
      genre: $PointsTable.$convertergenren.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}genre'],
        ),
      ),
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      source: $PointsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $PointsTable createAlias(String alias) {
    return $PointsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Genre, String, String> $convertergenre =
      const EnumNameConverter<Genre>(Genre.values);
  static JsonTypeConverter2<Genre?, String?, String?> $convertergenren =
      JsonTypeConverter2.asNullable($convertergenre);
  static JsonTypeConverter2<PointSource, String, String> $convertersource =
      const EnumNameConverter<PointSource>(PointSource.values);
}

class Point extends DataClass implements Insertable<Point> {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final Genre? genre;
  final String? memo;
  final PointSource source;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Point({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    this.genre,
    this.memo,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    if (!nullToAbsent || genre != null) {
      map['genre'] = Variable<String>(
        $PointsTable.$convertergenren.toSql(genre),
      );
    }
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    {
      map['source'] = Variable<String>(
        $PointsTable.$convertersource.toSql(source),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  PointsCompanion toCompanion(bool nullToAbsent) {
    return PointsCompanion(
      id: Value(id),
      name: Value(name),
      lat: Value(lat),
      lng: Value(lng),
      genre: genre == null && nullToAbsent
          ? const Value.absent()
          : Value(genre),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      source: Value(source),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Point.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Point(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      genre: $PointsTable.$convertergenren.fromJson(
        serializer.fromJson<String?>(json['genre']),
      ),
      memo: serializer.fromJson<String?>(json['memo']),
      source: $PointsTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'genre': serializer.toJson<String?>(
        $PointsTable.$convertergenren.toJson(genre),
      ),
      'memo': serializer.toJson<String?>(memo),
      'source': serializer.toJson<String>(
        $PointsTable.$convertersource.toJson(source),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Point copyWith({
    String? id,
    String? name,
    double? lat,
    double? lng,
    Value<Genre?> genre = const Value.absent(),
    Value<String?> memo = const Value.absent(),
    PointSource? source,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Point(
    id: id ?? this.id,
    name: name ?? this.name,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    genre: genre.present ? genre.value : this.genre,
    memo: memo.present ? memo.value : this.memo,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Point copyWithCompanion(PointsCompanion data) {
    return Point(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      genre: data.genre.present ? data.genre.value : this.genre,
      memo: data.memo.present ? data.memo.value : this.memo,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Point(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('genre: $genre, ')
          ..write('memo: $memo, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    lat,
    lng,
    genre,
    memo,
    source,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Point &&
          other.id == this.id &&
          other.name == this.name &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.genre == this.genre &&
          other.memo == this.memo &&
          other.source == this.source &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class PointsCompanion extends UpdateCompanion<Point> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> lat;
  final Value<double> lng;
  final Value<Genre?> genre;
  final Value<String?> memo;
  final Value<PointSource> source;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const PointsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.genre = const Value.absent(),
    this.memo = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PointsCompanion.insert({
    required String id,
    required String name,
    required double lat,
    required double lng,
    this.genre = const Value.absent(),
    this.memo = const Value.absent(),
    required PointSource source,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       lat = Value(lat),
       lng = Value(lng),
       source = Value(source),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Point> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<String>? genre,
    Expression<String>? memo,
    Expression<String>? source,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (genre != null) 'genre': genre,
      if (memo != null) 'memo': memo,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PointsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<double>? lat,
    Value<double>? lng,
    Value<Genre?>? genre,
    Value<String?>? memo,
    Value<PointSource>? source,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return PointsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      genre: genre ?? this.genre,
      memo: memo ?? this.memo,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
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
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(
        $PointsTable.$convertergenren.toSql(genre.value),
      );
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $PointsTable.$convertersource.toSql(source.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('PointsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('genre: $genre, ')
          ..write('memo: $memo, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatchLogsTable extends CatchLogs
    with TableInfo<$CatchLogsTable, CatchLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatchLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Genre, String> genre =
      GeneratedColumn<String>(
        'genre',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Genre>($CatchLogsTable.$convertergenre);
  static const VerificationMeta _fishedAtMeta = const VerificationMeta(
    'fishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fishedAt = GeneratedColumn<DateTime>(
    'fished_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pointIdMeta = const VerificationMeta(
    'pointId',
  );
  @override
  late final GeneratedColumn<String> pointId = GeneratedColumn<String>(
    'point_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES points (id)',
    ),
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genreDetailMeta = const VerificationMeta(
    'genreDetail',
  );
  @override
  late final GeneratedColumn<String> genreDetail = GeneratedColumn<String>(
    'genre_detail',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _envMeta = const VerificationMeta('env');
  @override
  late final GeneratedColumn<String> env = GeneratedColumn<String>(
    'env',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
    genre,
    fishedAt,
    pointId,
    lat,
    lng,
    memo,
    genreDetail,
    env,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catch_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatchLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('fished_at')) {
      context.handle(
        _fishedAtMeta,
        fishedAt.isAcceptableOrUnknown(data['fished_at']!, _fishedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fishedAtMeta);
    }
    if (data.containsKey('point_id')) {
      context.handle(
        _pointIdMeta,
        pointId.isAcceptableOrUnknown(data['point_id']!, _pointIdMeta),
      );
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('genre_detail')) {
      context.handle(
        _genreDetailMeta,
        genreDetail.isAcceptableOrUnknown(
          data['genre_detail']!,
          _genreDetailMeta,
        ),
      );
    }
    if (data.containsKey('env')) {
      context.handle(
        _envMeta,
        env.isAcceptableOrUnknown(data['env']!, _envMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
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
  CatchLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatchLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      genre: $CatchLogsTable.$convertergenre.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}genre'],
        )!,
      ),
      fishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fished_at'],
      )!,
      pointId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}point_id'],
      ),
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      ),
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      genreDetail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre_detail'],
      )!,
      env: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}env'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $CatchLogsTable createAlias(String alias) {
    return $CatchLogsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Genre, String, String> $convertergenre =
      const EnumNameConverter<Genre>(Genre.values);
}

class CatchLog extends DataClass implements Insertable<CatchLog> {
  final String id;
  final Genre genre;
  final DateTime fishedAt;
  final String? pointId;
  final double? lat;
  final double? lng;
  final String? memo;

  /// 장르별 항목(JSON 문자열). 장르 추가 시 스키마 변경을 피한다.
  final String genreDetail;

  /// 물때·수온·날씨 스냅샷(JSON 문자열).
  final String env;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const CatchLog({
    required this.id,
    required this.genre,
    required this.fishedAt,
    this.pointId,
    this.lat,
    this.lng,
    this.memo,
    required this.genreDetail,
    required this.env,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['genre'] = Variable<String>(
        $CatchLogsTable.$convertergenre.toSql(genre),
      );
    }
    map['fished_at'] = Variable<DateTime>(fishedAt);
    if (!nullToAbsent || pointId != null) {
      map['point_id'] = Variable<String>(pointId);
    }
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lng != null) {
      map['lng'] = Variable<double>(lng);
    }
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    map['genre_detail'] = Variable<String>(genreDetail);
    map['env'] = Variable<String>(env);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  CatchLogsCompanion toCompanion(bool nullToAbsent) {
    return CatchLogsCompanion(
      id: Value(id),
      genre: Value(genre),
      fishedAt: Value(fishedAt),
      pointId: pointId == null && nullToAbsent
          ? const Value.absent()
          : Value(pointId),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      genreDetail: Value(genreDetail),
      env: Value(env),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory CatchLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatchLog(
      id: serializer.fromJson<String>(json['id']),
      genre: $CatchLogsTable.$convertergenre.fromJson(
        serializer.fromJson<String>(json['genre']),
      ),
      fishedAt: serializer.fromJson<DateTime>(json['fishedAt']),
      pointId: serializer.fromJson<String?>(json['pointId']),
      lat: serializer.fromJson<double?>(json['lat']),
      lng: serializer.fromJson<double?>(json['lng']),
      memo: serializer.fromJson<String?>(json['memo']),
      genreDetail: serializer.fromJson<String>(json['genreDetail']),
      env: serializer.fromJson<String>(json['env']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'genre': serializer.toJson<String>(
        $CatchLogsTable.$convertergenre.toJson(genre),
      ),
      'fishedAt': serializer.toJson<DateTime>(fishedAt),
      'pointId': serializer.toJson<String?>(pointId),
      'lat': serializer.toJson<double?>(lat),
      'lng': serializer.toJson<double?>(lng),
      'memo': serializer.toJson<String?>(memo),
      'genreDetail': serializer.toJson<String>(genreDetail),
      'env': serializer.toJson<String>(env),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  CatchLog copyWith({
    String? id,
    Genre? genre,
    DateTime? fishedAt,
    Value<String?> pointId = const Value.absent(),
    Value<double?> lat = const Value.absent(),
    Value<double?> lng = const Value.absent(),
    Value<String?> memo = const Value.absent(),
    String? genreDetail,
    String? env,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => CatchLog(
    id: id ?? this.id,
    genre: genre ?? this.genre,
    fishedAt: fishedAt ?? this.fishedAt,
    pointId: pointId.present ? pointId.value : this.pointId,
    lat: lat.present ? lat.value : this.lat,
    lng: lng.present ? lng.value : this.lng,
    memo: memo.present ? memo.value : this.memo,
    genreDetail: genreDetail ?? this.genreDetail,
    env: env ?? this.env,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  CatchLog copyWithCompanion(CatchLogsCompanion data) {
    return CatchLog(
      id: data.id.present ? data.id.value : this.id,
      genre: data.genre.present ? data.genre.value : this.genre,
      fishedAt: data.fishedAt.present ? data.fishedAt.value : this.fishedAt,
      pointId: data.pointId.present ? data.pointId.value : this.pointId,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      memo: data.memo.present ? data.memo.value : this.memo,
      genreDetail: data.genreDetail.present
          ? data.genreDetail.value
          : this.genreDetail,
      env: data.env.present ? data.env.value : this.env,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatchLog(')
          ..write('id: $id, ')
          ..write('genre: $genre, ')
          ..write('fishedAt: $fishedAt, ')
          ..write('pointId: $pointId, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('memo: $memo, ')
          ..write('genreDetail: $genreDetail, ')
          ..write('env: $env, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    genre,
    fishedAt,
    pointId,
    lat,
    lng,
    memo,
    genreDetail,
    env,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatchLog &&
          other.id == this.id &&
          other.genre == this.genre &&
          other.fishedAt == this.fishedAt &&
          other.pointId == this.pointId &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.memo == this.memo &&
          other.genreDetail == this.genreDetail &&
          other.env == this.env &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class CatchLogsCompanion extends UpdateCompanion<CatchLog> {
  final Value<String> id;
  final Value<Genre> genre;
  final Value<DateTime> fishedAt;
  final Value<String?> pointId;
  final Value<double?> lat;
  final Value<double?> lng;
  final Value<String?> memo;
  final Value<String> genreDetail;
  final Value<String> env;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const CatchLogsCompanion({
    this.id = const Value.absent(),
    this.genre = const Value.absent(),
    this.fishedAt = const Value.absent(),
    this.pointId = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.memo = const Value.absent(),
    this.genreDetail = const Value.absent(),
    this.env = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatchLogsCompanion.insert({
    required String id,
    required Genre genre,
    required DateTime fishedAt,
    this.pointId = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.memo = const Value.absent(),
    this.genreDetail = const Value.absent(),
    this.env = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       genre = Value(genre),
       fishedAt = Value(fishedAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CatchLog> custom({
    Expression<String>? id,
    Expression<String>? genre,
    Expression<DateTime>? fishedAt,
    Expression<String>? pointId,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<String>? memo,
    Expression<String>? genreDetail,
    Expression<String>? env,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (genre != null) 'genre': genre,
      if (fishedAt != null) 'fished_at': fishedAt,
      if (pointId != null) 'point_id': pointId,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (memo != null) 'memo': memo,
      if (genreDetail != null) 'genre_detail': genreDetail,
      if (env != null) 'env': env,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatchLogsCompanion copyWith({
    Value<String>? id,
    Value<Genre>? genre,
    Value<DateTime>? fishedAt,
    Value<String?>? pointId,
    Value<double?>? lat,
    Value<double?>? lng,
    Value<String?>? memo,
    Value<String>? genreDetail,
    Value<String>? env,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return CatchLogsCompanion(
      id: id ?? this.id,
      genre: genre ?? this.genre,
      fishedAt: fishedAt ?? this.fishedAt,
      pointId: pointId ?? this.pointId,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      memo: memo ?? this.memo,
      genreDetail: genreDetail ?? this.genreDetail,
      env: env ?? this.env,
      createdAt: createdAt ?? this.createdAt,
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
    if (genre.present) {
      map['genre'] = Variable<String>(
        $CatchLogsTable.$convertergenre.toSql(genre.value),
      );
    }
    if (fishedAt.present) {
      map['fished_at'] = Variable<DateTime>(fishedAt.value);
    }
    if (pointId.present) {
      map['point_id'] = Variable<String>(pointId.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (genreDetail.present) {
      map['genre_detail'] = Variable<String>(genreDetail.value);
    }
    if (env.present) {
      map['env'] = Variable<String>(env.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('CatchLogsCompanion(')
          ..write('id: $id, ')
          ..write('genre: $genre, ')
          ..write('fishedAt: $fishedAt, ')
          ..write('pointId: $pointId, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('memo: $memo, ')
          ..write('genreDetail: $genreDetail, ')
          ..write('env: $env, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatchItemsTable extends CatchItems
    with TableInfo<$CatchItemsTable, CatchItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatchItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _logIdMeta = const VerificationMeta('logId');
  @override
  late final GeneratedColumn<String> logId = GeneratedColumn<String>(
    'log_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES catch_logs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _speciesCodeMeta = const VerificationMeta(
    'speciesCode',
  );
  @override
  late final GeneratedColumn<String> speciesCode = GeneratedColumn<String>(
    'species_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lengthCmMeta = const VerificationMeta(
    'lengthCm',
  );
  @override
  late final GeneratedColumn<double> lengthCm = GeneratedColumn<double>(
    'length_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    logId,
    speciesCode,
    lengthCm,
    count,
    memo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catch_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatchItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('log_id')) {
      context.handle(
        _logIdMeta,
        logId.isAcceptableOrUnknown(data['log_id']!, _logIdMeta),
      );
    } else if (isInserting) {
      context.missing(_logIdMeta);
    }
    if (data.containsKey('species_code')) {
      context.handle(
        _speciesCodeMeta,
        speciesCode.isAcceptableOrUnknown(
          data['species_code']!,
          _speciesCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_speciesCodeMeta);
    }
    if (data.containsKey('length_cm')) {
      context.handle(
        _lengthCmMeta,
        lengthCm.isAcceptableOrUnknown(data['length_cm']!, _lengthCmMeta),
      );
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatchItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatchItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      logId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}log_id'],
      )!,
      speciesCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}species_code'],
      )!,
      lengthCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}length_cm'],
      ),
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
    );
  }

  @override
  $CatchItemsTable createAlias(String alias) {
    return $CatchItemsTable(attachedDatabase, alias);
  }
}

class CatchItem extends DataClass implements Insertable<CatchItem> {
  final String id;
  final String logId;
  final String speciesCode;
  final double? lengthCm;
  final int count;
  final String? memo;
  const CatchItem({
    required this.id,
    required this.logId,
    required this.speciesCode,
    this.lengthCm,
    required this.count,
    this.memo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['log_id'] = Variable<String>(logId);
    map['species_code'] = Variable<String>(speciesCode);
    if (!nullToAbsent || lengthCm != null) {
      map['length_cm'] = Variable<double>(lengthCm);
    }
    map['count'] = Variable<int>(count);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    return map;
  }

  CatchItemsCompanion toCompanion(bool nullToAbsent) {
    return CatchItemsCompanion(
      id: Value(id),
      logId: Value(logId),
      speciesCode: Value(speciesCode),
      lengthCm: lengthCm == null && nullToAbsent
          ? const Value.absent()
          : Value(lengthCm),
      count: Value(count),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
    );
  }

  factory CatchItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatchItem(
      id: serializer.fromJson<String>(json['id']),
      logId: serializer.fromJson<String>(json['logId']),
      speciesCode: serializer.fromJson<String>(json['speciesCode']),
      lengthCm: serializer.fromJson<double?>(json['lengthCm']),
      count: serializer.fromJson<int>(json['count']),
      memo: serializer.fromJson<String?>(json['memo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'logId': serializer.toJson<String>(logId),
      'speciesCode': serializer.toJson<String>(speciesCode),
      'lengthCm': serializer.toJson<double?>(lengthCm),
      'count': serializer.toJson<int>(count),
      'memo': serializer.toJson<String?>(memo),
    };
  }

  CatchItem copyWith({
    String? id,
    String? logId,
    String? speciesCode,
    Value<double?> lengthCm = const Value.absent(),
    int? count,
    Value<String?> memo = const Value.absent(),
  }) => CatchItem(
    id: id ?? this.id,
    logId: logId ?? this.logId,
    speciesCode: speciesCode ?? this.speciesCode,
    lengthCm: lengthCm.present ? lengthCm.value : this.lengthCm,
    count: count ?? this.count,
    memo: memo.present ? memo.value : this.memo,
  );
  CatchItem copyWithCompanion(CatchItemsCompanion data) {
    return CatchItem(
      id: data.id.present ? data.id.value : this.id,
      logId: data.logId.present ? data.logId.value : this.logId,
      speciesCode: data.speciesCode.present
          ? data.speciesCode.value
          : this.speciesCode,
      lengthCm: data.lengthCm.present ? data.lengthCm.value : this.lengthCm,
      count: data.count.present ? data.count.value : this.count,
      memo: data.memo.present ? data.memo.value : this.memo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatchItem(')
          ..write('id: $id, ')
          ..write('logId: $logId, ')
          ..write('speciesCode: $speciesCode, ')
          ..write('lengthCm: $lengthCm, ')
          ..write('count: $count, ')
          ..write('memo: $memo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, logId, speciesCode, lengthCm, count, memo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatchItem &&
          other.id == this.id &&
          other.logId == this.logId &&
          other.speciesCode == this.speciesCode &&
          other.lengthCm == this.lengthCm &&
          other.count == this.count &&
          other.memo == this.memo);
}

class CatchItemsCompanion extends UpdateCompanion<CatchItem> {
  final Value<String> id;
  final Value<String> logId;
  final Value<String> speciesCode;
  final Value<double?> lengthCm;
  final Value<int> count;
  final Value<String?> memo;
  final Value<int> rowid;
  const CatchItemsCompanion({
    this.id = const Value.absent(),
    this.logId = const Value.absent(),
    this.speciesCode = const Value.absent(),
    this.lengthCm = const Value.absent(),
    this.count = const Value.absent(),
    this.memo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatchItemsCompanion.insert({
    required String id,
    required String logId,
    required String speciesCode,
    this.lengthCm = const Value.absent(),
    this.count = const Value.absent(),
    this.memo = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       logId = Value(logId),
       speciesCode = Value(speciesCode);
  static Insertable<CatchItem> custom({
    Expression<String>? id,
    Expression<String>? logId,
    Expression<String>? speciesCode,
    Expression<double>? lengthCm,
    Expression<int>? count,
    Expression<String>? memo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (logId != null) 'log_id': logId,
      if (speciesCode != null) 'species_code': speciesCode,
      if (lengthCm != null) 'length_cm': lengthCm,
      if (count != null) 'count': count,
      if (memo != null) 'memo': memo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatchItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? logId,
    Value<String>? speciesCode,
    Value<double?>? lengthCm,
    Value<int>? count,
    Value<String?>? memo,
    Value<int>? rowid,
  }) {
    return CatchItemsCompanion(
      id: id ?? this.id,
      logId: logId ?? this.logId,
      speciesCode: speciesCode ?? this.speciesCode,
      lengthCm: lengthCm ?? this.lengthCm,
      count: count ?? this.count,
      memo: memo ?? this.memo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (logId.present) {
      map['log_id'] = Variable<String>(logId.value);
    }
    if (speciesCode.present) {
      map['species_code'] = Variable<String>(speciesCode.value);
    }
    if (lengthCm.present) {
      map['length_cm'] = Variable<double>(lengthCm.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatchItemsCompanion(')
          ..write('id: $id, ')
          ..write('logId: $logId, ')
          ..write('speciesCode: $speciesCode, ')
          ..write('lengthCm: $lengthCm, ')
          ..write('count: $count, ')
          ..write('memo: $memo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhotosTable extends Photos with TableInfo<$PhotosTable, Photo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<OwnerType, String> ownerType =
      GeneratedColumn<String>(
        'owner_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<OwnerType>($PhotosTable.$converterownerType);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
    ownerType,
    ownerId,
    filePath,
    width,
    height,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Photo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
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
  Photo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Photo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerType: $PhotosTable.$converterownerType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}owner_type'],
        )!,
      ),
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PhotosTable createAlias(String alias) {
    return $PhotosTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<OwnerType, String, String> $converterownerType =
      const EnumNameConverter<OwnerType>(OwnerType.values);
}

class Photo extends DataClass implements Insertable<Photo> {
  final String id;
  final OwnerType ownerType;
  final String ownerId;

  /// 앱 저장소 내 파일 경로(상대 경로 권장).
  final String filePath;
  final int? width;
  final int? height;
  final DateTime createdAt;
  const Photo({
    required this.id,
    required this.ownerType,
    required this.ownerId,
    required this.filePath,
    this.width,
    this.height,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['owner_type'] = Variable<String>(
        $PhotosTable.$converterownerType.toSql(ownerType),
      );
    }
    map['owner_id'] = Variable<String>(ownerId);
    map['file_path'] = Variable<String>(filePath);
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PhotosCompanion toCompanion(bool nullToAbsent) {
    return PhotosCompanion(
      id: Value(id),
      ownerType: Value(ownerType),
      ownerId: Value(ownerId),
      filePath: Value(filePath),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      createdAt: Value(createdAt),
    );
  }

  factory Photo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Photo(
      id: serializer.fromJson<String>(json['id']),
      ownerType: $PhotosTable.$converterownerType.fromJson(
        serializer.fromJson<String>(json['ownerType']),
      ),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerType': serializer.toJson<String>(
        $PhotosTable.$converterownerType.toJson(ownerType),
      ),
      'ownerId': serializer.toJson<String>(ownerId),
      'filePath': serializer.toJson<String>(filePath),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Photo copyWith({
    String? id,
    OwnerType? ownerType,
    String? ownerId,
    String? filePath,
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    DateTime? createdAt,
  }) => Photo(
    id: id ?? this.id,
    ownerType: ownerType ?? this.ownerType,
    ownerId: ownerId ?? this.ownerId,
    filePath: filePath ?? this.filePath,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    createdAt: createdAt ?? this.createdAt,
  );
  Photo copyWithCompanion(PhotosCompanion data) {
    return Photo(
      id: data.id.present ? data.id.value : this.id,
      ownerType: data.ownerType.present ? data.ownerType.value : this.ownerType,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Photo(')
          ..write('id: $id, ')
          ..write('ownerType: $ownerType, ')
          ..write('ownerId: $ownerId, ')
          ..write('filePath: $filePath, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, ownerType, ownerId, filePath, width, height, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Photo &&
          other.id == this.id &&
          other.ownerType == this.ownerType &&
          other.ownerId == this.ownerId &&
          other.filePath == this.filePath &&
          other.width == this.width &&
          other.height == this.height &&
          other.createdAt == this.createdAt);
}

class PhotosCompanion extends UpdateCompanion<Photo> {
  final Value<String> id;
  final Value<OwnerType> ownerType;
  final Value<String> ownerId;
  final Value<String> filePath;
  final Value<int?> width;
  final Value<int?> height;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PhotosCompanion({
    this.id = const Value.absent(),
    this.ownerType = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhotosCompanion.insert({
    required String id,
    required OwnerType ownerType,
    required String ownerId,
    required String filePath,
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerType = Value(ownerType),
       ownerId = Value(ownerId),
       filePath = Value(filePath),
       createdAt = Value(createdAt);
  static Insertable<Photo> custom({
    Expression<String>? id,
    Expression<String>? ownerType,
    Expression<String>? ownerId,
    Expression<String>? filePath,
    Expression<int>? width,
    Expression<int>? height,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerType != null) 'owner_type': ownerType,
      if (ownerId != null) 'owner_id': ownerId,
      if (filePath != null) 'file_path': filePath,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhotosCompanion copyWith({
    Value<String>? id,
    Value<OwnerType>? ownerType,
    Value<String>? ownerId,
    Value<String>? filePath,
    Value<int?>? width,
    Value<int?>? height,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PhotosCompanion(
      id: id ?? this.id,
      ownerType: ownerType ?? this.ownerType,
      ownerId: ownerId ?? this.ownerId,
      filePath: filePath ?? this.filePath,
      width: width ?? this.width,
      height: height ?? this.height,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerType.present) {
      map['owner_type'] = Variable<String>(
        $PhotosTable.$converterownerType.toSql(ownerType.value),
      );
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotosCompanion(')
          ..write('id: $id, ')
          ..write('ownerType: $ownerType, ')
          ..write('ownerId: $ownerId, ')
          ..write('filePath: $filePath, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TracksTable extends Tracks with TableInfo<$TracksTable, Track> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TracksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pointIdMeta = const VerificationMeta(
    'pointId',
  );
  @override
  late final GeneratedColumn<String> pointId = GeneratedColumn<String>(
    'point_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES points (id)',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceMMeta = const VerificationMeta(
    'distanceM',
  );
  @override
  late final GeneratedColumn<double> distanceM = GeneratedColumn<double>(
    'distance_m',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _encodedPolylineMeta = const VerificationMeta(
    'encodedPolyline',
  );
  @override
  late final GeneratedColumn<String> encodedPolyline = GeneratedColumn<String>(
    'encoded_polyline',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TrackStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TrackStatus>($TracksTable.$converterstatus);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pointId,
    startedAt,
    endedAt,
    distanceM,
    encodedPolyline,
    status,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Track> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('point_id')) {
      context.handle(
        _pointIdMeta,
        pointId.isAcceptableOrUnknown(data['point_id']!, _pointIdMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('distance_m')) {
      context.handle(
        _distanceMMeta,
        distanceM.isAcceptableOrUnknown(data['distance_m']!, _distanceMMeta),
      );
    }
    if (data.containsKey('encoded_polyline')) {
      context.handle(
        _encodedPolylineMeta,
        encodedPolyline.isAcceptableOrUnknown(
          data['encoded_polyline']!,
          _encodedPolylineMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Track map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Track(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      pointId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}point_id'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      distanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_m'],
      )!,
      encodedPolyline: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encoded_polyline'],
      ),
      status: $TracksTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TracksTable createAlias(String alias) {
    return $TracksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TrackStatus, String, String> $converterstatus =
      const EnumNameConverter<TrackStatus>(TrackStatus.values);
}

class Track extends DataClass implements Insertable<Track> {
  final String id;
  final String? pointId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final double distanceM;

  /// 저장 후 단순화된 폴리라인 1개만 남긴다.
  final String? encodedPolyline;
  final TrackStatus status;
  final DateTime updatedAt;
  const Track({
    required this.id,
    this.pointId,
    required this.startedAt,
    this.endedAt,
    required this.distanceM,
    this.encodedPolyline,
    required this.status,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || pointId != null) {
      map['point_id'] = Variable<String>(pointId);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['distance_m'] = Variable<double>(distanceM);
    if (!nullToAbsent || encodedPolyline != null) {
      map['encoded_polyline'] = Variable<String>(encodedPolyline);
    }
    {
      map['status'] = Variable<String>(
        $TracksTable.$converterstatus.toSql(status),
      );
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TracksCompanion toCompanion(bool nullToAbsent) {
    return TracksCompanion(
      id: Value(id),
      pointId: pointId == null && nullToAbsent
          ? const Value.absent()
          : Value(pointId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      distanceM: Value(distanceM),
      encodedPolyline: encodedPolyline == null && nullToAbsent
          ? const Value.absent()
          : Value(encodedPolyline),
      status: Value(status),
      updatedAt: Value(updatedAt),
    );
  }

  factory Track.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Track(
      id: serializer.fromJson<String>(json['id']),
      pointId: serializer.fromJson<String?>(json['pointId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      distanceM: serializer.fromJson<double>(json['distanceM']),
      encodedPolyline: serializer.fromJson<String?>(json['encodedPolyline']),
      status: $TracksTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pointId': serializer.toJson<String?>(pointId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'distanceM': serializer.toJson<double>(distanceM),
      'encodedPolyline': serializer.toJson<String?>(encodedPolyline),
      'status': serializer.toJson<String>(
        $TracksTable.$converterstatus.toJson(status),
      ),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Track copyWith({
    String? id,
    Value<String?> pointId = const Value.absent(),
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    double? distanceM,
    Value<String?> encodedPolyline = const Value.absent(),
    TrackStatus? status,
    DateTime? updatedAt,
  }) => Track(
    id: id ?? this.id,
    pointId: pointId.present ? pointId.value : this.pointId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    distanceM: distanceM ?? this.distanceM,
    encodedPolyline: encodedPolyline.present
        ? encodedPolyline.value
        : this.encodedPolyline,
    status: status ?? this.status,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Track copyWithCompanion(TracksCompanion data) {
    return Track(
      id: data.id.present ? data.id.value : this.id,
      pointId: data.pointId.present ? data.pointId.value : this.pointId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      distanceM: data.distanceM.present ? data.distanceM.value : this.distanceM,
      encodedPolyline: data.encodedPolyline.present
          ? data.encodedPolyline.value
          : this.encodedPolyline,
      status: data.status.present ? data.status.value : this.status,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Track(')
          ..write('id: $id, ')
          ..write('pointId: $pointId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('distanceM: $distanceM, ')
          ..write('encodedPolyline: $encodedPolyline, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pointId,
    startedAt,
    endedAt,
    distanceM,
    encodedPolyline,
    status,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Track &&
          other.id == this.id &&
          other.pointId == this.pointId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.distanceM == this.distanceM &&
          other.encodedPolyline == this.encodedPolyline &&
          other.status == this.status &&
          other.updatedAt == this.updatedAt);
}

class TracksCompanion extends UpdateCompanion<Track> {
  final Value<String> id;
  final Value<String?> pointId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<double> distanceM;
  final Value<String?> encodedPolyline;
  final Value<TrackStatus> status;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TracksCompanion({
    this.id = const Value.absent(),
    this.pointId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.encodedPolyline = const Value.absent(),
    this.status = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TracksCompanion.insert({
    required String id,
    this.pointId = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.encodedPolyline = const Value.absent(),
    required TrackStatus status,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startedAt = Value(startedAt),
       status = Value(status),
       updatedAt = Value(updatedAt);
  static Insertable<Track> custom({
    Expression<String>? id,
    Expression<String>? pointId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<double>? distanceM,
    Expression<String>? encodedPolyline,
    Expression<String>? status,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pointId != null) 'point_id': pointId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (distanceM != null) 'distance_m': distanceM,
      if (encodedPolyline != null) 'encoded_polyline': encodedPolyline,
      if (status != null) 'status': status,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TracksCompanion copyWith({
    Value<String>? id,
    Value<String?>? pointId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<double>? distanceM,
    Value<String?>? encodedPolyline,
    Value<TrackStatus>? status,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TracksCompanion(
      id: id ?? this.id,
      pointId: pointId ?? this.pointId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      distanceM: distanceM ?? this.distanceM,
      encodedPolyline: encodedPolyline ?? this.encodedPolyline,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pointId.present) {
      map['point_id'] = Variable<String>(pointId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (distanceM.present) {
      map['distance_m'] = Variable<double>(distanceM.value);
    }
    if (encodedPolyline.present) {
      map['encoded_polyline'] = Variable<String>(encodedPolyline.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $TracksTable.$converterstatus.toSql(status.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TracksCompanion(')
          ..write('id: $id, ')
          ..write('pointId: $pointId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('distanceM: $distanceM, ')
          ..write('encodedPolyline: $encodedPolyline, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackPointsTable extends TrackPoints
    with TableInfo<$TrackPointsTable, TrackPoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackPointsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tracks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accuracyMMeta = const VerificationMeta(
    'accuracyM',
  );
  @override
  late final GeneratedColumn<double> accuracyM = GeneratedColumn<double>(
    'accuracy_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speedMpsMeta = const VerificationMeta(
    'speedMps',
  );
  @override
  late final GeneratedColumn<double> speedMps = GeneratedColumn<double>(
    'speed_mps',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    trackId,
    lat,
    lng,
    accuracyM,
    speedMps,
    recordedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackPoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('accuracy_m')) {
      context.handle(
        _accuracyMMeta,
        accuracyM.isAcceptableOrUnknown(data['accuracy_m']!, _accuracyMMeta),
      );
    }
    if (data.containsKey('speed_mps')) {
      context.handle(
        _speedMpsMeta,
        speedMps.isAcceptableOrUnknown(data['speed_mps']!, _speedMpsMeta),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackPoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackPoint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      )!,
      accuracyM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy_m'],
      ),
      speedMps: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed_mps'],
      ),
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
    );
  }

  @override
  $TrackPointsTable createAlias(String alias) {
    return $TrackPointsTable(attachedDatabase, alias);
  }
}

class TrackPoint extends DataClass implements Insertable<TrackPoint> {
  final int id;
  final String trackId;
  final double lat;
  final double lng;
  final double? accuracyM;
  final double? speedMps;
  final DateTime recordedAt;
  const TrackPoint({
    required this.id,
    required this.trackId,
    required this.lat,
    required this.lng,
    this.accuracyM,
    this.speedMps,
    required this.recordedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['track_id'] = Variable<String>(trackId);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    if (!nullToAbsent || accuracyM != null) {
      map['accuracy_m'] = Variable<double>(accuracyM);
    }
    if (!nullToAbsent || speedMps != null) {
      map['speed_mps'] = Variable<double>(speedMps);
    }
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    return map;
  }

  TrackPointsCompanion toCompanion(bool nullToAbsent) {
    return TrackPointsCompanion(
      id: Value(id),
      trackId: Value(trackId),
      lat: Value(lat),
      lng: Value(lng),
      accuracyM: accuracyM == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracyM),
      speedMps: speedMps == null && nullToAbsent
          ? const Value.absent()
          : Value(speedMps),
      recordedAt: Value(recordedAt),
    );
  }

  factory TrackPoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackPoint(
      id: serializer.fromJson<int>(json['id']),
      trackId: serializer.fromJson<String>(json['trackId']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      accuracyM: serializer.fromJson<double?>(json['accuracyM']),
      speedMps: serializer.fromJson<double?>(json['speedMps']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'trackId': serializer.toJson<String>(trackId),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'accuracyM': serializer.toJson<double?>(accuracyM),
      'speedMps': serializer.toJson<double?>(speedMps),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
    };
  }

  TrackPoint copyWith({
    int? id,
    String? trackId,
    double? lat,
    double? lng,
    Value<double?> accuracyM = const Value.absent(),
    Value<double?> speedMps = const Value.absent(),
    DateTime? recordedAt,
  }) => TrackPoint(
    id: id ?? this.id,
    trackId: trackId ?? this.trackId,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    accuracyM: accuracyM.present ? accuracyM.value : this.accuracyM,
    speedMps: speedMps.present ? speedMps.value : this.speedMps,
    recordedAt: recordedAt ?? this.recordedAt,
  );
  TrackPoint copyWithCompanion(TrackPointsCompanion data) {
    return TrackPoint(
      id: data.id.present ? data.id.value : this.id,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      accuracyM: data.accuracyM.present ? data.accuracyM.value : this.accuracyM,
      speedMps: data.speedMps.present ? data.speedMps.value : this.speedMps,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackPoint(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('speedMps: $speedMps, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, trackId, lat, lng, accuracyM, speedMps, recordedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackPoint &&
          other.id == this.id &&
          other.trackId == this.trackId &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.accuracyM == this.accuracyM &&
          other.speedMps == this.speedMps &&
          other.recordedAt == this.recordedAt);
}

class TrackPointsCompanion extends UpdateCompanion<TrackPoint> {
  final Value<int> id;
  final Value<String> trackId;
  final Value<double> lat;
  final Value<double> lng;
  final Value<double?> accuracyM;
  final Value<double?> speedMps;
  final Value<DateTime> recordedAt;
  const TrackPointsCompanion({
    this.id = const Value.absent(),
    this.trackId = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.accuracyM = const Value.absent(),
    this.speedMps = const Value.absent(),
    this.recordedAt = const Value.absent(),
  });
  TrackPointsCompanion.insert({
    this.id = const Value.absent(),
    required String trackId,
    required double lat,
    required double lng,
    this.accuracyM = const Value.absent(),
    this.speedMps = const Value.absent(),
    required DateTime recordedAt,
  }) : trackId = Value(trackId),
       lat = Value(lat),
       lng = Value(lng),
       recordedAt = Value(recordedAt);
  static Insertable<TrackPoint> custom({
    Expression<int>? id,
    Expression<String>? trackId,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<double>? accuracyM,
    Expression<double>? speedMps,
    Expression<DateTime>? recordedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trackId != null) 'track_id': trackId,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (accuracyM != null) 'accuracy_m': accuracyM,
      if (speedMps != null) 'speed_mps': speedMps,
      if (recordedAt != null) 'recorded_at': recordedAt,
    });
  }

  TrackPointsCompanion copyWith({
    Value<int>? id,
    Value<String>? trackId,
    Value<double>? lat,
    Value<double>? lng,
    Value<double?>? accuracyM,
    Value<double?>? speedMps,
    Value<DateTime>? recordedAt,
  }) {
    return TrackPointsCompanion(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      accuracyM: accuracyM ?? this.accuracyM,
      speedMps: speedMps ?? this.speedMps,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (accuracyM.present) {
      map['accuracy_m'] = Variable<double>(accuracyM.value);
    }
    if (speedMps.present) {
      map['speed_mps'] = Variable<double>(speedMps.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackPointsCompanion(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('speedMps: $speedMps, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }
}

class $PointCandidatesTable extends PointCandidates
    with TableInfo<$PointCandidatesTable, PointCandidate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PointCandidatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tracks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dwellSecMeta = const VerificationMeta(
    'dwellSec',
  );
  @override
  late final GeneratedColumn<int> dwellSec = GeneratedColumn<int>(
    'dwell_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CandidateStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CandidateStatus>($PointCandidatesTable.$converterstatus);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    trackId,
    lat,
    lng,
    dwellSec,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'point_candidates';
  @override
  VerificationContext validateIntegrity(
    Insertable<PointCandidate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('dwell_sec')) {
      context.handle(
        _dwellSecMeta,
        dwellSec.isAcceptableOrUnknown(data['dwell_sec']!, _dwellSecMeta),
      );
    } else if (isInserting) {
      context.missing(_dwellSecMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PointCandidate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PointCandidate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      )!,
      dwellSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dwell_sec'],
      )!,
      status: $PointCandidatesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
    );
  }

  @override
  $PointCandidatesTable createAlias(String alias) {
    return $PointCandidatesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CandidateStatus, String, String> $converterstatus =
      const EnumNameConverter<CandidateStatus>(CandidateStatus.values);
}

class PointCandidate extends DataClass implements Insertable<PointCandidate> {
  final String id;
  final String trackId;
  final double lat;
  final double lng;
  final int dwellSec;
  final CandidateStatus status;
  const PointCandidate({
    required this.id,
    required this.trackId,
    required this.lat,
    required this.lng,
    required this.dwellSec,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['track_id'] = Variable<String>(trackId);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    map['dwell_sec'] = Variable<int>(dwellSec);
    {
      map['status'] = Variable<String>(
        $PointCandidatesTable.$converterstatus.toSql(status),
      );
    }
    return map;
  }

  PointCandidatesCompanion toCompanion(bool nullToAbsent) {
    return PointCandidatesCompanion(
      id: Value(id),
      trackId: Value(trackId),
      lat: Value(lat),
      lng: Value(lng),
      dwellSec: Value(dwellSec),
      status: Value(status),
    );
  }

  factory PointCandidate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PointCandidate(
      id: serializer.fromJson<String>(json['id']),
      trackId: serializer.fromJson<String>(json['trackId']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      dwellSec: serializer.fromJson<int>(json['dwellSec']),
      status: $PointCandidatesTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'trackId': serializer.toJson<String>(trackId),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'dwellSec': serializer.toJson<int>(dwellSec),
      'status': serializer.toJson<String>(
        $PointCandidatesTable.$converterstatus.toJson(status),
      ),
    };
  }

  PointCandidate copyWith({
    String? id,
    String? trackId,
    double? lat,
    double? lng,
    int? dwellSec,
    CandidateStatus? status,
  }) => PointCandidate(
    id: id ?? this.id,
    trackId: trackId ?? this.trackId,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    dwellSec: dwellSec ?? this.dwellSec,
    status: status ?? this.status,
  );
  PointCandidate copyWithCompanion(PointCandidatesCompanion data) {
    return PointCandidate(
      id: data.id.present ? data.id.value : this.id,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      dwellSec: data.dwellSec.present ? data.dwellSec.value : this.dwellSec,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PointCandidate(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('dwellSec: $dwellSec, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, trackId, lat, lng, dwellSec, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PointCandidate &&
          other.id == this.id &&
          other.trackId == this.trackId &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.dwellSec == this.dwellSec &&
          other.status == this.status);
}

class PointCandidatesCompanion extends UpdateCompanion<PointCandidate> {
  final Value<String> id;
  final Value<String> trackId;
  final Value<double> lat;
  final Value<double> lng;
  final Value<int> dwellSec;
  final Value<CandidateStatus> status;
  final Value<int> rowid;
  const PointCandidatesCompanion({
    this.id = const Value.absent(),
    this.trackId = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.dwellSec = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PointCandidatesCompanion.insert({
    required String id,
    required String trackId,
    required double lat,
    required double lng,
    required int dwellSec,
    required CandidateStatus status,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       trackId = Value(trackId),
       lat = Value(lat),
       lng = Value(lng),
       dwellSec = Value(dwellSec),
       status = Value(status);
  static Insertable<PointCandidate> custom({
    Expression<String>? id,
    Expression<String>? trackId,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<int>? dwellSec,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trackId != null) 'track_id': trackId,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (dwellSec != null) 'dwell_sec': dwellSec,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PointCandidatesCompanion copyWith({
    Value<String>? id,
    Value<String>? trackId,
    Value<double>? lat,
    Value<double>? lng,
    Value<int>? dwellSec,
    Value<CandidateStatus>? status,
    Value<int>? rowid,
  }) {
    return PointCandidatesCompanion(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      dwellSec: dwellSec ?? this.dwellSec,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (dwellSec.present) {
      map['dwell_sec'] = Variable<int>(dwellSec.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $PointCandidatesTable.$converterstatus.toSql(status.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PointCandidatesCompanion(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('dwellSec: $dwellSec, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ForecastCacheTable extends ForecastCache
    with TableInfo<$ForecastCacheTable, ForecastCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ForecastCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, payload, fetchedAt, expiresAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'forecast_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<ForecastCacheEntry> instance, {
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
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  ForecastCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ForecastCacheEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
    );
  }

  @override
  $ForecastCacheTable createAlias(String alias) {
    return $ForecastCacheTable(attachedDatabase, alias);
  }
}

class ForecastCacheEntry extends DataClass
    implements Insertable<ForecastCacheEntry> {
  /// 해역코드+날짜+종류.
  final String key;
  final String payload;
  final DateTime fetchedAt;
  final DateTime expiresAt;
  const ForecastCacheEntry({
    required this.key,
    required this.payload,
    required this.fetchedAt,
    required this.expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['payload'] = Variable<String>(payload);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    return map;
  }

  ForecastCacheCompanion toCompanion(bool nullToAbsent) {
    return ForecastCacheCompanion(
      key: Value(key),
      payload: Value(payload),
      fetchedAt: Value(fetchedAt),
      expiresAt: Value(expiresAt),
    );
  }

  factory ForecastCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ForecastCacheEntry(
      key: serializer.fromJson<String>(json['key']),
      payload: serializer.fromJson<String>(json['payload']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'payload': serializer.toJson<String>(payload),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
    };
  }

  ForecastCacheEntry copyWith({
    String? key,
    String? payload,
    DateTime? fetchedAt,
    DateTime? expiresAt,
  }) => ForecastCacheEntry(
    key: key ?? this.key,
    payload: payload ?? this.payload,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    expiresAt: expiresAt ?? this.expiresAt,
  );
  ForecastCacheEntry copyWithCompanion(ForecastCacheCompanion data) {
    return ForecastCacheEntry(
      key: data.key.present ? data.key.value : this.key,
      payload: data.payload.present ? data.payload.value : this.payload,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ForecastCacheEntry(')
          ..write('key: $key, ')
          ..write('payload: $payload, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, payload, fetchedAt, expiresAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ForecastCacheEntry &&
          other.key == this.key &&
          other.payload == this.payload &&
          other.fetchedAt == this.fetchedAt &&
          other.expiresAt == this.expiresAt);
}

class ForecastCacheCompanion extends UpdateCompanion<ForecastCacheEntry> {
  final Value<String> key;
  final Value<String> payload;
  final Value<DateTime> fetchedAt;
  final Value<DateTime> expiresAt;
  final Value<int> rowid;
  const ForecastCacheCompanion({
    this.key = const Value.absent(),
    this.payload = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ForecastCacheCompanion.insert({
    required String key,
    required String payload,
    required DateTime fetchedAt,
    required DateTime expiresAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       payload = Value(payload),
       fetchedAt = Value(fetchedAt),
       expiresAt = Value(expiresAt);
  static Insertable<ForecastCacheEntry> custom({
    Expression<String>? key,
    Expression<String>? payload,
    Expression<DateTime>? fetchedAt,
    Expression<DateTime>? expiresAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (payload != null) 'payload': payload,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ForecastCacheCompanion copyWith({
    Value<String>? key,
    Value<String>? payload,
    Value<DateTime>? fetchedAt,
    Value<DateTime>? expiresAt,
    Value<int>? rowid,
  }) {
    return ForecastCacheCompanion(
      key: key ?? this.key,
      payload: payload ?? this.payload,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ForecastCacheCompanion(')
          ..write('key: $key, ')
          ..write('payload: $payload, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShareImportsTable extends ShareImports
    with TableInfo<$ShareImportsTable, ShareImport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShareImportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pointIdMeta = const VerificationMeta(
    'pointId',
  );
  @override
  late final GeneratedColumn<String> pointId = GeneratedColumn<String>(
    'point_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES points (id)',
    ),
  );
  static const VerificationMeta _payloadHashMeta = const VerificationMeta(
    'payloadHash',
  );
  @override
  late final GeneratedColumn<String> payloadHash = GeneratedColumn<String>(
    'payload_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, pointId, payloadHash, importedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'share_imports';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShareImport> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('point_id')) {
      context.handle(
        _pointIdMeta,
        pointId.isAcceptableOrUnknown(data['point_id']!, _pointIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pointIdMeta);
    }
    if (data.containsKey('payload_hash')) {
      context.handle(
        _payloadHashMeta,
        payloadHash.isAcceptableOrUnknown(
          data['payload_hash']!,
          _payloadHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadHashMeta);
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShareImport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShareImport(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      pointId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}point_id'],
      )!,
      payloadHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_hash'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
    );
  }

  @override
  $ShareImportsTable createAlias(String alias) {
    return $ShareImportsTable(attachedDatabase, alias);
  }
}

class ShareImport extends DataClass implements Insertable<ShareImport> {
  final String id;
  final String pointId;

  /// 같은 링크를 여러 번 열어도 중복 저장하지 않기 위한 해시(UNIQUE).
  final String payloadHash;
  final DateTime importedAt;
  const ShareImport({
    required this.id,
    required this.pointId,
    required this.payloadHash,
    required this.importedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['point_id'] = Variable<String>(pointId);
    map['payload_hash'] = Variable<String>(payloadHash);
    map['imported_at'] = Variable<DateTime>(importedAt);
    return map;
  }

  ShareImportsCompanion toCompanion(bool nullToAbsent) {
    return ShareImportsCompanion(
      id: Value(id),
      pointId: Value(pointId),
      payloadHash: Value(payloadHash),
      importedAt: Value(importedAt),
    );
  }

  factory ShareImport.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShareImport(
      id: serializer.fromJson<String>(json['id']),
      pointId: serializer.fromJson<String>(json['pointId']),
      payloadHash: serializer.fromJson<String>(json['payloadHash']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pointId': serializer.toJson<String>(pointId),
      'payloadHash': serializer.toJson<String>(payloadHash),
      'importedAt': serializer.toJson<DateTime>(importedAt),
    };
  }

  ShareImport copyWith({
    String? id,
    String? pointId,
    String? payloadHash,
    DateTime? importedAt,
  }) => ShareImport(
    id: id ?? this.id,
    pointId: pointId ?? this.pointId,
    payloadHash: payloadHash ?? this.payloadHash,
    importedAt: importedAt ?? this.importedAt,
  );
  ShareImport copyWithCompanion(ShareImportsCompanion data) {
    return ShareImport(
      id: data.id.present ? data.id.value : this.id,
      pointId: data.pointId.present ? data.pointId.value : this.pointId,
      payloadHash: data.payloadHash.present
          ? data.payloadHash.value
          : this.payloadHash,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShareImport(')
          ..write('id: $id, ')
          ..write('pointId: $pointId, ')
          ..write('payloadHash: $payloadHash, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, pointId, payloadHash, importedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShareImport &&
          other.id == this.id &&
          other.pointId == this.pointId &&
          other.payloadHash == this.payloadHash &&
          other.importedAt == this.importedAt);
}

class ShareImportsCompanion extends UpdateCompanion<ShareImport> {
  final Value<String> id;
  final Value<String> pointId;
  final Value<String> payloadHash;
  final Value<DateTime> importedAt;
  final Value<int> rowid;
  const ShareImportsCompanion({
    this.id = const Value.absent(),
    this.pointId = const Value.absent(),
    this.payloadHash = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShareImportsCompanion.insert({
    required String id,
    required String pointId,
    required String payloadHash,
    required DateTime importedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       pointId = Value(pointId),
       payloadHash = Value(payloadHash),
       importedAt = Value(importedAt);
  static Insertable<ShareImport> custom({
    Expression<String>? id,
    Expression<String>? pointId,
    Expression<String>? payloadHash,
    Expression<DateTime>? importedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pointId != null) 'point_id': pointId,
      if (payloadHash != null) 'payload_hash': payloadHash,
      if (importedAt != null) 'imported_at': importedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShareImportsCompanion copyWith({
    Value<String>? id,
    Value<String>? pointId,
    Value<String>? payloadHash,
    Value<DateTime>? importedAt,
    Value<int>? rowid,
  }) {
    return ShareImportsCompanion(
      id: id ?? this.id,
      pointId: pointId ?? this.pointId,
      payloadHash: payloadHash ?? this.payloadHash,
      importedAt: importedAt ?? this.importedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pointId.present) {
      map['point_id'] = Variable<String>(pointId.value);
    }
    if (payloadHash.present) {
      map['payload_hash'] = Variable<String>(payloadHash.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShareImportsCompanion(')
          ..write('id: $id, ')
          ..write('pointId: $pointId, ')
          ..write('payloadHash: $payloadHash, ')
          ..write('importedAt: $importedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
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
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
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
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
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

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
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
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
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

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
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
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TeamsTable extends Teams with TableInfo<$TeamsTable, TeamRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeamsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _remainderRuleMeta = const VerificationMeta(
    'remainderRule',
  );
  @override
  late final GeneratedColumn<String> remainderRule = GeneratedColumn<String>(
    'remainder_rule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('payer'),
  );
  static const VerificationMeta _treasurerIdMeta = const VerificationMeta(
    'treasurerId',
  );
  @override
  late final GeneratedColumn<String> treasurerId = GeneratedColumn<String>(
    'treasurer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
    remainderRule,
    treasurerId,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'teams';
  @override
  VerificationContext validateIntegrity(
    Insertable<TeamRow> instance, {
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
    if (data.containsKey('remainder_rule')) {
      context.handle(
        _remainderRuleMeta,
        remainderRule.isAcceptableOrUnknown(
          data['remainder_rule']!,
          _remainderRuleMeta,
        ),
      );
    }
    if (data.containsKey('treasurer_id')) {
      context.handle(
        _treasurerIdMeta,
        treasurerId.isAcceptableOrUnknown(
          data['treasurer_id']!,
          _treasurerIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
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
  TeamRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeamRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      remainderRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remainder_rule'],
      )!,
      treasurerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}treasurer_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $TeamsTable createAlias(String alias) {
    return $TeamsTable(attachedDatabase, alias);
  }
}

class TeamRow extends DataClass implements Insertable<TeamRow> {
  final String id;
  final String name;

  /// 끝전 부담 규칙: `payer`(결제자) 또는 `treasurer`(총무).
  final String remainderRule;
  final String? treasurerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const TeamRow({
    required this.id,
    required this.name,
    required this.remainderRule,
    this.treasurerId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['remainder_rule'] = Variable<String>(remainderRule);
    if (!nullToAbsent || treasurerId != null) {
      map['treasurer_id'] = Variable<String>(treasurerId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TeamsCompanion toCompanion(bool nullToAbsent) {
    return TeamsCompanion(
      id: Value(id),
      name: Value(name),
      remainderRule: Value(remainderRule),
      treasurerId: treasurerId == null && nullToAbsent
          ? const Value.absent()
          : Value(treasurerId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TeamRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeamRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      remainderRule: serializer.fromJson<String>(json['remainderRule']),
      treasurerId: serializer.fromJson<String?>(json['treasurerId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'remainderRule': serializer.toJson<String>(remainderRule),
      'treasurerId': serializer.toJson<String?>(treasurerId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  TeamRow copyWith({
    String? id,
    String? name,
    String? remainderRule,
    Value<String?> treasurerId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => TeamRow(
    id: id ?? this.id,
    name: name ?? this.name,
    remainderRule: remainderRule ?? this.remainderRule,
    treasurerId: treasurerId.present ? treasurerId.value : this.treasurerId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  TeamRow copyWithCompanion(TeamsCompanion data) {
    return TeamRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      remainderRule: data.remainderRule.present
          ? data.remainderRule.value
          : this.remainderRule,
      treasurerId: data.treasurerId.present
          ? data.treasurerId.value
          : this.treasurerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeamRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('remainderRule: $remainderRule, ')
          ..write('treasurerId: $treasurerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    remainderRule,
    treasurerId,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeamRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.remainderRule == this.remainderRule &&
          other.treasurerId == this.treasurerId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TeamsCompanion extends UpdateCompanion<TeamRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> remainderRule;
  final Value<String?> treasurerId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TeamsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.remainderRule = const Value.absent(),
    this.treasurerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeamsCompanion.insert({
    required String id,
    required String name,
    this.remainderRule = const Value.absent(),
    this.treasurerId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TeamRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? remainderRule,
    Expression<String>? treasurerId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (remainderRule != null) 'remainder_rule': remainderRule,
      if (treasurerId != null) 'treasurer_id': treasurerId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeamsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? remainderRule,
    Value<String?>? treasurerId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return TeamsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      remainderRule: remainderRule ?? this.remainderRule,
      treasurerId: treasurerId ?? this.treasurerId,
      createdAt: createdAt ?? this.createdAt,
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
    if (remainderRule.present) {
      map['remainder_rule'] = Variable<String>(remainderRule.value);
    }
    if (treasurerId.present) {
      map['treasurer_id'] = Variable<String>(treasurerId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('TeamsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('remainderRule: $remainderRule, ')
          ..write('treasurerId: $treasurerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TeamMembersTable extends TeamMembers
    with TableInfo<$TeamMembersTable, TeamMemberRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeamMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
    'team_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES teams (id)',
    ),
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
    teamId,
    name,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'team_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<TeamMemberRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teamIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
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
  TeamMemberRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeamMemberRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $TeamMembersTable createAlias(String alias) {
    return $TeamMembersTable(attachedDatabase, alias);
  }
}

class TeamMemberRow extends DataClass implements Insertable<TeamMemberRow> {
  final String id;
  final String teamId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const TeamMemberRow({
    required this.id,
    required this.teamId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['team_id'] = Variable<String>(teamId);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TeamMembersCompanion toCompanion(bool nullToAbsent) {
    return TeamMembersCompanion(
      id: Value(id),
      teamId: Value(teamId),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TeamMemberRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeamMemberRow(
      id: serializer.fromJson<String>(json['id']),
      teamId: serializer.fromJson<String>(json['teamId']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'teamId': serializer.toJson<String>(teamId),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  TeamMemberRow copyWith({
    String? id,
    String? teamId,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => TeamMemberRow(
    id: id ?? this.id,
    teamId: teamId ?? this.teamId,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  TeamMemberRow copyWithCompanion(TeamMembersCompanion data) {
    return TeamMemberRow(
      id: data.id.present ? data.id.value : this.id,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeamMemberRow(')
          ..write('id: $id, ')
          ..write('teamId: $teamId, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, teamId, name, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeamMemberRow &&
          other.id == this.id &&
          other.teamId == this.teamId &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TeamMembersCompanion extends UpdateCompanion<TeamMemberRow> {
  final Value<String> id;
  final Value<String> teamId;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TeamMembersCompanion({
    this.id = const Value.absent(),
    this.teamId = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeamMembersCompanion.insert({
    required String id,
    required String teamId,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       teamId = Value(teamId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TeamMemberRow> custom({
    Expression<String>? id,
    Expression<String>? teamId,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (teamId != null) 'team_id': teamId,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeamMembersCompanion copyWith({
    Value<String>? id,
    Value<String>? teamId,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return TeamMembersCompanion(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
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
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('TeamMembersCompanion(')
          ..write('id: $id, ')
          ..write('teamId: $teamId, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TripsTable extends Trips with TableInfo<$TripsTable, TripRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
    'team_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES teams (id)',
    ),
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
  static const VerificationMeta _tripDateMeta = const VerificationMeta(
    'tripDate',
  );
  @override
  late final GeneratedColumn<DateTime> tripDate = GeneratedColumn<DateTime>(
    'trip_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _participantIdsMeta = const VerificationMeta(
    'participantIds',
  );
  @override
  late final GeneratedColumn<String> participantIds = GeneratedColumn<String>(
    'participant_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _settledAtMeta = const VerificationMeta(
    'settledAt',
  );
  @override
  late final GeneratedColumn<DateTime> settledAt = GeneratedColumn<DateTime>(
    'settled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
    teamId,
    title,
    tripDate,
    participantIds,
    settledAt,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trips';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teamIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('trip_date')) {
      context.handle(
        _tripDateMeta,
        tripDate.isAcceptableOrUnknown(data['trip_date']!, _tripDateMeta),
      );
    } else if (isInserting) {
      context.missing(_tripDateMeta);
    }
    if (data.containsKey('participant_ids')) {
      context.handle(
        _participantIdsMeta,
        participantIds.isAcceptableOrUnknown(
          data['participant_ids']!,
          _participantIdsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_participantIdsMeta);
    }
    if (data.containsKey('settled_at')) {
      context.handle(
        _settledAtMeta,
        settledAt.isAcceptableOrUnknown(data['settled_at']!, _settledAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
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
  TripRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      tripDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}trip_date'],
      )!,
      participantIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}participant_ids'],
      )!,
      settledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}settled_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $TripsTable createAlias(String alias) {
    return $TripsTable(attachedDatabase, alias);
  }
}

class TripRow extends DataClass implements Insertable<TripRow> {
  final String id;
  final String teamId;
  final String title;
  final DateTime tripDate;
  final String participantIds;

  /// 정산을 마감한 시각. 마감하면 비용을 고칠 수 없다.
  final DateTime? settledAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const TripRow({
    required this.id,
    required this.teamId,
    required this.title,
    required this.tripDate,
    required this.participantIds,
    this.settledAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['team_id'] = Variable<String>(teamId);
    map['title'] = Variable<String>(title);
    map['trip_date'] = Variable<DateTime>(tripDate);
    map['participant_ids'] = Variable<String>(participantIds);
    if (!nullToAbsent || settledAt != null) {
      map['settled_at'] = Variable<DateTime>(settledAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TripsCompanion toCompanion(bool nullToAbsent) {
    return TripsCompanion(
      id: Value(id),
      teamId: Value(teamId),
      title: Value(title),
      tripDate: Value(tripDate),
      participantIds: Value(participantIds),
      settledAt: settledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(settledAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TripRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripRow(
      id: serializer.fromJson<String>(json['id']),
      teamId: serializer.fromJson<String>(json['teamId']),
      title: serializer.fromJson<String>(json['title']),
      tripDate: serializer.fromJson<DateTime>(json['tripDate']),
      participantIds: serializer.fromJson<String>(json['participantIds']),
      settledAt: serializer.fromJson<DateTime?>(json['settledAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'teamId': serializer.toJson<String>(teamId),
      'title': serializer.toJson<String>(title),
      'tripDate': serializer.toJson<DateTime>(tripDate),
      'participantIds': serializer.toJson<String>(participantIds),
      'settledAt': serializer.toJson<DateTime?>(settledAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  TripRow copyWith({
    String? id,
    String? teamId,
    String? title,
    DateTime? tripDate,
    String? participantIds,
    Value<DateTime?> settledAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => TripRow(
    id: id ?? this.id,
    teamId: teamId ?? this.teamId,
    title: title ?? this.title,
    tripDate: tripDate ?? this.tripDate,
    participantIds: participantIds ?? this.participantIds,
    settledAt: settledAt.present ? settledAt.value : this.settledAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  TripRow copyWithCompanion(TripsCompanion data) {
    return TripRow(
      id: data.id.present ? data.id.value : this.id,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      title: data.title.present ? data.title.value : this.title,
      tripDate: data.tripDate.present ? data.tripDate.value : this.tripDate,
      participantIds: data.participantIds.present
          ? data.participantIds.value
          : this.participantIds,
      settledAt: data.settledAt.present ? data.settledAt.value : this.settledAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripRow(')
          ..write('id: $id, ')
          ..write('teamId: $teamId, ')
          ..write('title: $title, ')
          ..write('tripDate: $tripDate, ')
          ..write('participantIds: $participantIds, ')
          ..write('settledAt: $settledAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    teamId,
    title,
    tripDate,
    participantIds,
    settledAt,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripRow &&
          other.id == this.id &&
          other.teamId == this.teamId &&
          other.title == this.title &&
          other.tripDate == this.tripDate &&
          other.participantIds == this.participantIds &&
          other.settledAt == this.settledAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TripsCompanion extends UpdateCompanion<TripRow> {
  final Value<String> id;
  final Value<String> teamId;
  final Value<String> title;
  final Value<DateTime> tripDate;
  final Value<String> participantIds;
  final Value<DateTime?> settledAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TripsCompanion({
    this.id = const Value.absent(),
    this.teamId = const Value.absent(),
    this.title = const Value.absent(),
    this.tripDate = const Value.absent(),
    this.participantIds = const Value.absent(),
    this.settledAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripsCompanion.insert({
    required String id,
    required String teamId,
    required String title,
    required DateTime tripDate,
    required String participantIds,
    this.settledAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       teamId = Value(teamId),
       title = Value(title),
       tripDate = Value(tripDate),
       participantIds = Value(participantIds),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TripRow> custom({
    Expression<String>? id,
    Expression<String>? teamId,
    Expression<String>? title,
    Expression<DateTime>? tripDate,
    Expression<String>? participantIds,
    Expression<DateTime>? settledAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (teamId != null) 'team_id': teamId,
      if (title != null) 'title': title,
      if (tripDate != null) 'trip_date': tripDate,
      if (participantIds != null) 'participant_ids': participantIds,
      if (settledAt != null) 'settled_at': settledAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripsCompanion copyWith({
    Value<String>? id,
    Value<String>? teamId,
    Value<String>? title,
    Value<DateTime>? tripDate,
    Value<String>? participantIds,
    Value<DateTime?>? settledAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return TripsCompanion(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      title: title ?? this.title,
      tripDate: tripDate ?? this.tripDate,
      participantIds: participantIds ?? this.participantIds,
      settledAt: settledAt ?? this.settledAt,
      createdAt: createdAt ?? this.createdAt,
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
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (tripDate.present) {
      map['trip_date'] = Variable<DateTime>(tripDate.value);
    }
    if (participantIds.present) {
      map['participant_ids'] = Variable<String>(participantIds.value);
    }
    if (settledAt.present) {
      map['settled_at'] = Variable<DateTime>(settledAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('TripsCompanion(')
          ..write('id: $id, ')
          ..write('teamId: $teamId, ')
          ..write('title: $title, ')
          ..write('tripDate: $tripDate, ')
          ..write('participantIds: $participantIds, ')
          ..write('settledAt: $settledAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TripExpensesTable extends TripExpenses
    with TableInfo<$TripExpensesTable, TripExpenseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id)',
    ),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payerIdMeta = const VerificationMeta(
    'payerId',
  );
  @override
  late final GeneratedColumn<String> payerId = GeneratedColumn<String>(
    'payer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetIdsMeta = const VerificationMeta(
    'targetIds',
  );
  @override
  late final GeneratedColumn<String> targetIds = GeneratedColumn<String>(
    'target_ids',
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
    tripId,
    description,
    amount,
    payerId,
    targetIds,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip_expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripExpenseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('payer_id')) {
      context.handle(
        _payerIdMeta,
        payerId.isAcceptableOrUnknown(data['payer_id']!, _payerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_payerIdMeta);
    }
    if (data.containsKey('target_ids')) {
      context.handle(
        _targetIdsMeta,
        targetIds.isAcceptableOrUnknown(data['target_ids']!, _targetIdsMeta),
      );
    } else if (isInserting) {
      context.missing(_targetIdsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
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
  TripExpenseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripExpenseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      payerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payer_id'],
      )!,
      targetIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_ids'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $TripExpensesTable createAlias(String alias) {
    return $TripExpensesTable(attachedDatabase, alias);
  }
}

class TripExpenseRow extends DataClass implements Insertable<TripExpenseRow> {
  final String id;
  final String tripId;
  final String description;
  final int amount;
  final String payerId;
  final String targetIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const TripExpenseRow({
    required this.id,
    required this.tripId,
    required this.description,
    required this.amount,
    required this.payerId,
    required this.targetIds,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['description'] = Variable<String>(description);
    map['amount'] = Variable<int>(amount);
    map['payer_id'] = Variable<String>(payerId);
    map['target_ids'] = Variable<String>(targetIds);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TripExpensesCompanion toCompanion(bool nullToAbsent) {
    return TripExpensesCompanion(
      id: Value(id),
      tripId: Value(tripId),
      description: Value(description),
      amount: Value(amount),
      payerId: Value(payerId),
      targetIds: Value(targetIds),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TripExpenseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripExpenseRow(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      description: serializer.fromJson<String>(json['description']),
      amount: serializer.fromJson<int>(json['amount']),
      payerId: serializer.fromJson<String>(json['payerId']),
      targetIds: serializer.fromJson<String>(json['targetIds']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'description': serializer.toJson<String>(description),
      'amount': serializer.toJson<int>(amount),
      'payerId': serializer.toJson<String>(payerId),
      'targetIds': serializer.toJson<String>(targetIds),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  TripExpenseRow copyWith({
    String? id,
    String? tripId,
    String? description,
    int? amount,
    String? payerId,
    String? targetIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => TripExpenseRow(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    description: description ?? this.description,
    amount: amount ?? this.amount,
    payerId: payerId ?? this.payerId,
    targetIds: targetIds ?? this.targetIds,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  TripExpenseRow copyWithCompanion(TripExpensesCompanion data) {
    return TripExpenseRow(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      description: data.description.present
          ? data.description.value
          : this.description,
      amount: data.amount.present ? data.amount.value : this.amount,
      payerId: data.payerId.present ? data.payerId.value : this.payerId,
      targetIds: data.targetIds.present ? data.targetIds.value : this.targetIds,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripExpenseRow(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('payerId: $payerId, ')
          ..write('targetIds: $targetIds, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    description,
    amount,
    payerId,
    targetIds,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripExpenseRow &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.description == this.description &&
          other.amount == this.amount &&
          other.payerId == this.payerId &&
          other.targetIds == this.targetIds &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TripExpensesCompanion extends UpdateCompanion<TripExpenseRow> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String> description;
  final Value<int> amount;
  final Value<String> payerId;
  final Value<String> targetIds;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TripExpensesCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.description = const Value.absent(),
    this.amount = const Value.absent(),
    this.payerId = const Value.absent(),
    this.targetIds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripExpensesCompanion.insert({
    required String id,
    required String tripId,
    required String description,
    required int amount,
    required String payerId,
    required String targetIds,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       description = Value(description),
       amount = Value(amount),
       payerId = Value(payerId),
       targetIds = Value(targetIds),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TripExpenseRow> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? description,
    Expression<int>? amount,
    Expression<String>? payerId,
    Expression<String>? targetIds,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (description != null) 'description': description,
      if (amount != null) 'amount': amount,
      if (payerId != null) 'payer_id': payerId,
      if (targetIds != null) 'target_ids': targetIds,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripExpensesCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<String>? description,
    Value<int>? amount,
    Value<String>? payerId,
    Value<String>? targetIds,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return TripExpensesCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      payerId: payerId ?? this.payerId,
      targetIds: targetIds ?? this.targetIds,
      createdAt: createdAt ?? this.createdAt,
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
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (payerId.present) {
      map['payer_id'] = Variable<String>(payerId.value);
    }
    if (targetIds.present) {
      map['target_ids'] = Variable<String>(targetIds.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('TripExpensesCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('payerId: $payerId, ')
          ..write('targetIds: $targetIds, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PointsTable points = $PointsTable(this);
  late final $CatchLogsTable catchLogs = $CatchLogsTable(this);
  late final $CatchItemsTable catchItems = $CatchItemsTable(this);
  late final $PhotosTable photos = $PhotosTable(this);
  late final $TracksTable tracks = $TracksTable(this);
  late final $TrackPointsTable trackPoints = $TrackPointsTable(this);
  late final $PointCandidatesTable pointCandidates = $PointCandidatesTable(
    this,
  );
  late final $ForecastCacheTable forecastCache = $ForecastCacheTable(this);
  late final $ShareImportsTable shareImports = $ShareImportsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $TeamsTable teams = $TeamsTable(this);
  late final $TeamMembersTable teamMembers = $TeamMembersTable(this);
  late final $TripsTable trips = $TripsTable(this);
  late final $TripExpensesTable tripExpenses = $TripExpensesTable(this);
  late final Index idxCatchLogFishedAt = Index(
    'idx_catch_log_fished_at',
    'CREATE INDEX idx_catch_log_fished_at ON catch_logs (fished_at)',
  );
  late final Index idxCatchItemLogId = Index(
    'idx_catch_item_log_id',
    'CREATE INDEX idx_catch_item_log_id ON catch_items (log_id)',
  );
  late final Index idxPointLatLng = Index(
    'idx_point_lat_lng',
    'CREATE INDEX idx_point_lat_lng ON points (lat, lng)',
  );
  late final Index idxTrackStartedAt = Index(
    'idx_track_started_at',
    'CREATE INDEX idx_track_started_at ON tracks (started_at)',
  );
  late final Index idxTeamMemberTeam = Index(
    'idx_team_member_team',
    'CREATE INDEX idx_team_member_team ON team_members (team_id)',
  );
  late final Index idxTripTeam = Index(
    'idx_trip_team',
    'CREATE INDEX idx_trip_team ON trips (team_id)',
  );
  late final Index idxTripExpenseTrip = Index(
    'idx_trip_expense_trip',
    'CREATE INDEX idx_trip_expense_trip ON trip_expenses (trip_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    points,
    catchLogs,
    catchItems,
    photos,
    tracks,
    trackPoints,
    pointCandidates,
    forecastCache,
    shareImports,
    appSettings,
    teams,
    teamMembers,
    trips,
    tripExpenses,
    idxCatchLogFishedAt,
    idxCatchItemLogId,
    idxPointLatLng,
    idxTrackStartedAt,
    idxTeamMemberTeam,
    idxTripTeam,
    idxTripExpenseTrip,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'catch_logs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('catch_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tracks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('track_points', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tracks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('point_candidates', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PointsTableCreateCompanionBuilder = PointsCompanion Function({
  required String id,
  required String name,
  required double lat,
  required double lng,
  Value<Genre?> genre,
  Value<String?> memo,
  required PointSource source,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$PointsTableUpdateCompanionBuilder = PointsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<double> lat,
  Value<double> lng,
  Value<Genre?> genre,
  Value<String?> memo,
  Value<PointSource> source,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

final class $$PointsTableReferences
    extends BaseReferences<_$AppDatabase, $PointsTable, Point> {
  $$PointsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CatchLogsTable, List<CatchLog>>
  _catchLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.catchLogs,
    aliasName: 'points__id__catch_logs__point_id',
  );

  $$CatchLogsTableProcessedTableManager get catchLogsRefs {
    final manager = $$CatchLogsTableTableManager(
      $_db,
      $_db.catchLogs,
    ).filter((f) => f.pointId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_catchLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TracksTable, List<Track>> _tracksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tracks,
    aliasName: 'points__id__tracks__point_id',
  );

  $$TracksTableProcessedTableManager get tracksRefs {
    final manager = $$TracksTableTableManager(
      $_db,
      $_db.tracks,
    ).filter((f) => f.pointId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tracksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ShareImportsTable, List<ShareImport>>
  _shareImportsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.shareImports,
    aliasName: 'points__id__share_imports__point_id',
  );

  $$ShareImportsTableProcessedTableManager get shareImportsRefs {
    final manager = $$ShareImportsTableTableManager(
      $_db,
      $_db.shareImports,
    ).filter((f) => f.pointId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_shareImportsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PointsTableFilterComposer
    extends Composer<_$AppDatabase, $PointsTable> {
  $$PointsTableFilterComposer({
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

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Genre?, Genre, String> get genre =>
      $composableBuilder(
        column: $table.genre,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PointSource, PointSource, String> get source =>
      $composableBuilder(
        column: $table.source,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  Expression<bool> catchLogsRefs(
    Expression<bool> Function($$CatchLogsTableFilterComposer f) f,
  ) {
    final $$CatchLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.catchLogs,
      getReferencedColumn: (t) => t.pointId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatchLogsTableFilterComposer(
            $db: $db,
            $table: $db.catchLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tracksRefs(
    Expression<bool> Function($$TracksTableFilterComposer f) f,
  ) {
    final $$TracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.pointId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableFilterComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> shareImportsRefs(
    Expression<bool> Function($$ShareImportsTableFilterComposer f) f,
  ) {
    final $$ShareImportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shareImports,
      getReferencedColumn: (t) => t.pointId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShareImportsTableFilterComposer(
            $db: $db,
            $table: $db.shareImports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PointsTableOrderingComposer
    extends Composer<_$AppDatabase, $PointsTable> {
  $$PointsTableOrderingComposer({
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

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

class $$PointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PointsTable> {
  $$PointsTableAnnotationComposer({
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

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Genre?, String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PointSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> catchLogsRefs<T extends Object>(
    Expression<T> Function($$CatchLogsTableAnnotationComposer a) f,
  ) {
    final $$CatchLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.catchLogs,
      getReferencedColumn: (t) => t.pointId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatchLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.catchLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tracksRefs<T extends Object>(
    Expression<T> Function($$TracksTableAnnotationComposer a) f,
  ) {
    final $$TracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.pointId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableAnnotationComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> shareImportsRefs<T extends Object>(
    Expression<T> Function($$ShareImportsTableAnnotationComposer a) f,
  ) {
    final $$ShareImportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shareImports,
      getReferencedColumn: (t) => t.pointId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShareImportsTableAnnotationComposer(
            $db: $db,
            $table: $db.shareImports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PointsTable,
          Point,
          $$PointsTableFilterComposer,
          $$PointsTableOrderingComposer,
          $$PointsTableAnnotationComposer,
          $$PointsTableCreateCompanionBuilder,
          $$PointsTableUpdateCompanionBuilder,
          (Point, $$PointsTableReferences),
          Point,
          PrefetchHooks Function({
            bool catchLogsRefs,
            bool tracksRefs,
            bool shareImportsRefs,
          })
        > {
  $$PointsTableTableManager(_$AppDatabase db, $PointsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lng = const Value.absent(),
                Value<Genre?> genre = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<PointSource> source = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PointsCompanion(
                id: id,
                name: name,
                lat: lat,
                lng: lng,
                genre: genre,
                memo: memo,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required double lat,
                required double lng,
                Value<Genre?> genre = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                required PointSource source,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PointsCompanion.insert(
                id: id,
                name: name,
                lat: lat,
                lng: lng,
                genre: genre,
                memo: memo,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PointsTable, Point>(table),
                  $$PointsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                catchLogsRefs = false,
                tracksRefs = false,
                shareImportsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (catchLogsRefs) db.catchLogs,
                    if (tracksRefs) db.tracks,
                    if (shareImportsRefs) db.shareImports,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (catchLogsRefs)
                        await $_getPrefetchedDataByColumns<
                          Point,
                          $PointsTable,
                          CatchLog,
                          $CatchLogsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PointsTableReferences
                              ._catchLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PointsTableReferences(
                                db,
                                table,
                                p0,
                              ).catchLogsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'point_id',
                          typedResults: items,
                        ),
                      if (tracksRefs)
                        await $_getPrefetchedDataByColumns<
                          Point,
                          $PointsTable,
                          Track,
                          $TracksTable
                        >(
                          currentTable: table,
                          referencedTable: $$PointsTableReferences
                              ._tracksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PointsTableReferences(db, table, p0).tracksRefs,
                          currentColumn: 'id',
                          referencedColumn: 'point_id',
                          typedResults: items,
                        ),
                      if (shareImportsRefs)
                        await $_getPrefetchedDataByColumns<
                          Point,
                          $PointsTable,
                          ShareImport,
                          $ShareImportsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PointsTableReferences
                              ._shareImportsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PointsTableReferences(
                                db,
                                table,
                                p0,
                              ).shareImportsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'point_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PointsTable,
      Point,
      $$PointsTableFilterComposer,
      $$PointsTableOrderingComposer,
      $$PointsTableAnnotationComposer,
      $$PointsTableCreateCompanionBuilder,
      $$PointsTableUpdateCompanionBuilder,
      (Point, $$PointsTableReferences),
      Point,
      PrefetchHooks Function({
        bool catchLogsRefs,
        bool tracksRefs,
        bool shareImportsRefs,
      })
    >;
typedef $$CatchLogsTableCreateCompanionBuilder = CatchLogsCompanion Function({
  required String id,
  required Genre genre,
  required DateTime fishedAt,
  Value<String?> pointId,
  Value<double?> lat,
  Value<double?> lng,
  Value<String?> memo,
  Value<String> genreDetail,
  Value<String> env,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$CatchLogsTableUpdateCompanionBuilder = CatchLogsCompanion Function({
  Value<String> id,
  Value<Genre> genre,
  Value<DateTime> fishedAt,
  Value<String?> pointId,
  Value<double?> lat,
  Value<double?> lng,
  Value<String?> memo,
  Value<String> genreDetail,
  Value<String> env,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

final class $$CatchLogsTableReferences
    extends BaseReferences<_$AppDatabase, $CatchLogsTable, CatchLog> {
  $$CatchLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PointsTable _pointIdTable(_$AppDatabase db) =>
      db.points.createAlias('catch_logs__point_id__points__id');

  $$PointsTableProcessedTableManager? get pointId {
    final $_column = $_itemColumn<String>('point_id');
    if ($_column == null) return null;
    final manager = $$PointsTableTableManager(
      $_db,
      $_db.points,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pointIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CatchItemsTable, List<CatchItem>>
  _catchItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.catchItems,
    aliasName: 'catch_logs__id__catch_items__log_id',
  );

  $$CatchItemsTableProcessedTableManager get catchItemsRefs {
    final manager = $$CatchItemsTableTableManager(
      $_db,
      $_db.catchItems,
    ).filter((f) => f.logId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_catchItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CatchLogsTableFilterComposer
    extends Composer<_$AppDatabase, $CatchLogsTable> {
  $$CatchLogsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<Genre, Genre, String> get genre =>
      $composableBuilder(
        column: $table.genre,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get fishedAt => $composableBuilder(
    column: $table.fishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genreDetail => $composableBuilder(
    column: $table.genreDetail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get env => $composableBuilder(
    column: $table.env,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  $$PointsTableFilterComposer get pointId {
    final $$PointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pointId,
      referencedTable: $db.points,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PointsTableFilterComposer(
            $db: $db,
            $table: $db.points,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> catchItemsRefs(
    Expression<bool> Function($$CatchItemsTableFilterComposer f) f,
  ) {
    final $$CatchItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.catchItems,
      getReferencedColumn: (t) => t.logId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatchItemsTableFilterComposer(
            $db: $db,
            $table: $db.catchItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CatchLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $CatchLogsTable> {
  $$CatchLogsTableOrderingComposer({
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

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fishedAt => $composableBuilder(
    column: $table.fishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genreDetail => $composableBuilder(
    column: $table.genreDetail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get env => $composableBuilder(
    column: $table.env,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  $$PointsTableOrderingComposer get pointId {
    final $$PointsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pointId,
      referencedTable: $db.points,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PointsTableOrderingComposer(
            $db: $db,
            $table: $db.points,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CatchLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatchLogsTable> {
  $$CatchLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Genre, String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<DateTime> get fishedAt =>
      $composableBuilder(column: $table.fishedAt, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<String> get genreDetail => $composableBuilder(
    column: $table.genreDetail,
    builder: (column) => column,
  );

  GeneratedColumn<String> get env =>
      $composableBuilder(column: $table.env, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$PointsTableAnnotationComposer get pointId {
    final $$PointsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pointId,
      referencedTable: $db.points,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PointsTableAnnotationComposer(
            $db: $db,
            $table: $db.points,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> catchItemsRefs<T extends Object>(
    Expression<T> Function($$CatchItemsTableAnnotationComposer a) f,
  ) {
    final $$CatchItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.catchItems,
      getReferencedColumn: (t) => t.logId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatchItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.catchItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CatchLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatchLogsTable,
          CatchLog,
          $$CatchLogsTableFilterComposer,
          $$CatchLogsTableOrderingComposer,
          $$CatchLogsTableAnnotationComposer,
          $$CatchLogsTableCreateCompanionBuilder,
          $$CatchLogsTableUpdateCompanionBuilder,
          (CatchLog, $$CatchLogsTableReferences),
          CatchLog,
          PrefetchHooks Function({bool pointId, bool catchItemsRefs})
        > {
  $$CatchLogsTableTableManager(_$AppDatabase db, $CatchLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatchLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatchLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatchLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<Genre> genre = const Value.absent(),
                Value<DateTime> fishedAt = const Value.absent(),
                Value<String?> pointId = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<String> genreDetail = const Value.absent(),
                Value<String> env = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatchLogsCompanion(
                id: id,
                genre: genre,
                fishedAt: fishedAt,
                pointId: pointId,
                lat: lat,
                lng: lng,
                memo: memo,
                genreDetail: genreDetail,
                env: env,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required Genre genre,
                required DateTime fishedAt,
                Value<String?> pointId = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<String> genreDetail = const Value.absent(),
                Value<String> env = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatchLogsCompanion.insert(
                id: id,
                genre: genre,
                fishedAt: fishedAt,
                pointId: pointId,
                lat: lat,
                lng: lng,
                memo: memo,
                genreDetail: genreDetail,
                env: env,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CatchLogsTable, CatchLog>(table),
                  $$CatchLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pointId = false, catchItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (catchItemsRefs) db.catchItems],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (pointId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.pointId,
                        referencedTable: $$CatchLogsTableReferences
                            ._pointIdTable(db),
                        referencedColumn: $$CatchLogsTableReferences
                            ._pointIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (catchItemsRefs)
                    await $_getPrefetchedDataByColumns<
                      CatchLog,
                      $CatchLogsTable,
                      CatchItem,
                      $CatchItemsTable
                    >(
                      currentTable: table,
                      referencedTable: $$CatchLogsTableReferences
                          ._catchItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CatchLogsTableReferences(
                            db,
                            table,
                            p0,
                          ).catchItemsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'log_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CatchLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatchLogsTable,
      CatchLog,
      $$CatchLogsTableFilterComposer,
      $$CatchLogsTableOrderingComposer,
      $$CatchLogsTableAnnotationComposer,
      $$CatchLogsTableCreateCompanionBuilder,
      $$CatchLogsTableUpdateCompanionBuilder,
      (CatchLog, $$CatchLogsTableReferences),
      CatchLog,
      PrefetchHooks Function({bool pointId, bool catchItemsRefs})
    >;
typedef $$CatchItemsTableCreateCompanionBuilder = CatchItemsCompanion Function({
  required String id,
  required String logId,
  required String speciesCode,
  Value<double?> lengthCm,
  Value<int> count,
  Value<String?> memo,
  Value<int> rowid,
});
typedef $$CatchItemsTableUpdateCompanionBuilder = CatchItemsCompanion Function({
  Value<String> id,
  Value<String> logId,
  Value<String> speciesCode,
  Value<double?> lengthCm,
  Value<int> count,
  Value<String?> memo,
  Value<int> rowid,
});

final class $$CatchItemsTableReferences
    extends BaseReferences<_$AppDatabase, $CatchItemsTable, CatchItem> {
  $$CatchItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CatchLogsTable _logIdTable(_$AppDatabase db) =>
      db.catchLogs.createAlias('catch_items__log_id__catch_logs__id');

  $$CatchLogsTableProcessedTableManager get logId {
    final $_column = $_itemColumn<String>('log_id')!;

    final manager = $$CatchLogsTableTableManager(
      $_db,
      $_db.catchLogs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_logIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CatchItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CatchItemsTable> {
  $$CatchItemsTableFilterComposer({
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

  ColumnFilters<String> get speciesCode => $composableBuilder(
    column: $table.speciesCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lengthCm => $composableBuilder(
    column: $table.lengthCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  $$CatchLogsTableFilterComposer get logId {
    final $$CatchLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.logId,
      referencedTable: $db.catchLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatchLogsTableFilterComposer(
            $db: $db,
            $table: $db.catchLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CatchItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CatchItemsTable> {
  $$CatchItemsTableOrderingComposer({
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

  ColumnOrderings<String> get speciesCode => $composableBuilder(
    column: $table.speciesCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lengthCm => $composableBuilder(
    column: $table.lengthCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  $$CatchLogsTableOrderingComposer get logId {
    final $$CatchLogsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.logId,
      referencedTable: $db.catchLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatchLogsTableOrderingComposer(
            $db: $db,
            $table: $db.catchLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CatchItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatchItemsTable> {
  $$CatchItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get speciesCode => $composableBuilder(
    column: $table.speciesCode,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lengthCm =>
      $composableBuilder(column: $table.lengthCm, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  $$CatchLogsTableAnnotationComposer get logId {
    final $$CatchLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.logId,
      referencedTable: $db.catchLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatchLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.catchLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CatchItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatchItemsTable,
          CatchItem,
          $$CatchItemsTableFilterComposer,
          $$CatchItemsTableOrderingComposer,
          $$CatchItemsTableAnnotationComposer,
          $$CatchItemsTableCreateCompanionBuilder,
          $$CatchItemsTableUpdateCompanionBuilder,
          (CatchItem, $$CatchItemsTableReferences),
          CatchItem,
          PrefetchHooks Function({bool logId})
        > {
  $$CatchItemsTableTableManager(_$AppDatabase db, $CatchItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatchItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatchItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatchItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> logId = const Value.absent(),
                Value<String> speciesCode = const Value.absent(),
                Value<double?> lengthCm = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatchItemsCompanion(
                id: id,
                logId: logId,
                speciesCode: speciesCode,
                lengthCm: lengthCm,
                count: count,
                memo: memo,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String logId,
                required String speciesCode,
                Value<double?> lengthCm = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatchItemsCompanion.insert(
                id: id,
                logId: logId,
                speciesCode: speciesCode,
                lengthCm: lengthCm,
                count: count,
                memo: memo,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CatchItemsTable, CatchItem>(table),
                  $$CatchItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({logId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (logId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.logId,
                        referencedTable: $$CatchItemsTableReferences
                            ._logIdTable(db),
                        referencedColumn: $$CatchItemsTableReferences
                            ._logIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CatchItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatchItemsTable,
      CatchItem,
      $$CatchItemsTableFilterComposer,
      $$CatchItemsTableOrderingComposer,
      $$CatchItemsTableAnnotationComposer,
      $$CatchItemsTableCreateCompanionBuilder,
      $$CatchItemsTableUpdateCompanionBuilder,
      (CatchItem, $$CatchItemsTableReferences),
      CatchItem,
      PrefetchHooks Function({bool logId})
    >;
typedef $$PhotosTableCreateCompanionBuilder = PhotosCompanion Function({
  required String id,
  required OwnerType ownerType,
  required String ownerId,
  required String filePath,
  Value<int?> width,
  Value<int?> height,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$PhotosTableUpdateCompanionBuilder = PhotosCompanion Function({
  Value<String> id,
  Value<OwnerType> ownerType,
  Value<String> ownerId,
  Value<String> filePath,
  Value<int?> width,
  Value<int?> height,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$PhotosTableFilterComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableFilterComposer({
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

  ColumnWithTypeConverterFilters<OwnerType, OwnerType, String> get ownerType =>
      $composableBuilder(
        column: $table.ownerType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableOrderingComposer({
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

  ColumnOrderings<String> get ownerType => $composableBuilder(
    column: $table.ownerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<OwnerType, String> get ownerType =>
      $composableBuilder(column: $table.ownerType, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhotosTable,
          Photo,
          $$PhotosTableFilterComposer,
          $$PhotosTableOrderingComposer,
          $$PhotosTableAnnotationComposer,
          $$PhotosTableCreateCompanionBuilder,
          $$PhotosTableUpdateCompanionBuilder,
          (Photo, BaseReferences<_$AppDatabase, $PhotosTable, Photo>),
          Photo,
          PrefetchHooks Function()
        > {
  $$PhotosTableTableManager(_$AppDatabase db, $PhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<OwnerType> ownerType = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotosCompanion(
                id: id,
                ownerType: ownerType,
                ownerId: ownerId,
                filePath: filePath,
                width: width,
                height: height,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required OwnerType ownerType,
                required String ownerId,
                required String filePath,
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PhotosCompanion.insert(
                id: id,
                ownerType: ownerType,
                ownerId: ownerId,
                filePath: filePath,
                width: width,
                height: height,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PhotosTable, Photo>(table),
                  BaseReferences<_$AppDatabase, $PhotosTable, Photo>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhotosTable,
      Photo,
      $$PhotosTableFilterComposer,
      $$PhotosTableOrderingComposer,
      $$PhotosTableAnnotationComposer,
      $$PhotosTableCreateCompanionBuilder,
      $$PhotosTableUpdateCompanionBuilder,
      (Photo, BaseReferences<_$AppDatabase, $PhotosTable, Photo>),
      Photo,
      PrefetchHooks Function()
    >;
typedef $$TracksTableCreateCompanionBuilder = TracksCompanion Function({
  required String id,
  Value<String?> pointId,
  required DateTime startedAt,
  Value<DateTime?> endedAt,
  Value<double> distanceM,
  Value<String?> encodedPolyline,
  required TrackStatus status,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$TracksTableUpdateCompanionBuilder = TracksCompanion Function({
  Value<String> id,
  Value<String?> pointId,
  Value<DateTime> startedAt,
  Value<DateTime?> endedAt,
  Value<double> distanceM,
  Value<String?> encodedPolyline,
  Value<TrackStatus> status,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$TracksTableReferences
    extends BaseReferences<_$AppDatabase, $TracksTable, Track> {
  $$TracksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PointsTable _pointIdTable(_$AppDatabase db) =>
      db.points.createAlias('tracks__point_id__points__id');

  $$PointsTableProcessedTableManager? get pointId {
    final $_column = $_itemColumn<String>('point_id');
    if ($_column == null) return null;
    final manager = $$PointsTableTableManager(
      $_db,
      $_db.points,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pointIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TrackPointsTable, List<TrackPoint>>
  _trackPointsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.trackPoints,
    aliasName: 'tracks__id__track_points__track_id',
  );

  $$TrackPointsTableProcessedTableManager get trackPointsRefs {
    final manager = $$TrackPointsTableTableManager(
      $_db,
      $_db.trackPoints,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_trackPointsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PointCandidatesTable, List<PointCandidate>>
  _pointCandidatesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pointCandidates,
    aliasName: 'tracks__id__point_candidates__track_id',
  );

  $$PointCandidatesTableProcessedTableManager get pointCandidatesRefs {
    final manager = $$PointCandidatesTableTableManager(
      $_db,
      $_db.pointCandidates,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _pointCandidatesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TracksTableFilterComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableFilterComposer({
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

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encodedPolyline => $composableBuilder(
    column: $table.encodedPolyline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TrackStatus, TrackStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PointsTableFilterComposer get pointId {
    final $$PointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pointId,
      referencedTable: $db.points,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PointsTableFilterComposer(
            $db: $db,
            $table: $db.points,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> trackPointsRefs(
    Expression<bool> Function($$TrackPointsTableFilterComposer f) f,
  ) {
    final $$TrackPointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackPoints,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackPointsTableFilterComposer(
            $db: $db,
            $table: $db.trackPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pointCandidatesRefs(
    Expression<bool> Function($$PointCandidatesTableFilterComposer f) f,
  ) {
    final $$PointCandidatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pointCandidates,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PointCandidatesTableFilterComposer(
            $db: $db,
            $table: $db.pointCandidates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TracksTableOrderingComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableOrderingComposer({
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

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encodedPolyline => $composableBuilder(
    column: $table.encodedPolyline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PointsTableOrderingComposer get pointId {
    final $$PointsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pointId,
      referencedTable: $db.points,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PointsTableOrderingComposer(
            $db: $db,
            $table: $db.points,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TracksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<double> get distanceM =>
      $composableBuilder(column: $table.distanceM, builder: (column) => column);

  GeneratedColumn<String> get encodedPolyline => $composableBuilder(
    column: $table.encodedPolyline,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TrackStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$PointsTableAnnotationComposer get pointId {
    final $$PointsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pointId,
      referencedTable: $db.points,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PointsTableAnnotationComposer(
            $db: $db,
            $table: $db.points,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> trackPointsRefs<T extends Object>(
    Expression<T> Function($$TrackPointsTableAnnotationComposer a) f,
  ) {
    final $$TrackPointsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackPoints,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackPointsTableAnnotationComposer(
            $db: $db,
            $table: $db.trackPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pointCandidatesRefs<T extends Object>(
    Expression<T> Function($$PointCandidatesTableAnnotationComposer a) f,
  ) {
    final $$PointCandidatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pointCandidates,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PointCandidatesTableAnnotationComposer(
            $db: $db,
            $table: $db.pointCandidates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TracksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TracksTable,
          Track,
          $$TracksTableFilterComposer,
          $$TracksTableOrderingComposer,
          $$TracksTableAnnotationComposer,
          $$TracksTableCreateCompanionBuilder,
          $$TracksTableUpdateCompanionBuilder,
          (Track, $$TracksTableReferences),
          Track,
          PrefetchHooks Function({
            bool pointId,
            bool trackPointsRefs,
            bool pointCandidatesRefs,
          })
        > {
  $$TracksTableTableManager(_$AppDatabase db, $TracksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TracksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TracksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TracksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> pointId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<double> distanceM = const Value.absent(),
                Value<String?> encodedPolyline = const Value.absent(),
                Value<TrackStatus> status = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TracksCompanion(
                id: id,
                pointId: pointId,
                startedAt: startedAt,
                endedAt: endedAt,
                distanceM: distanceM,
                encodedPolyline: encodedPolyline,
                status: status,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> pointId = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<double> distanceM = const Value.absent(),
                Value<String?> encodedPolyline = const Value.absent(),
                required TrackStatus status,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TracksCompanion.insert(
                id: id,
                pointId: pointId,
                startedAt: startedAt,
                endedAt: endedAt,
                distanceM: distanceM,
                encodedPolyline: encodedPolyline,
                status: status,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TracksTable, Track>(table),
                  $$TracksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                pointId = false,
                trackPointsRefs = false,
                pointCandidatesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (trackPointsRefs) db.trackPoints,
                    if (pointCandidatesRefs) db.pointCandidates,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (pointId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.pointId,
                            referencedTable: $$TracksTableReferences
                                ._pointIdTable(db),
                            referencedColumn: $$TracksTableReferences
                                ._pointIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (trackPointsRefs)
                        await $_getPrefetchedDataByColumns<
                          Track,
                          $TracksTable,
                          TrackPoint,
                          $TrackPointsTable
                        >(
                          currentTable: table,
                          referencedTable: $$TracksTableReferences
                              ._trackPointsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TracksTableReferences(
                                db,
                                table,
                                p0,
                              ).trackPointsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'track_id',
                          typedResults: items,
                        ),
                      if (pointCandidatesRefs)
                        await $_getPrefetchedDataByColumns<
                          Track,
                          $TracksTable,
                          PointCandidate,
                          $PointCandidatesTable
                        >(
                          currentTable: table,
                          referencedTable: $$TracksTableReferences
                              ._pointCandidatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TracksTableReferences(
                                db,
                                table,
                                p0,
                              ).pointCandidatesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'track_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TracksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TracksTable,
      Track,
      $$TracksTableFilterComposer,
      $$TracksTableOrderingComposer,
      $$TracksTableAnnotationComposer,
      $$TracksTableCreateCompanionBuilder,
      $$TracksTableUpdateCompanionBuilder,
      (Track, $$TracksTableReferences),
      Track,
      PrefetchHooks Function({
        bool pointId,
        bool trackPointsRefs,
        bool pointCandidatesRefs,
      })
    >;
typedef $$TrackPointsTableCreateCompanionBuilder =
    TrackPointsCompanion Function({
      Value<int> id,
      required String trackId,
      required double lat,
      required double lng,
      Value<double?> accuracyM,
      Value<double?> speedMps,
      required DateTime recordedAt,
    });
typedef $$TrackPointsTableUpdateCompanionBuilder =
    TrackPointsCompanion Function({
      Value<int> id,
      Value<String> trackId,
      Value<double> lat,
      Value<double> lng,
      Value<double?> accuracyM,
      Value<double?> speedMps,
      Value<DateTime> recordedAt,
    });

final class $$TrackPointsTableReferences
    extends BaseReferences<_$AppDatabase, $TrackPointsTable, TrackPoint> {
  $$TrackPointsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TracksTable _trackIdTable(_$AppDatabase db) =>
      db.tracks.createAlias('track_points__track_id__tracks__id');

  $$TracksTableProcessedTableManager get trackId {
    final $_column = $_itemColumn<String>('track_id')!;

    final manager = $$TracksTableTableManager(
      $_db,
      $_db.tracks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TrackPointsTableFilterComposer
    extends Composer<_$AppDatabase, $TrackPointsTable> {
  $$TrackPointsTableFilterComposer({
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

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speedMps => $composableBuilder(
    column: $table.speedMps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TracksTableFilterComposer get trackId {
    final $$TracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableFilterComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackPointsTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackPointsTable> {
  $$TrackPointsTableOrderingComposer({
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

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speedMps => $composableBuilder(
    column: $table.speedMps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TracksTableOrderingComposer get trackId {
    final $$TracksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableOrderingComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackPointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackPointsTable> {
  $$TrackPointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<double> get accuracyM =>
      $composableBuilder(column: $table.accuracyM, builder: (column) => column);

  GeneratedColumn<double> get speedMps =>
      $composableBuilder(column: $table.speedMps, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  $$TracksTableAnnotationComposer get trackId {
    final $$TracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableAnnotationComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackPointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackPointsTable,
          TrackPoint,
          $$TrackPointsTableFilterComposer,
          $$TrackPointsTableOrderingComposer,
          $$TrackPointsTableAnnotationComposer,
          $$TrackPointsTableCreateCompanionBuilder,
          $$TrackPointsTableUpdateCompanionBuilder,
          (TrackPoint, $$TrackPointsTableReferences),
          TrackPoint,
          PrefetchHooks Function({bool trackId})
        > {
  $$TrackPointsTableTableManager(_$AppDatabase db, $TrackPointsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackPointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackPointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackPointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lng = const Value.absent(),
                Value<double?> accuracyM = const Value.absent(),
                Value<double?> speedMps = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
              }) => TrackPointsCompanion(
                id: id,
                trackId: trackId,
                lat: lat,
                lng: lng,
                accuracyM: accuracyM,
                speedMps: speedMps,
                recordedAt: recordedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String trackId,
                required double lat,
                required double lng,
                Value<double?> accuracyM = const Value.absent(),
                Value<double?> speedMps = const Value.absent(),
                required DateTime recordedAt,
              }) => TrackPointsCompanion.insert(
                id: id,
                trackId: trackId,
                lat: lat,
                lng: lng,
                accuracyM: accuracyM,
                speedMps: speedMps,
                recordedAt: recordedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TrackPointsTable, TrackPoint>(table),
                  $$TrackPointsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trackId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (trackId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.trackId,
                        referencedTable: $$TrackPointsTableReferences
                            ._trackIdTable(db),
                        referencedColumn: $$TrackPointsTableReferences
                            ._trackIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TrackPointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackPointsTable,
      TrackPoint,
      $$TrackPointsTableFilterComposer,
      $$TrackPointsTableOrderingComposer,
      $$TrackPointsTableAnnotationComposer,
      $$TrackPointsTableCreateCompanionBuilder,
      $$TrackPointsTableUpdateCompanionBuilder,
      (TrackPoint, $$TrackPointsTableReferences),
      TrackPoint,
      PrefetchHooks Function({bool trackId})
    >;
typedef $$PointCandidatesTableCreateCompanionBuilder =
    PointCandidatesCompanion Function({
      required String id,
      required String trackId,
      required double lat,
      required double lng,
      required int dwellSec,
      required CandidateStatus status,
      Value<int> rowid,
    });
typedef $$PointCandidatesTableUpdateCompanionBuilder =
    PointCandidatesCompanion Function({
      Value<String> id,
      Value<String> trackId,
      Value<double> lat,
      Value<double> lng,
      Value<int> dwellSec,
      Value<CandidateStatus> status,
      Value<int> rowid,
    });

final class $$PointCandidatesTableReferences
    extends
        BaseReferences<_$AppDatabase, $PointCandidatesTable, PointCandidate> {
  $$PointCandidatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TracksTable _trackIdTable(_$AppDatabase db) =>
      db.tracks.createAlias('point_candidates__track_id__tracks__id');

  $$TracksTableProcessedTableManager get trackId {
    final $_column = $_itemColumn<String>('track_id')!;

    final manager = $$TracksTableTableManager(
      $_db,
      $_db.tracks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PointCandidatesTableFilterComposer
    extends Composer<_$AppDatabase, $PointCandidatesTable> {
  $$PointCandidatesTableFilterComposer({
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

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dwellSec => $composableBuilder(
    column: $table.dwellSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CandidateStatus, CandidateStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$TracksTableFilterComposer get trackId {
    final $$TracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableFilterComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PointCandidatesTableOrderingComposer
    extends Composer<_$AppDatabase, $PointCandidatesTable> {
  $$PointCandidatesTableOrderingComposer({
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

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dwellSec => $composableBuilder(
    column: $table.dwellSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $$TracksTableOrderingComposer get trackId {
    final $$TracksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableOrderingComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PointCandidatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PointCandidatesTable> {
  $$PointCandidatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<int> get dwellSec =>
      $composableBuilder(column: $table.dwellSec, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CandidateStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$TracksTableAnnotationComposer get trackId {
    final $$TracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableAnnotationComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PointCandidatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PointCandidatesTable,
          PointCandidate,
          $$PointCandidatesTableFilterComposer,
          $$PointCandidatesTableOrderingComposer,
          $$PointCandidatesTableAnnotationComposer,
          $$PointCandidatesTableCreateCompanionBuilder,
          $$PointCandidatesTableUpdateCompanionBuilder,
          (PointCandidate, $$PointCandidatesTableReferences),
          PointCandidate,
          PrefetchHooks Function({bool trackId})
        > {
  $$PointCandidatesTableTableManager(
    _$AppDatabase db,
    $PointCandidatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PointCandidatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PointCandidatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PointCandidatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lng = const Value.absent(),
                Value<int> dwellSec = const Value.absent(),
                Value<CandidateStatus> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PointCandidatesCompanion(
                id: id,
                trackId: trackId,
                lat: lat,
                lng: lng,
                dwellSec: dwellSec,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String trackId,
                required double lat,
                required double lng,
                required int dwellSec,
                required CandidateStatus status,
                Value<int> rowid = const Value.absent(),
              }) => PointCandidatesCompanion.insert(
                id: id,
                trackId: trackId,
                lat: lat,
                lng: lng,
                dwellSec: dwellSec,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PointCandidatesTable, PointCandidate>(table),
                  $$PointCandidatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trackId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (trackId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.trackId,
                        referencedTable: $$PointCandidatesTableReferences
                            ._trackIdTable(db),
                        referencedColumn: $$PointCandidatesTableReferences
                            ._trackIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PointCandidatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PointCandidatesTable,
      PointCandidate,
      $$PointCandidatesTableFilterComposer,
      $$PointCandidatesTableOrderingComposer,
      $$PointCandidatesTableAnnotationComposer,
      $$PointCandidatesTableCreateCompanionBuilder,
      $$PointCandidatesTableUpdateCompanionBuilder,
      (PointCandidate, $$PointCandidatesTableReferences),
      PointCandidate,
      PrefetchHooks Function({bool trackId})
    >;
typedef $$ForecastCacheTableCreateCompanionBuilder =
    ForecastCacheCompanion Function({
      required String key,
      required String payload,
      required DateTime fetchedAt,
      required DateTime expiresAt,
      Value<int> rowid,
    });
typedef $$ForecastCacheTableUpdateCompanionBuilder =
    ForecastCacheCompanion Function({
      Value<String> key,
      Value<String> payload,
      Value<DateTime> fetchedAt,
      Value<DateTime> expiresAt,
      Value<int> rowid,
    });

class $$ForecastCacheTableFilterComposer
    extends Composer<_$AppDatabase, $ForecastCacheTable> {
  $$ForecastCacheTableFilterComposer({
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

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ForecastCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $ForecastCacheTable> {
  $$ForecastCacheTableOrderingComposer({
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

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ForecastCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $ForecastCacheTable> {
  $$ForecastCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$ForecastCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ForecastCacheTable,
          ForecastCacheEntry,
          $$ForecastCacheTableFilterComposer,
          $$ForecastCacheTableOrderingComposer,
          $$ForecastCacheTableAnnotationComposer,
          $$ForecastCacheTableCreateCompanionBuilder,
          $$ForecastCacheTableUpdateCompanionBuilder,
          (
            ForecastCacheEntry,
            BaseReferences<
              _$AppDatabase,
              $ForecastCacheTable,
              ForecastCacheEntry
            >,
          ),
          ForecastCacheEntry,
          PrefetchHooks Function()
        > {
  $$ForecastCacheTableTableManager(_$AppDatabase db, $ForecastCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ForecastCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ForecastCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ForecastCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ForecastCacheCompanion(
                key: key,
                payload: payload,
                fetchedAt: fetchedAt,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String payload,
                required DateTime fetchedAt,
                required DateTime expiresAt,
                Value<int> rowid = const Value.absent(),
              }) => ForecastCacheCompanion.insert(
                key: key,
                payload: payload,
                fetchedAt: fetchedAt,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ForecastCacheTable, ForecastCacheEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ForecastCacheTable,
                    ForecastCacheEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ForecastCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ForecastCacheTable,
      ForecastCacheEntry,
      $$ForecastCacheTableFilterComposer,
      $$ForecastCacheTableOrderingComposer,
      $$ForecastCacheTableAnnotationComposer,
      $$ForecastCacheTableCreateCompanionBuilder,
      $$ForecastCacheTableUpdateCompanionBuilder,
      (
        ForecastCacheEntry,
        BaseReferences<_$AppDatabase, $ForecastCacheTable, ForecastCacheEntry>,
      ),
      ForecastCacheEntry,
      PrefetchHooks Function()
    >;
typedef $$ShareImportsTableCreateCompanionBuilder =
    ShareImportsCompanion Function({
      required String id,
      required String pointId,
      required String payloadHash,
      required DateTime importedAt,
      Value<int> rowid,
    });
typedef $$ShareImportsTableUpdateCompanionBuilder =
    ShareImportsCompanion Function({
      Value<String> id,
      Value<String> pointId,
      Value<String> payloadHash,
      Value<DateTime> importedAt,
      Value<int> rowid,
    });

final class $$ShareImportsTableReferences
    extends BaseReferences<_$AppDatabase, $ShareImportsTable, ShareImport> {
  $$ShareImportsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PointsTable _pointIdTable(_$AppDatabase db) =>
      db.points.createAlias('share_imports__point_id__points__id');

  $$PointsTableProcessedTableManager get pointId {
    final $_column = $_itemColumn<String>('point_id')!;

    final manager = $$PointsTableTableManager(
      $_db,
      $_db.points,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pointIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ShareImportsTableFilterComposer
    extends Composer<_$AppDatabase, $ShareImportsTable> {
  $$ShareImportsTableFilterComposer({
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

  ColumnFilters<String> get payloadHash => $composableBuilder(
    column: $table.payloadHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PointsTableFilterComposer get pointId {
    final $$PointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pointId,
      referencedTable: $db.points,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PointsTableFilterComposer(
            $db: $db,
            $table: $db.points,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShareImportsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShareImportsTable> {
  $$ShareImportsTableOrderingComposer({
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

  ColumnOrderings<String> get payloadHash => $composableBuilder(
    column: $table.payloadHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PointsTableOrderingComposer get pointId {
    final $$PointsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pointId,
      referencedTable: $db.points,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PointsTableOrderingComposer(
            $db: $db,
            $table: $db.points,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShareImportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShareImportsTable> {
  $$ShareImportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payloadHash => $composableBuilder(
    column: $table.payloadHash,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  $$PointsTableAnnotationComposer get pointId {
    final $$PointsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pointId,
      referencedTable: $db.points,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PointsTableAnnotationComposer(
            $db: $db,
            $table: $db.points,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShareImportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShareImportsTable,
          ShareImport,
          $$ShareImportsTableFilterComposer,
          $$ShareImportsTableOrderingComposer,
          $$ShareImportsTableAnnotationComposer,
          $$ShareImportsTableCreateCompanionBuilder,
          $$ShareImportsTableUpdateCompanionBuilder,
          (ShareImport, $$ShareImportsTableReferences),
          ShareImport,
          PrefetchHooks Function({bool pointId})
        > {
  $$ShareImportsTableTableManager(_$AppDatabase db, $ShareImportsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShareImportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShareImportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShareImportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> pointId = const Value.absent(),
                Value<String> payloadHash = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShareImportsCompanion(
                id: id,
                pointId: pointId,
                payloadHash: payloadHash,
                importedAt: importedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String pointId,
                required String payloadHash,
                required DateTime importedAt,
                Value<int> rowid = const Value.absent(),
              }) => ShareImportsCompanion.insert(
                id: id,
                pointId: pointId,
                payloadHash: payloadHash,
                importedAt: importedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ShareImportsTable, ShareImport>(table),
                  $$ShareImportsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pointId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (pointId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.pointId,
                        referencedTable: $$ShareImportsTableReferences
                            ._pointIdTable(db),
                        referencedColumn: $$ShareImportsTableReferences
                            ._pointIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ShareImportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShareImportsTable,
      ShareImport,
      $$ShareImportsTableFilterComposer,
      $$ShareImportsTableOrderingComposer,
      $$ShareImportsTableAnnotationComposer,
      $$ShareImportsTableCreateCompanionBuilder,
      $$ShareImportsTableUpdateCompanionBuilder,
      (ShareImport, $$ShareImportsTableReferences),
      ShareImport,
      PrefetchHooks Function({bool pointId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
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

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
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

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
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

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$TeamsTableCreateCompanionBuilder = TeamsCompanion Function({
  required String id,
  required String name,
  Value<String> remainderRule,
  Value<String?> treasurerId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$TeamsTableUpdateCompanionBuilder = TeamsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> remainderRule,
  Value<String?> treasurerId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

final class $$TeamsTableReferences
    extends BaseReferences<_$AppDatabase, $TeamsTable, TeamRow> {
  $$TeamsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TeamMembersTable, List<TeamMemberRow>>
  _teamMembersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.teamMembers,
    aliasName: 'teams__id__team_members__team_id',
  );

  $$TeamMembersTableProcessedTableManager get teamMembersRefs {
    final manager = $$TeamMembersTableTableManager(
      $_db,
      $_db.teamMembers,
    ).filter((f) => f.teamId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_teamMembersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TripsTable, List<TripRow>> _tripsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.trips,
    aliasName: 'teams__id__trips__team_id',
  );

  $$TripsTableProcessedTableManager get tripsRefs {
    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.teamId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tripsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TeamsTableFilterComposer extends Composer<_$AppDatabase, $TeamsTable> {
  $$TeamsTableFilterComposer({
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

  ColumnFilters<String> get remainderRule => $composableBuilder(
    column: $table.remainderRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get treasurerId => $composableBuilder(
    column: $table.treasurerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  Expression<bool> teamMembersRefs(
    Expression<bool> Function($$TeamMembersTableFilterComposer f) f,
  ) {
    final $$TeamMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.teamMembers,
      getReferencedColumn: (t) => t.teamId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TeamMembersTableFilterComposer(
            $db: $db,
            $table: $db.teamMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tripsRefs(
    Expression<bool> Function($$TripsTableFilterComposer f) f,
  ) {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.teamId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TeamsTableOrderingComposer
    extends Composer<_$AppDatabase, $TeamsTable> {
  $$TeamsTableOrderingComposer({
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

  ColumnOrderings<String> get remainderRule => $composableBuilder(
    column: $table.remainderRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get treasurerId => $composableBuilder(
    column: $table.treasurerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

class $$TeamsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TeamsTable> {
  $$TeamsTableAnnotationComposer({
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

  GeneratedColumn<String> get remainderRule => $composableBuilder(
    column: $table.remainderRule,
    builder: (column) => column,
  );

  GeneratedColumn<String> get treasurerId => $composableBuilder(
    column: $table.treasurerId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> teamMembersRefs<T extends Object>(
    Expression<T> Function($$TeamMembersTableAnnotationComposer a) f,
  ) {
    final $$TeamMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.teamMembers,
      getReferencedColumn: (t) => t.teamId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TeamMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.teamMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tripsRefs<T extends Object>(
    Expression<T> Function($$TripsTableAnnotationComposer a) f,
  ) {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.teamId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TeamsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TeamsTable,
          TeamRow,
          $$TeamsTableFilterComposer,
          $$TeamsTableOrderingComposer,
          $$TeamsTableAnnotationComposer,
          $$TeamsTableCreateCompanionBuilder,
          $$TeamsTableUpdateCompanionBuilder,
          (TeamRow, $$TeamsTableReferences),
          TeamRow,
          PrefetchHooks Function({bool teamMembersRefs, bool tripsRefs})
        > {
  $$TeamsTableTableManager(_$AppDatabase db, $TeamsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeamsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeamsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TeamsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> remainderRule = const Value.absent(),
                Value<String?> treasurerId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeamsCompanion(
                id: id,
                name: name,
                remainderRule: remainderRule,
                treasurerId: treasurerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> remainderRule = const Value.absent(),
                Value<String?> treasurerId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeamsCompanion.insert(
                id: id,
                name: name,
                remainderRule: remainderRule,
                treasurerId: treasurerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TeamsTable, TeamRow>(table),
                  $$TeamsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({teamMembersRefs = false, tripsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (teamMembersRefs) db.teamMembers,
                    if (tripsRefs) db.trips,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (teamMembersRefs)
                        await $_getPrefetchedDataByColumns<
                          TeamRow,
                          $TeamsTable,
                          TeamMemberRow,
                          $TeamMembersTable
                        >(
                          currentTable: table,
                          referencedTable: $$TeamsTableReferences
                              ._teamMembersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TeamsTableReferences(
                                db,
                                table,
                                p0,
                              ).teamMembersRefs,
                          currentColumn: 'id',
                          referencedColumn: 'team_id',
                          typedResults: items,
                        ),
                      if (tripsRefs)
                        await $_getPrefetchedDataByColumns<
                          TeamRow,
                          $TeamsTable,
                          TripRow,
                          $TripsTable
                        >(
                          currentTable: table,
                          referencedTable: $$TeamsTableReferences
                              ._tripsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TeamsTableReferences(db, table, p0).tripsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'team_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TeamsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TeamsTable,
      TeamRow,
      $$TeamsTableFilterComposer,
      $$TeamsTableOrderingComposer,
      $$TeamsTableAnnotationComposer,
      $$TeamsTableCreateCompanionBuilder,
      $$TeamsTableUpdateCompanionBuilder,
      (TeamRow, $$TeamsTableReferences),
      TeamRow,
      PrefetchHooks Function({bool teamMembersRefs, bool tripsRefs})
    >;
typedef $$TeamMembersTableCreateCompanionBuilder =
    TeamMembersCompanion Function({
      required String id,
      required String teamId,
      required String name,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$TeamMembersTableUpdateCompanionBuilder =
    TeamMembersCompanion Function({
      Value<String> id,
      Value<String> teamId,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$TeamMembersTableReferences
    extends BaseReferences<_$AppDatabase, $TeamMembersTable, TeamMemberRow> {
  $$TeamMembersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TeamsTable _teamIdTable(_$AppDatabase db) =>
      db.teams.createAlias('team_members__team_id__teams__id');

  $$TeamsTableProcessedTableManager get teamId {
    final $_column = $_itemColumn<String>('team_id')!;

    final manager = $$TeamsTableTableManager(
      $_db,
      $_db.teams,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_teamIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TeamMembersTableFilterComposer
    extends Composer<_$AppDatabase, $TeamMembersTable> {
  $$TeamMembersTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  $$TeamsTableFilterComposer get teamId {
    final $$TeamsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.teamId,
      referencedTable: $db.teams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TeamsTableFilterComposer(
            $db: $db,
            $table: $db.teams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TeamMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $TeamMembersTable> {
  $$TeamMembersTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  $$TeamsTableOrderingComposer get teamId {
    final $$TeamsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.teamId,
      referencedTable: $db.teams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TeamsTableOrderingComposer(
            $db: $db,
            $table: $db.teams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TeamMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TeamMembersTable> {
  $$TeamMembersTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$TeamsTableAnnotationComposer get teamId {
    final $$TeamsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.teamId,
      referencedTable: $db.teams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TeamsTableAnnotationComposer(
            $db: $db,
            $table: $db.teams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TeamMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TeamMembersTable,
          TeamMemberRow,
          $$TeamMembersTableFilterComposer,
          $$TeamMembersTableOrderingComposer,
          $$TeamMembersTableAnnotationComposer,
          $$TeamMembersTableCreateCompanionBuilder,
          $$TeamMembersTableUpdateCompanionBuilder,
          (TeamMemberRow, $$TeamMembersTableReferences),
          TeamMemberRow,
          PrefetchHooks Function({bool teamId})
        > {
  $$TeamMembersTableTableManager(_$AppDatabase db, $TeamMembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeamMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeamMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TeamMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> teamId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeamMembersCompanion(
                id: id,
                teamId: teamId,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String teamId,
                required String name,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeamMembersCompanion.insert(
                id: id,
                teamId: teamId,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TeamMembersTable, TeamMemberRow>(table),
                  $$TeamMembersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({teamId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (teamId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.teamId,
                        referencedTable: $$TeamMembersTableReferences
                            ._teamIdTable(db),
                        referencedColumn: $$TeamMembersTableReferences
                            ._teamIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TeamMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TeamMembersTable,
      TeamMemberRow,
      $$TeamMembersTableFilterComposer,
      $$TeamMembersTableOrderingComposer,
      $$TeamMembersTableAnnotationComposer,
      $$TeamMembersTableCreateCompanionBuilder,
      $$TeamMembersTableUpdateCompanionBuilder,
      (TeamMemberRow, $$TeamMembersTableReferences),
      TeamMemberRow,
      PrefetchHooks Function({bool teamId})
    >;
typedef $$TripsTableCreateCompanionBuilder = TripsCompanion Function({
  required String id,
  required String teamId,
  required String title,
  required DateTime tripDate,
  required String participantIds,
  Value<DateTime?> settledAt,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$TripsTableUpdateCompanionBuilder = TripsCompanion Function({
  Value<String> id,
  Value<String> teamId,
  Value<String> title,
  Value<DateTime> tripDate,
  Value<String> participantIds,
  Value<DateTime?> settledAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

final class $$TripsTableReferences
    extends BaseReferences<_$AppDatabase, $TripsTable, TripRow> {
  $$TripsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TeamsTable _teamIdTable(_$AppDatabase db) =>
      db.teams.createAlias('trips__team_id__teams__id');

  $$TeamsTableProcessedTableManager get teamId {
    final $_column = $_itemColumn<String>('team_id')!;

    final manager = $$TeamsTableTableManager(
      $_db,
      $_db.teams,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_teamIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TripExpensesTable, List<TripExpenseRow>>
  _tripExpensesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tripExpenses,
    aliasName: 'trips__id__trip_expenses__trip_id',
  );

  $$TripExpensesTableProcessedTableManager get tripExpensesRefs {
    final manager = $$TripExpensesTableTableManager(
      $_db,
      $_db.tripExpenses,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tripExpensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TripsTableFilterComposer extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tripDate => $composableBuilder(
    column: $table.tripDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get participantIds => $composableBuilder(
    column: $table.participantIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get settledAt => $composableBuilder(
    column: $table.settledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  $$TeamsTableFilterComposer get teamId {
    final $$TeamsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.teamId,
      referencedTable: $db.teams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TeamsTableFilterComposer(
            $db: $db,
            $table: $db.teams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tripExpensesRefs(
    Expression<bool> Function($$TripExpensesTableFilterComposer f) f,
  ) {
    final $$TripExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripExpenses,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripExpensesTableFilterComposer(
            $db: $db,
            $table: $db.tripExpenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripsTableOrderingComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tripDate => $composableBuilder(
    column: $table.tripDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get participantIds => $composableBuilder(
    column: $table.participantIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get settledAt => $composableBuilder(
    column: $table.settledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  $$TeamsTableOrderingComposer get teamId {
    final $$TeamsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.teamId,
      referencedTable: $db.teams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TeamsTableOrderingComposer(
            $db: $db,
            $table: $db.teams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get tripDate =>
      $composableBuilder(column: $table.tripDate, builder: (column) => column);

  GeneratedColumn<String> get participantIds => $composableBuilder(
    column: $table.participantIds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get settledAt =>
      $composableBuilder(column: $table.settledAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$TeamsTableAnnotationComposer get teamId {
    final $$TeamsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.teamId,
      referencedTable: $db.teams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TeamsTableAnnotationComposer(
            $db: $db,
            $table: $db.teams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> tripExpensesRefs<T extends Object>(
    Expression<T> Function($$TripExpensesTableAnnotationComposer a) f,
  ) {
    final $$TripExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripExpenses,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.tripExpenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripsTable,
          TripRow,
          $$TripsTableFilterComposer,
          $$TripsTableOrderingComposer,
          $$TripsTableAnnotationComposer,
          $$TripsTableCreateCompanionBuilder,
          $$TripsTableUpdateCompanionBuilder,
          (TripRow, $$TripsTableReferences),
          TripRow,
          PrefetchHooks Function({bool teamId, bool tripExpensesRefs})
        > {
  $$TripsTableTableManager(_$AppDatabase db, $TripsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> teamId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> tripDate = const Value.absent(),
                Value<String> participantIds = const Value.absent(),
                Value<DateTime?> settledAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripsCompanion(
                id: id,
                teamId: teamId,
                title: title,
                tripDate: tripDate,
                participantIds: participantIds,
                settledAt: settledAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String teamId,
                required String title,
                required DateTime tripDate,
                required String participantIds,
                Value<DateTime?> settledAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripsCompanion.insert(
                id: id,
                teamId: teamId,
                title: title,
                tripDate: tripDate,
                participantIds: participantIds,
                settledAt: settledAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TripsTable, TripRow>(table),
                  $$TripsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({teamId = false, tripExpensesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tripExpensesRefs) db.tripExpenses],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (teamId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.teamId,
                        referencedTable: $$TripsTableReferences._teamIdTable(
                          db,
                        ),
                        referencedColumn: $$TripsTableReferences
                            ._teamIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tripExpensesRefs)
                    await $_getPrefetchedDataByColumns<
                      TripRow,
                      $TripsTable,
                      TripExpenseRow,
                      $TripExpensesTable
                    >(
                      currentTable: table,
                      referencedTable: $$TripsTableReferences
                          ._tripExpensesRefsTable(db),
                      managerFromTypedResult: (p0) => $$TripsTableReferences(
                        db,
                        table,
                        p0,
                      ).tripExpensesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'trip_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TripsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripsTable,
      TripRow,
      $$TripsTableFilterComposer,
      $$TripsTableOrderingComposer,
      $$TripsTableAnnotationComposer,
      $$TripsTableCreateCompanionBuilder,
      $$TripsTableUpdateCompanionBuilder,
      (TripRow, $$TripsTableReferences),
      TripRow,
      PrefetchHooks Function({bool teamId, bool tripExpensesRefs})
    >;
typedef $$TripExpensesTableCreateCompanionBuilder =
    TripExpensesCompanion Function({
      required String id,
      required String tripId,
      required String description,
      required int amount,
      required String payerId,
      required String targetIds,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$TripExpensesTableUpdateCompanionBuilder =
    TripExpensesCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<String> description,
      Value<int> amount,
      Value<String> payerId,
      Value<String> targetIds,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$TripExpensesTableReferences
    extends BaseReferences<_$AppDatabase, $TripExpensesTable, TripExpenseRow> {
  $$TripExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TripsTable _tripIdTable(_$AppDatabase db) =>
      db.trips.createAlias('trip_expenses__trip_id__trips__id');

  $$TripsTableProcessedTableManager get tripId {
    final $_column = $_itemColumn<String>('trip_id')!;

    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TripExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $TripExpensesTable> {
  $$TripExpensesTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payerId => $composableBuilder(
    column: $table.payerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetIds => $composableBuilder(
    column: $table.targetIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $TripExpensesTable> {
  $$TripExpensesTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payerId => $composableBuilder(
    column: $table.payerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetIds => $composableBuilder(
    column: $table.targetIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripExpensesTable> {
  $$TripExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get payerId =>
      $composableBuilder(column: $table.payerId, builder: (column) => column);

  GeneratedColumn<String> get targetIds =>
      $composableBuilder(column: $table.targetIds, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripExpensesTable,
          TripExpenseRow,
          $$TripExpensesTableFilterComposer,
          $$TripExpensesTableOrderingComposer,
          $$TripExpensesTableAnnotationComposer,
          $$TripExpensesTableCreateCompanionBuilder,
          $$TripExpensesTableUpdateCompanionBuilder,
          (TripExpenseRow, $$TripExpensesTableReferences),
          TripExpenseRow,
          PrefetchHooks Function({bool tripId})
        > {
  $$TripExpensesTableTableManager(_$AppDatabase db, $TripExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> payerId = const Value.absent(),
                Value<String> targetIds = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripExpensesCompanion(
                id: id,
                tripId: tripId,
                description: description,
                amount: amount,
                payerId: payerId,
                targetIds: targetIds,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                required String description,
                required int amount,
                required String payerId,
                required String targetIds,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripExpensesCompanion.insert(
                id: id,
                tripId: tripId,
                description: description,
                amount: amount,
                payerId: payerId,
                targetIds: targetIds,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TripExpensesTable, TripExpenseRow>(table),
                  $$TripExpensesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tripId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tripId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.tripId,
                        referencedTable: $$TripExpensesTableReferences
                            ._tripIdTable(db),
                        referencedColumn: $$TripExpensesTableReferences
                            ._tripIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TripExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripExpensesTable,
      TripExpenseRow,
      $$TripExpensesTableFilterComposer,
      $$TripExpensesTableOrderingComposer,
      $$TripExpensesTableAnnotationComposer,
      $$TripExpensesTableCreateCompanionBuilder,
      $$TripExpensesTableUpdateCompanionBuilder,
      (TripExpenseRow, $$TripExpensesTableReferences),
      TripExpenseRow,
      PrefetchHooks Function({bool tripId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PointsTableTableManager get points =>
      $$PointsTableTableManager(_db, _db.points);
  $$CatchLogsTableTableManager get catchLogs =>
      $$CatchLogsTableTableManager(_db, _db.catchLogs);
  $$CatchItemsTableTableManager get catchItems =>
      $$CatchItemsTableTableManager(_db, _db.catchItems);
  $$PhotosTableTableManager get photos =>
      $$PhotosTableTableManager(_db, _db.photos);
  $$TracksTableTableManager get tracks =>
      $$TracksTableTableManager(_db, _db.tracks);
  $$TrackPointsTableTableManager get trackPoints =>
      $$TrackPointsTableTableManager(_db, _db.trackPoints);
  $$PointCandidatesTableTableManager get pointCandidates =>
      $$PointCandidatesTableTableManager(_db, _db.pointCandidates);
  $$ForecastCacheTableTableManager get forecastCache =>
      $$ForecastCacheTableTableManager(_db, _db.forecastCache);
  $$ShareImportsTableTableManager get shareImports =>
      $$ShareImportsTableTableManager(_db, _db.shareImports);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$TeamsTableTableManager get teams =>
      $$TeamsTableTableManager(_db, _db.teams);
  $$TeamMembersTableTableManager get teamMembers =>
      $$TeamMembersTableTableManager(_db, _db.teamMembers);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db, _db.trips);
  $$TripExpensesTableTableManager get tripExpenses =>
      $$TripExpensesTableTableManager(_db, _db.tripExpenses);
}
