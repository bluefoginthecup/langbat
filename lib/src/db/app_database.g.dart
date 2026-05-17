// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TermsTable extends Terms with TableInfo<$TermsTable, Term> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TermsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _frontTextMeta =
      const VerificationMeta('frontText');
  @override
  late final GeneratedColumn<String> frontText = GeneratedColumn<String>(
      'front_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _backTextMeta =
      const VerificationMeta('backText');
  @override
  late final GeneratedColumn<String> backText = GeneratedColumn<String>(
      'back_text', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _frontLanguageMeta =
      const VerificationMeta('frontLanguage');
  @override
  late final GeneratedColumn<String> frontLanguage = GeneratedColumn<String>(
      'front_language', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('es-ES'));
  static const VerificationMeta _backLanguageMeta =
      const VerificationMeta('backLanguage');
  @override
  late final GeneratedColumn<String> backLanguage = GeneratedColumn<String>(
      'back_language', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('ko-KR'));
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _audioFrontPathMeta =
      const VerificationMeta('audioFrontPath');
  @override
  late final GeneratedColumn<String> audioFrontPath = GeneratedColumn<String>(
      'audio_front_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _audioBackPathMeta =
      const VerificationMeta('audioBackPath');
  @override
  late final GeneratedColumn<String> audioBackPath = GeneratedColumn<String>(
      'audio_back_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tagsJsonMeta =
      const VerificationMeta('tagsJson');
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
      'tags_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        frontText,
        backText,
        note,
        frontLanguage,
        backLanguage,
        imagePath,
        audioFrontPath,
        audioBackPath,
        tagsJson,
        createdAt,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'terms';
  @override
  VerificationContext validateIntegrity(Insertable<Term> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('front_text')) {
      context.handle(_frontTextMeta,
          frontText.isAcceptableOrUnknown(data['front_text']!, _frontTextMeta));
    } else if (isInserting) {
      context.missing(_frontTextMeta);
    }
    if (data.containsKey('back_text')) {
      context.handle(_backTextMeta,
          backText.isAcceptableOrUnknown(data['back_text']!, _backTextMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('front_language')) {
      context.handle(
          _frontLanguageMeta,
          frontLanguage.isAcceptableOrUnknown(
              data['front_language']!, _frontLanguageMeta));
    }
    if (data.containsKey('back_language')) {
      context.handle(
          _backLanguageMeta,
          backLanguage.isAcceptableOrUnknown(
              data['back_language']!, _backLanguageMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('audio_front_path')) {
      context.handle(
          _audioFrontPathMeta,
          audioFrontPath.isAcceptableOrUnknown(
              data['audio_front_path']!, _audioFrontPathMeta));
    }
    if (data.containsKey('audio_back_path')) {
      context.handle(
          _audioBackPathMeta,
          audioBackPath.isAcceptableOrUnknown(
              data['audio_back_path']!, _audioBackPathMeta));
    }
    if (data.containsKey('tags_json')) {
      context.handle(_tagsJsonMeta,
          tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Term map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Term(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      frontText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}front_text'])!,
      backText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}back_text'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      frontLanguage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}front_language'])!,
      backLanguage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}back_language'])!,
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      audioFrontPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}audio_front_path']),
      audioBackPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}audio_back_path']),
      tagsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags_json']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $TermsTable createAlias(String alias) {
    return $TermsTable(attachedDatabase, alias);
  }
}

class Term extends DataClass implements Insertable<Term> {
  final String id;
  final String type;
  final String frontText;
  final String backText;
  final String note;
  final String frontLanguage;
  final String backLanguage;
  final String? imagePath;
  final String? audioFrontPath;
  final String? audioBackPath;
  final String? tagsJson;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  const Term(
      {required this.id,
      required this.type,
      required this.frontText,
      required this.backText,
      required this.note,
      required this.frontLanguage,
      required this.backLanguage,
      this.imagePath,
      this.audioFrontPath,
      this.audioBackPath,
      this.tagsJson,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['front_text'] = Variable<String>(frontText);
    map['back_text'] = Variable<String>(backText);
    map['note'] = Variable<String>(note);
    map['front_language'] = Variable<String>(frontLanguage);
    map['back_language'] = Variable<String>(backLanguage);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || audioFrontPath != null) {
      map['audio_front_path'] = Variable<String>(audioFrontPath);
    }
    if (!nullToAbsent || audioBackPath != null) {
      map['audio_back_path'] = Variable<String>(audioBackPath);
    }
    if (!nullToAbsent || tagsJson != null) {
      map['tags_json'] = Variable<String>(tagsJson);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    return map;
  }

  TermsCompanion toCompanion(bool nullToAbsent) {
    return TermsCompanion(
      id: Value(id),
      type: Value(type),
      frontText: Value(frontText),
      backText: Value(backText),
      note: Value(note),
      frontLanguage: Value(frontLanguage),
      backLanguage: Value(backLanguage),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      audioFrontPath: audioFrontPath == null && nullToAbsent
          ? const Value.absent()
          : Value(audioFrontPath),
      audioBackPath: audioBackPath == null && nullToAbsent
          ? const Value.absent()
          : Value(audioBackPath),
      tagsJson: tagsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(tagsJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Term.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Term(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      frontText: serializer.fromJson<String>(json['frontText']),
      backText: serializer.fromJson<String>(json['backText']),
      note: serializer.fromJson<String>(json['note']),
      frontLanguage: serializer.fromJson<String>(json['frontLanguage']),
      backLanguage: serializer.fromJson<String>(json['backLanguage']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      audioFrontPath: serializer.fromJson<String?>(json['audioFrontPath']),
      audioBackPath: serializer.fromJson<String?>(json['audioBackPath']),
      tagsJson: serializer.fromJson<String?>(json['tagsJson']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'frontText': serializer.toJson<String>(frontText),
      'backText': serializer.toJson<String>(backText),
      'note': serializer.toJson<String>(note),
      'frontLanguage': serializer.toJson<String>(frontLanguage),
      'backLanguage': serializer.toJson<String>(backLanguage),
      'imagePath': serializer.toJson<String?>(imagePath),
      'audioFrontPath': serializer.toJson<String?>(audioFrontPath),
      'audioBackPath': serializer.toJson<String?>(audioBackPath),
      'tagsJson': serializer.toJson<String?>(tagsJson),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
    };
  }

  Term copyWith(
          {String? id,
          String? type,
          String? frontText,
          String? backText,
          String? note,
          String? frontLanguage,
          String? backLanguage,
          Value<String?> imagePath = const Value.absent(),
          Value<String?> audioFrontPath = const Value.absent(),
          Value<String?> audioBackPath = const Value.absent(),
          Value<String?> tagsJson = const Value.absent(),
          String? createdAt,
          String? updatedAt,
          Value<String?> deletedAt = const Value.absent()}) =>
      Term(
        id: id ?? this.id,
        type: type ?? this.type,
        frontText: frontText ?? this.frontText,
        backText: backText ?? this.backText,
        note: note ?? this.note,
        frontLanguage: frontLanguage ?? this.frontLanguage,
        backLanguage: backLanguage ?? this.backLanguage,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        audioFrontPath:
            audioFrontPath.present ? audioFrontPath.value : this.audioFrontPath,
        audioBackPath:
            audioBackPath.present ? audioBackPath.value : this.audioBackPath,
        tagsJson: tagsJson.present ? tagsJson.value : this.tagsJson,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Term copyWithCompanion(TermsCompanion data) {
    return Term(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      frontText: data.frontText.present ? data.frontText.value : this.frontText,
      backText: data.backText.present ? data.backText.value : this.backText,
      note: data.note.present ? data.note.value : this.note,
      frontLanguage: data.frontLanguage.present
          ? data.frontLanguage.value
          : this.frontLanguage,
      backLanguage: data.backLanguage.present
          ? data.backLanguage.value
          : this.backLanguage,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      audioFrontPath: data.audioFrontPath.present
          ? data.audioFrontPath.value
          : this.audioFrontPath,
      audioBackPath: data.audioBackPath.present
          ? data.audioBackPath.value
          : this.audioBackPath,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Term(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('frontText: $frontText, ')
          ..write('backText: $backText, ')
          ..write('note: $note, ')
          ..write('frontLanguage: $frontLanguage, ')
          ..write('backLanguage: $backLanguage, ')
          ..write('imagePath: $imagePath, ')
          ..write('audioFrontPath: $audioFrontPath, ')
          ..write('audioBackPath: $audioBackPath, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      type,
      frontText,
      backText,
      note,
      frontLanguage,
      backLanguage,
      imagePath,
      audioFrontPath,
      audioBackPath,
      tagsJson,
      createdAt,
      updatedAt,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Term &&
          other.id == this.id &&
          other.type == this.type &&
          other.frontText == this.frontText &&
          other.backText == this.backText &&
          other.note == this.note &&
          other.frontLanguage == this.frontLanguage &&
          other.backLanguage == this.backLanguage &&
          other.imagePath == this.imagePath &&
          other.audioFrontPath == this.audioFrontPath &&
          other.audioBackPath == this.audioBackPath &&
          other.tagsJson == this.tagsJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TermsCompanion extends UpdateCompanion<Term> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> frontText;
  final Value<String> backText;
  final Value<String> note;
  final Value<String> frontLanguage;
  final Value<String> backLanguage;
  final Value<String?> imagePath;
  final Value<String?> audioFrontPath;
  final Value<String?> audioBackPath;
  final Value<String?> tagsJson;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<int> rowid;
  const TermsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.frontText = const Value.absent(),
    this.backText = const Value.absent(),
    this.note = const Value.absent(),
    this.frontLanguage = const Value.absent(),
    this.backLanguage = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.audioFrontPath = const Value.absent(),
    this.audioBackPath = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TermsCompanion.insert({
    required String id,
    required String type,
    required String frontText,
    this.backText = const Value.absent(),
    this.note = const Value.absent(),
    this.frontLanguage = const Value.absent(),
    this.backLanguage = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.audioFrontPath = const Value.absent(),
    this.audioBackPath = const Value.absent(),
    this.tagsJson = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        frontText = Value(frontText),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Term> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? frontText,
    Expression<String>? backText,
    Expression<String>? note,
    Expression<String>? frontLanguage,
    Expression<String>? backLanguage,
    Expression<String>? imagePath,
    Expression<String>? audioFrontPath,
    Expression<String>? audioBackPath,
    Expression<String>? tagsJson,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (frontText != null) 'front_text': frontText,
      if (backText != null) 'back_text': backText,
      if (note != null) 'note': note,
      if (frontLanguage != null) 'front_language': frontLanguage,
      if (backLanguage != null) 'back_language': backLanguage,
      if (imagePath != null) 'image_path': imagePath,
      if (audioFrontPath != null) 'audio_front_path': audioFrontPath,
      if (audioBackPath != null) 'audio_back_path': audioBackPath,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TermsCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<String>? frontText,
      Value<String>? backText,
      Value<String>? note,
      Value<String>? frontLanguage,
      Value<String>? backLanguage,
      Value<String?>? imagePath,
      Value<String?>? audioFrontPath,
      Value<String?>? audioBackPath,
      Value<String?>? tagsJson,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<String?>? deletedAt,
      Value<int>? rowid}) {
    return TermsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      frontText: frontText ?? this.frontText,
      backText: backText ?? this.backText,
      note: note ?? this.note,
      frontLanguage: frontLanguage ?? this.frontLanguage,
      backLanguage: backLanguage ?? this.backLanguage,
      imagePath: imagePath ?? this.imagePath,
      audioFrontPath: audioFrontPath ?? this.audioFrontPath,
      audioBackPath: audioBackPath ?? this.audioBackPath,
      tagsJson: tagsJson ?? this.tagsJson,
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
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (frontText.present) {
      map['front_text'] = Variable<String>(frontText.value);
    }
    if (backText.present) {
      map['back_text'] = Variable<String>(backText.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (frontLanguage.present) {
      map['front_language'] = Variable<String>(frontLanguage.value);
    }
    if (backLanguage.present) {
      map['back_language'] = Variable<String>(backLanguage.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (audioFrontPath.present) {
      map['audio_front_path'] = Variable<String>(audioFrontPath.value);
    }
    if (audioBackPath.present) {
      map['audio_back_path'] = Variable<String>(audioBackPath.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TermsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('frontText: $frontText, ')
          ..write('backText: $backText, ')
          ..write('note: $note, ')
          ..write('frontLanguage: $frontLanguage, ')
          ..write('backLanguage: $backLanguage, ')
          ..write('imagePath: $imagePath, ')
          ..write('audioFrontPath: $audioFrontPath, ')
          ..write('audioBackPath: $audioBackPath, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FlashcardSetsTable extends FlashcardSets
    with TableInfo<$FlashcardSetsTable, FlashcardSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlashcardSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, description, createdAt, updatedAt, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flashcard_sets';
  @override
  VerificationContext validateIntegrity(Insertable<FlashcardSet> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FlashcardSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FlashcardSet(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $FlashcardSetsTable createAlias(String alias) {
    return $FlashcardSetsTable(attachedDatabase, alias);
  }
}

class FlashcardSet extends DataClass implements Insertable<FlashcardSet> {
  final String id;
  final String title;
  final String description;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  const FlashcardSet(
      {required this.id,
      required this.title,
      required this.description,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    return map;
  }

  FlashcardSetsCompanion toCompanion(bool nullToAbsent) {
    return FlashcardSetsCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory FlashcardSet.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FlashcardSet(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
    };
  }

  FlashcardSet copyWith(
          {String? id,
          String? title,
          String? description,
          String? createdAt,
          String? updatedAt,
          Value<String?> deletedAt = const Value.absent()}) =>
      FlashcardSet(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  FlashcardSet copyWithCompanion(FlashcardSetsCompanion data) {
    return FlashcardSet(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardSet(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, description, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FlashcardSet &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class FlashcardSetsCompanion extends UpdateCompanion<FlashcardSet> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<int> rowid;
  const FlashcardSetsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FlashcardSetsCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<FlashcardSet> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FlashcardSetsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? description,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<String?>? deletedAt,
      Value<int>? rowid}) {
    return FlashcardSetsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
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
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardSetsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FlashcardSetItemsTable extends FlashcardSetItems
    with TableInfo<$FlashcardSetItemsTable, FlashcardSetItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlashcardSetItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _setIdMeta = const VerificationMeta('setId');
  @override
  late final GeneratedColumn<String> setId = GeneratedColumn<String>(
      'set_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES flashcard_sets (id) ON DELETE CASCADE'));
  static const VerificationMeta _termIdMeta = const VerificationMeta('termId');
  @override
  late final GeneratedColumn<String> termId = GeneratedColumn<String>(
      'term_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES terms (id) ON DELETE CASCADE'));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, setId, termId, sortOrder, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flashcard_set_items';
  @override
  VerificationContext validateIntegrity(Insertable<FlashcardSetItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('set_id')) {
      context.handle(
          _setIdMeta, setId.isAcceptableOrUnknown(data['set_id']!, _setIdMeta));
    } else if (isInserting) {
      context.missing(_setIdMeta);
    }
    if (data.containsKey('term_id')) {
      context.handle(_termIdMeta,
          termId.isAcceptableOrUnknown(data['term_id']!, _termIdMeta));
    } else if (isInserting) {
      context.missing(_termIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FlashcardSetItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FlashcardSetItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      setId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}set_id'])!,
      termId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}term_id'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $FlashcardSetItemsTable createAlias(String alias) {
    return $FlashcardSetItemsTable(attachedDatabase, alias);
  }
}

class FlashcardSetItem extends DataClass
    implements Insertable<FlashcardSetItem> {
  final String id;
  final String setId;
  final String termId;
  final int sortOrder;
  final String createdAt;
  const FlashcardSetItem(
      {required this.id,
      required this.setId,
      required this.termId,
      required this.sortOrder,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['set_id'] = Variable<String>(setId);
    map['term_id'] = Variable<String>(termId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  FlashcardSetItemsCompanion toCompanion(bool nullToAbsent) {
    return FlashcardSetItemsCompanion(
      id: Value(id),
      setId: Value(setId),
      termId: Value(termId),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory FlashcardSetItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FlashcardSetItem(
      id: serializer.fromJson<String>(json['id']),
      setId: serializer.fromJson<String>(json['setId']),
      termId: serializer.fromJson<String>(json['termId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'setId': serializer.toJson<String>(setId),
      'termId': serializer.toJson<String>(termId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  FlashcardSetItem copyWith(
          {String? id,
          String? setId,
          String? termId,
          int? sortOrder,
          String? createdAt}) =>
      FlashcardSetItem(
        id: id ?? this.id,
        setId: setId ?? this.setId,
        termId: termId ?? this.termId,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
      );
  FlashcardSetItem copyWithCompanion(FlashcardSetItemsCompanion data) {
    return FlashcardSetItem(
      id: data.id.present ? data.id.value : this.id,
      setId: data.setId.present ? data.setId.value : this.setId,
      termId: data.termId.present ? data.termId.value : this.termId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardSetItem(')
          ..write('id: $id, ')
          ..write('setId: $setId, ')
          ..write('termId: $termId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, setId, termId, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FlashcardSetItem &&
          other.id == this.id &&
          other.setId == this.setId &&
          other.termId == this.termId &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class FlashcardSetItemsCompanion extends UpdateCompanion<FlashcardSetItem> {
  final Value<String> id;
  final Value<String> setId;
  final Value<String> termId;
  final Value<int> sortOrder;
  final Value<String> createdAt;
  final Value<int> rowid;
  const FlashcardSetItemsCompanion({
    this.id = const Value.absent(),
    this.setId = const Value.absent(),
    this.termId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FlashcardSetItemsCompanion.insert({
    required String id,
    required String setId,
    required String termId,
    this.sortOrder = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        setId = Value(setId),
        termId = Value(termId),
        createdAt = Value(createdAt);
  static Insertable<FlashcardSetItem> custom({
    Expression<String>? id,
    Expression<String>? setId,
    Expression<String>? termId,
    Expression<int>? sortOrder,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (setId != null) 'set_id': setId,
      if (termId != null) 'term_id': termId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FlashcardSetItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? setId,
      Value<String>? termId,
      Value<int>? sortOrder,
      Value<String>? createdAt,
      Value<int>? rowid}) {
    return FlashcardSetItemsCompanion(
      id: id ?? this.id,
      setId: setId ?? this.setId,
      termId: termId ?? this.termId,
      sortOrder: sortOrder ?? this.sortOrder,
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
    if (setId.present) {
      map['set_id'] = Variable<String>(setId.value);
    }
    if (termId.present) {
      map['term_id'] = Variable<String>(termId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardSetItemsCompanion(')
          ..write('id: $id, ')
          ..write('setId: $setId, ')
          ..write('termId: $termId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudySessionsTable extends StudySessions
    with TableInfo<$StudySessionsTable, StudySession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudySessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _setIdMeta = const VerificationMeta('setId');
  @override
  late final GeneratedColumn<String> setId = GeneratedColumn<String>(
      'set_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<String> startedAt = GeneratedColumn<String>(
      'started_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _endedAtMeta =
      const VerificationMeta('endedAt');
  @override
  late final GeneratedColumn<String> endedAt = GeneratedColumn<String>(
      'ended_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cardsSeenMeta =
      const VerificationMeta('cardsSeen');
  @override
  late final GeneratedColumn<int> cardsSeen = GeneratedColumn<int>(
      'cards_seen', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _pointsEarnedMeta =
      const VerificationMeta('pointsEarned');
  @override
  late final GeneratedColumn<int> pointsEarned = GeneratedColumn<int>(
      'points_earned', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, setId, startedAt, endedAt, cardsSeen, pointsEarned];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<StudySession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('set_id')) {
      context.handle(
          _setIdMeta, setId.isAcceptableOrUnknown(data['set_id']!, _setIdMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(_endedAtMeta,
          endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta));
    }
    if (data.containsKey('cards_seen')) {
      context.handle(_cardsSeenMeta,
          cardsSeen.isAcceptableOrUnknown(data['cards_seen']!, _cardsSeenMeta));
    }
    if (data.containsKey('points_earned')) {
      context.handle(
          _pointsEarnedMeta,
          pointsEarned.isAcceptableOrUnknown(
              data['points_earned']!, _pointsEarnedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudySession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudySession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      setId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}set_id']),
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}started_at'])!,
      endedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ended_at']),
      cardsSeen: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cards_seen'])!,
      pointsEarned: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}points_earned'])!,
    );
  }

  @override
  $StudySessionsTable createAlias(String alias) {
    return $StudySessionsTable(attachedDatabase, alias);
  }
}

class StudySession extends DataClass implements Insertable<StudySession> {
  final String id;
  final String? setId;
  final String startedAt;
  final String? endedAt;
  final int cardsSeen;
  final int pointsEarned;
  const StudySession(
      {required this.id,
      this.setId,
      required this.startedAt,
      this.endedAt,
      required this.cardsSeen,
      required this.pointsEarned});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || setId != null) {
      map['set_id'] = Variable<String>(setId);
    }
    map['started_at'] = Variable<String>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<String>(endedAt);
    }
    map['cards_seen'] = Variable<int>(cardsSeen);
    map['points_earned'] = Variable<int>(pointsEarned);
    return map;
  }

  StudySessionsCompanion toCompanion(bool nullToAbsent) {
    return StudySessionsCompanion(
      id: Value(id),
      setId:
          setId == null && nullToAbsent ? const Value.absent() : Value(setId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      cardsSeen: Value(cardsSeen),
      pointsEarned: Value(pointsEarned),
    );
  }

  factory StudySession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudySession(
      id: serializer.fromJson<String>(json['id']),
      setId: serializer.fromJson<String?>(json['setId']),
      startedAt: serializer.fromJson<String>(json['startedAt']),
      endedAt: serializer.fromJson<String?>(json['endedAt']),
      cardsSeen: serializer.fromJson<int>(json['cardsSeen']),
      pointsEarned: serializer.fromJson<int>(json['pointsEarned']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'setId': serializer.toJson<String?>(setId),
      'startedAt': serializer.toJson<String>(startedAt),
      'endedAt': serializer.toJson<String?>(endedAt),
      'cardsSeen': serializer.toJson<int>(cardsSeen),
      'pointsEarned': serializer.toJson<int>(pointsEarned),
    };
  }

  StudySession copyWith(
          {String? id,
          Value<String?> setId = const Value.absent(),
          String? startedAt,
          Value<String?> endedAt = const Value.absent(),
          int? cardsSeen,
          int? pointsEarned}) =>
      StudySession(
        id: id ?? this.id,
        setId: setId.present ? setId.value : this.setId,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt.present ? endedAt.value : this.endedAt,
        cardsSeen: cardsSeen ?? this.cardsSeen,
        pointsEarned: pointsEarned ?? this.pointsEarned,
      );
  StudySession copyWithCompanion(StudySessionsCompanion data) {
    return StudySession(
      id: data.id.present ? data.id.value : this.id,
      setId: data.setId.present ? data.setId.value : this.setId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      cardsSeen: data.cardsSeen.present ? data.cardsSeen.value : this.cardsSeen,
      pointsEarned: data.pointsEarned.present
          ? data.pointsEarned.value
          : this.pointsEarned,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudySession(')
          ..write('id: $id, ')
          ..write('setId: $setId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('cardsSeen: $cardsSeen, ')
          ..write('pointsEarned: $pointsEarned')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, setId, startedAt, endedAt, cardsSeen, pointsEarned);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudySession &&
          other.id == this.id &&
          other.setId == this.setId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.cardsSeen == this.cardsSeen &&
          other.pointsEarned == this.pointsEarned);
}

class StudySessionsCompanion extends UpdateCompanion<StudySession> {
  final Value<String> id;
  final Value<String?> setId;
  final Value<String> startedAt;
  final Value<String?> endedAt;
  final Value<int> cardsSeen;
  final Value<int> pointsEarned;
  final Value<int> rowid;
  const StudySessionsCompanion({
    this.id = const Value.absent(),
    this.setId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.cardsSeen = const Value.absent(),
    this.pointsEarned = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudySessionsCompanion.insert({
    required String id,
    this.setId = const Value.absent(),
    required String startedAt,
    this.endedAt = const Value.absent(),
    this.cardsSeen = const Value.absent(),
    this.pointsEarned = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        startedAt = Value(startedAt);
  static Insertable<StudySession> custom({
    Expression<String>? id,
    Expression<String>? setId,
    Expression<String>? startedAt,
    Expression<String>? endedAt,
    Expression<int>? cardsSeen,
    Expression<int>? pointsEarned,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (setId != null) 'set_id': setId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (cardsSeen != null) 'cards_seen': cardsSeen,
      if (pointsEarned != null) 'points_earned': pointsEarned,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudySessionsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? setId,
      Value<String>? startedAt,
      Value<String?>? endedAt,
      Value<int>? cardsSeen,
      Value<int>? pointsEarned,
      Value<int>? rowid}) {
    return StudySessionsCompanion(
      id: id ?? this.id,
      setId: setId ?? this.setId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      cardsSeen: cardsSeen ?? this.cardsSeen,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (setId.present) {
      map['set_id'] = Variable<String>(setId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<String>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<String>(endedAt.value);
    }
    if (cardsSeen.present) {
      map['cards_seen'] = Variable<int>(cardsSeen.value);
    }
    if (pointsEarned.present) {
      map['points_earned'] = Variable<int>(pointsEarned.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudySessionsCompanion(')
          ..write('id: $id, ')
          ..write('setId: $setId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('cardsSeen: $cardsSeen, ')
          ..write('pointsEarned: $pointsEarned, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudyEventsTable extends StudyEvents
    with TableInfo<$StudyEventsTable, StudyEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudyEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES study_sessions (id) ON DELETE CASCADE'));
  static const VerificationMeta _termIdMeta = const VerificationMeta('termId');
  @override
  late final GeneratedColumn<String> termId = GeneratedColumn<String>(
      'term_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
      'result', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('seen'));
  static const VerificationMeta _shownAtMeta =
      const VerificationMeta('shownAt');
  @override
  late final GeneratedColumn<String> shownAt = GeneratedColumn<String>(
      'shown_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, sessionId, termId, result, shownAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_events';
  @override
  VerificationContext validateIntegrity(Insertable<StudyEvent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('term_id')) {
      context.handle(_termIdMeta,
          termId.isAcceptableOrUnknown(data['term_id']!, _termIdMeta));
    }
    if (data.containsKey('result')) {
      context.handle(_resultMeta,
          result.isAcceptableOrUnknown(data['result']!, _resultMeta));
    }
    if (data.containsKey('shown_at')) {
      context.handle(_shownAtMeta,
          shownAt.isAcceptableOrUnknown(data['shown_at']!, _shownAtMeta));
    } else if (isInserting) {
      context.missing(_shownAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudyEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudyEvent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id'])!,
      termId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}term_id']),
      result: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}result'])!,
      shownAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shown_at'])!,
    );
  }

  @override
  $StudyEventsTable createAlias(String alias) {
    return $StudyEventsTable(attachedDatabase, alias);
  }
}

class StudyEvent extends DataClass implements Insertable<StudyEvent> {
  final String id;
  final String sessionId;
  final String? termId;
  final String result;
  final String shownAt;
  const StudyEvent(
      {required this.id,
      required this.sessionId,
      this.termId,
      required this.result,
      required this.shownAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    if (!nullToAbsent || termId != null) {
      map['term_id'] = Variable<String>(termId);
    }
    map['result'] = Variable<String>(result);
    map['shown_at'] = Variable<String>(shownAt);
    return map;
  }

  StudyEventsCompanion toCompanion(bool nullToAbsent) {
    return StudyEventsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      termId:
          termId == null && nullToAbsent ? const Value.absent() : Value(termId),
      result: Value(result),
      shownAt: Value(shownAt),
    );
  }

  factory StudyEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudyEvent(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      termId: serializer.fromJson<String?>(json['termId']),
      result: serializer.fromJson<String>(json['result']),
      shownAt: serializer.fromJson<String>(json['shownAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'termId': serializer.toJson<String?>(termId),
      'result': serializer.toJson<String>(result),
      'shownAt': serializer.toJson<String>(shownAt),
    };
  }

  StudyEvent copyWith(
          {String? id,
          String? sessionId,
          Value<String?> termId = const Value.absent(),
          String? result,
          String? shownAt}) =>
      StudyEvent(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        termId: termId.present ? termId.value : this.termId,
        result: result ?? this.result,
        shownAt: shownAt ?? this.shownAt,
      );
  StudyEvent copyWithCompanion(StudyEventsCompanion data) {
    return StudyEvent(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      termId: data.termId.present ? data.termId.value : this.termId,
      result: data.result.present ? data.result.value : this.result,
      shownAt: data.shownAt.present ? data.shownAt.value : this.shownAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudyEvent(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('termId: $termId, ')
          ..write('result: $result, ')
          ..write('shownAt: $shownAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, termId, result, shownAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudyEvent &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.termId == this.termId &&
          other.result == this.result &&
          other.shownAt == this.shownAt);
}

class StudyEventsCompanion extends UpdateCompanion<StudyEvent> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String?> termId;
  final Value<String> result;
  final Value<String> shownAt;
  final Value<int> rowid;
  const StudyEventsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.termId = const Value.absent(),
    this.result = const Value.absent(),
    this.shownAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudyEventsCompanion.insert({
    required String id,
    required String sessionId,
    this.termId = const Value.absent(),
    this.result = const Value.absent(),
    required String shownAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sessionId = Value(sessionId),
        shownAt = Value(shownAt);
  static Insertable<StudyEvent> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? termId,
    Expression<String>? result,
    Expression<String>? shownAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (termId != null) 'term_id': termId,
      if (result != null) 'result': result,
      if (shownAt != null) 'shown_at': shownAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudyEventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? sessionId,
      Value<String?>? termId,
      Value<String>? result,
      Value<String>? shownAt,
      Value<int>? rowid}) {
    return StudyEventsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      termId: termId ?? this.termId,
      result: result ?? this.result,
      shownAt: shownAt ?? this.shownAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (termId.present) {
      map['term_id'] = Variable<String>(termId.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (shownAt.present) {
      map['shown_at'] = Variable<String>(shownAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudyEventsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('termId: $termId, ')
          ..write('result: $result, ')
          ..write('shownAt: $shownAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PointLogsTable extends PointLogs
    with TableInfo<$PointLogsTable, PointLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PointLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, amount, type, description, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'point_logs';
  @override
  VerificationContext validateIntegrity(Insertable<PointLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PointLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PointLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PointLogsTable createAlias(String alias) {
    return $PointLogsTable(attachedDatabase, alias);
  }
}

class PointLog extends DataClass implements Insertable<PointLog> {
  final String id;
  final int amount;
  final String type;
  final String description;
  final String createdAt;
  const PointLog(
      {required this.id,
      required this.amount,
      required this.type,
      required this.description,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['amount'] = Variable<int>(amount);
    map['type'] = Variable<String>(type);
    map['description'] = Variable<String>(description);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  PointLogsCompanion toCompanion(bool nullToAbsent) {
    return PointLogsCompanion(
      id: Value(id),
      amount: Value(amount),
      type: Value(type),
      description: Value(description),
      createdAt: Value(createdAt),
    );
  }

  factory PointLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PointLog(
      id: serializer.fromJson<String>(json['id']),
      amount: serializer.fromJson<int>(json['amount']),
      type: serializer.fromJson<String>(json['type']),
      description: serializer.fromJson<String>(json['description']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'amount': serializer.toJson<int>(amount),
      'type': serializer.toJson<String>(type),
      'description': serializer.toJson<String>(description),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  PointLog copyWith(
          {String? id,
          int? amount,
          String? type,
          String? description,
          String? createdAt}) =>
      PointLog(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
      );
  PointLog copyWithCompanion(PointLogsCompanion data) {
    return PointLog(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      type: data.type.present ? data.type.value : this.type,
      description:
          data.description.present ? data.description.value : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PointLog(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, amount, type, description, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PointLog &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.type == this.type &&
          other.description == this.description &&
          other.createdAt == this.createdAt);
}

class PointLogsCompanion extends UpdateCompanion<PointLog> {
  final Value<String> id;
  final Value<int> amount;
  final Value<String> type;
  final Value<String> description;
  final Value<String> createdAt;
  final Value<int> rowid;
  const PointLogsCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.type = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PointLogsCompanion.insert({
    required String id,
    required int amount,
    required String type,
    this.description = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        amount = Value(amount),
        type = Value(type),
        createdAt = Value(createdAt);
  static Insertable<PointLog> custom({
    Expression<String>? id,
    Expression<int>? amount,
    Expression<String>? type,
    Expression<String>? description,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (type != null) 'type': type,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PointLogsCompanion copyWith(
      {Value<String>? id,
      Value<int>? amount,
      Value<String>? type,
      Value<String>? description,
      Value<String>? createdAt,
      Value<int>? rowid}) {
    return PointLogsCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
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
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PointLogsCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GardenCellsTable extends GardenCells
    with TableInfo<$GardenCellsTable, GardenCell> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GardenCellsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rowMeta = const VerificationMeta('row');
  @override
  late final GeneratedColumn<int> row = GeneratedColumn<int>(
      'row', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _colMeta = const VerificationMeta('col');
  @override
  late final GeneratedColumn<int> col = GeneratedColumn<int>(
      'col', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _itemTypeMeta =
      const VerificationMeta('itemType');
  @override
  late final GeneratedColumn<String> itemType = GeneratedColumn<String>(
      'item_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _growthMeta = const VerificationMeta('growth');
  @override
  late final GeneratedColumn<int> growth = GeneratedColumn<int>(
      'growth', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, row, col, itemType, growth, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'garden_cells';
  @override
  VerificationContext validateIntegrity(Insertable<GardenCell> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('row')) {
      context.handle(
          _rowMeta, row.isAcceptableOrUnknown(data['row']!, _rowMeta));
    } else if (isInserting) {
      context.missing(_rowMeta);
    }
    if (data.containsKey('col')) {
      context.handle(
          _colMeta, col.isAcceptableOrUnknown(data['col']!, _colMeta));
    } else if (isInserting) {
      context.missing(_colMeta);
    }
    if (data.containsKey('item_type')) {
      context.handle(_itemTypeMeta,
          itemType.isAcceptableOrUnknown(data['item_type']!, _itemTypeMeta));
    } else if (isInserting) {
      context.missing(_itemTypeMeta);
    }
    if (data.containsKey('growth')) {
      context.handle(_growthMeta,
          growth.isAcceptableOrUnknown(data['growth']!, _growthMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GardenCell map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GardenCell(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      row: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}row'])!,
      col: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}col'])!,
      itemType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_type'])!,
      growth: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}growth'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $GardenCellsTable createAlias(String alias) {
    return $GardenCellsTable(attachedDatabase, alias);
  }
}

class GardenCell extends DataClass implements Insertable<GardenCell> {
  final String id;
  final int row;
  final int col;
  final String itemType;
  final int growth;
  final String updatedAt;
  const GardenCell(
      {required this.id,
      required this.row,
      required this.col,
      required this.itemType,
      required this.growth,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['row'] = Variable<int>(row);
    map['col'] = Variable<int>(col);
    map['item_type'] = Variable<String>(itemType);
    map['growth'] = Variable<int>(growth);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  GardenCellsCompanion toCompanion(bool nullToAbsent) {
    return GardenCellsCompanion(
      id: Value(id),
      row: Value(row),
      col: Value(col),
      itemType: Value(itemType),
      growth: Value(growth),
      updatedAt: Value(updatedAt),
    );
  }

  factory GardenCell.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GardenCell(
      id: serializer.fromJson<String>(json['id']),
      row: serializer.fromJson<int>(json['row']),
      col: serializer.fromJson<int>(json['col']),
      itemType: serializer.fromJson<String>(json['itemType']),
      growth: serializer.fromJson<int>(json['growth']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'row': serializer.toJson<int>(row),
      'col': serializer.toJson<int>(col),
      'itemType': serializer.toJson<String>(itemType),
      'growth': serializer.toJson<int>(growth),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  GardenCell copyWith(
          {String? id,
          int? row,
          int? col,
          String? itemType,
          int? growth,
          String? updatedAt}) =>
      GardenCell(
        id: id ?? this.id,
        row: row ?? this.row,
        col: col ?? this.col,
        itemType: itemType ?? this.itemType,
        growth: growth ?? this.growth,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  GardenCell copyWithCompanion(GardenCellsCompanion data) {
    return GardenCell(
      id: data.id.present ? data.id.value : this.id,
      row: data.row.present ? data.row.value : this.row,
      col: data.col.present ? data.col.value : this.col,
      itemType: data.itemType.present ? data.itemType.value : this.itemType,
      growth: data.growth.present ? data.growth.value : this.growth,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GardenCell(')
          ..write('id: $id, ')
          ..write('row: $row, ')
          ..write('col: $col, ')
          ..write('itemType: $itemType, ')
          ..write('growth: $growth, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, row, col, itemType, growth, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GardenCell &&
          other.id == this.id &&
          other.row == this.row &&
          other.col == this.col &&
          other.itemType == this.itemType &&
          other.growth == this.growth &&
          other.updatedAt == this.updatedAt);
}

class GardenCellsCompanion extends UpdateCompanion<GardenCell> {
  final Value<String> id;
  final Value<int> row;
  final Value<int> col;
  final Value<String> itemType;
  final Value<int> growth;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const GardenCellsCompanion({
    this.id = const Value.absent(),
    this.row = const Value.absent(),
    this.col = const Value.absent(),
    this.itemType = const Value.absent(),
    this.growth = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GardenCellsCompanion.insert({
    required String id,
    required int row,
    required int col,
    required String itemType,
    this.growth = const Value.absent(),
    required String updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        row = Value(row),
        col = Value(col),
        itemType = Value(itemType),
        updatedAt = Value(updatedAt);
  static Insertable<GardenCell> custom({
    Expression<String>? id,
    Expression<int>? row,
    Expression<int>? col,
    Expression<String>? itemType,
    Expression<int>? growth,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (row != null) 'row': row,
      if (col != null) 'col': col,
      if (itemType != null) 'item_type': itemType,
      if (growth != null) 'growth': growth,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GardenCellsCompanion copyWith(
      {Value<String>? id,
      Value<int>? row,
      Value<int>? col,
      Value<String>? itemType,
      Value<int>? growth,
      Value<String>? updatedAt,
      Value<int>? rowid}) {
    return GardenCellsCompanion(
      id: id ?? this.id,
      row: row ?? this.row,
      col: col ?? this.col,
      itemType: itemType ?? this.itemType,
      growth: growth ?? this.growth,
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
    if (row.present) {
      map['row'] = Variable<int>(row.value);
    }
    if (col.present) {
      map['col'] = Variable<int>(col.value);
    }
    if (itemType.present) {
      map['item_type'] = Variable<String>(itemType.value);
    }
    if (growth.present) {
      map['growth'] = Variable<int>(growth.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GardenCellsCompanion(')
          ..write('id: $id, ')
          ..write('row: $row, ')
          ..write('col: $col, ')
          ..write('itemType: $itemType, ')
          ..write('growth: $growth, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryItemsTable extends InventoryItems
    with TableInfo<$InventoryItemsTable, InventoryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemTypeMeta =
      const VerificationMeta('itemType');
  @override
  late final GeneratedColumn<String> itemType = GeneratedColumn<String>(
      'item_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
      'count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [itemType, count, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_items';
  @override
  VerificationContext validateIntegrity(Insertable<InventoryItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_type')) {
      context.handle(_itemTypeMeta,
          itemType.isAcceptableOrUnknown(data['item_type']!, _itemTypeMeta));
    } else if (isInserting) {
      context.missing(_itemTypeMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
          _countMeta, count.isAcceptableOrUnknown(data['count']!, _countMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemType};
  @override
  InventoryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryItem(
      itemType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_type'])!,
      count: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}count'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $InventoryItemsTable createAlias(String alias) {
    return $InventoryItemsTable(attachedDatabase, alias);
  }
}

class InventoryItem extends DataClass implements Insertable<InventoryItem> {
  final String itemType;
  final int count;
  final String updatedAt;
  const InventoryItem(
      {required this.itemType, required this.count, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_type'] = Variable<String>(itemType);
    map['count'] = Variable<int>(count);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  InventoryItemsCompanion toCompanion(bool nullToAbsent) {
    return InventoryItemsCompanion(
      itemType: Value(itemType),
      count: Value(count),
      updatedAt: Value(updatedAt),
    );
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryItem(
      itemType: serializer.fromJson<String>(json['itemType']),
      count: serializer.fromJson<int>(json['count']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemType': serializer.toJson<String>(itemType),
      'count': serializer.toJson<int>(count),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  InventoryItem copyWith({String? itemType, int? count, String? updatedAt}) =>
      InventoryItem(
        itemType: itemType ?? this.itemType,
        count: count ?? this.count,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  InventoryItem copyWithCompanion(InventoryItemsCompanion data) {
    return InventoryItem(
      itemType: data.itemType.present ? data.itemType.value : this.itemType,
      count: data.count.present ? data.count.value : this.count,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryItem(')
          ..write('itemType: $itemType, ')
          ..write('count: $count, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(itemType, count, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryItem &&
          other.itemType == this.itemType &&
          other.count == this.count &&
          other.updatedAt == this.updatedAt);
}

class InventoryItemsCompanion extends UpdateCompanion<InventoryItem> {
  final Value<String> itemType;
  final Value<int> count;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const InventoryItemsCompanion({
    this.itemType = const Value.absent(),
    this.count = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryItemsCompanion.insert({
    required String itemType,
    this.count = const Value.absent(),
    required String updatedAt,
    this.rowid = const Value.absent(),
  })  : itemType = Value(itemType),
        updatedAt = Value(updatedAt);
  static Insertable<InventoryItem> custom({
    Expression<String>? itemType,
    Expression<int>? count,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemType != null) 'item_type': itemType,
      if (count != null) 'count': count,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryItemsCompanion copyWith(
      {Value<String>? itemType,
      Value<int>? count,
      Value<String>? updatedAt,
      Value<int>? rowid}) {
    return InventoryItemsCompanion(
      itemType: itemType ?? this.itemType,
      count: count ?? this.count,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemType.present) {
      map['item_type'] = Variable<String>(itemType.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryItemsCompanion(')
          ..write('itemType: $itemType, ')
          ..write('count: $count, ')
          ..write('updatedAt: $updatedAt, ')
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
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
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
  final String updatedAt;
  const AppSetting(
      {required this.key, required this.value, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  AppSetting copyWith({String? key, String? value, String? updatedAt}) =>
      AppSetting(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    required String updatedAt,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value),
        updatedAt = Value(updatedAt);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith(
      {Value<String>? key,
      Value<String>? value,
      Value<String>? updatedAt,
      Value<int>? rowid}) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
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
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaFilesTable extends MediaFiles
    with TableInfo<$MediaFilesTable, MediaFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownerTypeMeta =
      const VerificationMeta('ownerType');
  @override
  late final GeneratedColumn<String> ownerType = GeneratedColumn<String>(
      'owner_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _relativePathMeta =
      const VerificationMeta('relativePath');
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
      'relative_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sizeBytesMeta =
      const VerificationMeta('sizeBytes');
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
      'size_bytes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, ownerType, ownerId, role, relativePath, sizeBytes, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_files';
  @override
  VerificationContext validateIntegrity(Insertable<MediaFile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_type')) {
      context.handle(_ownerTypeMeta,
          ownerType.isAcceptableOrUnknown(data['owner_type']!, _ownerTypeMeta));
    } else if (isInserting) {
      context.missing(_ownerTypeMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('relative_path')) {
      context.handle(
          _relativePathMeta,
          relativePath.isAcceptableOrUnknown(
              data['relative_path']!, _relativePathMeta));
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(_sizeBytesMeta,
          sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaFile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      ownerType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_type'])!,
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      relativePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}relative_path'])!,
      sizeBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}size_bytes'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MediaFilesTable createAlias(String alias) {
    return $MediaFilesTable(attachedDatabase, alias);
  }
}

class MediaFile extends DataClass implements Insertable<MediaFile> {
  final String id;
  final String ownerType;
  final String ownerId;
  final String role;
  final String relativePath;
  final int sizeBytes;
  final String createdAt;
  const MediaFile(
      {required this.id,
      required this.ownerType,
      required this.ownerId,
      required this.role,
      required this.relativePath,
      required this.sizeBytes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_type'] = Variable<String>(ownerType);
    map['owner_id'] = Variable<String>(ownerId);
    map['role'] = Variable<String>(role);
    map['relative_path'] = Variable<String>(relativePath);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  MediaFilesCompanion toCompanion(bool nullToAbsent) {
    return MediaFilesCompanion(
      id: Value(id),
      ownerType: Value(ownerType),
      ownerId: Value(ownerId),
      role: Value(role),
      relativePath: Value(relativePath),
      sizeBytes: Value(sizeBytes),
      createdAt: Value(createdAt),
    );
  }

  factory MediaFile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaFile(
      id: serializer.fromJson<String>(json['id']),
      ownerType: serializer.fromJson<String>(json['ownerType']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      role: serializer.fromJson<String>(json['role']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerType': serializer.toJson<String>(ownerType),
      'ownerId': serializer.toJson<String>(ownerId),
      'role': serializer.toJson<String>(role),
      'relativePath': serializer.toJson<String>(relativePath),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  MediaFile copyWith(
          {String? id,
          String? ownerType,
          String? ownerId,
          String? role,
          String? relativePath,
          int? sizeBytes,
          String? createdAt}) =>
      MediaFile(
        id: id ?? this.id,
        ownerType: ownerType ?? this.ownerType,
        ownerId: ownerId ?? this.ownerId,
        role: role ?? this.role,
        relativePath: relativePath ?? this.relativePath,
        sizeBytes: sizeBytes ?? this.sizeBytes,
        createdAt: createdAt ?? this.createdAt,
      );
  MediaFile copyWithCompanion(MediaFilesCompanion data) {
    return MediaFile(
      id: data.id.present ? data.id.value : this.id,
      ownerType: data.ownerType.present ? data.ownerType.value : this.ownerType,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      role: data.role.present ? data.role.value : this.role,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaFile(')
          ..write('id: $id, ')
          ..write('ownerType: $ownerType, ')
          ..write('ownerId: $ownerId, ')
          ..write('role: $role, ')
          ..write('relativePath: $relativePath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, ownerType, ownerId, role, relativePath, sizeBytes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaFile &&
          other.id == this.id &&
          other.ownerType == this.ownerType &&
          other.ownerId == this.ownerId &&
          other.role == this.role &&
          other.relativePath == this.relativePath &&
          other.sizeBytes == this.sizeBytes &&
          other.createdAt == this.createdAt);
}

class MediaFilesCompanion extends UpdateCompanion<MediaFile> {
  final Value<String> id;
  final Value<String> ownerType;
  final Value<String> ownerId;
  final Value<String> role;
  final Value<String> relativePath;
  final Value<int> sizeBytes;
  final Value<String> createdAt;
  final Value<int> rowid;
  const MediaFilesCompanion({
    this.id = const Value.absent(),
    this.ownerType = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.role = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaFilesCompanion.insert({
    required String id,
    required String ownerType,
    required String ownerId,
    required String role,
    required String relativePath,
    this.sizeBytes = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        ownerType = Value(ownerType),
        ownerId = Value(ownerId),
        role = Value(role),
        relativePath = Value(relativePath),
        createdAt = Value(createdAt);
  static Insertable<MediaFile> custom({
    Expression<String>? id,
    Expression<String>? ownerType,
    Expression<String>? ownerId,
    Expression<String>? role,
    Expression<String>? relativePath,
    Expression<int>? sizeBytes,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerType != null) 'owner_type': ownerType,
      if (ownerId != null) 'owner_id': ownerId,
      if (role != null) 'role': role,
      if (relativePath != null) 'relative_path': relativePath,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaFilesCompanion copyWith(
      {Value<String>? id,
      Value<String>? ownerType,
      Value<String>? ownerId,
      Value<String>? role,
      Value<String>? relativePath,
      Value<int>? sizeBytes,
      Value<String>? createdAt,
      Value<int>? rowid}) {
    return MediaFilesCompanion(
      id: id ?? this.id,
      ownerType: ownerType ?? this.ownerType,
      ownerId: ownerId ?? this.ownerId,
      role: role ?? this.role,
      relativePath: relativePath ?? this.relativePath,
      sizeBytes: sizeBytes ?? this.sizeBytes,
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
      map['owner_type'] = Variable<String>(ownerType.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaFilesCompanion(')
          ..write('id: $id, ')
          ..write('ownerType: $ownerType, ')
          ..write('ownerId: $ownerId, ')
          ..write('role: $role, ')
          ..write('relativePath: $relativePath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TermsTable terms = $TermsTable(this);
  late final $FlashcardSetsTable flashcardSets = $FlashcardSetsTable(this);
  late final $FlashcardSetItemsTable flashcardSetItems =
      $FlashcardSetItemsTable(this);
  late final $StudySessionsTable studySessions = $StudySessionsTable(this);
  late final $StudyEventsTable studyEvents = $StudyEventsTable(this);
  late final $PointLogsTable pointLogs = $PointLogsTable(this);
  late final $GardenCellsTable gardenCells = $GardenCellsTable(this);
  late final $InventoryItemsTable inventoryItems = $InventoryItemsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $MediaFilesTable mediaFiles = $MediaFilesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        terms,
        flashcardSets,
        flashcardSetItems,
        studySessions,
        studyEvents,
        pointLogs,
        gardenCells,
        inventoryItems,
        appSettings,
        mediaFiles
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('flashcard_sets',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('flashcard_set_items', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('terms',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('flashcard_set_items', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('study_sessions',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('study_events', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$TermsTableCreateCompanionBuilder = TermsCompanion Function({
  required String id,
  required String type,
  required String frontText,
  Value<String> backText,
  Value<String> note,
  Value<String> frontLanguage,
  Value<String> backLanguage,
  Value<String?> imagePath,
  Value<String?> audioFrontPath,
  Value<String?> audioBackPath,
  Value<String?> tagsJson,
  required String createdAt,
  required String updatedAt,
  Value<String?> deletedAt,
  Value<int> rowid,
});
typedef $$TermsTableUpdateCompanionBuilder = TermsCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<String> frontText,
  Value<String> backText,
  Value<String> note,
  Value<String> frontLanguage,
  Value<String> backLanguage,
  Value<String?> imagePath,
  Value<String?> audioFrontPath,
  Value<String?> audioBackPath,
  Value<String?> tagsJson,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String?> deletedAt,
  Value<int> rowid,
});

final class $$TermsTableReferences
    extends BaseReferences<_$AppDatabase, $TermsTable, Term> {
  $$TermsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FlashcardSetItemsTable, List<FlashcardSetItem>>
      _flashcardSetItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.flashcardSetItems,
              aliasName: $_aliasNameGenerator(
                  db.terms.id, db.flashcardSetItems.termId));

  $$FlashcardSetItemsTableProcessedTableManager get flashcardSetItemsRefs {
    final manager =
        $$FlashcardSetItemsTableTableManager($_db, $_db.flashcardSetItems)
            .filter((f) => f.termId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_flashcardSetItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TermsTableFilterComposer extends Composer<_$AppDatabase, $TermsTable> {
  $$TermsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get frontText => $composableBuilder(
      column: $table.frontText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get backText => $composableBuilder(
      column: $table.backText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get frontLanguage => $composableBuilder(
      column: $table.frontLanguage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get backLanguage => $composableBuilder(
      column: $table.backLanguage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get audioFrontPath => $composableBuilder(
      column: $table.audioFrontPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get audioBackPath => $composableBuilder(
      column: $table.audioBackPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> flashcardSetItemsRefs(
      Expression<bool> Function($$FlashcardSetItemsTableFilterComposer f) f) {
    final $$FlashcardSetItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.flashcardSetItems,
        getReferencedColumn: (t) => t.termId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FlashcardSetItemsTableFilterComposer(
              $db: $db,
              $table: $db.flashcardSetItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TermsTableOrderingComposer
    extends Composer<_$AppDatabase, $TermsTable> {
  $$TermsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get frontText => $composableBuilder(
      column: $table.frontText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get backText => $composableBuilder(
      column: $table.backText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get frontLanguage => $composableBuilder(
      column: $table.frontLanguage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get backLanguage => $composableBuilder(
      column: $table.backLanguage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get audioFrontPath => $composableBuilder(
      column: $table.audioFrontPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get audioBackPath => $composableBuilder(
      column: $table.audioBackPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$TermsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TermsTable> {
  $$TermsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get frontText =>
      $composableBuilder(column: $table.frontText, builder: (column) => column);

  GeneratedColumn<String> get backText =>
      $composableBuilder(column: $table.backText, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get frontLanguage => $composableBuilder(
      column: $table.frontLanguage, builder: (column) => column);

  GeneratedColumn<String> get backLanguage => $composableBuilder(
      column: $table.backLanguage, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get audioFrontPath => $composableBuilder(
      column: $table.audioFrontPath, builder: (column) => column);

  GeneratedColumn<String> get audioBackPath => $composableBuilder(
      column: $table.audioBackPath, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> flashcardSetItemsRefs<T extends Object>(
      Expression<T> Function($$FlashcardSetItemsTableAnnotationComposer a) f) {
    final $$FlashcardSetItemsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.flashcardSetItems,
            getReferencedColumn: (t) => t.termId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$FlashcardSetItemsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.flashcardSetItems,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$TermsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TermsTable,
    Term,
    $$TermsTableFilterComposer,
    $$TermsTableOrderingComposer,
    $$TermsTableAnnotationComposer,
    $$TermsTableCreateCompanionBuilder,
    $$TermsTableUpdateCompanionBuilder,
    (Term, $$TermsTableReferences),
    Term,
    PrefetchHooks Function({bool flashcardSetItemsRefs})> {
  $$TermsTableTableManager(_$AppDatabase db, $TermsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TermsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TermsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TermsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> frontText = const Value.absent(),
            Value<String> backText = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<String> frontLanguage = const Value.absent(),
            Value<String> backLanguage = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<String?> audioFrontPath = const Value.absent(),
            Value<String?> audioBackPath = const Value.absent(),
            Value<String?> tagsJson = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TermsCompanion(
            id: id,
            type: type,
            frontText: frontText,
            backText: backText,
            note: note,
            frontLanguage: frontLanguage,
            backLanguage: backLanguage,
            imagePath: imagePath,
            audioFrontPath: audioFrontPath,
            audioBackPath: audioBackPath,
            tagsJson: tagsJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            required String frontText,
            Value<String> backText = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<String> frontLanguage = const Value.absent(),
            Value<String> backLanguage = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<String?> audioFrontPath = const Value.absent(),
            Value<String?> audioBackPath = const Value.absent(),
            Value<String?> tagsJson = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TermsCompanion.insert(
            id: id,
            type: type,
            frontText: frontText,
            backText: backText,
            note: note,
            frontLanguage: frontLanguage,
            backLanguage: backLanguage,
            imagePath: imagePath,
            audioFrontPath: audioFrontPath,
            audioBackPath: audioBackPath,
            tagsJson: tagsJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TermsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({flashcardSetItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (flashcardSetItemsRefs) db.flashcardSetItems
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (flashcardSetItemsRefs)
                    await $_getPrefetchedData<Term, $TermsTable,
                            FlashcardSetItem>(
                        currentTable: table,
                        referencedTable: $$TermsTableReferences
                            ._flashcardSetItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TermsTableReferences(db, table, p0)
                                .flashcardSetItemsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.termId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TermsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TermsTable,
    Term,
    $$TermsTableFilterComposer,
    $$TermsTableOrderingComposer,
    $$TermsTableAnnotationComposer,
    $$TermsTableCreateCompanionBuilder,
    $$TermsTableUpdateCompanionBuilder,
    (Term, $$TermsTableReferences),
    Term,
    PrefetchHooks Function({bool flashcardSetItemsRefs})>;
typedef $$FlashcardSetsTableCreateCompanionBuilder = FlashcardSetsCompanion
    Function({
  required String id,
  required String title,
  Value<String> description,
  required String createdAt,
  required String updatedAt,
  Value<String?> deletedAt,
  Value<int> rowid,
});
typedef $$FlashcardSetsTableUpdateCompanionBuilder = FlashcardSetsCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<String> description,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String?> deletedAt,
  Value<int> rowid,
});

final class $$FlashcardSetsTableReferences
    extends BaseReferences<_$AppDatabase, $FlashcardSetsTable, FlashcardSet> {
  $$FlashcardSetsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FlashcardSetItemsTable, List<FlashcardSetItem>>
      _flashcardSetItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.flashcardSetItems,
              aliasName: $_aliasNameGenerator(
                  db.flashcardSets.id, db.flashcardSetItems.setId));

  $$FlashcardSetItemsTableProcessedTableManager get flashcardSetItemsRefs {
    final manager =
        $$FlashcardSetItemsTableTableManager($_db, $_db.flashcardSetItems)
            .filter((f) => f.setId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_flashcardSetItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$FlashcardSetsTableFilterComposer
    extends Composer<_$AppDatabase, $FlashcardSetsTable> {
  $$FlashcardSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> flashcardSetItemsRefs(
      Expression<bool> Function($$FlashcardSetItemsTableFilterComposer f) f) {
    final $$FlashcardSetItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.flashcardSetItems,
        getReferencedColumn: (t) => t.setId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FlashcardSetItemsTableFilterComposer(
              $db: $db,
              $table: $db.flashcardSetItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$FlashcardSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $FlashcardSetsTable> {
  $$FlashcardSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$FlashcardSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FlashcardSetsTable> {
  $$FlashcardSetsTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> flashcardSetItemsRefs<T extends Object>(
      Expression<T> Function($$FlashcardSetItemsTableAnnotationComposer a) f) {
    final $$FlashcardSetItemsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.flashcardSetItems,
            getReferencedColumn: (t) => t.setId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$FlashcardSetItemsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.flashcardSetItems,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$FlashcardSetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FlashcardSetsTable,
    FlashcardSet,
    $$FlashcardSetsTableFilterComposer,
    $$FlashcardSetsTableOrderingComposer,
    $$FlashcardSetsTableAnnotationComposer,
    $$FlashcardSetsTableCreateCompanionBuilder,
    $$FlashcardSetsTableUpdateCompanionBuilder,
    (FlashcardSet, $$FlashcardSetsTableReferences),
    FlashcardSet,
    PrefetchHooks Function({bool flashcardSetItemsRefs})> {
  $$FlashcardSetsTableTableManager(_$AppDatabase db, $FlashcardSetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlashcardSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlashcardSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlashcardSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FlashcardSetsCompanion(
            id: id,
            title: title,
            description: description,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            Value<String> description = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FlashcardSetsCompanion.insert(
            id: id,
            title: title,
            description: description,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$FlashcardSetsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({flashcardSetItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (flashcardSetItemsRefs) db.flashcardSetItems
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (flashcardSetItemsRefs)
                    await $_getPrefetchedData<FlashcardSet, $FlashcardSetsTable,
                            FlashcardSetItem>(
                        currentTable: table,
                        referencedTable: $$FlashcardSetsTableReferences
                            ._flashcardSetItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$FlashcardSetsTableReferences(db, table, p0)
                                .flashcardSetItemsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.setId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$FlashcardSetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FlashcardSetsTable,
    FlashcardSet,
    $$FlashcardSetsTableFilterComposer,
    $$FlashcardSetsTableOrderingComposer,
    $$FlashcardSetsTableAnnotationComposer,
    $$FlashcardSetsTableCreateCompanionBuilder,
    $$FlashcardSetsTableUpdateCompanionBuilder,
    (FlashcardSet, $$FlashcardSetsTableReferences),
    FlashcardSet,
    PrefetchHooks Function({bool flashcardSetItemsRefs})>;
typedef $$FlashcardSetItemsTableCreateCompanionBuilder
    = FlashcardSetItemsCompanion Function({
  required String id,
  required String setId,
  required String termId,
  Value<int> sortOrder,
  required String createdAt,
  Value<int> rowid,
});
typedef $$FlashcardSetItemsTableUpdateCompanionBuilder
    = FlashcardSetItemsCompanion Function({
  Value<String> id,
  Value<String> setId,
  Value<String> termId,
  Value<int> sortOrder,
  Value<String> createdAt,
  Value<int> rowid,
});

final class $$FlashcardSetItemsTableReferences extends BaseReferences<
    _$AppDatabase, $FlashcardSetItemsTable, FlashcardSetItem> {
  $$FlashcardSetItemsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $FlashcardSetsTable _setIdTable(_$AppDatabase db) =>
      db.flashcardSets.createAlias($_aliasNameGenerator(
          db.flashcardSetItems.setId, db.flashcardSets.id));

  $$FlashcardSetsTableProcessedTableManager get setId {
    final $_column = $_itemColumn<String>('set_id')!;

    final manager = $$FlashcardSetsTableTableManager($_db, $_db.flashcardSets)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_setIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TermsTable _termIdTable(_$AppDatabase db) => db.terms.createAlias(
      $_aliasNameGenerator(db.flashcardSetItems.termId, db.terms.id));

  $$TermsTableProcessedTableManager get termId {
    final $_column = $_itemColumn<String>('term_id')!;

    final manager = $$TermsTableTableManager($_db, $_db.terms)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_termIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$FlashcardSetItemsTableFilterComposer
    extends Composer<_$AppDatabase, $FlashcardSetItemsTable> {
  $$FlashcardSetItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$FlashcardSetsTableFilterComposer get setId {
    final $$FlashcardSetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.setId,
        referencedTable: $db.flashcardSets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FlashcardSetsTableFilterComposer(
              $db: $db,
              $table: $db.flashcardSets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TermsTableFilterComposer get termId {
    final $$TermsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.termId,
        referencedTable: $db.terms,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TermsTableFilterComposer(
              $db: $db,
              $table: $db.terms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FlashcardSetItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $FlashcardSetItemsTable> {
  $$FlashcardSetItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$FlashcardSetsTableOrderingComposer get setId {
    final $$FlashcardSetsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.setId,
        referencedTable: $db.flashcardSets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FlashcardSetsTableOrderingComposer(
              $db: $db,
              $table: $db.flashcardSets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TermsTableOrderingComposer get termId {
    final $$TermsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.termId,
        referencedTable: $db.terms,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TermsTableOrderingComposer(
              $db: $db,
              $table: $db.terms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FlashcardSetItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FlashcardSetItemsTable> {
  $$FlashcardSetItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$FlashcardSetsTableAnnotationComposer get setId {
    final $$FlashcardSetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.setId,
        referencedTable: $db.flashcardSets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FlashcardSetsTableAnnotationComposer(
              $db: $db,
              $table: $db.flashcardSets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TermsTableAnnotationComposer get termId {
    final $$TermsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.termId,
        referencedTable: $db.terms,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TermsTableAnnotationComposer(
              $db: $db,
              $table: $db.terms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FlashcardSetItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FlashcardSetItemsTable,
    FlashcardSetItem,
    $$FlashcardSetItemsTableFilterComposer,
    $$FlashcardSetItemsTableOrderingComposer,
    $$FlashcardSetItemsTableAnnotationComposer,
    $$FlashcardSetItemsTableCreateCompanionBuilder,
    $$FlashcardSetItemsTableUpdateCompanionBuilder,
    (FlashcardSetItem, $$FlashcardSetItemsTableReferences),
    FlashcardSetItem,
    PrefetchHooks Function({bool setId, bool termId})> {
  $$FlashcardSetItemsTableTableManager(
      _$AppDatabase db, $FlashcardSetItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlashcardSetItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlashcardSetItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlashcardSetItemsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> setId = const Value.absent(),
            Value<String> termId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FlashcardSetItemsCompanion(
            id: id,
            setId: setId,
            termId: termId,
            sortOrder: sortOrder,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String setId,
            required String termId,
            Value<int> sortOrder = const Value.absent(),
            required String createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              FlashcardSetItemsCompanion.insert(
            id: id,
            setId: setId,
            termId: termId,
            sortOrder: sortOrder,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$FlashcardSetItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({setId = false, termId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (setId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.setId,
                    referencedTable:
                        $$FlashcardSetItemsTableReferences._setIdTable(db),
                    referencedColumn:
                        $$FlashcardSetItemsTableReferences._setIdTable(db).id,
                  ) as T;
                }
                if (termId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.termId,
                    referencedTable:
                        $$FlashcardSetItemsTableReferences._termIdTable(db),
                    referencedColumn:
                        $$FlashcardSetItemsTableReferences._termIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$FlashcardSetItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FlashcardSetItemsTable,
    FlashcardSetItem,
    $$FlashcardSetItemsTableFilterComposer,
    $$FlashcardSetItemsTableOrderingComposer,
    $$FlashcardSetItemsTableAnnotationComposer,
    $$FlashcardSetItemsTableCreateCompanionBuilder,
    $$FlashcardSetItemsTableUpdateCompanionBuilder,
    (FlashcardSetItem, $$FlashcardSetItemsTableReferences),
    FlashcardSetItem,
    PrefetchHooks Function({bool setId, bool termId})>;
typedef $$StudySessionsTableCreateCompanionBuilder = StudySessionsCompanion
    Function({
  required String id,
  Value<String?> setId,
  required String startedAt,
  Value<String?> endedAt,
  Value<int> cardsSeen,
  Value<int> pointsEarned,
  Value<int> rowid,
});
typedef $$StudySessionsTableUpdateCompanionBuilder = StudySessionsCompanion
    Function({
  Value<String> id,
  Value<String?> setId,
  Value<String> startedAt,
  Value<String?> endedAt,
  Value<int> cardsSeen,
  Value<int> pointsEarned,
  Value<int> rowid,
});

final class $$StudySessionsTableReferences
    extends BaseReferences<_$AppDatabase, $StudySessionsTable, StudySession> {
  $$StudySessionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StudyEventsTable, List<StudyEvent>>
      _studyEventsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.studyEvents,
              aliasName: $_aliasNameGenerator(
                  db.studySessions.id, db.studyEvents.sessionId));

  $$StudyEventsTableProcessedTableManager get studyEventsRefs {
    final manager = $$StudyEventsTableTableManager($_db, $_db.studyEvents)
        .filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_studyEventsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$StudySessionsTableFilterComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get setId => $composableBuilder(
      column: $table.setId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cardsSeen => $composableBuilder(
      column: $table.cardsSeen, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pointsEarned => $composableBuilder(
      column: $table.pointsEarned, builder: (column) => ColumnFilters(column));

  Expression<bool> studyEventsRefs(
      Expression<bool> Function($$StudyEventsTableFilterComposer f) f) {
    final $$StudyEventsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.studyEvents,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StudyEventsTableFilterComposer(
              $db: $db,
              $table: $db.studyEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$StudySessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get setId => $composableBuilder(
      column: $table.setId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cardsSeen => $composableBuilder(
      column: $table.cardsSeen, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pointsEarned => $composableBuilder(
      column: $table.pointsEarned,
      builder: (column) => ColumnOrderings(column));
}

class $$StudySessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get setId =>
      $composableBuilder(column: $table.setId, builder: (column) => column);

  GeneratedColumn<String> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<String> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get cardsSeen =>
      $composableBuilder(column: $table.cardsSeen, builder: (column) => column);

  GeneratedColumn<int> get pointsEarned => $composableBuilder(
      column: $table.pointsEarned, builder: (column) => column);

  Expression<T> studyEventsRefs<T extends Object>(
      Expression<T> Function($$StudyEventsTableAnnotationComposer a) f) {
    final $$StudyEventsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.studyEvents,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StudyEventsTableAnnotationComposer(
              $db: $db,
              $table: $db.studyEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$StudySessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StudySessionsTable,
    StudySession,
    $$StudySessionsTableFilterComposer,
    $$StudySessionsTableOrderingComposer,
    $$StudySessionsTableAnnotationComposer,
    $$StudySessionsTableCreateCompanionBuilder,
    $$StudySessionsTableUpdateCompanionBuilder,
    (StudySession, $$StudySessionsTableReferences),
    StudySession,
    PrefetchHooks Function({bool studyEventsRefs})> {
  $$StudySessionsTableTableManager(_$AppDatabase db, $StudySessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudySessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudySessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudySessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> setId = const Value.absent(),
            Value<String> startedAt = const Value.absent(),
            Value<String?> endedAt = const Value.absent(),
            Value<int> cardsSeen = const Value.absent(),
            Value<int> pointsEarned = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StudySessionsCompanion(
            id: id,
            setId: setId,
            startedAt: startedAt,
            endedAt: endedAt,
            cardsSeen: cardsSeen,
            pointsEarned: pointsEarned,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> setId = const Value.absent(),
            required String startedAt,
            Value<String?> endedAt = const Value.absent(),
            Value<int> cardsSeen = const Value.absent(),
            Value<int> pointsEarned = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StudySessionsCompanion.insert(
            id: id,
            setId: setId,
            startedAt: startedAt,
            endedAt: endedAt,
            cardsSeen: cardsSeen,
            pointsEarned: pointsEarned,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$StudySessionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({studyEventsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (studyEventsRefs) db.studyEvents],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (studyEventsRefs)
                    await $_getPrefetchedData<StudySession, $StudySessionsTable,
                            StudyEvent>(
                        currentTable: table,
                        referencedTable: $$StudySessionsTableReferences
                            ._studyEventsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$StudySessionsTableReferences(db, table, p0)
                                .studyEventsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sessionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$StudySessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StudySessionsTable,
    StudySession,
    $$StudySessionsTableFilterComposer,
    $$StudySessionsTableOrderingComposer,
    $$StudySessionsTableAnnotationComposer,
    $$StudySessionsTableCreateCompanionBuilder,
    $$StudySessionsTableUpdateCompanionBuilder,
    (StudySession, $$StudySessionsTableReferences),
    StudySession,
    PrefetchHooks Function({bool studyEventsRefs})>;
typedef $$StudyEventsTableCreateCompanionBuilder = StudyEventsCompanion
    Function({
  required String id,
  required String sessionId,
  Value<String?> termId,
  Value<String> result,
  required String shownAt,
  Value<int> rowid,
});
typedef $$StudyEventsTableUpdateCompanionBuilder = StudyEventsCompanion
    Function({
  Value<String> id,
  Value<String> sessionId,
  Value<String?> termId,
  Value<String> result,
  Value<String> shownAt,
  Value<int> rowid,
});

final class $$StudyEventsTableReferences
    extends BaseReferences<_$AppDatabase, $StudyEventsTable, StudyEvent> {
  $$StudyEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StudySessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.studySessions.createAlias(
          $_aliasNameGenerator(db.studyEvents.sessionId, db.studySessions.id));

  $$StudySessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$StudySessionsTableTableManager($_db, $_db.studySessions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$StudyEventsTableFilterComposer
    extends Composer<_$AppDatabase, $StudyEventsTable> {
  $$StudyEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get termId => $composableBuilder(
      column: $table.termId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get result => $composableBuilder(
      column: $table.result, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shownAt => $composableBuilder(
      column: $table.shownAt, builder: (column) => ColumnFilters(column));

  $$StudySessionsTableFilterComposer get sessionId {
    final $$StudySessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.studySessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StudySessionsTableFilterComposer(
              $db: $db,
              $table: $db.studySessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StudyEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudyEventsTable> {
  $$StudyEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get termId => $composableBuilder(
      column: $table.termId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get result => $composableBuilder(
      column: $table.result, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shownAt => $composableBuilder(
      column: $table.shownAt, builder: (column) => ColumnOrderings(column));

  $$StudySessionsTableOrderingComposer get sessionId {
    final $$StudySessionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.studySessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StudySessionsTableOrderingComposer(
              $db: $db,
              $table: $db.studySessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StudyEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudyEventsTable> {
  $$StudyEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get termId =>
      $composableBuilder(column: $table.termId, builder: (column) => column);

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<String> get shownAt =>
      $composableBuilder(column: $table.shownAt, builder: (column) => column);

  $$StudySessionsTableAnnotationComposer get sessionId {
    final $$StudySessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.studySessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StudySessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.studySessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StudyEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StudyEventsTable,
    StudyEvent,
    $$StudyEventsTableFilterComposer,
    $$StudyEventsTableOrderingComposer,
    $$StudyEventsTableAnnotationComposer,
    $$StudyEventsTableCreateCompanionBuilder,
    $$StudyEventsTableUpdateCompanionBuilder,
    (StudyEvent, $$StudyEventsTableReferences),
    StudyEvent,
    PrefetchHooks Function({bool sessionId})> {
  $$StudyEventsTableTableManager(_$AppDatabase db, $StudyEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudyEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudyEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudyEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sessionId = const Value.absent(),
            Value<String?> termId = const Value.absent(),
            Value<String> result = const Value.absent(),
            Value<String> shownAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StudyEventsCompanion(
            id: id,
            sessionId: sessionId,
            termId: termId,
            result: result,
            shownAt: shownAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sessionId,
            Value<String?> termId = const Value.absent(),
            Value<String> result = const Value.absent(),
            required String shownAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              StudyEventsCompanion.insert(
            id: id,
            sessionId: sessionId,
            termId: termId,
            result: result,
            shownAt: shownAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$StudyEventsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (sessionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sessionId,
                    referencedTable:
                        $$StudyEventsTableReferences._sessionIdTable(db),
                    referencedColumn:
                        $$StudyEventsTableReferences._sessionIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$StudyEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StudyEventsTable,
    StudyEvent,
    $$StudyEventsTableFilterComposer,
    $$StudyEventsTableOrderingComposer,
    $$StudyEventsTableAnnotationComposer,
    $$StudyEventsTableCreateCompanionBuilder,
    $$StudyEventsTableUpdateCompanionBuilder,
    (StudyEvent, $$StudyEventsTableReferences),
    StudyEvent,
    PrefetchHooks Function({bool sessionId})>;
typedef $$PointLogsTableCreateCompanionBuilder = PointLogsCompanion Function({
  required String id,
  required int amount,
  required String type,
  Value<String> description,
  required String createdAt,
  Value<int> rowid,
});
typedef $$PointLogsTableUpdateCompanionBuilder = PointLogsCompanion Function({
  Value<String> id,
  Value<int> amount,
  Value<String> type,
  Value<String> description,
  Value<String> createdAt,
  Value<int> rowid,
});

class $$PointLogsTableFilterComposer
    extends Composer<_$AppDatabase, $PointLogsTable> {
  $$PointLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PointLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $PointLogsTable> {
  $$PointLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PointLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PointLogsTable> {
  $$PointLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PointLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PointLogsTable,
    PointLog,
    $$PointLogsTableFilterComposer,
    $$PointLogsTableOrderingComposer,
    $$PointLogsTableAnnotationComposer,
    $$PointLogsTableCreateCompanionBuilder,
    $$PointLogsTableUpdateCompanionBuilder,
    (PointLog, BaseReferences<_$AppDatabase, $PointLogsTable, PointLog>),
    PointLog,
    PrefetchHooks Function()> {
  $$PointLogsTableTableManager(_$AppDatabase db, $PointLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PointLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PointLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PointLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PointLogsCompanion(
            id: id,
            amount: amount,
            type: type,
            description: description,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required int amount,
            required String type,
            Value<String> description = const Value.absent(),
            required String createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PointLogsCompanion.insert(
            id: id,
            amount: amount,
            type: type,
            description: description,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PointLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PointLogsTable,
    PointLog,
    $$PointLogsTableFilterComposer,
    $$PointLogsTableOrderingComposer,
    $$PointLogsTableAnnotationComposer,
    $$PointLogsTableCreateCompanionBuilder,
    $$PointLogsTableUpdateCompanionBuilder,
    (PointLog, BaseReferences<_$AppDatabase, $PointLogsTable, PointLog>),
    PointLog,
    PrefetchHooks Function()>;
typedef $$GardenCellsTableCreateCompanionBuilder = GardenCellsCompanion
    Function({
  required String id,
  required int row,
  required int col,
  required String itemType,
  Value<int> growth,
  required String updatedAt,
  Value<int> rowid,
});
typedef $$GardenCellsTableUpdateCompanionBuilder = GardenCellsCompanion
    Function({
  Value<String> id,
  Value<int> row,
  Value<int> col,
  Value<String> itemType,
  Value<int> growth,
  Value<String> updatedAt,
  Value<int> rowid,
});

class $$GardenCellsTableFilterComposer
    extends Composer<_$AppDatabase, $GardenCellsTable> {
  $$GardenCellsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get row => $composableBuilder(
      column: $table.row, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get col => $composableBuilder(
      column: $table.col, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemType => $composableBuilder(
      column: $table.itemType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get growth => $composableBuilder(
      column: $table.growth, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$GardenCellsTableOrderingComposer
    extends Composer<_$AppDatabase, $GardenCellsTable> {
  $$GardenCellsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get row => $composableBuilder(
      column: $table.row, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get col => $composableBuilder(
      column: $table.col, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemType => $composableBuilder(
      column: $table.itemType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get growth => $composableBuilder(
      column: $table.growth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$GardenCellsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GardenCellsTable> {
  $$GardenCellsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get row =>
      $composableBuilder(column: $table.row, builder: (column) => column);

  GeneratedColumn<int> get col =>
      $composableBuilder(column: $table.col, builder: (column) => column);

  GeneratedColumn<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);

  GeneratedColumn<int> get growth =>
      $composableBuilder(column: $table.growth, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$GardenCellsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GardenCellsTable,
    GardenCell,
    $$GardenCellsTableFilterComposer,
    $$GardenCellsTableOrderingComposer,
    $$GardenCellsTableAnnotationComposer,
    $$GardenCellsTableCreateCompanionBuilder,
    $$GardenCellsTableUpdateCompanionBuilder,
    (GardenCell, BaseReferences<_$AppDatabase, $GardenCellsTable, GardenCell>),
    GardenCell,
    PrefetchHooks Function()> {
  $$GardenCellsTableTableManager(_$AppDatabase db, $GardenCellsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GardenCellsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GardenCellsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GardenCellsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> row = const Value.absent(),
            Value<int> col = const Value.absent(),
            Value<String> itemType = const Value.absent(),
            Value<int> growth = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GardenCellsCompanion(
            id: id,
            row: row,
            col: col,
            itemType: itemType,
            growth: growth,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required int row,
            required int col,
            required String itemType,
            Value<int> growth = const Value.absent(),
            required String updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              GardenCellsCompanion.insert(
            id: id,
            row: row,
            col: col,
            itemType: itemType,
            growth: growth,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GardenCellsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GardenCellsTable,
    GardenCell,
    $$GardenCellsTableFilterComposer,
    $$GardenCellsTableOrderingComposer,
    $$GardenCellsTableAnnotationComposer,
    $$GardenCellsTableCreateCompanionBuilder,
    $$GardenCellsTableUpdateCompanionBuilder,
    (GardenCell, BaseReferences<_$AppDatabase, $GardenCellsTable, GardenCell>),
    GardenCell,
    PrefetchHooks Function()>;
typedef $$InventoryItemsTableCreateCompanionBuilder = InventoryItemsCompanion
    Function({
  required String itemType,
  Value<int> count,
  required String updatedAt,
  Value<int> rowid,
});
typedef $$InventoryItemsTableUpdateCompanionBuilder = InventoryItemsCompanion
    Function({
  Value<String> itemType,
  Value<int> count,
  Value<String> updatedAt,
  Value<int> rowid,
});

class $$InventoryItemsTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryItemsTable> {
  $$InventoryItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemType => $composableBuilder(
      column: $table.itemType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get count => $composableBuilder(
      column: $table.count, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$InventoryItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryItemsTable> {
  $$InventoryItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemType => $composableBuilder(
      column: $table.itemType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get count => $composableBuilder(
      column: $table.count, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$InventoryItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryItemsTable> {
  $$InventoryItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$InventoryItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InventoryItemsTable,
    InventoryItem,
    $$InventoryItemsTableFilterComposer,
    $$InventoryItemsTableOrderingComposer,
    $$InventoryItemsTableAnnotationComposer,
    $$InventoryItemsTableCreateCompanionBuilder,
    $$InventoryItemsTableUpdateCompanionBuilder,
    (
      InventoryItem,
      BaseReferences<_$AppDatabase, $InventoryItemsTable, InventoryItem>
    ),
    InventoryItem,
    PrefetchHooks Function()> {
  $$InventoryItemsTableTableManager(
      _$AppDatabase db, $InventoryItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> itemType = const Value.absent(),
            Value<int> count = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InventoryItemsCompanion(
            itemType: itemType,
            count: count,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String itemType,
            Value<int> count = const Value.absent(),
            required String updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              InventoryItemsCompanion.insert(
            itemType: itemType,
            count: count,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InventoryItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InventoryItemsTable,
    InventoryItem,
    $$InventoryItemsTableFilterComposer,
    $$InventoryItemsTableOrderingComposer,
    $$InventoryItemsTableAnnotationComposer,
    $$InventoryItemsTableCreateCompanionBuilder,
    $$InventoryItemsTableUpdateCompanionBuilder,
    (
      InventoryItem,
      BaseReferences<_$AppDatabase, $InventoryItemsTable, InventoryItem>
    ),
    InventoryItem,
    PrefetchHooks Function()>;
typedef $$AppSettingsTableCreateCompanionBuilder = AppSettingsCompanion
    Function({
  required String key,
  required String value,
  required String updatedAt,
  Value<int> rowid,
});
typedef $$AppSettingsTableUpdateCompanionBuilder = AppSettingsCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<String> updatedAt,
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
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
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
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
    AppSetting,
    PrefetchHooks Function()> {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
      : super(TableManagerState(
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
            Value<String> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion(
            key: key,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            required String updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion.insert(
            key: key,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
    AppSetting,
    PrefetchHooks Function()>;
typedef $$MediaFilesTableCreateCompanionBuilder = MediaFilesCompanion Function({
  required String id,
  required String ownerType,
  required String ownerId,
  required String role,
  required String relativePath,
  Value<int> sizeBytes,
  required String createdAt,
  Value<int> rowid,
});
typedef $$MediaFilesTableUpdateCompanionBuilder = MediaFilesCompanion Function({
  Value<String> id,
  Value<String> ownerType,
  Value<String> ownerId,
  Value<String> role,
  Value<String> relativePath,
  Value<int> sizeBytes,
  Value<String> createdAt,
  Value<int> rowid,
});

class $$MediaFilesTableFilterComposer
    extends Composer<_$AppDatabase, $MediaFilesTable> {
  $$MediaFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerType => $composableBuilder(
      column: $table.ownerType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relativePath => $composableBuilder(
      column: $table.relativePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$MediaFilesTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaFilesTable> {
  $$MediaFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerType => $composableBuilder(
      column: $table.ownerType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relativePath => $composableBuilder(
      column: $table.relativePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$MediaFilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaFilesTable> {
  $$MediaFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerType =>
      $composableBuilder(column: $table.ownerType, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get relativePath => $composableBuilder(
      column: $table.relativePath, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MediaFilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MediaFilesTable,
    MediaFile,
    $$MediaFilesTableFilterComposer,
    $$MediaFilesTableOrderingComposer,
    $$MediaFilesTableAnnotationComposer,
    $$MediaFilesTableCreateCompanionBuilder,
    $$MediaFilesTableUpdateCompanionBuilder,
    (MediaFile, BaseReferences<_$AppDatabase, $MediaFilesTable, MediaFile>),
    MediaFile,
    PrefetchHooks Function()> {
  $$MediaFilesTableTableManager(_$AppDatabase db, $MediaFilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> ownerType = const Value.absent(),
            Value<String> ownerId = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> relativePath = const Value.absent(),
            Value<int> sizeBytes = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MediaFilesCompanion(
            id: id,
            ownerType: ownerType,
            ownerId: ownerId,
            role: role,
            relativePath: relativePath,
            sizeBytes: sizeBytes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String ownerType,
            required String ownerId,
            required String role,
            required String relativePath,
            Value<int> sizeBytes = const Value.absent(),
            required String createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              MediaFilesCompanion.insert(
            id: id,
            ownerType: ownerType,
            ownerId: ownerId,
            role: role,
            relativePath: relativePath,
            sizeBytes: sizeBytes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MediaFilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MediaFilesTable,
    MediaFile,
    $$MediaFilesTableFilterComposer,
    $$MediaFilesTableOrderingComposer,
    $$MediaFilesTableAnnotationComposer,
    $$MediaFilesTableCreateCompanionBuilder,
    $$MediaFilesTableUpdateCompanionBuilder,
    (MediaFile, BaseReferences<_$AppDatabase, $MediaFilesTable, MediaFile>),
    MediaFile,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TermsTableTableManager get terms =>
      $$TermsTableTableManager(_db, _db.terms);
  $$FlashcardSetsTableTableManager get flashcardSets =>
      $$FlashcardSetsTableTableManager(_db, _db.flashcardSets);
  $$FlashcardSetItemsTableTableManager get flashcardSetItems =>
      $$FlashcardSetItemsTableTableManager(_db, _db.flashcardSetItems);
  $$StudySessionsTableTableManager get studySessions =>
      $$StudySessionsTableTableManager(_db, _db.studySessions);
  $$StudyEventsTableTableManager get studyEvents =>
      $$StudyEventsTableTableManager(_db, _db.studyEvents);
  $$PointLogsTableTableManager get pointLogs =>
      $$PointLogsTableTableManager(_db, _db.pointLogs);
  $$GardenCellsTableTableManager get gardenCells =>
      $$GardenCellsTableTableManager(_db, _db.gardenCells);
  $$InventoryItemsTableTableManager get inventoryItems =>
      $$InventoryItemsTableTableManager(_db, _db.inventoryItems);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$MediaFilesTableTableManager get mediaFiles =>
      $$MediaFilesTableTableManager(_db, _db.mediaFiles);
}
