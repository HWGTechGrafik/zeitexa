// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _passwordHashMeta = const VerificationMeta(
    'passwordHash',
  );
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
    'password_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isAdminMeta = const VerificationMeta(
    'isAdmin',
  );
  @override
  late final GeneratedColumn<bool> isAdmin = GeneratedColumn<bool>(
    'is_admin',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_admin" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _mustChangePasswordMeta =
      const VerificationMeta('mustChangePassword');
  @override
  late final GeneratedColumn<bool> mustChangePassword = GeneratedColumn<bool>(
    'must_change_password',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("must_change_password" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _mitarbeiterEmailMeta = const VerificationMeta(
    'mitarbeiterEmail',
  );
  @override
  late final GeneratedColumn<String> mitarbeiterEmail = GeneratedColumn<String>(
    'mitarbeiter_email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    username,
    passwordHash,
    displayName,
    isAdmin,
    mustChangePassword,
    createdAt,
    mitarbeiterEmail,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
        _passwordHashMeta,
        passwordHash.isAcceptableOrUnknown(
          data['password_hash']!,
          _passwordHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('is_admin')) {
      context.handle(
        _isAdminMeta,
        isAdmin.isAcceptableOrUnknown(data['is_admin']!, _isAdminMeta),
      );
    }
    if (data.containsKey('must_change_password')) {
      context.handle(
        _mustChangePasswordMeta,
        mustChangePassword.isAcceptableOrUnknown(
          data['must_change_password']!,
          _mustChangePasswordMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('mitarbeiter_email')) {
      context.handle(
        _mitarbeiterEmailMeta,
        mitarbeiterEmail.isAcceptableOrUnknown(
          data['mitarbeiter_email']!,
          _mitarbeiterEmailMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      passwordHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_hash'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      isAdmin: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_admin'],
      )!,
      mustChangePassword: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}must_change_password'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      mitarbeiterEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mitarbeiter_email'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final int id;
  final String username;
  final String passwordHash;
  final String displayName;
  final bool isAdmin;
  final bool mustChangePassword;
  final DateTime createdAt;

  /// E-Mail-Adresse des Mitarbeiters selbst (für die Excel-Kopie beim
  /// Mail-Export, siehe lib/export/export_service.dart).
  final String mitarbeiterEmail;
  const User({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.displayName,
    required this.isAdmin,
    required this.mustChangePassword,
    required this.createdAt,
    required this.mitarbeiterEmail,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['username'] = Variable<String>(username);
    map['password_hash'] = Variable<String>(passwordHash);
    map['display_name'] = Variable<String>(displayName);
    map['is_admin'] = Variable<bool>(isAdmin);
    map['must_change_password'] = Variable<bool>(mustChangePassword);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['mitarbeiter_email'] = Variable<String>(mitarbeiterEmail);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      username: Value(username),
      passwordHash: Value(passwordHash),
      displayName: Value(displayName),
      isAdmin: Value(isAdmin),
      mustChangePassword: Value(mustChangePassword),
      createdAt: Value(createdAt),
      mitarbeiterEmail: Value(mitarbeiterEmail),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      displayName: serializer.fromJson<String>(json['displayName']),
      isAdmin: serializer.fromJson<bool>(json['isAdmin']),
      mustChangePassword: serializer.fromJson<bool>(json['mustChangePassword']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      mitarbeiterEmail: serializer.fromJson<String>(json['mitarbeiterEmail']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'username': serializer.toJson<String>(username),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'displayName': serializer.toJson<String>(displayName),
      'isAdmin': serializer.toJson<bool>(isAdmin),
      'mustChangePassword': serializer.toJson<bool>(mustChangePassword),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'mitarbeiterEmail': serializer.toJson<String>(mitarbeiterEmail),
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? passwordHash,
    String? displayName,
    bool? isAdmin,
    bool? mustChangePassword,
    DateTime? createdAt,
    String? mitarbeiterEmail,
  }) => User(
    id: id ?? this.id,
    username: username ?? this.username,
    passwordHash: passwordHash ?? this.passwordHash,
    displayName: displayName ?? this.displayName,
    isAdmin: isAdmin ?? this.isAdmin,
    mustChangePassword: mustChangePassword ?? this.mustChangePassword,
    createdAt: createdAt ?? this.createdAt,
    mitarbeiterEmail: mitarbeiterEmail ?? this.mitarbeiterEmail,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      isAdmin: data.isAdmin.present ? data.isAdmin.value : this.isAdmin,
      mustChangePassword: data.mustChangePassword.present
          ? data.mustChangePassword.value
          : this.mustChangePassword,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      mitarbeiterEmail: data.mitarbeiterEmail.present
          ? data.mitarbeiterEmail.value
          : this.mitarbeiterEmail,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('displayName: $displayName, ')
          ..write('isAdmin: $isAdmin, ')
          ..write('mustChangePassword: $mustChangePassword, ')
          ..write('createdAt: $createdAt, ')
          ..write('mitarbeiterEmail: $mitarbeiterEmail')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    username,
    passwordHash,
    displayName,
    isAdmin,
    mustChangePassword,
    createdAt,
    mitarbeiterEmail,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.username == this.username &&
          other.passwordHash == this.passwordHash &&
          other.displayName == this.displayName &&
          other.isAdmin == this.isAdmin &&
          other.mustChangePassword == this.mustChangePassword &&
          other.createdAt == this.createdAt &&
          other.mitarbeiterEmail == this.mitarbeiterEmail);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String> username;
  final Value<String> passwordHash;
  final Value<String> displayName;
  final Value<bool> isAdmin;
  final Value<bool> mustChangePassword;
  final Value<DateTime> createdAt;
  final Value<String> mitarbeiterEmail;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.displayName = const Value.absent(),
    this.isAdmin = const Value.absent(),
    this.mustChangePassword = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.mitarbeiterEmail = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String username,
    required String passwordHash,
    required String displayName,
    this.isAdmin = const Value.absent(),
    this.mustChangePassword = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.mitarbeiterEmail = const Value.absent(),
  }) : username = Value(username),
       passwordHash = Value(passwordHash),
       displayName = Value(displayName);
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<String>? username,
    Expression<String>? passwordHash,
    Expression<String>? displayName,
    Expression<bool>? isAdmin,
    Expression<bool>? mustChangePassword,
    Expression<DateTime>? createdAt,
    Expression<String>? mitarbeiterEmail,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (displayName != null) 'display_name': displayName,
      if (isAdmin != null) 'is_admin': isAdmin,
      if (mustChangePassword != null)
        'must_change_password': mustChangePassword,
      if (createdAt != null) 'created_at': createdAt,
      if (mitarbeiterEmail != null) 'mitarbeiter_email': mitarbeiterEmail,
    });
  }

  UsersCompanion copyWith({
    Value<int>? id,
    Value<String>? username,
    Value<String>? passwordHash,
    Value<String>? displayName,
    Value<bool>? isAdmin,
    Value<bool>? mustChangePassword,
    Value<DateTime>? createdAt,
    Value<String>? mitarbeiterEmail,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      displayName: displayName ?? this.displayName,
      isAdmin: isAdmin ?? this.isAdmin,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      createdAt: createdAt ?? this.createdAt,
      mitarbeiterEmail: mitarbeiterEmail ?? this.mitarbeiterEmail,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (isAdmin.present) {
      map['is_admin'] = Variable<bool>(isAdmin.value);
    }
    if (mustChangePassword.present) {
      map['must_change_password'] = Variable<bool>(mustChangePassword.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (mitarbeiterEmail.present) {
      map['mitarbeiter_email'] = Variable<String>(mitarbeiterEmail.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('displayName: $displayName, ')
          ..write('isAdmin: $isAdmin, ')
          ..write('mustChangePassword: $mustChangePassword, ')
          ..write('createdAt: $createdAt, ')
          ..write('mitarbeiterEmail: $mitarbeiterEmail')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTable extends UserSettings
    with TableInfo<$UserSettingsTable, UserSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SollModus, int> sollModus =
      GeneratedColumn<int>(
        'soll_modus',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<SollModus>($UserSettingsTable.$convertersollModus);
  static const VerificationMeta _sollStundenTagMeta = const VerificationMeta(
    'sollStundenTag',
  );
  @override
  late final GeneratedColumn<double> sollStundenTag = GeneratedColumn<double>(
    'soll_stunden_tag',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(8.0),
  );
  static const VerificationMeta _sollStundenMoDoMeta = const VerificationMeta(
    'sollStundenMoDo',
  );
  @override
  late final GeneratedColumn<double> sollStundenMoDo = GeneratedColumn<double>(
    'soll_stunden_mo_do',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(8.0),
  );
  static const VerificationMeta _sollStundenFrMeta = const VerificationMeta(
    'sollStundenFr',
  );
  @override
  late final GeneratedColumn<double> sollStundenFr = GeneratedColumn<double>(
    'soll_stunden_fr',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(5.0),
  );
  static const VerificationMeta _sollStundenMoMeta = const VerificationMeta(
    'sollStundenMo',
  );
  @override
  late final GeneratedColumn<double> sollStundenMo = GeneratedColumn<double>(
    'soll_stunden_mo',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(8.0),
  );
  static const VerificationMeta _sollStundenDiMeta = const VerificationMeta(
    'sollStundenDi',
  );
  @override
  late final GeneratedColumn<double> sollStundenDi = GeneratedColumn<double>(
    'soll_stunden_di',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(8.0),
  );
  static const VerificationMeta _sollStundenMiMeta = const VerificationMeta(
    'sollStundenMi',
  );
  @override
  late final GeneratedColumn<double> sollStundenMi = GeneratedColumn<double>(
    'soll_stunden_mi',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(8.0),
  );
  static const VerificationMeta _sollStundenDoMeta = const VerificationMeta(
    'sollStundenDo',
  );
  @override
  late final GeneratedColumn<double> sollStundenDo = GeneratedColumn<double>(
    'soll_stunden_do',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(8.0),
  );
  static const VerificationMeta _sollStundenFrTagMeta = const VerificationMeta(
    'sollStundenFrTag',
  );
  @override
  late final GeneratedColumn<double> sollStundenFrTag = GeneratedColumn<double>(
    'soll_stunden_fr_tag',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(8.0),
  );
  static const VerificationMeta _sollStundenSaMeta = const VerificationMeta(
    'sollStundenSa',
  );
  @override
  late final GeneratedColumn<double> sollStundenSa = GeneratedColumn<double>(
    'soll_stunden_sa',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _sollStundenSoMeta = const VerificationMeta(
    'sollStundenSo',
  );
  @override
  late final GeneratedColumn<double> sollStundenSo = GeneratedColumn<double>(
    'soll_stunden_so',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _standardZeitenProTagMeta =
      const VerificationMeta('standardZeitenProTag');
  @override
  late final GeneratedColumn<String> standardZeitenProTag =
      GeneratedColumn<String>(
        'standard_zeiten_pro_tag',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _pausenregelAktivMeta = const VerificationMeta(
    'pausenregelAktiv',
  );
  @override
  late final GeneratedColumn<bool> pausenregelAktiv = GeneratedColumn<bool>(
    'pausenregel_aktiv',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pausenregel_aktiv" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pausenSchwelleMinMeta = const VerificationMeta(
    'pausenSchwelleMin',
  );
  @override
  late final GeneratedColumn<int> pausenSchwelleMin = GeneratedColumn<int>(
    'pausen_schwelle_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(12 * 60),
  );
  static const VerificationMeta _pausenMindestMinMeta = const VerificationMeta(
    'pausenMindestMin',
  );
  @override
  late final GeneratedColumn<int> pausenMindestMin = GeneratedColumn<int>(
    'pausen_mindest_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(60),
  );
  static const VerificationMeta _standardBeginnMinMeta = const VerificationMeta(
    'standardBeginnMin',
  );
  @override
  late final GeneratedColumn<int> standardBeginnMin = GeneratedColumn<int>(
    'standard_beginn_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(7 * 60),
  );
  static const VerificationMeta _standardEndeMinMeta = const VerificationMeta(
    'standardEndeMin',
  );
  @override
  late final GeneratedColumn<int> standardEndeMin = GeneratedColumn<int>(
    'standard_ende_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(16 * 60),
  );
  static const VerificationMeta _standardPauseMinMeta = const VerificationMeta(
    'standardPauseMin',
  );
  @override
  late final GeneratedColumn<int> standardPauseMin = GeneratedColumn<int>(
    'standard_pause_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _standardBeginnFrMinMeta =
      const VerificationMeta('standardBeginnFrMin');
  @override
  late final GeneratedColumn<int> standardBeginnFrMin = GeneratedColumn<int>(
    'standard_beginn_fr_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _standardEndeFrMinMeta = const VerificationMeta(
    'standardEndeFrMin',
  );
  @override
  late final GeneratedColumn<int> standardEndeFrMin = GeneratedColumn<int>(
    'standard_ende_fr_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _standardPauseFrMinMeta =
      const VerificationMeta('standardPauseFrMin');
  @override
  late final GeneratedColumn<int> standardPauseFrMin = GeneratedColumn<int>(
    'standard_pause_fr_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _anfangsstandStichtagMeta =
      const VerificationMeta('anfangsstandStichtag');
  @override
  late final GeneratedColumn<DateTime> anfangsstandStichtag =
      GeneratedColumn<DateTime>(
        'anfangsstand_stichtag',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _anfangsstandUrlaubTageMeta =
      const VerificationMeta('anfangsstandUrlaubTage');
  @override
  late final GeneratedColumn<double> anfangsstandUrlaubTage =
      GeneratedColumn<double>(
        'anfangsstand_urlaub_tage',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _anfangsstandZeitausgleichMinMeta =
      const VerificationMeta('anfangsstandZeitausgleichMin');
  @override
  late final GeneratedColumn<int> anfangsstandZeitausgleichMin =
      GeneratedColumn<int>(
        'anfangsstand_zeitausgleich_min',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _urlaubFrGetrenntMeta = const VerificationMeta(
    'urlaubFrGetrennt',
  );
  @override
  late final GeneratedColumn<bool> urlaubFrGetrennt = GeneratedColumn<bool>(
    'urlaub_fr_getrennt',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("urlaub_fr_getrennt" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _anfangsstandUrlaubFrTageMeta =
      const VerificationMeta('anfangsstandUrlaubFrTage');
  @override
  late final GeneratedColumn<double> anfangsstandUrlaubFrTage =
      GeneratedColumn<double>(
        'anfangsstand_urlaub_fr_tage',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _firmenurlaubAktivMeta = const VerificationMeta(
    'firmenurlaubAktiv',
  );
  @override
  late final GeneratedColumn<bool> firmenurlaubAktiv = GeneratedColumn<bool>(
    'firmenurlaub_aktiv',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("firmenurlaub_aktiv" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _anfangsstandFirmenurlaubTageMeta =
      const VerificationMeta('anfangsstandFirmenurlaubTage');
  @override
  late final GeneratedColumn<double> anfangsstandFirmenurlaubTage =
      GeneratedColumn<double>(
        'anfangsstand_firmenurlaub_tage',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    sollModus,
    sollStundenTag,
    sollStundenMoDo,
    sollStundenFr,
    sollStundenMo,
    sollStundenDi,
    sollStundenMi,
    sollStundenDo,
    sollStundenFrTag,
    sollStundenSa,
    sollStundenSo,
    standardZeitenProTag,
    pausenregelAktiv,
    pausenSchwelleMin,
    pausenMindestMin,
    standardBeginnMin,
    standardEndeMin,
    standardPauseMin,
    standardBeginnFrMin,
    standardEndeFrMin,
    standardPauseFrMin,
    anfangsstandStichtag,
    anfangsstandUrlaubTage,
    anfangsstandZeitausgleichMin,
    urlaubFrGetrennt,
    anfangsstandUrlaubFrTage,
    firmenurlaubAktiv,
    anfangsstandFirmenurlaubTage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('soll_stunden_tag')) {
      context.handle(
        _sollStundenTagMeta,
        sollStundenTag.isAcceptableOrUnknown(
          data['soll_stunden_tag']!,
          _sollStundenTagMeta,
        ),
      );
    }
    if (data.containsKey('soll_stunden_mo_do')) {
      context.handle(
        _sollStundenMoDoMeta,
        sollStundenMoDo.isAcceptableOrUnknown(
          data['soll_stunden_mo_do']!,
          _sollStundenMoDoMeta,
        ),
      );
    }
    if (data.containsKey('soll_stunden_fr')) {
      context.handle(
        _sollStundenFrMeta,
        sollStundenFr.isAcceptableOrUnknown(
          data['soll_stunden_fr']!,
          _sollStundenFrMeta,
        ),
      );
    }
    if (data.containsKey('soll_stunden_mo')) {
      context.handle(
        _sollStundenMoMeta,
        sollStundenMo.isAcceptableOrUnknown(
          data['soll_stunden_mo']!,
          _sollStundenMoMeta,
        ),
      );
    }
    if (data.containsKey('soll_stunden_di')) {
      context.handle(
        _sollStundenDiMeta,
        sollStundenDi.isAcceptableOrUnknown(
          data['soll_stunden_di']!,
          _sollStundenDiMeta,
        ),
      );
    }
    if (data.containsKey('soll_stunden_mi')) {
      context.handle(
        _sollStundenMiMeta,
        sollStundenMi.isAcceptableOrUnknown(
          data['soll_stunden_mi']!,
          _sollStundenMiMeta,
        ),
      );
    }
    if (data.containsKey('soll_stunden_do')) {
      context.handle(
        _sollStundenDoMeta,
        sollStundenDo.isAcceptableOrUnknown(
          data['soll_stunden_do']!,
          _sollStundenDoMeta,
        ),
      );
    }
    if (data.containsKey('soll_stunden_fr_tag')) {
      context.handle(
        _sollStundenFrTagMeta,
        sollStundenFrTag.isAcceptableOrUnknown(
          data['soll_stunden_fr_tag']!,
          _sollStundenFrTagMeta,
        ),
      );
    }
    if (data.containsKey('soll_stunden_sa')) {
      context.handle(
        _sollStundenSaMeta,
        sollStundenSa.isAcceptableOrUnknown(
          data['soll_stunden_sa']!,
          _sollStundenSaMeta,
        ),
      );
    }
    if (data.containsKey('soll_stunden_so')) {
      context.handle(
        _sollStundenSoMeta,
        sollStundenSo.isAcceptableOrUnknown(
          data['soll_stunden_so']!,
          _sollStundenSoMeta,
        ),
      );
    }
    if (data.containsKey('standard_zeiten_pro_tag')) {
      context.handle(
        _standardZeitenProTagMeta,
        standardZeitenProTag.isAcceptableOrUnknown(
          data['standard_zeiten_pro_tag']!,
          _standardZeitenProTagMeta,
        ),
      );
    }
    if (data.containsKey('pausenregel_aktiv')) {
      context.handle(
        _pausenregelAktivMeta,
        pausenregelAktiv.isAcceptableOrUnknown(
          data['pausenregel_aktiv']!,
          _pausenregelAktivMeta,
        ),
      );
    }
    if (data.containsKey('pausen_schwelle_min')) {
      context.handle(
        _pausenSchwelleMinMeta,
        pausenSchwelleMin.isAcceptableOrUnknown(
          data['pausen_schwelle_min']!,
          _pausenSchwelleMinMeta,
        ),
      );
    }
    if (data.containsKey('pausen_mindest_min')) {
      context.handle(
        _pausenMindestMinMeta,
        pausenMindestMin.isAcceptableOrUnknown(
          data['pausen_mindest_min']!,
          _pausenMindestMinMeta,
        ),
      );
    }
    if (data.containsKey('standard_beginn_min')) {
      context.handle(
        _standardBeginnMinMeta,
        standardBeginnMin.isAcceptableOrUnknown(
          data['standard_beginn_min']!,
          _standardBeginnMinMeta,
        ),
      );
    }
    if (data.containsKey('standard_ende_min')) {
      context.handle(
        _standardEndeMinMeta,
        standardEndeMin.isAcceptableOrUnknown(
          data['standard_ende_min']!,
          _standardEndeMinMeta,
        ),
      );
    }
    if (data.containsKey('standard_pause_min')) {
      context.handle(
        _standardPauseMinMeta,
        standardPauseMin.isAcceptableOrUnknown(
          data['standard_pause_min']!,
          _standardPauseMinMeta,
        ),
      );
    }
    if (data.containsKey('standard_beginn_fr_min')) {
      context.handle(
        _standardBeginnFrMinMeta,
        standardBeginnFrMin.isAcceptableOrUnknown(
          data['standard_beginn_fr_min']!,
          _standardBeginnFrMinMeta,
        ),
      );
    }
    if (data.containsKey('standard_ende_fr_min')) {
      context.handle(
        _standardEndeFrMinMeta,
        standardEndeFrMin.isAcceptableOrUnknown(
          data['standard_ende_fr_min']!,
          _standardEndeFrMinMeta,
        ),
      );
    }
    if (data.containsKey('standard_pause_fr_min')) {
      context.handle(
        _standardPauseFrMinMeta,
        standardPauseFrMin.isAcceptableOrUnknown(
          data['standard_pause_fr_min']!,
          _standardPauseFrMinMeta,
        ),
      );
    }
    if (data.containsKey('anfangsstand_stichtag')) {
      context.handle(
        _anfangsstandStichtagMeta,
        anfangsstandStichtag.isAcceptableOrUnknown(
          data['anfangsstand_stichtag']!,
          _anfangsstandStichtagMeta,
        ),
      );
    }
    if (data.containsKey('anfangsstand_urlaub_tage')) {
      context.handle(
        _anfangsstandUrlaubTageMeta,
        anfangsstandUrlaubTage.isAcceptableOrUnknown(
          data['anfangsstand_urlaub_tage']!,
          _anfangsstandUrlaubTageMeta,
        ),
      );
    }
    if (data.containsKey('anfangsstand_zeitausgleich_min')) {
      context.handle(
        _anfangsstandZeitausgleichMinMeta,
        anfangsstandZeitausgleichMin.isAcceptableOrUnknown(
          data['anfangsstand_zeitausgleich_min']!,
          _anfangsstandZeitausgleichMinMeta,
        ),
      );
    }
    if (data.containsKey('urlaub_fr_getrennt')) {
      context.handle(
        _urlaubFrGetrenntMeta,
        urlaubFrGetrennt.isAcceptableOrUnknown(
          data['urlaub_fr_getrennt']!,
          _urlaubFrGetrenntMeta,
        ),
      );
    }
    if (data.containsKey('anfangsstand_urlaub_fr_tage')) {
      context.handle(
        _anfangsstandUrlaubFrTageMeta,
        anfangsstandUrlaubFrTage.isAcceptableOrUnknown(
          data['anfangsstand_urlaub_fr_tage']!,
          _anfangsstandUrlaubFrTageMeta,
        ),
      );
    }
    if (data.containsKey('firmenurlaub_aktiv')) {
      context.handle(
        _firmenurlaubAktivMeta,
        firmenurlaubAktiv.isAcceptableOrUnknown(
          data['firmenurlaub_aktiv']!,
          _firmenurlaubAktivMeta,
        ),
      );
    }
    if (data.containsKey('anfangsstand_firmenurlaub_tage')) {
      context.handle(
        _anfangsstandFirmenurlaubTageMeta,
        anfangsstandFirmenurlaubTage.isAcceptableOrUnknown(
          data['anfangsstand_firmenurlaub_tage']!,
          _anfangsstandFirmenurlaubTageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  UserSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSetting(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      sollModus: $UserSettingsTable.$convertersollModus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}soll_modus'],
        )!,
      ),
      sollStundenTag: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}soll_stunden_tag'],
      )!,
      sollStundenMoDo: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}soll_stunden_mo_do'],
      )!,
      sollStundenFr: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}soll_stunden_fr'],
      )!,
      sollStundenMo: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}soll_stunden_mo'],
      )!,
      sollStundenDi: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}soll_stunden_di'],
      )!,
      sollStundenMi: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}soll_stunden_mi'],
      )!,
      sollStundenDo: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}soll_stunden_do'],
      )!,
      sollStundenFrTag: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}soll_stunden_fr_tag'],
      )!,
      sollStundenSa: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}soll_stunden_sa'],
      )!,
      sollStundenSo: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}soll_stunden_so'],
      )!,
      standardZeitenProTag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}standard_zeiten_pro_tag'],
      ),
      pausenregelAktiv: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pausenregel_aktiv'],
      )!,
      pausenSchwelleMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pausen_schwelle_min'],
      )!,
      pausenMindestMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pausen_mindest_min'],
      )!,
      standardBeginnMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}standard_beginn_min'],
      )!,
      standardEndeMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}standard_ende_min'],
      )!,
      standardPauseMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}standard_pause_min'],
      )!,
      standardBeginnFrMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}standard_beginn_fr_min'],
      ),
      standardEndeFrMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}standard_ende_fr_min'],
      ),
      standardPauseFrMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}standard_pause_fr_min'],
      ),
      anfangsstandStichtag: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}anfangsstand_stichtag'],
      ),
      anfangsstandUrlaubTage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}anfangsstand_urlaub_tage'],
      )!,
      anfangsstandZeitausgleichMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anfangsstand_zeitausgleich_min'],
      )!,
      urlaubFrGetrennt: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}urlaub_fr_getrennt'],
      )!,
      anfangsstandUrlaubFrTage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}anfangsstand_urlaub_fr_tage'],
      )!,
      firmenurlaubAktiv: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}firmenurlaub_aktiv'],
      )!,
      anfangsstandFirmenurlaubTage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}anfangsstand_firmenurlaub_tage'],
      )!,
    );
  }

  @override
  $UserSettingsTable createAlias(String alias) {
    return $UserSettingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SollModus, int, int> $convertersollModus =
      const EnumIndexConverter<SollModus>(SollModus.values);
}

class UserSetting extends DataClass implements Insertable<UserSetting> {
  final int userId;
  final SollModus sollModus;
  final double sollStundenTag;
  final double sollStundenMoDo;
  final double sollStundenFr;

  /// Sollstunden je Wochentag – nur relevant im Modus
  /// [SollModus.proWochentag]. Standard: Mo–Fr 8 h, Sa/So 0 h. So kann z.B.
  /// eine 25-Stunden-Woche mit freiem Mittwoch tagesgenau hinterlegt werden.
  final double sollStundenMo;
  final double sollStundenDi;
  final double sollStundenMi;
  final double sollStundenDo;
  final double sollStundenFrTag;
  final double sollStundenSa;
  final double sollStundenSo;

  /// Standardzeiten je Wochentag als JSON (Vorbelegung neuer Einträge im
  /// Modus [SollModus.proWochentag]). Aufbau: `{"1":{"b":420,"e":960,"p":30},
  /// …}` mit Wochentag 1=Mo … 7=So und Minuten seit Mitternacht. Fehlt ein
  /// Wochentag oder ein Feld, gilt der allgemeine Standard. `null` = für alle
  /// Tage der allgemeine Standard (Abwärtskompatibilität).
  final String? standardZeitenProTag;

  /// Automatische Pausenregel: Ab [pausenSchwelleMin] Minuten Anwesenheit
  /// muss die Pause mindestens [pausenMindestMin] Minuten betragen; eine
  /// zu kurze (oder aus Blocklücken errechnete) Pause wird nur AUFGEFÜLLT,
  /// nie doppelt abgezogen. Standard aus, Vorschlagswerte 12 h / 60 min.
  final bool pausenregelAktiv;
  final int pausenSchwelleMin;
  final int pausenMindestMin;

  /// Vorbelegung für neue Arbeits-Einträge (Minuten seit Mitternacht bzw.
  /// Pausendauer in Minuten). Vom Chef bei der Anlage gesetzt, danach vom
  /// Mitarbeiter selbst in seinen Einstellungen änderbar.
  final int standardBeginnMin;
  final int standardEndeMin;
  final int standardPauseMin;

  /// Abweichende Standardzeiten für den Freitag – nur relevant, wenn der
  /// Sollmodus [SollModus.moDoFrGetrennt] ist (der Freitag ist dort meist
  /// kürzer). `null` heißt „wie Mo–Do", damit sich für Bestandsbenutzer
  /// nichts ändert.
  final int? standardBeginnFrMin;
  final int? standardEndeFrMin;
  final int? standardPauseFrMin;

  /// Anfangsstand (vom Chef bei der Profilanlage gesetzt, später
  /// korrigierbar) zu einem Stichtag; die App schreibt die Stände danach
  /// automatisch fort, siehe lib/logic/konten.dart.
  final DateTime? anfangsstandStichtag;
  final double anfangsstandUrlaubTage;
  final int anfangsstandZeitausgleichMin;

  /// Freitags-Urlaub als eigenes Konto führen (manche Firmen vergeben
  /// Mo–Do- und Fr-Urlaub getrennt). Wenn aktiv, bucht Urlaub am Freitag
  /// vom Fr-Konto ab und [anfangsstandUrlaubTage] gilt nur für Mo–Do.
  final bool urlaubFrGetrennt;
  final double anfangsstandUrlaubFrTage;

  /// Interner Firmenurlaub als eigenes Konto führen: ein von der Firma
  /// bereitgestelltes Zusatz-Kontingent (z.B. eine Extra-Woche), das pro
  /// Mitarbeiter unterschiedlich hoch sein kann und nicht verfällt.
  /// Verbraucht wird es über [Tagesart.firmenurlaub]; den Anfangsstand
  /// erhöht der Chef jährlich selbst.
  final bool firmenurlaubAktiv;
  final double anfangsstandFirmenurlaubTage;
  const UserSetting({
    required this.userId,
    required this.sollModus,
    required this.sollStundenTag,
    required this.sollStundenMoDo,
    required this.sollStundenFr,
    required this.sollStundenMo,
    required this.sollStundenDi,
    required this.sollStundenMi,
    required this.sollStundenDo,
    required this.sollStundenFrTag,
    required this.sollStundenSa,
    required this.sollStundenSo,
    this.standardZeitenProTag,
    required this.pausenregelAktiv,
    required this.pausenSchwelleMin,
    required this.pausenMindestMin,
    required this.standardBeginnMin,
    required this.standardEndeMin,
    required this.standardPauseMin,
    this.standardBeginnFrMin,
    this.standardEndeFrMin,
    this.standardPauseFrMin,
    this.anfangsstandStichtag,
    required this.anfangsstandUrlaubTage,
    required this.anfangsstandZeitausgleichMin,
    required this.urlaubFrGetrennt,
    required this.anfangsstandUrlaubFrTage,
    required this.firmenurlaubAktiv,
    required this.anfangsstandFirmenurlaubTage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<int>(userId);
    {
      map['soll_modus'] = Variable<int>(
        $UserSettingsTable.$convertersollModus.toSql(sollModus),
      );
    }
    map['soll_stunden_tag'] = Variable<double>(sollStundenTag);
    map['soll_stunden_mo_do'] = Variable<double>(sollStundenMoDo);
    map['soll_stunden_fr'] = Variable<double>(sollStundenFr);
    map['soll_stunden_mo'] = Variable<double>(sollStundenMo);
    map['soll_stunden_di'] = Variable<double>(sollStundenDi);
    map['soll_stunden_mi'] = Variable<double>(sollStundenMi);
    map['soll_stunden_do'] = Variable<double>(sollStundenDo);
    map['soll_stunden_fr_tag'] = Variable<double>(sollStundenFrTag);
    map['soll_stunden_sa'] = Variable<double>(sollStundenSa);
    map['soll_stunden_so'] = Variable<double>(sollStundenSo);
    if (!nullToAbsent || standardZeitenProTag != null) {
      map['standard_zeiten_pro_tag'] = Variable<String>(standardZeitenProTag);
    }
    map['pausenregel_aktiv'] = Variable<bool>(pausenregelAktiv);
    map['pausen_schwelle_min'] = Variable<int>(pausenSchwelleMin);
    map['pausen_mindest_min'] = Variable<int>(pausenMindestMin);
    map['standard_beginn_min'] = Variable<int>(standardBeginnMin);
    map['standard_ende_min'] = Variable<int>(standardEndeMin);
    map['standard_pause_min'] = Variable<int>(standardPauseMin);
    if (!nullToAbsent || standardBeginnFrMin != null) {
      map['standard_beginn_fr_min'] = Variable<int>(standardBeginnFrMin);
    }
    if (!nullToAbsent || standardEndeFrMin != null) {
      map['standard_ende_fr_min'] = Variable<int>(standardEndeFrMin);
    }
    if (!nullToAbsent || standardPauseFrMin != null) {
      map['standard_pause_fr_min'] = Variable<int>(standardPauseFrMin);
    }
    if (!nullToAbsent || anfangsstandStichtag != null) {
      map['anfangsstand_stichtag'] = Variable<DateTime>(anfangsstandStichtag);
    }
    map['anfangsstand_urlaub_tage'] = Variable<double>(anfangsstandUrlaubTage);
    map['anfangsstand_zeitausgleich_min'] = Variable<int>(
      anfangsstandZeitausgleichMin,
    );
    map['urlaub_fr_getrennt'] = Variable<bool>(urlaubFrGetrennt);
    map['anfangsstand_urlaub_fr_tage'] = Variable<double>(
      anfangsstandUrlaubFrTage,
    );
    map['firmenurlaub_aktiv'] = Variable<bool>(firmenurlaubAktiv);
    map['anfangsstand_firmenurlaub_tage'] = Variable<double>(
      anfangsstandFirmenurlaubTage,
    );
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(
      userId: Value(userId),
      sollModus: Value(sollModus),
      sollStundenTag: Value(sollStundenTag),
      sollStundenMoDo: Value(sollStundenMoDo),
      sollStundenFr: Value(sollStundenFr),
      sollStundenMo: Value(sollStundenMo),
      sollStundenDi: Value(sollStundenDi),
      sollStundenMi: Value(sollStundenMi),
      sollStundenDo: Value(sollStundenDo),
      sollStundenFrTag: Value(sollStundenFrTag),
      sollStundenSa: Value(sollStundenSa),
      sollStundenSo: Value(sollStundenSo),
      standardZeitenProTag: standardZeitenProTag == null && nullToAbsent
          ? const Value.absent()
          : Value(standardZeitenProTag),
      pausenregelAktiv: Value(pausenregelAktiv),
      pausenSchwelleMin: Value(pausenSchwelleMin),
      pausenMindestMin: Value(pausenMindestMin),
      standardBeginnMin: Value(standardBeginnMin),
      standardEndeMin: Value(standardEndeMin),
      standardPauseMin: Value(standardPauseMin),
      standardBeginnFrMin: standardBeginnFrMin == null && nullToAbsent
          ? const Value.absent()
          : Value(standardBeginnFrMin),
      standardEndeFrMin: standardEndeFrMin == null && nullToAbsent
          ? const Value.absent()
          : Value(standardEndeFrMin),
      standardPauseFrMin: standardPauseFrMin == null && nullToAbsent
          ? const Value.absent()
          : Value(standardPauseFrMin),
      anfangsstandStichtag: anfangsstandStichtag == null && nullToAbsent
          ? const Value.absent()
          : Value(anfangsstandStichtag),
      anfangsstandUrlaubTage: Value(anfangsstandUrlaubTage),
      anfangsstandZeitausgleichMin: Value(anfangsstandZeitausgleichMin),
      urlaubFrGetrennt: Value(urlaubFrGetrennt),
      anfangsstandUrlaubFrTage: Value(anfangsstandUrlaubFrTage),
      firmenurlaubAktiv: Value(firmenurlaubAktiv),
      anfangsstandFirmenurlaubTage: Value(anfangsstandFirmenurlaubTage),
    );
  }

  factory UserSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSetting(
      userId: serializer.fromJson<int>(json['userId']),
      sollModus: $UserSettingsTable.$convertersollModus.fromJson(
        serializer.fromJson<int>(json['sollModus']),
      ),
      sollStundenTag: serializer.fromJson<double>(json['sollStundenTag']),
      sollStundenMoDo: serializer.fromJson<double>(json['sollStundenMoDo']),
      sollStundenFr: serializer.fromJson<double>(json['sollStundenFr']),
      sollStundenMo: serializer.fromJson<double>(json['sollStundenMo']),
      sollStundenDi: serializer.fromJson<double>(json['sollStundenDi']),
      sollStundenMi: serializer.fromJson<double>(json['sollStundenMi']),
      sollStundenDo: serializer.fromJson<double>(json['sollStundenDo']),
      sollStundenFrTag: serializer.fromJson<double>(json['sollStundenFrTag']),
      sollStundenSa: serializer.fromJson<double>(json['sollStundenSa']),
      sollStundenSo: serializer.fromJson<double>(json['sollStundenSo']),
      standardZeitenProTag: serializer.fromJson<String?>(
        json['standardZeitenProTag'],
      ),
      pausenregelAktiv: serializer.fromJson<bool>(json['pausenregelAktiv']),
      pausenSchwelleMin: serializer.fromJson<int>(json['pausenSchwelleMin']),
      pausenMindestMin: serializer.fromJson<int>(json['pausenMindestMin']),
      standardBeginnMin: serializer.fromJson<int>(json['standardBeginnMin']),
      standardEndeMin: serializer.fromJson<int>(json['standardEndeMin']),
      standardPauseMin: serializer.fromJson<int>(json['standardPauseMin']),
      standardBeginnFrMin: serializer.fromJson<int?>(
        json['standardBeginnFrMin'],
      ),
      standardEndeFrMin: serializer.fromJson<int?>(json['standardEndeFrMin']),
      standardPauseFrMin: serializer.fromJson<int?>(json['standardPauseFrMin']),
      anfangsstandStichtag: serializer.fromJson<DateTime?>(
        json['anfangsstandStichtag'],
      ),
      anfangsstandUrlaubTage: serializer.fromJson<double>(
        json['anfangsstandUrlaubTage'],
      ),
      anfangsstandZeitausgleichMin: serializer.fromJson<int>(
        json['anfangsstandZeitausgleichMin'],
      ),
      urlaubFrGetrennt: serializer.fromJson<bool>(json['urlaubFrGetrennt']),
      anfangsstandUrlaubFrTage: serializer.fromJson<double>(
        json['anfangsstandUrlaubFrTage'],
      ),
      firmenurlaubAktiv: serializer.fromJson<bool>(json['firmenurlaubAktiv']),
      anfangsstandFirmenurlaubTage: serializer.fromJson<double>(
        json['anfangsstandFirmenurlaubTage'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<int>(userId),
      'sollModus': serializer.toJson<int>(
        $UserSettingsTable.$convertersollModus.toJson(sollModus),
      ),
      'sollStundenTag': serializer.toJson<double>(sollStundenTag),
      'sollStundenMoDo': serializer.toJson<double>(sollStundenMoDo),
      'sollStundenFr': serializer.toJson<double>(sollStundenFr),
      'sollStundenMo': serializer.toJson<double>(sollStundenMo),
      'sollStundenDi': serializer.toJson<double>(sollStundenDi),
      'sollStundenMi': serializer.toJson<double>(sollStundenMi),
      'sollStundenDo': serializer.toJson<double>(sollStundenDo),
      'sollStundenFrTag': serializer.toJson<double>(sollStundenFrTag),
      'sollStundenSa': serializer.toJson<double>(sollStundenSa),
      'sollStundenSo': serializer.toJson<double>(sollStundenSo),
      'standardZeitenProTag': serializer.toJson<String?>(standardZeitenProTag),
      'pausenregelAktiv': serializer.toJson<bool>(pausenregelAktiv),
      'pausenSchwelleMin': serializer.toJson<int>(pausenSchwelleMin),
      'pausenMindestMin': serializer.toJson<int>(pausenMindestMin),
      'standardBeginnMin': serializer.toJson<int>(standardBeginnMin),
      'standardEndeMin': serializer.toJson<int>(standardEndeMin),
      'standardPauseMin': serializer.toJson<int>(standardPauseMin),
      'standardBeginnFrMin': serializer.toJson<int?>(standardBeginnFrMin),
      'standardEndeFrMin': serializer.toJson<int?>(standardEndeFrMin),
      'standardPauseFrMin': serializer.toJson<int?>(standardPauseFrMin),
      'anfangsstandStichtag': serializer.toJson<DateTime?>(
        anfangsstandStichtag,
      ),
      'anfangsstandUrlaubTage': serializer.toJson<double>(
        anfangsstandUrlaubTage,
      ),
      'anfangsstandZeitausgleichMin': serializer.toJson<int>(
        anfangsstandZeitausgleichMin,
      ),
      'urlaubFrGetrennt': serializer.toJson<bool>(urlaubFrGetrennt),
      'anfangsstandUrlaubFrTage': serializer.toJson<double>(
        anfangsstandUrlaubFrTage,
      ),
      'firmenurlaubAktiv': serializer.toJson<bool>(firmenurlaubAktiv),
      'anfangsstandFirmenurlaubTage': serializer.toJson<double>(
        anfangsstandFirmenurlaubTage,
      ),
    };
  }

  UserSetting copyWith({
    int? userId,
    SollModus? sollModus,
    double? sollStundenTag,
    double? sollStundenMoDo,
    double? sollStundenFr,
    double? sollStundenMo,
    double? sollStundenDi,
    double? sollStundenMi,
    double? sollStundenDo,
    double? sollStundenFrTag,
    double? sollStundenSa,
    double? sollStundenSo,
    Value<String?> standardZeitenProTag = const Value.absent(),
    bool? pausenregelAktiv,
    int? pausenSchwelleMin,
    int? pausenMindestMin,
    int? standardBeginnMin,
    int? standardEndeMin,
    int? standardPauseMin,
    Value<int?> standardBeginnFrMin = const Value.absent(),
    Value<int?> standardEndeFrMin = const Value.absent(),
    Value<int?> standardPauseFrMin = const Value.absent(),
    Value<DateTime?> anfangsstandStichtag = const Value.absent(),
    double? anfangsstandUrlaubTage,
    int? anfangsstandZeitausgleichMin,
    bool? urlaubFrGetrennt,
    double? anfangsstandUrlaubFrTage,
    bool? firmenurlaubAktiv,
    double? anfangsstandFirmenurlaubTage,
  }) => UserSetting(
    userId: userId ?? this.userId,
    sollModus: sollModus ?? this.sollModus,
    sollStundenTag: sollStundenTag ?? this.sollStundenTag,
    sollStundenMoDo: sollStundenMoDo ?? this.sollStundenMoDo,
    sollStundenFr: sollStundenFr ?? this.sollStundenFr,
    sollStundenMo: sollStundenMo ?? this.sollStundenMo,
    sollStundenDi: sollStundenDi ?? this.sollStundenDi,
    sollStundenMi: sollStundenMi ?? this.sollStundenMi,
    sollStundenDo: sollStundenDo ?? this.sollStundenDo,
    sollStundenFrTag: sollStundenFrTag ?? this.sollStundenFrTag,
    sollStundenSa: sollStundenSa ?? this.sollStundenSa,
    sollStundenSo: sollStundenSo ?? this.sollStundenSo,
    standardZeitenProTag: standardZeitenProTag.present
        ? standardZeitenProTag.value
        : this.standardZeitenProTag,
    pausenregelAktiv: pausenregelAktiv ?? this.pausenregelAktiv,
    pausenSchwelleMin: pausenSchwelleMin ?? this.pausenSchwelleMin,
    pausenMindestMin: pausenMindestMin ?? this.pausenMindestMin,
    standardBeginnMin: standardBeginnMin ?? this.standardBeginnMin,
    standardEndeMin: standardEndeMin ?? this.standardEndeMin,
    standardPauseMin: standardPauseMin ?? this.standardPauseMin,
    standardBeginnFrMin: standardBeginnFrMin.present
        ? standardBeginnFrMin.value
        : this.standardBeginnFrMin,
    standardEndeFrMin: standardEndeFrMin.present
        ? standardEndeFrMin.value
        : this.standardEndeFrMin,
    standardPauseFrMin: standardPauseFrMin.present
        ? standardPauseFrMin.value
        : this.standardPauseFrMin,
    anfangsstandStichtag: anfangsstandStichtag.present
        ? anfangsstandStichtag.value
        : this.anfangsstandStichtag,
    anfangsstandUrlaubTage:
        anfangsstandUrlaubTage ?? this.anfangsstandUrlaubTage,
    anfangsstandZeitausgleichMin:
        anfangsstandZeitausgleichMin ?? this.anfangsstandZeitausgleichMin,
    urlaubFrGetrennt: urlaubFrGetrennt ?? this.urlaubFrGetrennt,
    anfangsstandUrlaubFrTage:
        anfangsstandUrlaubFrTage ?? this.anfangsstandUrlaubFrTage,
    firmenurlaubAktiv: firmenurlaubAktiv ?? this.firmenurlaubAktiv,
    anfangsstandFirmenurlaubTage:
        anfangsstandFirmenurlaubTage ?? this.anfangsstandFirmenurlaubTage,
  );
  UserSetting copyWithCompanion(UserSettingsCompanion data) {
    return UserSetting(
      userId: data.userId.present ? data.userId.value : this.userId,
      sollModus: data.sollModus.present ? data.sollModus.value : this.sollModus,
      sollStundenTag: data.sollStundenTag.present
          ? data.sollStundenTag.value
          : this.sollStundenTag,
      sollStundenMoDo: data.sollStundenMoDo.present
          ? data.sollStundenMoDo.value
          : this.sollStundenMoDo,
      sollStundenFr: data.sollStundenFr.present
          ? data.sollStundenFr.value
          : this.sollStundenFr,
      sollStundenMo: data.sollStundenMo.present
          ? data.sollStundenMo.value
          : this.sollStundenMo,
      sollStundenDi: data.sollStundenDi.present
          ? data.sollStundenDi.value
          : this.sollStundenDi,
      sollStundenMi: data.sollStundenMi.present
          ? data.sollStundenMi.value
          : this.sollStundenMi,
      sollStundenDo: data.sollStundenDo.present
          ? data.sollStundenDo.value
          : this.sollStundenDo,
      sollStundenFrTag: data.sollStundenFrTag.present
          ? data.sollStundenFrTag.value
          : this.sollStundenFrTag,
      sollStundenSa: data.sollStundenSa.present
          ? data.sollStundenSa.value
          : this.sollStundenSa,
      sollStundenSo: data.sollStundenSo.present
          ? data.sollStundenSo.value
          : this.sollStundenSo,
      standardZeitenProTag: data.standardZeitenProTag.present
          ? data.standardZeitenProTag.value
          : this.standardZeitenProTag,
      pausenregelAktiv: data.pausenregelAktiv.present
          ? data.pausenregelAktiv.value
          : this.pausenregelAktiv,
      pausenSchwelleMin: data.pausenSchwelleMin.present
          ? data.pausenSchwelleMin.value
          : this.pausenSchwelleMin,
      pausenMindestMin: data.pausenMindestMin.present
          ? data.pausenMindestMin.value
          : this.pausenMindestMin,
      standardBeginnMin: data.standardBeginnMin.present
          ? data.standardBeginnMin.value
          : this.standardBeginnMin,
      standardEndeMin: data.standardEndeMin.present
          ? data.standardEndeMin.value
          : this.standardEndeMin,
      standardPauseMin: data.standardPauseMin.present
          ? data.standardPauseMin.value
          : this.standardPauseMin,
      standardBeginnFrMin: data.standardBeginnFrMin.present
          ? data.standardBeginnFrMin.value
          : this.standardBeginnFrMin,
      standardEndeFrMin: data.standardEndeFrMin.present
          ? data.standardEndeFrMin.value
          : this.standardEndeFrMin,
      standardPauseFrMin: data.standardPauseFrMin.present
          ? data.standardPauseFrMin.value
          : this.standardPauseFrMin,
      anfangsstandStichtag: data.anfangsstandStichtag.present
          ? data.anfangsstandStichtag.value
          : this.anfangsstandStichtag,
      anfangsstandUrlaubTage: data.anfangsstandUrlaubTage.present
          ? data.anfangsstandUrlaubTage.value
          : this.anfangsstandUrlaubTage,
      anfangsstandZeitausgleichMin: data.anfangsstandZeitausgleichMin.present
          ? data.anfangsstandZeitausgleichMin.value
          : this.anfangsstandZeitausgleichMin,
      urlaubFrGetrennt: data.urlaubFrGetrennt.present
          ? data.urlaubFrGetrennt.value
          : this.urlaubFrGetrennt,
      anfangsstandUrlaubFrTage: data.anfangsstandUrlaubFrTage.present
          ? data.anfangsstandUrlaubFrTage.value
          : this.anfangsstandUrlaubFrTage,
      firmenurlaubAktiv: data.firmenurlaubAktiv.present
          ? data.firmenurlaubAktiv.value
          : this.firmenurlaubAktiv,
      anfangsstandFirmenurlaubTage: data.anfangsstandFirmenurlaubTage.present
          ? data.anfangsstandFirmenurlaubTage.value
          : this.anfangsstandFirmenurlaubTage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSetting(')
          ..write('userId: $userId, ')
          ..write('sollModus: $sollModus, ')
          ..write('sollStundenTag: $sollStundenTag, ')
          ..write('sollStundenMoDo: $sollStundenMoDo, ')
          ..write('sollStundenFr: $sollStundenFr, ')
          ..write('sollStundenMo: $sollStundenMo, ')
          ..write('sollStundenDi: $sollStundenDi, ')
          ..write('sollStundenMi: $sollStundenMi, ')
          ..write('sollStundenDo: $sollStundenDo, ')
          ..write('sollStundenFrTag: $sollStundenFrTag, ')
          ..write('sollStundenSa: $sollStundenSa, ')
          ..write('sollStundenSo: $sollStundenSo, ')
          ..write('standardZeitenProTag: $standardZeitenProTag, ')
          ..write('pausenregelAktiv: $pausenregelAktiv, ')
          ..write('pausenSchwelleMin: $pausenSchwelleMin, ')
          ..write('pausenMindestMin: $pausenMindestMin, ')
          ..write('standardBeginnMin: $standardBeginnMin, ')
          ..write('standardEndeMin: $standardEndeMin, ')
          ..write('standardPauseMin: $standardPauseMin, ')
          ..write('standardBeginnFrMin: $standardBeginnFrMin, ')
          ..write('standardEndeFrMin: $standardEndeFrMin, ')
          ..write('standardPauseFrMin: $standardPauseFrMin, ')
          ..write('anfangsstandStichtag: $anfangsstandStichtag, ')
          ..write('anfangsstandUrlaubTage: $anfangsstandUrlaubTage, ')
          ..write(
            'anfangsstandZeitausgleichMin: $anfangsstandZeitausgleichMin, ',
          )
          ..write('urlaubFrGetrennt: $urlaubFrGetrennt, ')
          ..write('anfangsstandUrlaubFrTage: $anfangsstandUrlaubFrTage, ')
          ..write('firmenurlaubAktiv: $firmenurlaubAktiv, ')
          ..write('anfangsstandFirmenurlaubTage: $anfangsstandFirmenurlaubTage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    userId,
    sollModus,
    sollStundenTag,
    sollStundenMoDo,
    sollStundenFr,
    sollStundenMo,
    sollStundenDi,
    sollStundenMi,
    sollStundenDo,
    sollStundenFrTag,
    sollStundenSa,
    sollStundenSo,
    standardZeitenProTag,
    pausenregelAktiv,
    pausenSchwelleMin,
    pausenMindestMin,
    standardBeginnMin,
    standardEndeMin,
    standardPauseMin,
    standardBeginnFrMin,
    standardEndeFrMin,
    standardPauseFrMin,
    anfangsstandStichtag,
    anfangsstandUrlaubTage,
    anfangsstandZeitausgleichMin,
    urlaubFrGetrennt,
    anfangsstandUrlaubFrTage,
    firmenurlaubAktiv,
    anfangsstandFirmenurlaubTage,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSetting &&
          other.userId == this.userId &&
          other.sollModus == this.sollModus &&
          other.sollStundenTag == this.sollStundenTag &&
          other.sollStundenMoDo == this.sollStundenMoDo &&
          other.sollStundenFr == this.sollStundenFr &&
          other.sollStundenMo == this.sollStundenMo &&
          other.sollStundenDi == this.sollStundenDi &&
          other.sollStundenMi == this.sollStundenMi &&
          other.sollStundenDo == this.sollStundenDo &&
          other.sollStundenFrTag == this.sollStundenFrTag &&
          other.sollStundenSa == this.sollStundenSa &&
          other.sollStundenSo == this.sollStundenSo &&
          other.standardZeitenProTag == this.standardZeitenProTag &&
          other.pausenregelAktiv == this.pausenregelAktiv &&
          other.pausenSchwelleMin == this.pausenSchwelleMin &&
          other.pausenMindestMin == this.pausenMindestMin &&
          other.standardBeginnMin == this.standardBeginnMin &&
          other.standardEndeMin == this.standardEndeMin &&
          other.standardPauseMin == this.standardPauseMin &&
          other.standardBeginnFrMin == this.standardBeginnFrMin &&
          other.standardEndeFrMin == this.standardEndeFrMin &&
          other.standardPauseFrMin == this.standardPauseFrMin &&
          other.anfangsstandStichtag == this.anfangsstandStichtag &&
          other.anfangsstandUrlaubTage == this.anfangsstandUrlaubTage &&
          other.anfangsstandZeitausgleichMin ==
              this.anfangsstandZeitausgleichMin &&
          other.urlaubFrGetrennt == this.urlaubFrGetrennt &&
          other.anfangsstandUrlaubFrTage == this.anfangsstandUrlaubFrTage &&
          other.firmenurlaubAktiv == this.firmenurlaubAktiv &&
          other.anfangsstandFirmenurlaubTage ==
              this.anfangsstandFirmenurlaubTage);
}

class UserSettingsCompanion extends UpdateCompanion<UserSetting> {
  final Value<int> userId;
  final Value<SollModus> sollModus;
  final Value<double> sollStundenTag;
  final Value<double> sollStundenMoDo;
  final Value<double> sollStundenFr;
  final Value<double> sollStundenMo;
  final Value<double> sollStundenDi;
  final Value<double> sollStundenMi;
  final Value<double> sollStundenDo;
  final Value<double> sollStundenFrTag;
  final Value<double> sollStundenSa;
  final Value<double> sollStundenSo;
  final Value<String?> standardZeitenProTag;
  final Value<bool> pausenregelAktiv;
  final Value<int> pausenSchwelleMin;
  final Value<int> pausenMindestMin;
  final Value<int> standardBeginnMin;
  final Value<int> standardEndeMin;
  final Value<int> standardPauseMin;
  final Value<int?> standardBeginnFrMin;
  final Value<int?> standardEndeFrMin;
  final Value<int?> standardPauseFrMin;
  final Value<DateTime?> anfangsstandStichtag;
  final Value<double> anfangsstandUrlaubTage;
  final Value<int> anfangsstandZeitausgleichMin;
  final Value<bool> urlaubFrGetrennt;
  final Value<double> anfangsstandUrlaubFrTage;
  final Value<bool> firmenurlaubAktiv;
  final Value<double> anfangsstandFirmenurlaubTage;
  const UserSettingsCompanion({
    this.userId = const Value.absent(),
    this.sollModus = const Value.absent(),
    this.sollStundenTag = const Value.absent(),
    this.sollStundenMoDo = const Value.absent(),
    this.sollStundenFr = const Value.absent(),
    this.sollStundenMo = const Value.absent(),
    this.sollStundenDi = const Value.absent(),
    this.sollStundenMi = const Value.absent(),
    this.sollStundenDo = const Value.absent(),
    this.sollStundenFrTag = const Value.absent(),
    this.sollStundenSa = const Value.absent(),
    this.sollStundenSo = const Value.absent(),
    this.standardZeitenProTag = const Value.absent(),
    this.pausenregelAktiv = const Value.absent(),
    this.pausenSchwelleMin = const Value.absent(),
    this.pausenMindestMin = const Value.absent(),
    this.standardBeginnMin = const Value.absent(),
    this.standardEndeMin = const Value.absent(),
    this.standardPauseMin = const Value.absent(),
    this.standardBeginnFrMin = const Value.absent(),
    this.standardEndeFrMin = const Value.absent(),
    this.standardPauseFrMin = const Value.absent(),
    this.anfangsstandStichtag = const Value.absent(),
    this.anfangsstandUrlaubTage = const Value.absent(),
    this.anfangsstandZeitausgleichMin = const Value.absent(),
    this.urlaubFrGetrennt = const Value.absent(),
    this.anfangsstandUrlaubFrTage = const Value.absent(),
    this.firmenurlaubAktiv = const Value.absent(),
    this.anfangsstandFirmenurlaubTage = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    this.userId = const Value.absent(),
    required SollModus sollModus,
    this.sollStundenTag = const Value.absent(),
    this.sollStundenMoDo = const Value.absent(),
    this.sollStundenFr = const Value.absent(),
    this.sollStundenMo = const Value.absent(),
    this.sollStundenDi = const Value.absent(),
    this.sollStundenMi = const Value.absent(),
    this.sollStundenDo = const Value.absent(),
    this.sollStundenFrTag = const Value.absent(),
    this.sollStundenSa = const Value.absent(),
    this.sollStundenSo = const Value.absent(),
    this.standardZeitenProTag = const Value.absent(),
    this.pausenregelAktiv = const Value.absent(),
    this.pausenSchwelleMin = const Value.absent(),
    this.pausenMindestMin = const Value.absent(),
    this.standardBeginnMin = const Value.absent(),
    this.standardEndeMin = const Value.absent(),
    this.standardPauseMin = const Value.absent(),
    this.standardBeginnFrMin = const Value.absent(),
    this.standardEndeFrMin = const Value.absent(),
    this.standardPauseFrMin = const Value.absent(),
    this.anfangsstandStichtag = const Value.absent(),
    this.anfangsstandUrlaubTage = const Value.absent(),
    this.anfangsstandZeitausgleichMin = const Value.absent(),
    this.urlaubFrGetrennt = const Value.absent(),
    this.anfangsstandUrlaubFrTage = const Value.absent(),
    this.firmenurlaubAktiv = const Value.absent(),
    this.anfangsstandFirmenurlaubTage = const Value.absent(),
  }) : sollModus = Value(sollModus);
  static Insertable<UserSetting> custom({
    Expression<int>? userId,
    Expression<int>? sollModus,
    Expression<double>? sollStundenTag,
    Expression<double>? sollStundenMoDo,
    Expression<double>? sollStundenFr,
    Expression<double>? sollStundenMo,
    Expression<double>? sollStundenDi,
    Expression<double>? sollStundenMi,
    Expression<double>? sollStundenDo,
    Expression<double>? sollStundenFrTag,
    Expression<double>? sollStundenSa,
    Expression<double>? sollStundenSo,
    Expression<String>? standardZeitenProTag,
    Expression<bool>? pausenregelAktiv,
    Expression<int>? pausenSchwelleMin,
    Expression<int>? pausenMindestMin,
    Expression<int>? standardBeginnMin,
    Expression<int>? standardEndeMin,
    Expression<int>? standardPauseMin,
    Expression<int>? standardBeginnFrMin,
    Expression<int>? standardEndeFrMin,
    Expression<int>? standardPauseFrMin,
    Expression<DateTime>? anfangsstandStichtag,
    Expression<double>? anfangsstandUrlaubTage,
    Expression<int>? anfangsstandZeitausgleichMin,
    Expression<bool>? urlaubFrGetrennt,
    Expression<double>? anfangsstandUrlaubFrTage,
    Expression<bool>? firmenurlaubAktiv,
    Expression<double>? anfangsstandFirmenurlaubTage,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (sollModus != null) 'soll_modus': sollModus,
      if (sollStundenTag != null) 'soll_stunden_tag': sollStundenTag,
      if (sollStundenMoDo != null) 'soll_stunden_mo_do': sollStundenMoDo,
      if (sollStundenFr != null) 'soll_stunden_fr': sollStundenFr,
      if (sollStundenMo != null) 'soll_stunden_mo': sollStundenMo,
      if (sollStundenDi != null) 'soll_stunden_di': sollStundenDi,
      if (sollStundenMi != null) 'soll_stunden_mi': sollStundenMi,
      if (sollStundenDo != null) 'soll_stunden_do': sollStundenDo,
      if (sollStundenFrTag != null) 'soll_stunden_fr_tag': sollStundenFrTag,
      if (sollStundenSa != null) 'soll_stunden_sa': sollStundenSa,
      if (sollStundenSo != null) 'soll_stunden_so': sollStundenSo,
      if (standardZeitenProTag != null)
        'standard_zeiten_pro_tag': standardZeitenProTag,
      if (pausenregelAktiv != null) 'pausenregel_aktiv': pausenregelAktiv,
      if (pausenSchwelleMin != null) 'pausen_schwelle_min': pausenSchwelleMin,
      if (pausenMindestMin != null) 'pausen_mindest_min': pausenMindestMin,
      if (standardBeginnMin != null) 'standard_beginn_min': standardBeginnMin,
      if (standardEndeMin != null) 'standard_ende_min': standardEndeMin,
      if (standardPauseMin != null) 'standard_pause_min': standardPauseMin,
      if (standardBeginnFrMin != null)
        'standard_beginn_fr_min': standardBeginnFrMin,
      if (standardEndeFrMin != null) 'standard_ende_fr_min': standardEndeFrMin,
      if (standardPauseFrMin != null)
        'standard_pause_fr_min': standardPauseFrMin,
      if (anfangsstandStichtag != null)
        'anfangsstand_stichtag': anfangsstandStichtag,
      if (anfangsstandUrlaubTage != null)
        'anfangsstand_urlaub_tage': anfangsstandUrlaubTage,
      if (anfangsstandZeitausgleichMin != null)
        'anfangsstand_zeitausgleich_min': anfangsstandZeitausgleichMin,
      if (urlaubFrGetrennt != null) 'urlaub_fr_getrennt': urlaubFrGetrennt,
      if (anfangsstandUrlaubFrTage != null)
        'anfangsstand_urlaub_fr_tage': anfangsstandUrlaubFrTage,
      if (firmenurlaubAktiv != null) 'firmenurlaub_aktiv': firmenurlaubAktiv,
      if (anfangsstandFirmenurlaubTage != null)
        'anfangsstand_firmenurlaub_tage': anfangsstandFirmenurlaubTage,
    });
  }

  UserSettingsCompanion copyWith({
    Value<int>? userId,
    Value<SollModus>? sollModus,
    Value<double>? sollStundenTag,
    Value<double>? sollStundenMoDo,
    Value<double>? sollStundenFr,
    Value<double>? sollStundenMo,
    Value<double>? sollStundenDi,
    Value<double>? sollStundenMi,
    Value<double>? sollStundenDo,
    Value<double>? sollStundenFrTag,
    Value<double>? sollStundenSa,
    Value<double>? sollStundenSo,
    Value<String?>? standardZeitenProTag,
    Value<bool>? pausenregelAktiv,
    Value<int>? pausenSchwelleMin,
    Value<int>? pausenMindestMin,
    Value<int>? standardBeginnMin,
    Value<int>? standardEndeMin,
    Value<int>? standardPauseMin,
    Value<int?>? standardBeginnFrMin,
    Value<int?>? standardEndeFrMin,
    Value<int?>? standardPauseFrMin,
    Value<DateTime?>? anfangsstandStichtag,
    Value<double>? anfangsstandUrlaubTage,
    Value<int>? anfangsstandZeitausgleichMin,
    Value<bool>? urlaubFrGetrennt,
    Value<double>? anfangsstandUrlaubFrTage,
    Value<bool>? firmenurlaubAktiv,
    Value<double>? anfangsstandFirmenurlaubTage,
  }) {
    return UserSettingsCompanion(
      userId: userId ?? this.userId,
      sollModus: sollModus ?? this.sollModus,
      sollStundenTag: sollStundenTag ?? this.sollStundenTag,
      sollStundenMoDo: sollStundenMoDo ?? this.sollStundenMoDo,
      sollStundenFr: sollStundenFr ?? this.sollStundenFr,
      sollStundenMo: sollStundenMo ?? this.sollStundenMo,
      sollStundenDi: sollStundenDi ?? this.sollStundenDi,
      sollStundenMi: sollStundenMi ?? this.sollStundenMi,
      sollStundenDo: sollStundenDo ?? this.sollStundenDo,
      sollStundenFrTag: sollStundenFrTag ?? this.sollStundenFrTag,
      sollStundenSa: sollStundenSa ?? this.sollStundenSa,
      sollStundenSo: sollStundenSo ?? this.sollStundenSo,
      standardZeitenProTag: standardZeitenProTag ?? this.standardZeitenProTag,
      pausenregelAktiv: pausenregelAktiv ?? this.pausenregelAktiv,
      pausenSchwelleMin: pausenSchwelleMin ?? this.pausenSchwelleMin,
      pausenMindestMin: pausenMindestMin ?? this.pausenMindestMin,
      standardBeginnMin: standardBeginnMin ?? this.standardBeginnMin,
      standardEndeMin: standardEndeMin ?? this.standardEndeMin,
      standardPauseMin: standardPauseMin ?? this.standardPauseMin,
      standardBeginnFrMin: standardBeginnFrMin ?? this.standardBeginnFrMin,
      standardEndeFrMin: standardEndeFrMin ?? this.standardEndeFrMin,
      standardPauseFrMin: standardPauseFrMin ?? this.standardPauseFrMin,
      anfangsstandStichtag: anfangsstandStichtag ?? this.anfangsstandStichtag,
      anfangsstandUrlaubTage:
          anfangsstandUrlaubTage ?? this.anfangsstandUrlaubTage,
      anfangsstandZeitausgleichMin:
          anfangsstandZeitausgleichMin ?? this.anfangsstandZeitausgleichMin,
      urlaubFrGetrennt: urlaubFrGetrennt ?? this.urlaubFrGetrennt,
      anfangsstandUrlaubFrTage:
          anfangsstandUrlaubFrTage ?? this.anfangsstandUrlaubFrTage,
      firmenurlaubAktiv: firmenurlaubAktiv ?? this.firmenurlaubAktiv,
      anfangsstandFirmenurlaubTage:
          anfangsstandFirmenurlaubTage ?? this.anfangsstandFirmenurlaubTage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (sollModus.present) {
      map['soll_modus'] = Variable<int>(
        $UserSettingsTable.$convertersollModus.toSql(sollModus.value),
      );
    }
    if (sollStundenTag.present) {
      map['soll_stunden_tag'] = Variable<double>(sollStundenTag.value);
    }
    if (sollStundenMoDo.present) {
      map['soll_stunden_mo_do'] = Variable<double>(sollStundenMoDo.value);
    }
    if (sollStundenFr.present) {
      map['soll_stunden_fr'] = Variable<double>(sollStundenFr.value);
    }
    if (sollStundenMo.present) {
      map['soll_stunden_mo'] = Variable<double>(sollStundenMo.value);
    }
    if (sollStundenDi.present) {
      map['soll_stunden_di'] = Variable<double>(sollStundenDi.value);
    }
    if (sollStundenMi.present) {
      map['soll_stunden_mi'] = Variable<double>(sollStundenMi.value);
    }
    if (sollStundenDo.present) {
      map['soll_stunden_do'] = Variable<double>(sollStundenDo.value);
    }
    if (sollStundenFrTag.present) {
      map['soll_stunden_fr_tag'] = Variable<double>(sollStundenFrTag.value);
    }
    if (sollStundenSa.present) {
      map['soll_stunden_sa'] = Variable<double>(sollStundenSa.value);
    }
    if (sollStundenSo.present) {
      map['soll_stunden_so'] = Variable<double>(sollStundenSo.value);
    }
    if (standardZeitenProTag.present) {
      map['standard_zeiten_pro_tag'] = Variable<String>(
        standardZeitenProTag.value,
      );
    }
    if (pausenregelAktiv.present) {
      map['pausenregel_aktiv'] = Variable<bool>(pausenregelAktiv.value);
    }
    if (pausenSchwelleMin.present) {
      map['pausen_schwelle_min'] = Variable<int>(pausenSchwelleMin.value);
    }
    if (pausenMindestMin.present) {
      map['pausen_mindest_min'] = Variable<int>(pausenMindestMin.value);
    }
    if (standardBeginnMin.present) {
      map['standard_beginn_min'] = Variable<int>(standardBeginnMin.value);
    }
    if (standardEndeMin.present) {
      map['standard_ende_min'] = Variable<int>(standardEndeMin.value);
    }
    if (standardPauseMin.present) {
      map['standard_pause_min'] = Variable<int>(standardPauseMin.value);
    }
    if (standardBeginnFrMin.present) {
      map['standard_beginn_fr_min'] = Variable<int>(standardBeginnFrMin.value);
    }
    if (standardEndeFrMin.present) {
      map['standard_ende_fr_min'] = Variable<int>(standardEndeFrMin.value);
    }
    if (standardPauseFrMin.present) {
      map['standard_pause_fr_min'] = Variable<int>(standardPauseFrMin.value);
    }
    if (anfangsstandStichtag.present) {
      map['anfangsstand_stichtag'] = Variable<DateTime>(
        anfangsstandStichtag.value,
      );
    }
    if (anfangsstandUrlaubTage.present) {
      map['anfangsstand_urlaub_tage'] = Variable<double>(
        anfangsstandUrlaubTage.value,
      );
    }
    if (anfangsstandZeitausgleichMin.present) {
      map['anfangsstand_zeitausgleich_min'] = Variable<int>(
        anfangsstandZeitausgleichMin.value,
      );
    }
    if (urlaubFrGetrennt.present) {
      map['urlaub_fr_getrennt'] = Variable<bool>(urlaubFrGetrennt.value);
    }
    if (anfangsstandUrlaubFrTage.present) {
      map['anfangsstand_urlaub_fr_tage'] = Variable<double>(
        anfangsstandUrlaubFrTage.value,
      );
    }
    if (firmenurlaubAktiv.present) {
      map['firmenurlaub_aktiv'] = Variable<bool>(firmenurlaubAktiv.value);
    }
    if (anfangsstandFirmenurlaubTage.present) {
      map['anfangsstand_firmenurlaub_tage'] = Variable<double>(
        anfangsstandFirmenurlaubTage.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsCompanion(')
          ..write('userId: $userId, ')
          ..write('sollModus: $sollModus, ')
          ..write('sollStundenTag: $sollStundenTag, ')
          ..write('sollStundenMoDo: $sollStundenMoDo, ')
          ..write('sollStundenFr: $sollStundenFr, ')
          ..write('sollStundenMo: $sollStundenMo, ')
          ..write('sollStundenDi: $sollStundenDi, ')
          ..write('sollStundenMi: $sollStundenMi, ')
          ..write('sollStundenDo: $sollStundenDo, ')
          ..write('sollStundenFrTag: $sollStundenFrTag, ')
          ..write('sollStundenSa: $sollStundenSa, ')
          ..write('sollStundenSo: $sollStundenSo, ')
          ..write('standardZeitenProTag: $standardZeitenProTag, ')
          ..write('pausenregelAktiv: $pausenregelAktiv, ')
          ..write('pausenSchwelleMin: $pausenSchwelleMin, ')
          ..write('pausenMindestMin: $pausenMindestMin, ')
          ..write('standardBeginnMin: $standardBeginnMin, ')
          ..write('standardEndeMin: $standardEndeMin, ')
          ..write('standardPauseMin: $standardPauseMin, ')
          ..write('standardBeginnFrMin: $standardBeginnFrMin, ')
          ..write('standardEndeFrMin: $standardEndeFrMin, ')
          ..write('standardPauseFrMin: $standardPauseFrMin, ')
          ..write('anfangsstandStichtag: $anfangsstandStichtag, ')
          ..write('anfangsstandUrlaubTage: $anfangsstandUrlaubTage, ')
          ..write(
            'anfangsstandZeitausgleichMin: $anfangsstandZeitausgleichMin, ',
          )
          ..write('urlaubFrGetrennt: $urlaubFrGetrennt, ')
          ..write('anfangsstandUrlaubFrTage: $anfangsstandUrlaubFrTage, ')
          ..write('firmenurlaubAktiv: $firmenurlaubAktiv, ')
          ..write('anfangsstandFirmenurlaubTage: $anfangsstandFirmenurlaubTage')
          ..write(')'))
        .toString();
  }
}

class $PlacesTable extends Places with TableInfo<$PlacesTable, Place> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlacesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
    'last_used_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _useCountMeta = const VerificationMeta(
    'useCount',
  );
  @override
  late final GeneratedColumn<int> useCount = GeneratedColumn<int>(
    'use_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, lastUsedAt, useCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'places';
  @override
  VerificationContext validateIntegrity(
    Insertable<Place> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    }
    if (data.containsKey('use_count')) {
      context.handle(
        _useCountMeta,
        useCount.isAcceptableOrUnknown(data['use_count']!, _useCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Place map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Place(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used_at'],
      )!,
      useCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}use_count'],
      )!,
    );
  }

  @override
  $PlacesTable createAlias(String alias) {
    return $PlacesTable(attachedDatabase, alias);
  }
}

class Place extends DataClass implements Insertable<Place> {
  final int id;
  final String name;
  final DateTime lastUsedAt;
  final int useCount;
  const Place({
    required this.id,
    required this.name,
    required this.lastUsedAt,
    required this.useCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    map['use_count'] = Variable<int>(useCount);
    return map;
  }

  PlacesCompanion toCompanion(bool nullToAbsent) {
    return PlacesCompanion(
      id: Value(id),
      name: Value(name),
      lastUsedAt: Value(lastUsedAt),
      useCount: Value(useCount),
    );
  }

  factory Place.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Place(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      lastUsedAt: serializer.fromJson<DateTime>(json['lastUsedAt']),
      useCount: serializer.fromJson<int>(json['useCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'lastUsedAt': serializer.toJson<DateTime>(lastUsedAt),
      'useCount': serializer.toJson<int>(useCount),
    };
  }

  Place copyWith({
    int? id,
    String? name,
    DateTime? lastUsedAt,
    int? useCount,
  }) => Place(
    id: id ?? this.id,
    name: name ?? this.name,
    lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    useCount: useCount ?? this.useCount,
  );
  Place copyWithCompanion(PlacesCompanion data) {
    return Place(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
      useCount: data.useCount.present ? data.useCount.value : this.useCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Place(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('useCount: $useCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, lastUsedAt, useCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Place &&
          other.id == this.id &&
          other.name == this.name &&
          other.lastUsedAt == this.lastUsedAt &&
          other.useCount == this.useCount);
}

class PlacesCompanion extends UpdateCompanion<Place> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> lastUsedAt;
  final Value<int> useCount;
  const PlacesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.useCount = const Value.absent(),
  });
  PlacesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.lastUsedAt = const Value.absent(),
    this.useCount = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Place> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? lastUsedAt,
    Expression<int>? useCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (useCount != null) 'use_count': useCount,
    });
  }

  PlacesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? lastUsedAt,
    Value<int>? useCount,
  }) {
    return PlacesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      useCount: useCount ?? this.useCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    if (useCount.present) {
      map['use_count'] = Variable<int>(useCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlacesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('useCount: $useCount')
          ..write(')'))
        .toString();
  }
}

class $TimeEntriesTable extends TimeEntries
    with TableInfo<$TimeEntriesTable, TimeEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimeEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _datumMeta = const VerificationMeta('datum');
  @override
  late final GeneratedColumn<DateTime> datum = GeneratedColumn<DateTime>(
    'datum',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Tagesart, int> tagesart =
      GeneratedColumn<int>(
        'tagesart',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Tagesart>($TimeEntriesTable.$convertertagesart);
  static const VerificationMeta _ortIdMeta = const VerificationMeta('ortId');
  @override
  late final GeneratedColumn<int> ortId = GeneratedColumn<int>(
    'ort_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES places (id)',
    ),
  );
  static const VerificationMeta _beginnMinMeta = const VerificationMeta(
    'beginnMin',
  );
  @override
  late final GeneratedColumn<int> beginnMin = GeneratedColumn<int>(
    'beginn_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pauseMinMeta = const VerificationMeta(
    'pauseMin',
  );
  @override
  late final GeneratedColumn<int> pauseMin = GeneratedColumn<int>(
    'pause_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _endeMinMeta = const VerificationMeta(
    'endeMin',
  );
  @override
  late final GeneratedColumn<int> endeMin = GeneratedColumn<int>(
    'ende_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notizMeta = const VerificationMeta('notiz');
  @override
  late final GeneratedColumn<String> notiz = GeneratedColumn<String>(
    'notiz',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SonderurlaubGrund?, int>
  sonderurlaubGrund =
      GeneratedColumn<int>(
        'sonderurlaub_grund',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<SonderurlaubGrund?>(
        $TimeEntriesTable.$convertersonderurlaubGrundn,
      );
  static const VerificationMeta _urlaubMinutenMeta = const VerificationMeta(
    'urlaubMinuten',
  );
  @override
  late final GeneratedColumn<int> urlaubMinuten = GeneratedColumn<int>(
    'urlaub_minuten',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _halberTagMeta = const VerificationMeta(
    'halberTag',
  );
  @override
  late final GeneratedColumn<bool> halberTag = GeneratedColumn<bool>(
    'halber_tag',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("halber_tag" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    datum,
    tagesart,
    ortId,
    beginnMin,
    pauseMin,
    endeMin,
    notiz,
    sonderurlaubGrund,
    urlaubMinuten,
    halberTag,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'time_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimeEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('datum')) {
      context.handle(
        _datumMeta,
        datum.isAcceptableOrUnknown(data['datum']!, _datumMeta),
      );
    } else if (isInserting) {
      context.missing(_datumMeta);
    }
    if (data.containsKey('ort_id')) {
      context.handle(
        _ortIdMeta,
        ortId.isAcceptableOrUnknown(data['ort_id']!, _ortIdMeta),
      );
    }
    if (data.containsKey('beginn_min')) {
      context.handle(
        _beginnMinMeta,
        beginnMin.isAcceptableOrUnknown(data['beginn_min']!, _beginnMinMeta),
      );
    }
    if (data.containsKey('pause_min')) {
      context.handle(
        _pauseMinMeta,
        pauseMin.isAcceptableOrUnknown(data['pause_min']!, _pauseMinMeta),
      );
    }
    if (data.containsKey('ende_min')) {
      context.handle(
        _endeMinMeta,
        endeMin.isAcceptableOrUnknown(data['ende_min']!, _endeMinMeta),
      );
    }
    if (data.containsKey('notiz')) {
      context.handle(
        _notizMeta,
        notiz.isAcceptableOrUnknown(data['notiz']!, _notizMeta),
      );
    }
    if (data.containsKey('urlaub_minuten')) {
      context.handle(
        _urlaubMinutenMeta,
        urlaubMinuten.isAcceptableOrUnknown(
          data['urlaub_minuten']!,
          _urlaubMinutenMeta,
        ),
      );
    }
    if (data.containsKey('halber_tag')) {
      context.handle(
        _halberTagMeta,
        halberTag.isAcceptableOrUnknown(data['halber_tag']!, _halberTagMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {userId, datum},
  ];
  @override
  TimeEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimeEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      datum: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}datum'],
      )!,
      tagesart: $TimeEntriesTable.$convertertagesart.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}tagesart'],
        )!,
      ),
      ortId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ort_id'],
      ),
      beginnMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}beginn_min'],
      ),
      pauseMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pause_min'],
      )!,
      endeMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ende_min'],
      ),
      notiz: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notiz'],
      )!,
      sonderurlaubGrund: $TimeEntriesTable.$convertersonderurlaubGrundn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sonderurlaub_grund'],
        ),
      ),
      urlaubMinuten: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}urlaub_minuten'],
      ),
      halberTag: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}halber_tag'],
      )!,
    );
  }

  @override
  $TimeEntriesTable createAlias(String alias) {
    return $TimeEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Tagesart, int, int> $convertertagesart =
      const EnumIndexConverter<Tagesart>(Tagesart.values);
  static JsonTypeConverter2<SonderurlaubGrund, int, int>
  $convertersonderurlaubGrund = const EnumIndexConverter<SonderurlaubGrund>(
    SonderurlaubGrund.values,
  );
  static JsonTypeConverter2<SonderurlaubGrund?, int?, int?>
  $convertersonderurlaubGrundn = JsonTypeConverter2.asNullable(
    $convertersonderurlaubGrund,
  );
}

class TimeEntry extends DataClass implements Insertable<TimeEntry> {
  final int id;
  final int userId;

  /// Nur das Datum (Zeitanteil 00:00).
  final DateTime datum;
  final Tagesart tagesart;
  final int? ortId;

  /// Minuten seit Mitternacht, null wenn nicht erfasst.
  final int? beginnMin;
  final int pauseMin;
  final int? endeMin;
  final String notiz;

  /// Anlass bei [Tagesart.sonderurlaub], sonst null.
  final SonderurlaubGrund? sonderurlaubGrund;

  /// Urlaubsanteil des Tages in Minuten – gilt für Urlaub, Sonderurlaub und
  /// Firmenurlaub. `null` bedeutet „ganzer Tag". Ist der Anteil kleiner als
  /// das Tagessoll, darf am selben Tag zusätzlich gearbeitet werden.
  final int? urlaubMinuten;

  /// ALTFORMAT (bis Schema 3): halber Urlaubstag als Ja/Nein. Wird nicht
  /// mehr geschrieben, aber weiterhin gelesen – aufgelöst ausschließlich in
  /// `urlaubAnteil()` in lib/logic/berechnung.dart. Nicht migrierbar, weil
  /// der zugehörige Sollwert vom Wochentag und den Benutzereinstellungen
  /// abhängt.
  final bool halberTag;
  const TimeEntry({
    required this.id,
    required this.userId,
    required this.datum,
    required this.tagesart,
    this.ortId,
    this.beginnMin,
    required this.pauseMin,
    this.endeMin,
    required this.notiz,
    this.sonderurlaubGrund,
    this.urlaubMinuten,
    required this.halberTag,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['datum'] = Variable<DateTime>(datum);
    {
      map['tagesart'] = Variable<int>(
        $TimeEntriesTable.$convertertagesart.toSql(tagesart),
      );
    }
    if (!nullToAbsent || ortId != null) {
      map['ort_id'] = Variable<int>(ortId);
    }
    if (!nullToAbsent || beginnMin != null) {
      map['beginn_min'] = Variable<int>(beginnMin);
    }
    map['pause_min'] = Variable<int>(pauseMin);
    if (!nullToAbsent || endeMin != null) {
      map['ende_min'] = Variable<int>(endeMin);
    }
    map['notiz'] = Variable<String>(notiz);
    if (!nullToAbsent || sonderurlaubGrund != null) {
      map['sonderurlaub_grund'] = Variable<int>(
        $TimeEntriesTable.$convertersonderurlaubGrundn.toSql(sonderurlaubGrund),
      );
    }
    if (!nullToAbsent || urlaubMinuten != null) {
      map['urlaub_minuten'] = Variable<int>(urlaubMinuten);
    }
    map['halber_tag'] = Variable<bool>(halberTag);
    return map;
  }

  TimeEntriesCompanion toCompanion(bool nullToAbsent) {
    return TimeEntriesCompanion(
      id: Value(id),
      userId: Value(userId),
      datum: Value(datum),
      tagesart: Value(tagesart),
      ortId: ortId == null && nullToAbsent
          ? const Value.absent()
          : Value(ortId),
      beginnMin: beginnMin == null && nullToAbsent
          ? const Value.absent()
          : Value(beginnMin),
      pauseMin: Value(pauseMin),
      endeMin: endeMin == null && nullToAbsent
          ? const Value.absent()
          : Value(endeMin),
      notiz: Value(notiz),
      sonderurlaubGrund: sonderurlaubGrund == null && nullToAbsent
          ? const Value.absent()
          : Value(sonderurlaubGrund),
      urlaubMinuten: urlaubMinuten == null && nullToAbsent
          ? const Value.absent()
          : Value(urlaubMinuten),
      halberTag: Value(halberTag),
    );
  }

  factory TimeEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimeEntry(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      datum: serializer.fromJson<DateTime>(json['datum']),
      tagesart: $TimeEntriesTable.$convertertagesart.fromJson(
        serializer.fromJson<int>(json['tagesart']),
      ),
      ortId: serializer.fromJson<int?>(json['ortId']),
      beginnMin: serializer.fromJson<int?>(json['beginnMin']),
      pauseMin: serializer.fromJson<int>(json['pauseMin']),
      endeMin: serializer.fromJson<int?>(json['endeMin']),
      notiz: serializer.fromJson<String>(json['notiz']),
      sonderurlaubGrund: $TimeEntriesTable.$convertersonderurlaubGrundn
          .fromJson(serializer.fromJson<int?>(json['sonderurlaubGrund'])),
      urlaubMinuten: serializer.fromJson<int?>(json['urlaubMinuten']),
      halberTag: serializer.fromJson<bool>(json['halberTag']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'datum': serializer.toJson<DateTime>(datum),
      'tagesart': serializer.toJson<int>(
        $TimeEntriesTable.$convertertagesart.toJson(tagesart),
      ),
      'ortId': serializer.toJson<int?>(ortId),
      'beginnMin': serializer.toJson<int?>(beginnMin),
      'pauseMin': serializer.toJson<int>(pauseMin),
      'endeMin': serializer.toJson<int?>(endeMin),
      'notiz': serializer.toJson<String>(notiz),
      'sonderurlaubGrund': serializer.toJson<int?>(
        $TimeEntriesTable.$convertersonderurlaubGrundn.toJson(
          sonderurlaubGrund,
        ),
      ),
      'urlaubMinuten': serializer.toJson<int?>(urlaubMinuten),
      'halberTag': serializer.toJson<bool>(halberTag),
    };
  }

  TimeEntry copyWith({
    int? id,
    int? userId,
    DateTime? datum,
    Tagesart? tagesart,
    Value<int?> ortId = const Value.absent(),
    Value<int?> beginnMin = const Value.absent(),
    int? pauseMin,
    Value<int?> endeMin = const Value.absent(),
    String? notiz,
    Value<SonderurlaubGrund?> sonderurlaubGrund = const Value.absent(),
    Value<int?> urlaubMinuten = const Value.absent(),
    bool? halberTag,
  }) => TimeEntry(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    datum: datum ?? this.datum,
    tagesart: tagesart ?? this.tagesart,
    ortId: ortId.present ? ortId.value : this.ortId,
    beginnMin: beginnMin.present ? beginnMin.value : this.beginnMin,
    pauseMin: pauseMin ?? this.pauseMin,
    endeMin: endeMin.present ? endeMin.value : this.endeMin,
    notiz: notiz ?? this.notiz,
    sonderurlaubGrund: sonderurlaubGrund.present
        ? sonderurlaubGrund.value
        : this.sonderurlaubGrund,
    urlaubMinuten: urlaubMinuten.present
        ? urlaubMinuten.value
        : this.urlaubMinuten,
    halberTag: halberTag ?? this.halberTag,
  );
  TimeEntry copyWithCompanion(TimeEntriesCompanion data) {
    return TimeEntry(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      datum: data.datum.present ? data.datum.value : this.datum,
      tagesart: data.tagesart.present ? data.tagesart.value : this.tagesart,
      ortId: data.ortId.present ? data.ortId.value : this.ortId,
      beginnMin: data.beginnMin.present ? data.beginnMin.value : this.beginnMin,
      pauseMin: data.pauseMin.present ? data.pauseMin.value : this.pauseMin,
      endeMin: data.endeMin.present ? data.endeMin.value : this.endeMin,
      notiz: data.notiz.present ? data.notiz.value : this.notiz,
      sonderurlaubGrund: data.sonderurlaubGrund.present
          ? data.sonderurlaubGrund.value
          : this.sonderurlaubGrund,
      urlaubMinuten: data.urlaubMinuten.present
          ? data.urlaubMinuten.value
          : this.urlaubMinuten,
      halberTag: data.halberTag.present ? data.halberTag.value : this.halberTag,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimeEntry(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('datum: $datum, ')
          ..write('tagesart: $tagesart, ')
          ..write('ortId: $ortId, ')
          ..write('beginnMin: $beginnMin, ')
          ..write('pauseMin: $pauseMin, ')
          ..write('endeMin: $endeMin, ')
          ..write('notiz: $notiz, ')
          ..write('sonderurlaubGrund: $sonderurlaubGrund, ')
          ..write('urlaubMinuten: $urlaubMinuten, ')
          ..write('halberTag: $halberTag')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    datum,
    tagesart,
    ortId,
    beginnMin,
    pauseMin,
    endeMin,
    notiz,
    sonderurlaubGrund,
    urlaubMinuten,
    halberTag,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimeEntry &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.datum == this.datum &&
          other.tagesart == this.tagesart &&
          other.ortId == this.ortId &&
          other.beginnMin == this.beginnMin &&
          other.pauseMin == this.pauseMin &&
          other.endeMin == this.endeMin &&
          other.notiz == this.notiz &&
          other.sonderurlaubGrund == this.sonderurlaubGrund &&
          other.urlaubMinuten == this.urlaubMinuten &&
          other.halberTag == this.halberTag);
}

class TimeEntriesCompanion extends UpdateCompanion<TimeEntry> {
  final Value<int> id;
  final Value<int> userId;
  final Value<DateTime> datum;
  final Value<Tagesart> tagesart;
  final Value<int?> ortId;
  final Value<int?> beginnMin;
  final Value<int> pauseMin;
  final Value<int?> endeMin;
  final Value<String> notiz;
  final Value<SonderurlaubGrund?> sonderurlaubGrund;
  final Value<int?> urlaubMinuten;
  final Value<bool> halberTag;
  const TimeEntriesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.datum = const Value.absent(),
    this.tagesart = const Value.absent(),
    this.ortId = const Value.absent(),
    this.beginnMin = const Value.absent(),
    this.pauseMin = const Value.absent(),
    this.endeMin = const Value.absent(),
    this.notiz = const Value.absent(),
    this.sonderurlaubGrund = const Value.absent(),
    this.urlaubMinuten = const Value.absent(),
    this.halberTag = const Value.absent(),
  });
  TimeEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required DateTime datum,
    required Tagesart tagesart,
    this.ortId = const Value.absent(),
    this.beginnMin = const Value.absent(),
    this.pauseMin = const Value.absent(),
    this.endeMin = const Value.absent(),
    this.notiz = const Value.absent(),
    this.sonderurlaubGrund = const Value.absent(),
    this.urlaubMinuten = const Value.absent(),
    this.halberTag = const Value.absent(),
  }) : userId = Value(userId),
       datum = Value(datum),
       tagesart = Value(tagesart);
  static Insertable<TimeEntry> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<DateTime>? datum,
    Expression<int>? tagesart,
    Expression<int>? ortId,
    Expression<int>? beginnMin,
    Expression<int>? pauseMin,
    Expression<int>? endeMin,
    Expression<String>? notiz,
    Expression<int>? sonderurlaubGrund,
    Expression<int>? urlaubMinuten,
    Expression<bool>? halberTag,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (datum != null) 'datum': datum,
      if (tagesart != null) 'tagesart': tagesart,
      if (ortId != null) 'ort_id': ortId,
      if (beginnMin != null) 'beginn_min': beginnMin,
      if (pauseMin != null) 'pause_min': pauseMin,
      if (endeMin != null) 'ende_min': endeMin,
      if (notiz != null) 'notiz': notiz,
      if (sonderurlaubGrund != null) 'sonderurlaub_grund': sonderurlaubGrund,
      if (urlaubMinuten != null) 'urlaub_minuten': urlaubMinuten,
      if (halberTag != null) 'halber_tag': halberTag,
    });
  }

  TimeEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<DateTime>? datum,
    Value<Tagesart>? tagesart,
    Value<int?>? ortId,
    Value<int?>? beginnMin,
    Value<int>? pauseMin,
    Value<int?>? endeMin,
    Value<String>? notiz,
    Value<SonderurlaubGrund?>? sonderurlaubGrund,
    Value<int?>? urlaubMinuten,
    Value<bool>? halberTag,
  }) {
    return TimeEntriesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      datum: datum ?? this.datum,
      tagesart: tagesart ?? this.tagesart,
      ortId: ortId ?? this.ortId,
      beginnMin: beginnMin ?? this.beginnMin,
      pauseMin: pauseMin ?? this.pauseMin,
      endeMin: endeMin ?? this.endeMin,
      notiz: notiz ?? this.notiz,
      sonderurlaubGrund: sonderurlaubGrund ?? this.sonderurlaubGrund,
      urlaubMinuten: urlaubMinuten ?? this.urlaubMinuten,
      halberTag: halberTag ?? this.halberTag,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (datum.present) {
      map['datum'] = Variable<DateTime>(datum.value);
    }
    if (tagesart.present) {
      map['tagesart'] = Variable<int>(
        $TimeEntriesTable.$convertertagesart.toSql(tagesart.value),
      );
    }
    if (ortId.present) {
      map['ort_id'] = Variable<int>(ortId.value);
    }
    if (beginnMin.present) {
      map['beginn_min'] = Variable<int>(beginnMin.value);
    }
    if (pauseMin.present) {
      map['pause_min'] = Variable<int>(pauseMin.value);
    }
    if (endeMin.present) {
      map['ende_min'] = Variable<int>(endeMin.value);
    }
    if (notiz.present) {
      map['notiz'] = Variable<String>(notiz.value);
    }
    if (sonderurlaubGrund.present) {
      map['sonderurlaub_grund'] = Variable<int>(
        $TimeEntriesTable.$convertersonderurlaubGrundn.toSql(
          sonderurlaubGrund.value,
        ),
      );
    }
    if (urlaubMinuten.present) {
      map['urlaub_minuten'] = Variable<int>(urlaubMinuten.value);
    }
    if (halberTag.present) {
      map['halber_tag'] = Variable<bool>(halberTag.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimeEntriesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('datum: $datum, ')
          ..write('tagesart: $tagesart, ')
          ..write('ortId: $ortId, ')
          ..write('beginnMin: $beginnMin, ')
          ..write('pauseMin: $pauseMin, ')
          ..write('endeMin: $endeMin, ')
          ..write('notiz: $notiz, ')
          ..write('sonderurlaubGrund: $sonderurlaubGrund, ')
          ..write('urlaubMinuten: $urlaubMinuten, ')
          ..write('halberTag: $halberTag')
          ..write(')'))
        .toString();
  }
}

class $ZeitbloeckeTable extends Zeitbloecke
    with TableInfo<$ZeitbloeckeTable, Zeitblock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ZeitbloeckeTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _eintragIdMeta = const VerificationMeta(
    'eintragId',
  );
  @override
  late final GeneratedColumn<int> eintragId = GeneratedColumn<int>(
    'eintrag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES time_entries (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _beginnMinMeta = const VerificationMeta(
    'beginnMin',
  );
  @override
  late final GeneratedColumn<int> beginnMin = GeneratedColumn<int>(
    'beginn_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endeMinMeta = const VerificationMeta(
    'endeMin',
  );
  @override
  late final GeneratedColumn<int> endeMin = GeneratedColumn<int>(
    'ende_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pauseMinMeta = const VerificationMeta(
    'pauseMin',
  );
  @override
  late final GeneratedColumn<int> pauseMin = GeneratedColumn<int>(
    'pause_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eintragId,
    beginnMin,
    endeMin,
    pauseMin,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'zeitbloecke';
  @override
  VerificationContext validateIntegrity(
    Insertable<Zeitblock> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('eintrag_id')) {
      context.handle(
        _eintragIdMeta,
        eintragId.isAcceptableOrUnknown(data['eintrag_id']!, _eintragIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eintragIdMeta);
    }
    if (data.containsKey('beginn_min')) {
      context.handle(
        _beginnMinMeta,
        beginnMin.isAcceptableOrUnknown(data['beginn_min']!, _beginnMinMeta),
      );
    } else if (isInserting) {
      context.missing(_beginnMinMeta);
    }
    if (data.containsKey('ende_min')) {
      context.handle(
        _endeMinMeta,
        endeMin.isAcceptableOrUnknown(data['ende_min']!, _endeMinMeta),
      );
    }
    if (data.containsKey('pause_min')) {
      context.handle(
        _pauseMinMeta,
        pauseMin.isAcceptableOrUnknown(data['pause_min']!, _pauseMinMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Zeitblock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Zeitblock(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      eintragId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}eintrag_id'],
      )!,
      beginnMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}beginn_min'],
      )!,
      endeMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ende_min'],
      ),
      pauseMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pause_min'],
      )!,
    );
  }

  @override
  $ZeitbloeckeTable createAlias(String alias) {
    return $ZeitbloeckeTable(attachedDatabase, alias);
  }
}

class Zeitblock extends DataClass implements Insertable<Zeitblock> {
  final int id;
  final int eintragId;

  /// Minuten seit Mitternacht.
  final int beginnMin;

  /// `null` = offener Block (noch nicht ausgestempelt).
  final int? endeMin;

  /// Pause dieses Blocks in Minuten.
  final int pauseMin;
  const Zeitblock({
    required this.id,
    required this.eintragId,
    required this.beginnMin,
    this.endeMin,
    required this.pauseMin,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['eintrag_id'] = Variable<int>(eintragId);
    map['beginn_min'] = Variable<int>(beginnMin);
    if (!nullToAbsent || endeMin != null) {
      map['ende_min'] = Variable<int>(endeMin);
    }
    map['pause_min'] = Variable<int>(pauseMin);
    return map;
  }

  ZeitbloeckeCompanion toCompanion(bool nullToAbsent) {
    return ZeitbloeckeCompanion(
      id: Value(id),
      eintragId: Value(eintragId),
      beginnMin: Value(beginnMin),
      endeMin: endeMin == null && nullToAbsent
          ? const Value.absent()
          : Value(endeMin),
      pauseMin: Value(pauseMin),
    );
  }

  factory Zeitblock.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Zeitblock(
      id: serializer.fromJson<int>(json['id']),
      eintragId: serializer.fromJson<int>(json['eintragId']),
      beginnMin: serializer.fromJson<int>(json['beginnMin']),
      endeMin: serializer.fromJson<int?>(json['endeMin']),
      pauseMin: serializer.fromJson<int>(json['pauseMin']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'eintragId': serializer.toJson<int>(eintragId),
      'beginnMin': serializer.toJson<int>(beginnMin),
      'endeMin': serializer.toJson<int?>(endeMin),
      'pauseMin': serializer.toJson<int>(pauseMin),
    };
  }

  Zeitblock copyWith({
    int? id,
    int? eintragId,
    int? beginnMin,
    Value<int?> endeMin = const Value.absent(),
    int? pauseMin,
  }) => Zeitblock(
    id: id ?? this.id,
    eintragId: eintragId ?? this.eintragId,
    beginnMin: beginnMin ?? this.beginnMin,
    endeMin: endeMin.present ? endeMin.value : this.endeMin,
    pauseMin: pauseMin ?? this.pauseMin,
  );
  Zeitblock copyWithCompanion(ZeitbloeckeCompanion data) {
    return Zeitblock(
      id: data.id.present ? data.id.value : this.id,
      eintragId: data.eintragId.present ? data.eintragId.value : this.eintragId,
      beginnMin: data.beginnMin.present ? data.beginnMin.value : this.beginnMin,
      endeMin: data.endeMin.present ? data.endeMin.value : this.endeMin,
      pauseMin: data.pauseMin.present ? data.pauseMin.value : this.pauseMin,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Zeitblock(')
          ..write('id: $id, ')
          ..write('eintragId: $eintragId, ')
          ..write('beginnMin: $beginnMin, ')
          ..write('endeMin: $endeMin, ')
          ..write('pauseMin: $pauseMin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, eintragId, beginnMin, endeMin, pauseMin);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Zeitblock &&
          other.id == this.id &&
          other.eintragId == this.eintragId &&
          other.beginnMin == this.beginnMin &&
          other.endeMin == this.endeMin &&
          other.pauseMin == this.pauseMin);
}

class ZeitbloeckeCompanion extends UpdateCompanion<Zeitblock> {
  final Value<int> id;
  final Value<int> eintragId;
  final Value<int> beginnMin;
  final Value<int?> endeMin;
  final Value<int> pauseMin;
  const ZeitbloeckeCompanion({
    this.id = const Value.absent(),
    this.eintragId = const Value.absent(),
    this.beginnMin = const Value.absent(),
    this.endeMin = const Value.absent(),
    this.pauseMin = const Value.absent(),
  });
  ZeitbloeckeCompanion.insert({
    this.id = const Value.absent(),
    required int eintragId,
    required int beginnMin,
    this.endeMin = const Value.absent(),
    this.pauseMin = const Value.absent(),
  }) : eintragId = Value(eintragId),
       beginnMin = Value(beginnMin);
  static Insertable<Zeitblock> custom({
    Expression<int>? id,
    Expression<int>? eintragId,
    Expression<int>? beginnMin,
    Expression<int>? endeMin,
    Expression<int>? pauseMin,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eintragId != null) 'eintrag_id': eintragId,
      if (beginnMin != null) 'beginn_min': beginnMin,
      if (endeMin != null) 'ende_min': endeMin,
      if (pauseMin != null) 'pause_min': pauseMin,
    });
  }

  ZeitbloeckeCompanion copyWith({
    Value<int>? id,
    Value<int>? eintragId,
    Value<int>? beginnMin,
    Value<int?>? endeMin,
    Value<int>? pauseMin,
  }) {
    return ZeitbloeckeCompanion(
      id: id ?? this.id,
      eintragId: eintragId ?? this.eintragId,
      beginnMin: beginnMin ?? this.beginnMin,
      endeMin: endeMin ?? this.endeMin,
      pauseMin: pauseMin ?? this.pauseMin,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (eintragId.present) {
      map['eintrag_id'] = Variable<int>(eintragId.value);
    }
    if (beginnMin.present) {
      map['beginn_min'] = Variable<int>(beginnMin.value);
    }
    if (endeMin.present) {
      map['ende_min'] = Variable<int>(endeMin.value);
    }
    if (pauseMin.present) {
      map['pause_min'] = Variable<int>(pauseMin.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ZeitbloeckeCompanion(')
          ..write('id: $id, ')
          ..write('eintragId: $eintragId, ')
          ..write('beginnMin: $beginnMin, ')
          ..write('endeMin: $endeMin, ')
          ..write('pauseMin: $pauseMin')
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

class $BrandingsTable extends Brandings
    with TableInfo<$BrandingsTable, Branding> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BrandingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firmennameMeta = const VerificationMeta(
    'firmenname',
  );
  @override
  late final GeneratedColumn<String> firmenname = GeneratedColumn<String>(
    'firmenname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Zeitexa'),
  );
  static const VerificationMeta _adresseMeta = const VerificationMeta(
    'adresse',
  );
  @override
  late final GeneratedColumn<String> adresse = GeneratedColumn<String>(
    'adresse',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _telefonMeta = const VerificationMeta(
    'telefon',
  );
  @override
  late final GeneratedColumn<String> telefon = GeneratedColumn<String>(
    'telefon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _logoMeta = const VerificationMeta('logo');
  @override
  late final GeneratedColumn<Uint8List> logo = GeneratedColumn<Uint8List>(
    'logo',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _akzentFarbeMeta = const VerificationMeta(
    'akzentFarbe',
  );
  @override
  late final GeneratedColumn<int> akzentFarbe = GeneratedColumn<int>(
    'akzent_farbe',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFF1565C0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    firmenname,
    adresse,
    telefon,
    email,
    logo,
    akzentFarbe,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'brandings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Branding> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('firmenname')) {
      context.handle(
        _firmennameMeta,
        firmenname.isAcceptableOrUnknown(data['firmenname']!, _firmennameMeta),
      );
    }
    if (data.containsKey('adresse')) {
      context.handle(
        _adresseMeta,
        adresse.isAcceptableOrUnknown(data['adresse']!, _adresseMeta),
      );
    }
    if (data.containsKey('telefon')) {
      context.handle(
        _telefonMeta,
        telefon.isAcceptableOrUnknown(data['telefon']!, _telefonMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('logo')) {
      context.handle(
        _logoMeta,
        logo.isAcceptableOrUnknown(data['logo']!, _logoMeta),
      );
    }
    if (data.containsKey('akzent_farbe')) {
      context.handle(
        _akzentFarbeMeta,
        akzentFarbe.isAcceptableOrUnknown(
          data['akzent_farbe']!,
          _akzentFarbeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Branding map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Branding(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      firmenname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}firmenname'],
      )!,
      adresse: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adresse'],
      )!,
      telefon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telefon'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      logo: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}logo'],
      ),
      akzentFarbe: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}akzent_farbe'],
      )!,
    );
  }

  @override
  $BrandingsTable createAlias(String alias) {
    return $BrandingsTable(attachedDatabase, alias);
  }
}

class Branding extends DataClass implements Insertable<Branding> {
  final int id;
  final String firmenname;
  final String adresse;
  final String telefon;
  final String email;
  final Uint8List? logo;
  final int akzentFarbe;
  const Branding({
    required this.id,
    required this.firmenname,
    required this.adresse,
    required this.telefon,
    required this.email,
    this.logo,
    required this.akzentFarbe,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['firmenname'] = Variable<String>(firmenname);
    map['adresse'] = Variable<String>(adresse);
    map['telefon'] = Variable<String>(telefon);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || logo != null) {
      map['logo'] = Variable<Uint8List>(logo);
    }
    map['akzent_farbe'] = Variable<int>(akzentFarbe);
    return map;
  }

  BrandingsCompanion toCompanion(bool nullToAbsent) {
    return BrandingsCompanion(
      id: Value(id),
      firmenname: Value(firmenname),
      adresse: Value(adresse),
      telefon: Value(telefon),
      email: Value(email),
      logo: logo == null && nullToAbsent ? const Value.absent() : Value(logo),
      akzentFarbe: Value(akzentFarbe),
    );
  }

  factory Branding.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Branding(
      id: serializer.fromJson<int>(json['id']),
      firmenname: serializer.fromJson<String>(json['firmenname']),
      adresse: serializer.fromJson<String>(json['adresse']),
      telefon: serializer.fromJson<String>(json['telefon']),
      email: serializer.fromJson<String>(json['email']),
      logo: serializer.fromJson<Uint8List?>(json['logo']),
      akzentFarbe: serializer.fromJson<int>(json['akzentFarbe']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'firmenname': serializer.toJson<String>(firmenname),
      'adresse': serializer.toJson<String>(adresse),
      'telefon': serializer.toJson<String>(telefon),
      'email': serializer.toJson<String>(email),
      'logo': serializer.toJson<Uint8List?>(logo),
      'akzentFarbe': serializer.toJson<int>(akzentFarbe),
    };
  }

  Branding copyWith({
    int? id,
    String? firmenname,
    String? adresse,
    String? telefon,
    String? email,
    Value<Uint8List?> logo = const Value.absent(),
    int? akzentFarbe,
  }) => Branding(
    id: id ?? this.id,
    firmenname: firmenname ?? this.firmenname,
    adresse: adresse ?? this.adresse,
    telefon: telefon ?? this.telefon,
    email: email ?? this.email,
    logo: logo.present ? logo.value : this.logo,
    akzentFarbe: akzentFarbe ?? this.akzentFarbe,
  );
  Branding copyWithCompanion(BrandingsCompanion data) {
    return Branding(
      id: data.id.present ? data.id.value : this.id,
      firmenname: data.firmenname.present
          ? data.firmenname.value
          : this.firmenname,
      adresse: data.adresse.present ? data.adresse.value : this.adresse,
      telefon: data.telefon.present ? data.telefon.value : this.telefon,
      email: data.email.present ? data.email.value : this.email,
      logo: data.logo.present ? data.logo.value : this.logo,
      akzentFarbe: data.akzentFarbe.present
          ? data.akzentFarbe.value
          : this.akzentFarbe,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Branding(')
          ..write('id: $id, ')
          ..write('firmenname: $firmenname, ')
          ..write('adresse: $adresse, ')
          ..write('telefon: $telefon, ')
          ..write('email: $email, ')
          ..write('logo: $logo, ')
          ..write('akzentFarbe: $akzentFarbe')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    firmenname,
    adresse,
    telefon,
    email,
    $driftBlobEquality.hash(logo),
    akzentFarbe,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Branding &&
          other.id == this.id &&
          other.firmenname == this.firmenname &&
          other.adresse == this.adresse &&
          other.telefon == this.telefon &&
          other.email == this.email &&
          $driftBlobEquality.equals(other.logo, this.logo) &&
          other.akzentFarbe == this.akzentFarbe);
}

class BrandingsCompanion extends UpdateCompanion<Branding> {
  final Value<int> id;
  final Value<String> firmenname;
  final Value<String> adresse;
  final Value<String> telefon;
  final Value<String> email;
  final Value<Uint8List?> logo;
  final Value<int> akzentFarbe;
  const BrandingsCompanion({
    this.id = const Value.absent(),
    this.firmenname = const Value.absent(),
    this.adresse = const Value.absent(),
    this.telefon = const Value.absent(),
    this.email = const Value.absent(),
    this.logo = const Value.absent(),
    this.akzentFarbe = const Value.absent(),
  });
  BrandingsCompanion.insert({
    this.id = const Value.absent(),
    this.firmenname = const Value.absent(),
    this.adresse = const Value.absent(),
    this.telefon = const Value.absent(),
    this.email = const Value.absent(),
    this.logo = const Value.absent(),
    this.akzentFarbe = const Value.absent(),
  });
  static Insertable<Branding> custom({
    Expression<int>? id,
    Expression<String>? firmenname,
    Expression<String>? adresse,
    Expression<String>? telefon,
    Expression<String>? email,
    Expression<Uint8List>? logo,
    Expression<int>? akzentFarbe,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firmenname != null) 'firmenname': firmenname,
      if (adresse != null) 'adresse': adresse,
      if (telefon != null) 'telefon': telefon,
      if (email != null) 'email': email,
      if (logo != null) 'logo': logo,
      if (akzentFarbe != null) 'akzent_farbe': akzentFarbe,
    });
  }

  BrandingsCompanion copyWith({
    Value<int>? id,
    Value<String>? firmenname,
    Value<String>? adresse,
    Value<String>? telefon,
    Value<String>? email,
    Value<Uint8List?>? logo,
    Value<int>? akzentFarbe,
  }) {
    return BrandingsCompanion(
      id: id ?? this.id,
      firmenname: firmenname ?? this.firmenname,
      adresse: adresse ?? this.adresse,
      telefon: telefon ?? this.telefon,
      email: email ?? this.email,
      logo: logo ?? this.logo,
      akzentFarbe: akzentFarbe ?? this.akzentFarbe,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (firmenname.present) {
      map['firmenname'] = Variable<String>(firmenname.value);
    }
    if (adresse.present) {
      map['adresse'] = Variable<String>(adresse.value);
    }
    if (telefon.present) {
      map['telefon'] = Variable<String>(telefon.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (logo.present) {
      map['logo'] = Variable<Uint8List>(logo.value);
    }
    if (akzentFarbe.present) {
      map['akzent_farbe'] = Variable<int>(akzentFarbe.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BrandingsCompanion(')
          ..write('id: $id, ')
          ..write('firmenname: $firmenname, ')
          ..write('adresse: $adresse, ')
          ..write('telefon: $telefon, ')
          ..write('email: $email, ')
          ..write('logo: $logo, ')
          ..write('akzentFarbe: $akzentFarbe')
          ..write(')'))
        .toString();
  }
}

class $ImportedEntriesTable extends ImportedEntries
    with TableInfo<$ImportedEntriesTable, ImportedEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportedEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _quellUsernameMeta = const VerificationMeta(
    'quellUsername',
  );
  @override
  late final GeneratedColumn<String> quellUsername = GeneratedColumn<String>(
    'quell_username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quellDisplayNameMeta = const VerificationMeta(
    'quellDisplayName',
  );
  @override
  late final GeneratedColumn<String> quellDisplayName = GeneratedColumn<String>(
    'quell_display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monatMeta = const VerificationMeta('monat');
  @override
  late final GeneratedColumn<String> monat = GeneratedColumn<String>(
    'monat',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _datumMeta = const VerificationMeta('datum');
  @override
  late final GeneratedColumn<DateTime> datum = GeneratedColumn<DateTime>(
    'datum',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Tagesart, int> tagesart =
      GeneratedColumn<int>(
        'tagesart',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Tagesart>($ImportedEntriesTable.$convertertagesart);
  static const VerificationMeta _ortMeta = const VerificationMeta('ort');
  @override
  late final GeneratedColumn<String> ort = GeneratedColumn<String>(
    'ort',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _beginnMinMeta = const VerificationMeta(
    'beginnMin',
  );
  @override
  late final GeneratedColumn<int> beginnMin = GeneratedColumn<int>(
    'beginn_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pauseMinMeta = const VerificationMeta(
    'pauseMin',
  );
  @override
  late final GeneratedColumn<int> pauseMin = GeneratedColumn<int>(
    'pause_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _endeMinMeta = const VerificationMeta(
    'endeMin',
  );
  @override
  late final GeneratedColumn<int> endeMin = GeneratedColumn<int>(
    'ende_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notizMeta = const VerificationMeta('notiz');
  @override
  late final GeneratedColumn<String> notiz = GeneratedColumn<String>(
    'notiz',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SonderurlaubGrund?, int>
  sonderurlaubGrund =
      GeneratedColumn<int>(
        'sonderurlaub_grund',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<SonderurlaubGrund?>(
        $ImportedEntriesTable.$convertersonderurlaubGrundn,
      );
  static const VerificationMeta _urlaubMinutenMeta = const VerificationMeta(
    'urlaubMinuten',
  );
  @override
  late final GeneratedColumn<int> urlaubMinuten = GeneratedColumn<int>(
    'urlaub_minuten',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sollStundenMeta = const VerificationMeta(
    'sollStunden',
  );
  @override
  late final GeneratedColumn<double> sollStunden = GeneratedColumn<double>(
    'soll_stunden',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importZeitMeta = const VerificationMeta(
    'importZeit',
  );
  @override
  late final GeneratedColumn<DateTime> importZeit = GeneratedColumn<DateTime>(
    'import_zeit',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    quellUsername,
    quellDisplayName,
    monat,
    datum,
    tagesart,
    ort,
    beginnMin,
    pauseMin,
    endeMin,
    notiz,
    sonderurlaubGrund,
    urlaubMinuten,
    sollStunden,
    importZeit,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'imported_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportedEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('quell_username')) {
      context.handle(
        _quellUsernameMeta,
        quellUsername.isAcceptableOrUnknown(
          data['quell_username']!,
          _quellUsernameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quellUsernameMeta);
    }
    if (data.containsKey('quell_display_name')) {
      context.handle(
        _quellDisplayNameMeta,
        quellDisplayName.isAcceptableOrUnknown(
          data['quell_display_name']!,
          _quellDisplayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quellDisplayNameMeta);
    }
    if (data.containsKey('monat')) {
      context.handle(
        _monatMeta,
        monat.isAcceptableOrUnknown(data['monat']!, _monatMeta),
      );
    } else if (isInserting) {
      context.missing(_monatMeta);
    }
    if (data.containsKey('datum')) {
      context.handle(
        _datumMeta,
        datum.isAcceptableOrUnknown(data['datum']!, _datumMeta),
      );
    } else if (isInserting) {
      context.missing(_datumMeta);
    }
    if (data.containsKey('ort')) {
      context.handle(
        _ortMeta,
        ort.isAcceptableOrUnknown(data['ort']!, _ortMeta),
      );
    }
    if (data.containsKey('beginn_min')) {
      context.handle(
        _beginnMinMeta,
        beginnMin.isAcceptableOrUnknown(data['beginn_min']!, _beginnMinMeta),
      );
    }
    if (data.containsKey('pause_min')) {
      context.handle(
        _pauseMinMeta,
        pauseMin.isAcceptableOrUnknown(data['pause_min']!, _pauseMinMeta),
      );
    }
    if (data.containsKey('ende_min')) {
      context.handle(
        _endeMinMeta,
        endeMin.isAcceptableOrUnknown(data['ende_min']!, _endeMinMeta),
      );
    }
    if (data.containsKey('notiz')) {
      context.handle(
        _notizMeta,
        notiz.isAcceptableOrUnknown(data['notiz']!, _notizMeta),
      );
    }
    if (data.containsKey('urlaub_minuten')) {
      context.handle(
        _urlaubMinutenMeta,
        urlaubMinuten.isAcceptableOrUnknown(
          data['urlaub_minuten']!,
          _urlaubMinutenMeta,
        ),
      );
    }
    if (data.containsKey('soll_stunden')) {
      context.handle(
        _sollStundenMeta,
        sollStunden.isAcceptableOrUnknown(
          data['soll_stunden']!,
          _sollStundenMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sollStundenMeta);
    }
    if (data.containsKey('import_zeit')) {
      context.handle(
        _importZeitMeta,
        importZeit.isAcceptableOrUnknown(data['import_zeit']!, _importZeitMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImportedEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportedEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      quellUsername: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quell_username'],
      )!,
      quellDisplayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quell_display_name'],
      )!,
      monat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}monat'],
      )!,
      datum: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}datum'],
      )!,
      tagesart: $ImportedEntriesTable.$convertertagesart.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}tagesart'],
        )!,
      ),
      ort: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ort'],
      )!,
      beginnMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}beginn_min'],
      ),
      pauseMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pause_min'],
      )!,
      endeMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ende_min'],
      ),
      notiz: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notiz'],
      )!,
      sonderurlaubGrund: $ImportedEntriesTable.$convertersonderurlaubGrundn
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.int,
              data['${effectivePrefix}sonderurlaub_grund'],
            ),
          ),
      urlaubMinuten: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}urlaub_minuten'],
      ),
      sollStunden: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}soll_stunden'],
      )!,
      importZeit: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}import_zeit'],
      )!,
    );
  }

  @override
  $ImportedEntriesTable createAlias(String alias) {
    return $ImportedEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Tagesart, int, int> $convertertagesart =
      const EnumIndexConverter<Tagesart>(Tagesart.values);
  static JsonTypeConverter2<SonderurlaubGrund, int, int>
  $convertersonderurlaubGrund = const EnumIndexConverter<SonderurlaubGrund>(
    SonderurlaubGrund.values,
  );
  static JsonTypeConverter2<SonderurlaubGrund?, int?, int?>
  $convertersonderurlaubGrundn = JsonTypeConverter2.asNullable(
    $convertersonderurlaubGrund,
  );
}

class ImportedEntry extends DataClass implements Insertable<ImportedEntry> {
  final int id;
  final String quellUsername;
  final String quellDisplayName;

  /// 'JJJJ-MM' des exportierten Monats.
  final String monat;
  final DateTime datum;
  final Tagesart tagesart;
  final String ort;
  final int? beginnMin;
  final int pauseMin;
  final int? endeMin;
  final String notiz;

  /// Anlass bei [Tagesart.sonderurlaub] laut Export, sonst null.
  final SonderurlaubGrund? sonderurlaubGrund;

  /// Urlaubsanteil in Minuten laut Export; `null` = ganzer Tag. Das
  /// exportierende Gerät löst das Altformat `halberTag` bereits auf, hier
  /// steht also immer der fertige Minutenwert.
  final int? urlaubMinuten;

  /// Sollstunden des Tages laut Export (damit die Auswertung nicht von
  /// lokalen Einstellungen abhängt).
  final double sollStunden;
  final DateTime importZeit;
  const ImportedEntry({
    required this.id,
    required this.quellUsername,
    required this.quellDisplayName,
    required this.monat,
    required this.datum,
    required this.tagesart,
    required this.ort,
    this.beginnMin,
    required this.pauseMin,
    this.endeMin,
    required this.notiz,
    this.sonderurlaubGrund,
    this.urlaubMinuten,
    required this.sollStunden,
    required this.importZeit,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['quell_username'] = Variable<String>(quellUsername);
    map['quell_display_name'] = Variable<String>(quellDisplayName);
    map['monat'] = Variable<String>(monat);
    map['datum'] = Variable<DateTime>(datum);
    {
      map['tagesart'] = Variable<int>(
        $ImportedEntriesTable.$convertertagesart.toSql(tagesart),
      );
    }
    map['ort'] = Variable<String>(ort);
    if (!nullToAbsent || beginnMin != null) {
      map['beginn_min'] = Variable<int>(beginnMin);
    }
    map['pause_min'] = Variable<int>(pauseMin);
    if (!nullToAbsent || endeMin != null) {
      map['ende_min'] = Variable<int>(endeMin);
    }
    map['notiz'] = Variable<String>(notiz);
    if (!nullToAbsent || sonderurlaubGrund != null) {
      map['sonderurlaub_grund'] = Variable<int>(
        $ImportedEntriesTable.$convertersonderurlaubGrundn.toSql(
          sonderurlaubGrund,
        ),
      );
    }
    if (!nullToAbsent || urlaubMinuten != null) {
      map['urlaub_minuten'] = Variable<int>(urlaubMinuten);
    }
    map['soll_stunden'] = Variable<double>(sollStunden);
    map['import_zeit'] = Variable<DateTime>(importZeit);
    return map;
  }

  ImportedEntriesCompanion toCompanion(bool nullToAbsent) {
    return ImportedEntriesCompanion(
      id: Value(id),
      quellUsername: Value(quellUsername),
      quellDisplayName: Value(quellDisplayName),
      monat: Value(monat),
      datum: Value(datum),
      tagesart: Value(tagesart),
      ort: Value(ort),
      beginnMin: beginnMin == null && nullToAbsent
          ? const Value.absent()
          : Value(beginnMin),
      pauseMin: Value(pauseMin),
      endeMin: endeMin == null && nullToAbsent
          ? const Value.absent()
          : Value(endeMin),
      notiz: Value(notiz),
      sonderurlaubGrund: sonderurlaubGrund == null && nullToAbsent
          ? const Value.absent()
          : Value(sonderurlaubGrund),
      urlaubMinuten: urlaubMinuten == null && nullToAbsent
          ? const Value.absent()
          : Value(urlaubMinuten),
      sollStunden: Value(sollStunden),
      importZeit: Value(importZeit),
    );
  }

  factory ImportedEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportedEntry(
      id: serializer.fromJson<int>(json['id']),
      quellUsername: serializer.fromJson<String>(json['quellUsername']),
      quellDisplayName: serializer.fromJson<String>(json['quellDisplayName']),
      monat: serializer.fromJson<String>(json['monat']),
      datum: serializer.fromJson<DateTime>(json['datum']),
      tagesart: $ImportedEntriesTable.$convertertagesart.fromJson(
        serializer.fromJson<int>(json['tagesart']),
      ),
      ort: serializer.fromJson<String>(json['ort']),
      beginnMin: serializer.fromJson<int?>(json['beginnMin']),
      pauseMin: serializer.fromJson<int>(json['pauseMin']),
      endeMin: serializer.fromJson<int?>(json['endeMin']),
      notiz: serializer.fromJson<String>(json['notiz']),
      sonderurlaubGrund: $ImportedEntriesTable.$convertersonderurlaubGrundn
          .fromJson(serializer.fromJson<int?>(json['sonderurlaubGrund'])),
      urlaubMinuten: serializer.fromJson<int?>(json['urlaubMinuten']),
      sollStunden: serializer.fromJson<double>(json['sollStunden']),
      importZeit: serializer.fromJson<DateTime>(json['importZeit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'quellUsername': serializer.toJson<String>(quellUsername),
      'quellDisplayName': serializer.toJson<String>(quellDisplayName),
      'monat': serializer.toJson<String>(monat),
      'datum': serializer.toJson<DateTime>(datum),
      'tagesart': serializer.toJson<int>(
        $ImportedEntriesTable.$convertertagesart.toJson(tagesart),
      ),
      'ort': serializer.toJson<String>(ort),
      'beginnMin': serializer.toJson<int?>(beginnMin),
      'pauseMin': serializer.toJson<int>(pauseMin),
      'endeMin': serializer.toJson<int?>(endeMin),
      'notiz': serializer.toJson<String>(notiz),
      'sonderurlaubGrund': serializer.toJson<int?>(
        $ImportedEntriesTable.$convertersonderurlaubGrundn.toJson(
          sonderurlaubGrund,
        ),
      ),
      'urlaubMinuten': serializer.toJson<int?>(urlaubMinuten),
      'sollStunden': serializer.toJson<double>(sollStunden),
      'importZeit': serializer.toJson<DateTime>(importZeit),
    };
  }

  ImportedEntry copyWith({
    int? id,
    String? quellUsername,
    String? quellDisplayName,
    String? monat,
    DateTime? datum,
    Tagesart? tagesart,
    String? ort,
    Value<int?> beginnMin = const Value.absent(),
    int? pauseMin,
    Value<int?> endeMin = const Value.absent(),
    String? notiz,
    Value<SonderurlaubGrund?> sonderurlaubGrund = const Value.absent(),
    Value<int?> urlaubMinuten = const Value.absent(),
    double? sollStunden,
    DateTime? importZeit,
  }) => ImportedEntry(
    id: id ?? this.id,
    quellUsername: quellUsername ?? this.quellUsername,
    quellDisplayName: quellDisplayName ?? this.quellDisplayName,
    monat: monat ?? this.monat,
    datum: datum ?? this.datum,
    tagesart: tagesart ?? this.tagesart,
    ort: ort ?? this.ort,
    beginnMin: beginnMin.present ? beginnMin.value : this.beginnMin,
    pauseMin: pauseMin ?? this.pauseMin,
    endeMin: endeMin.present ? endeMin.value : this.endeMin,
    notiz: notiz ?? this.notiz,
    sonderurlaubGrund: sonderurlaubGrund.present
        ? sonderurlaubGrund.value
        : this.sonderurlaubGrund,
    urlaubMinuten: urlaubMinuten.present
        ? urlaubMinuten.value
        : this.urlaubMinuten,
    sollStunden: sollStunden ?? this.sollStunden,
    importZeit: importZeit ?? this.importZeit,
  );
  ImportedEntry copyWithCompanion(ImportedEntriesCompanion data) {
    return ImportedEntry(
      id: data.id.present ? data.id.value : this.id,
      quellUsername: data.quellUsername.present
          ? data.quellUsername.value
          : this.quellUsername,
      quellDisplayName: data.quellDisplayName.present
          ? data.quellDisplayName.value
          : this.quellDisplayName,
      monat: data.monat.present ? data.monat.value : this.monat,
      datum: data.datum.present ? data.datum.value : this.datum,
      tagesart: data.tagesart.present ? data.tagesart.value : this.tagesart,
      ort: data.ort.present ? data.ort.value : this.ort,
      beginnMin: data.beginnMin.present ? data.beginnMin.value : this.beginnMin,
      pauseMin: data.pauseMin.present ? data.pauseMin.value : this.pauseMin,
      endeMin: data.endeMin.present ? data.endeMin.value : this.endeMin,
      notiz: data.notiz.present ? data.notiz.value : this.notiz,
      sonderurlaubGrund: data.sonderurlaubGrund.present
          ? data.sonderurlaubGrund.value
          : this.sonderurlaubGrund,
      urlaubMinuten: data.urlaubMinuten.present
          ? data.urlaubMinuten.value
          : this.urlaubMinuten,
      sollStunden: data.sollStunden.present
          ? data.sollStunden.value
          : this.sollStunden,
      importZeit: data.importZeit.present
          ? data.importZeit.value
          : this.importZeit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportedEntry(')
          ..write('id: $id, ')
          ..write('quellUsername: $quellUsername, ')
          ..write('quellDisplayName: $quellDisplayName, ')
          ..write('monat: $monat, ')
          ..write('datum: $datum, ')
          ..write('tagesart: $tagesart, ')
          ..write('ort: $ort, ')
          ..write('beginnMin: $beginnMin, ')
          ..write('pauseMin: $pauseMin, ')
          ..write('endeMin: $endeMin, ')
          ..write('notiz: $notiz, ')
          ..write('sonderurlaubGrund: $sonderurlaubGrund, ')
          ..write('urlaubMinuten: $urlaubMinuten, ')
          ..write('sollStunden: $sollStunden, ')
          ..write('importZeit: $importZeit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    quellUsername,
    quellDisplayName,
    monat,
    datum,
    tagesart,
    ort,
    beginnMin,
    pauseMin,
    endeMin,
    notiz,
    sonderurlaubGrund,
    urlaubMinuten,
    sollStunden,
    importZeit,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportedEntry &&
          other.id == this.id &&
          other.quellUsername == this.quellUsername &&
          other.quellDisplayName == this.quellDisplayName &&
          other.monat == this.monat &&
          other.datum == this.datum &&
          other.tagesart == this.tagesart &&
          other.ort == this.ort &&
          other.beginnMin == this.beginnMin &&
          other.pauseMin == this.pauseMin &&
          other.endeMin == this.endeMin &&
          other.notiz == this.notiz &&
          other.sonderurlaubGrund == this.sonderurlaubGrund &&
          other.urlaubMinuten == this.urlaubMinuten &&
          other.sollStunden == this.sollStunden &&
          other.importZeit == this.importZeit);
}

class ImportedEntriesCompanion extends UpdateCompanion<ImportedEntry> {
  final Value<int> id;
  final Value<String> quellUsername;
  final Value<String> quellDisplayName;
  final Value<String> monat;
  final Value<DateTime> datum;
  final Value<Tagesart> tagesart;
  final Value<String> ort;
  final Value<int?> beginnMin;
  final Value<int> pauseMin;
  final Value<int?> endeMin;
  final Value<String> notiz;
  final Value<SonderurlaubGrund?> sonderurlaubGrund;
  final Value<int?> urlaubMinuten;
  final Value<double> sollStunden;
  final Value<DateTime> importZeit;
  const ImportedEntriesCompanion({
    this.id = const Value.absent(),
    this.quellUsername = const Value.absent(),
    this.quellDisplayName = const Value.absent(),
    this.monat = const Value.absent(),
    this.datum = const Value.absent(),
    this.tagesart = const Value.absent(),
    this.ort = const Value.absent(),
    this.beginnMin = const Value.absent(),
    this.pauseMin = const Value.absent(),
    this.endeMin = const Value.absent(),
    this.notiz = const Value.absent(),
    this.sonderurlaubGrund = const Value.absent(),
    this.urlaubMinuten = const Value.absent(),
    this.sollStunden = const Value.absent(),
    this.importZeit = const Value.absent(),
  });
  ImportedEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String quellUsername,
    required String quellDisplayName,
    required String monat,
    required DateTime datum,
    required Tagesart tagesart,
    this.ort = const Value.absent(),
    this.beginnMin = const Value.absent(),
    this.pauseMin = const Value.absent(),
    this.endeMin = const Value.absent(),
    this.notiz = const Value.absent(),
    this.sonderurlaubGrund = const Value.absent(),
    this.urlaubMinuten = const Value.absent(),
    required double sollStunden,
    this.importZeit = const Value.absent(),
  }) : quellUsername = Value(quellUsername),
       quellDisplayName = Value(quellDisplayName),
       monat = Value(monat),
       datum = Value(datum),
       tagesart = Value(tagesart),
       sollStunden = Value(sollStunden);
  static Insertable<ImportedEntry> custom({
    Expression<int>? id,
    Expression<String>? quellUsername,
    Expression<String>? quellDisplayName,
    Expression<String>? monat,
    Expression<DateTime>? datum,
    Expression<int>? tagesart,
    Expression<String>? ort,
    Expression<int>? beginnMin,
    Expression<int>? pauseMin,
    Expression<int>? endeMin,
    Expression<String>? notiz,
    Expression<int>? sonderurlaubGrund,
    Expression<int>? urlaubMinuten,
    Expression<double>? sollStunden,
    Expression<DateTime>? importZeit,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (quellUsername != null) 'quell_username': quellUsername,
      if (quellDisplayName != null) 'quell_display_name': quellDisplayName,
      if (monat != null) 'monat': monat,
      if (datum != null) 'datum': datum,
      if (tagesart != null) 'tagesart': tagesart,
      if (ort != null) 'ort': ort,
      if (beginnMin != null) 'beginn_min': beginnMin,
      if (pauseMin != null) 'pause_min': pauseMin,
      if (endeMin != null) 'ende_min': endeMin,
      if (notiz != null) 'notiz': notiz,
      if (sonderurlaubGrund != null) 'sonderurlaub_grund': sonderurlaubGrund,
      if (urlaubMinuten != null) 'urlaub_minuten': urlaubMinuten,
      if (sollStunden != null) 'soll_stunden': sollStunden,
      if (importZeit != null) 'import_zeit': importZeit,
    });
  }

  ImportedEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? quellUsername,
    Value<String>? quellDisplayName,
    Value<String>? monat,
    Value<DateTime>? datum,
    Value<Tagesart>? tagesart,
    Value<String>? ort,
    Value<int?>? beginnMin,
    Value<int>? pauseMin,
    Value<int?>? endeMin,
    Value<String>? notiz,
    Value<SonderurlaubGrund?>? sonderurlaubGrund,
    Value<int?>? urlaubMinuten,
    Value<double>? sollStunden,
    Value<DateTime>? importZeit,
  }) {
    return ImportedEntriesCompanion(
      id: id ?? this.id,
      quellUsername: quellUsername ?? this.quellUsername,
      quellDisplayName: quellDisplayName ?? this.quellDisplayName,
      monat: monat ?? this.monat,
      datum: datum ?? this.datum,
      tagesart: tagesart ?? this.tagesart,
      ort: ort ?? this.ort,
      beginnMin: beginnMin ?? this.beginnMin,
      pauseMin: pauseMin ?? this.pauseMin,
      endeMin: endeMin ?? this.endeMin,
      notiz: notiz ?? this.notiz,
      sonderurlaubGrund: sonderurlaubGrund ?? this.sonderurlaubGrund,
      urlaubMinuten: urlaubMinuten ?? this.urlaubMinuten,
      sollStunden: sollStunden ?? this.sollStunden,
      importZeit: importZeit ?? this.importZeit,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (quellUsername.present) {
      map['quell_username'] = Variable<String>(quellUsername.value);
    }
    if (quellDisplayName.present) {
      map['quell_display_name'] = Variable<String>(quellDisplayName.value);
    }
    if (monat.present) {
      map['monat'] = Variable<String>(monat.value);
    }
    if (datum.present) {
      map['datum'] = Variable<DateTime>(datum.value);
    }
    if (tagesart.present) {
      map['tagesart'] = Variable<int>(
        $ImportedEntriesTable.$convertertagesart.toSql(tagesart.value),
      );
    }
    if (ort.present) {
      map['ort'] = Variable<String>(ort.value);
    }
    if (beginnMin.present) {
      map['beginn_min'] = Variable<int>(beginnMin.value);
    }
    if (pauseMin.present) {
      map['pause_min'] = Variable<int>(pauseMin.value);
    }
    if (endeMin.present) {
      map['ende_min'] = Variable<int>(endeMin.value);
    }
    if (notiz.present) {
      map['notiz'] = Variable<String>(notiz.value);
    }
    if (sonderurlaubGrund.present) {
      map['sonderurlaub_grund'] = Variable<int>(
        $ImportedEntriesTable.$convertersonderurlaubGrundn.toSql(
          sonderurlaubGrund.value,
        ),
      );
    }
    if (urlaubMinuten.present) {
      map['urlaub_minuten'] = Variable<int>(urlaubMinuten.value);
    }
    if (sollStunden.present) {
      map['soll_stunden'] = Variable<double>(sollStunden.value);
    }
    if (importZeit.present) {
      map['import_zeit'] = Variable<DateTime>(importZeit.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportedEntriesCompanion(')
          ..write('id: $id, ')
          ..write('quellUsername: $quellUsername, ')
          ..write('quellDisplayName: $quellDisplayName, ')
          ..write('monat: $monat, ')
          ..write('datum: $datum, ')
          ..write('tagesart: $tagesart, ')
          ..write('ort: $ort, ')
          ..write('beginnMin: $beginnMin, ')
          ..write('pauseMin: $pauseMin, ')
          ..write('endeMin: $endeMin, ')
          ..write('notiz: $notiz, ')
          ..write('sonderurlaubGrund: $sonderurlaubGrund, ')
          ..write('urlaubMinuten: $urlaubMinuten, ')
          ..write('sollStunden: $sollStunden, ')
          ..write('importZeit: $importZeit')
          ..write(')'))
        .toString();
  }
}

abstract class _$ZeitexaDb extends GeneratedDatabase {
  _$ZeitexaDb(QueryExecutor e) : super(e);
  $ZeitexaDbManager get managers => $ZeitexaDbManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  late final $PlacesTable places = $PlacesTable(this);
  late final $TimeEntriesTable timeEntries = $TimeEntriesTable(this);
  late final $ZeitbloeckeTable zeitbloecke = $ZeitbloeckeTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $BrandingsTable brandings = $BrandingsTable(this);
  late final $ImportedEntriesTable importedEntries = $ImportedEntriesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    userSettings,
    places,
    timeEntries,
    zeitbloecke,
    appSettings,
    brandings,
    importedEntries,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'time_entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('zeitbloecke', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      required String username,
      required String passwordHash,
      required String displayName,
      Value<bool> isAdmin,
      Value<bool> mustChangePassword,
      Value<DateTime> createdAt,
      Value<String> mitarbeiterEmail,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      Value<String> username,
      Value<String> passwordHash,
      Value<String> displayName,
      Value<bool> isAdmin,
      Value<bool> mustChangePassword,
      Value<DateTime> createdAt,
      Value<String> mitarbeiterEmail,
    });

final class $$UsersTableReferences
    extends BaseReferences<_$ZeitexaDb, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserSettingsTable, List<UserSetting>>
  _userSettingsRefsTable(_$ZeitexaDb db) => MultiTypedResultKey.fromTable(
    db.userSettings,
    aliasName: 'users__id__user_settings__user_id',
  );

  $$UserSettingsTableProcessedTableManager get userSettingsRefs {
    final manager = $$UserSettingsTableTableManager(
      $_db,
      $_db.userSettings,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userSettingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TimeEntriesTable, List<TimeEntry>>
  _timeEntriesRefsTable(_$ZeitexaDb db) => MultiTypedResultKey.fromTable(
    db.timeEntries,
    aliasName: 'users__id__time_entries__user_id',
  );

  $$TimeEntriesTableProcessedTableManager get timeEntriesRefs {
    final manager = $$TimeEntriesTableTableManager(
      $_db,
      $_db.timeEntries,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_timeEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsersTableFilterComposer extends Composer<_$ZeitexaDb, $UsersTable> {
  $$UsersTableFilterComposer({
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

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAdmin => $composableBuilder(
    column: $table.isAdmin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get mustChangePassword => $composableBuilder(
    column: $table.mustChangePassword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mitarbeiterEmail => $composableBuilder(
    column: $table.mitarbeiterEmail,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> userSettingsRefs(
    Expression<bool> Function($$UserSettingsTableFilterComposer f) f,
  ) {
    final $$UserSettingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userSettings,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserSettingsTableFilterComposer(
            $db: $db,
            $table: $db.userSettings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> timeEntriesRefs(
    Expression<bool> Function($$TimeEntriesTableFilterComposer f) f,
  ) {
    final $$TimeEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timeEntries,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimeEntriesTableFilterComposer(
            $db: $db,
            $table: $db.timeEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableOrderingComposer extends Composer<_$ZeitexaDb, $UsersTable> {
  $$UsersTableOrderingComposer({
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

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAdmin => $composableBuilder(
    column: $table.isAdmin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get mustChangePassword => $composableBuilder(
    column: $table.mustChangePassword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mitarbeiterEmail => $composableBuilder(
    column: $table.mitarbeiterEmail,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$ZeitexaDb, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAdmin =>
      $composableBuilder(column: $table.isAdmin, builder: (column) => column);

  GeneratedColumn<bool> get mustChangePassword => $composableBuilder(
    column: $table.mustChangePassword,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get mitarbeiterEmail => $composableBuilder(
    column: $table.mitarbeiterEmail,
    builder: (column) => column,
  );

  Expression<T> userSettingsRefs<T extends Object>(
    Expression<T> Function($$UserSettingsTableAnnotationComposer a) f,
  ) {
    final $$UserSettingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userSettings,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserSettingsTableAnnotationComposer(
            $db: $db,
            $table: $db.userSettings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> timeEntriesRefs<T extends Object>(
    Expression<T> Function($$TimeEntriesTableAnnotationComposer a) f,
  ) {
    final $$TimeEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timeEntries,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimeEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.timeEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$ZeitexaDb,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, $$UsersTableReferences),
          User,
          PrefetchHooks Function({bool userSettingsRefs, bool timeEntriesRefs})
        > {
  $$UsersTableTableManager(_$ZeitexaDb db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> passwordHash = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<bool> isAdmin = const Value.absent(),
                Value<bool> mustChangePassword = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> mitarbeiterEmail = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                username: username,
                passwordHash: passwordHash,
                displayName: displayName,
                isAdmin: isAdmin,
                mustChangePassword: mustChangePassword,
                createdAt: createdAt,
                mitarbeiterEmail: mitarbeiterEmail,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String username,
                required String passwordHash,
                required String displayName,
                Value<bool> isAdmin = const Value.absent(),
                Value<bool> mustChangePassword = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> mitarbeiterEmail = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                username: username,
                passwordHash: passwordHash,
                displayName: displayName,
                isAdmin: isAdmin,
                mustChangePassword: mustChangePassword,
                createdAt: createdAt,
                mitarbeiterEmail: mitarbeiterEmail,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$UsersTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({userSettingsRefs = false, timeEntriesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (userSettingsRefs) db.userSettings,
                    if (timeEntriesRefs) db.timeEntries,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (userSettingsRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          UserSetting
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._userSettingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).userSettingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (timeEntriesRefs)
                        await $_getPrefetchedData<User, $UsersTable, TimeEntry>(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._timeEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).timeEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$ZeitexaDb,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, $$UsersTableReferences),
      User,
      PrefetchHooks Function({bool userSettingsRefs, bool timeEntriesRefs})
    >;
typedef $$UserSettingsTableCreateCompanionBuilder =
    UserSettingsCompanion Function({
      Value<int> userId,
      required SollModus sollModus,
      Value<double> sollStundenTag,
      Value<double> sollStundenMoDo,
      Value<double> sollStundenFr,
      Value<double> sollStundenMo,
      Value<double> sollStundenDi,
      Value<double> sollStundenMi,
      Value<double> sollStundenDo,
      Value<double> sollStundenFrTag,
      Value<double> sollStundenSa,
      Value<double> sollStundenSo,
      Value<String?> standardZeitenProTag,
      Value<bool> pausenregelAktiv,
      Value<int> pausenSchwelleMin,
      Value<int> pausenMindestMin,
      Value<int> standardBeginnMin,
      Value<int> standardEndeMin,
      Value<int> standardPauseMin,
      Value<int?> standardBeginnFrMin,
      Value<int?> standardEndeFrMin,
      Value<int?> standardPauseFrMin,
      Value<DateTime?> anfangsstandStichtag,
      Value<double> anfangsstandUrlaubTage,
      Value<int> anfangsstandZeitausgleichMin,
      Value<bool> urlaubFrGetrennt,
      Value<double> anfangsstandUrlaubFrTage,
      Value<bool> firmenurlaubAktiv,
      Value<double> anfangsstandFirmenurlaubTage,
    });
typedef $$UserSettingsTableUpdateCompanionBuilder =
    UserSettingsCompanion Function({
      Value<int> userId,
      Value<SollModus> sollModus,
      Value<double> sollStundenTag,
      Value<double> sollStundenMoDo,
      Value<double> sollStundenFr,
      Value<double> sollStundenMo,
      Value<double> sollStundenDi,
      Value<double> sollStundenMi,
      Value<double> sollStundenDo,
      Value<double> sollStundenFrTag,
      Value<double> sollStundenSa,
      Value<double> sollStundenSo,
      Value<String?> standardZeitenProTag,
      Value<bool> pausenregelAktiv,
      Value<int> pausenSchwelleMin,
      Value<int> pausenMindestMin,
      Value<int> standardBeginnMin,
      Value<int> standardEndeMin,
      Value<int> standardPauseMin,
      Value<int?> standardBeginnFrMin,
      Value<int?> standardEndeFrMin,
      Value<int?> standardPauseFrMin,
      Value<DateTime?> anfangsstandStichtag,
      Value<double> anfangsstandUrlaubTage,
      Value<int> anfangsstandZeitausgleichMin,
      Value<bool> urlaubFrGetrennt,
      Value<double> anfangsstandUrlaubFrTage,
      Value<bool> firmenurlaubAktiv,
      Value<double> anfangsstandFirmenurlaubTage,
    });

final class $$UserSettingsTableReferences
    extends BaseReferences<_$ZeitexaDb, $UserSettingsTable, UserSetting> {
  $$UserSettingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$ZeitexaDb db) =>
      db.users.createAlias('user_settings__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserSettingsTableFilterComposer
    extends Composer<_$ZeitexaDb, $UserSettingsTable> {
  $$UserSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<SollModus, SollModus, int> get sollModus =>
      $composableBuilder(
        column: $table.sollModus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get sollStundenTag => $composableBuilder(
    column: $table.sollStundenTag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sollStundenMoDo => $composableBuilder(
    column: $table.sollStundenMoDo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sollStundenFr => $composableBuilder(
    column: $table.sollStundenFr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sollStundenMo => $composableBuilder(
    column: $table.sollStundenMo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sollStundenDi => $composableBuilder(
    column: $table.sollStundenDi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sollStundenMi => $composableBuilder(
    column: $table.sollStundenMi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sollStundenDo => $composableBuilder(
    column: $table.sollStundenDo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sollStundenFrTag => $composableBuilder(
    column: $table.sollStundenFrTag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sollStundenSa => $composableBuilder(
    column: $table.sollStundenSa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sollStundenSo => $composableBuilder(
    column: $table.sollStundenSo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get standardZeitenProTag => $composableBuilder(
    column: $table.standardZeitenProTag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pausenregelAktiv => $composableBuilder(
    column: $table.pausenregelAktiv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pausenSchwelleMin => $composableBuilder(
    column: $table.pausenSchwelleMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pausenMindestMin => $composableBuilder(
    column: $table.pausenMindestMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get standardBeginnMin => $composableBuilder(
    column: $table.standardBeginnMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get standardEndeMin => $composableBuilder(
    column: $table.standardEndeMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get standardPauseMin => $composableBuilder(
    column: $table.standardPauseMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get standardBeginnFrMin => $composableBuilder(
    column: $table.standardBeginnFrMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get standardEndeFrMin => $composableBuilder(
    column: $table.standardEndeFrMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get standardPauseFrMin => $composableBuilder(
    column: $table.standardPauseFrMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get anfangsstandStichtag => $composableBuilder(
    column: $table.anfangsstandStichtag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get anfangsstandUrlaubTage => $composableBuilder(
    column: $table.anfangsstandUrlaubTage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get anfangsstandZeitausgleichMin => $composableBuilder(
    column: $table.anfangsstandZeitausgleichMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get urlaubFrGetrennt => $composableBuilder(
    column: $table.urlaubFrGetrennt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get anfangsstandUrlaubFrTage => $composableBuilder(
    column: $table.anfangsstandUrlaubFrTage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get firmenurlaubAktiv => $composableBuilder(
    column: $table.firmenurlaubAktiv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get anfangsstandFirmenurlaubTage => $composableBuilder(
    column: $table.anfangsstandFirmenurlaubTage,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserSettingsTableOrderingComposer
    extends Composer<_$ZeitexaDb, $UserSettingsTable> {
  $$UserSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get sollModus => $composableBuilder(
    column: $table.sollModus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sollStundenTag => $composableBuilder(
    column: $table.sollStundenTag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sollStundenMoDo => $composableBuilder(
    column: $table.sollStundenMoDo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sollStundenFr => $composableBuilder(
    column: $table.sollStundenFr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sollStundenMo => $composableBuilder(
    column: $table.sollStundenMo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sollStundenDi => $composableBuilder(
    column: $table.sollStundenDi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sollStundenMi => $composableBuilder(
    column: $table.sollStundenMi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sollStundenDo => $composableBuilder(
    column: $table.sollStundenDo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sollStundenFrTag => $composableBuilder(
    column: $table.sollStundenFrTag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sollStundenSa => $composableBuilder(
    column: $table.sollStundenSa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sollStundenSo => $composableBuilder(
    column: $table.sollStundenSo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get standardZeitenProTag => $composableBuilder(
    column: $table.standardZeitenProTag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pausenregelAktiv => $composableBuilder(
    column: $table.pausenregelAktiv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pausenSchwelleMin => $composableBuilder(
    column: $table.pausenSchwelleMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pausenMindestMin => $composableBuilder(
    column: $table.pausenMindestMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get standardBeginnMin => $composableBuilder(
    column: $table.standardBeginnMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get standardEndeMin => $composableBuilder(
    column: $table.standardEndeMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get standardPauseMin => $composableBuilder(
    column: $table.standardPauseMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get standardBeginnFrMin => $composableBuilder(
    column: $table.standardBeginnFrMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get standardEndeFrMin => $composableBuilder(
    column: $table.standardEndeFrMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get standardPauseFrMin => $composableBuilder(
    column: $table.standardPauseFrMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get anfangsstandStichtag => $composableBuilder(
    column: $table.anfangsstandStichtag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get anfangsstandUrlaubTage => $composableBuilder(
    column: $table.anfangsstandUrlaubTage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get anfangsstandZeitausgleichMin => $composableBuilder(
    column: $table.anfangsstandZeitausgleichMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get urlaubFrGetrennt => $composableBuilder(
    column: $table.urlaubFrGetrennt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get anfangsstandUrlaubFrTage => $composableBuilder(
    column: $table.anfangsstandUrlaubFrTage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get firmenurlaubAktiv => $composableBuilder(
    column: $table.firmenurlaubAktiv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get anfangsstandFirmenurlaubTage =>
      $composableBuilder(
        column: $table.anfangsstandFirmenurlaubTage,
        builder: (column) => ColumnOrderings(column),
      );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserSettingsTableAnnotationComposer
    extends Composer<_$ZeitexaDb, $UserSettingsTable> {
  $$UserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<SollModus, int> get sollModus =>
      $composableBuilder(column: $table.sollModus, builder: (column) => column);

  GeneratedColumn<double> get sollStundenTag => $composableBuilder(
    column: $table.sollStundenTag,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sollStundenMoDo => $composableBuilder(
    column: $table.sollStundenMoDo,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sollStundenFr => $composableBuilder(
    column: $table.sollStundenFr,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sollStundenMo => $composableBuilder(
    column: $table.sollStundenMo,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sollStundenDi => $composableBuilder(
    column: $table.sollStundenDi,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sollStundenMi => $composableBuilder(
    column: $table.sollStundenMi,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sollStundenDo => $composableBuilder(
    column: $table.sollStundenDo,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sollStundenFrTag => $composableBuilder(
    column: $table.sollStundenFrTag,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sollStundenSa => $composableBuilder(
    column: $table.sollStundenSa,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sollStundenSo => $composableBuilder(
    column: $table.sollStundenSo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get standardZeitenProTag => $composableBuilder(
    column: $table.standardZeitenProTag,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pausenregelAktiv => $composableBuilder(
    column: $table.pausenregelAktiv,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pausenSchwelleMin => $composableBuilder(
    column: $table.pausenSchwelleMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pausenMindestMin => $composableBuilder(
    column: $table.pausenMindestMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get standardBeginnMin => $composableBuilder(
    column: $table.standardBeginnMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get standardEndeMin => $composableBuilder(
    column: $table.standardEndeMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get standardPauseMin => $composableBuilder(
    column: $table.standardPauseMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get standardBeginnFrMin => $composableBuilder(
    column: $table.standardBeginnFrMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get standardEndeFrMin => $composableBuilder(
    column: $table.standardEndeFrMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get standardPauseFrMin => $composableBuilder(
    column: $table.standardPauseFrMin,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get anfangsstandStichtag => $composableBuilder(
    column: $table.anfangsstandStichtag,
    builder: (column) => column,
  );

  GeneratedColumn<double> get anfangsstandUrlaubTage => $composableBuilder(
    column: $table.anfangsstandUrlaubTage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get anfangsstandZeitausgleichMin => $composableBuilder(
    column: $table.anfangsstandZeitausgleichMin,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get urlaubFrGetrennt => $composableBuilder(
    column: $table.urlaubFrGetrennt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get anfangsstandUrlaubFrTage => $composableBuilder(
    column: $table.anfangsstandUrlaubFrTage,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get firmenurlaubAktiv => $composableBuilder(
    column: $table.firmenurlaubAktiv,
    builder: (column) => column,
  );

  GeneratedColumn<double> get anfangsstandFirmenurlaubTage =>
      $composableBuilder(
        column: $table.anfangsstandFirmenurlaubTage,
        builder: (column) => column,
      );

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserSettingsTableTableManager
    extends
        RootTableManager<
          _$ZeitexaDb,
          $UserSettingsTable,
          UserSetting,
          $$UserSettingsTableFilterComposer,
          $$UserSettingsTableOrderingComposer,
          $$UserSettingsTableAnnotationComposer,
          $$UserSettingsTableCreateCompanionBuilder,
          $$UserSettingsTableUpdateCompanionBuilder,
          (UserSetting, $$UserSettingsTableReferences),
          UserSetting,
          PrefetchHooks Function({bool userId})
        > {
  $$UserSettingsTableTableManager(_$ZeitexaDb db, $UserSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> userId = const Value.absent(),
                Value<SollModus> sollModus = const Value.absent(),
                Value<double> sollStundenTag = const Value.absent(),
                Value<double> sollStundenMoDo = const Value.absent(),
                Value<double> sollStundenFr = const Value.absent(),
                Value<double> sollStundenMo = const Value.absent(),
                Value<double> sollStundenDi = const Value.absent(),
                Value<double> sollStundenMi = const Value.absent(),
                Value<double> sollStundenDo = const Value.absent(),
                Value<double> sollStundenFrTag = const Value.absent(),
                Value<double> sollStundenSa = const Value.absent(),
                Value<double> sollStundenSo = const Value.absent(),
                Value<String?> standardZeitenProTag = const Value.absent(),
                Value<bool> pausenregelAktiv = const Value.absent(),
                Value<int> pausenSchwelleMin = const Value.absent(),
                Value<int> pausenMindestMin = const Value.absent(),
                Value<int> standardBeginnMin = const Value.absent(),
                Value<int> standardEndeMin = const Value.absent(),
                Value<int> standardPauseMin = const Value.absent(),
                Value<int?> standardBeginnFrMin = const Value.absent(),
                Value<int?> standardEndeFrMin = const Value.absent(),
                Value<int?> standardPauseFrMin = const Value.absent(),
                Value<DateTime?> anfangsstandStichtag = const Value.absent(),
                Value<double> anfangsstandUrlaubTage = const Value.absent(),
                Value<int> anfangsstandZeitausgleichMin = const Value.absent(),
                Value<bool> urlaubFrGetrennt = const Value.absent(),
                Value<double> anfangsstandUrlaubFrTage = const Value.absent(),
                Value<bool> firmenurlaubAktiv = const Value.absent(),
                Value<double> anfangsstandFirmenurlaubTage =
                    const Value.absent(),
              }) => UserSettingsCompanion(
                userId: userId,
                sollModus: sollModus,
                sollStundenTag: sollStundenTag,
                sollStundenMoDo: sollStundenMoDo,
                sollStundenFr: sollStundenFr,
                sollStundenMo: sollStundenMo,
                sollStundenDi: sollStundenDi,
                sollStundenMi: sollStundenMi,
                sollStundenDo: sollStundenDo,
                sollStundenFrTag: sollStundenFrTag,
                sollStundenSa: sollStundenSa,
                sollStundenSo: sollStundenSo,
                standardZeitenProTag: standardZeitenProTag,
                pausenregelAktiv: pausenregelAktiv,
                pausenSchwelleMin: pausenSchwelleMin,
                pausenMindestMin: pausenMindestMin,
                standardBeginnMin: standardBeginnMin,
                standardEndeMin: standardEndeMin,
                standardPauseMin: standardPauseMin,
                standardBeginnFrMin: standardBeginnFrMin,
                standardEndeFrMin: standardEndeFrMin,
                standardPauseFrMin: standardPauseFrMin,
                anfangsstandStichtag: anfangsstandStichtag,
                anfangsstandUrlaubTage: anfangsstandUrlaubTage,
                anfangsstandZeitausgleichMin: anfangsstandZeitausgleichMin,
                urlaubFrGetrennt: urlaubFrGetrennt,
                anfangsstandUrlaubFrTage: anfangsstandUrlaubFrTage,
                firmenurlaubAktiv: firmenurlaubAktiv,
                anfangsstandFirmenurlaubTage: anfangsstandFirmenurlaubTage,
              ),
          createCompanionCallback:
              ({
                Value<int> userId = const Value.absent(),
                required SollModus sollModus,
                Value<double> sollStundenTag = const Value.absent(),
                Value<double> sollStundenMoDo = const Value.absent(),
                Value<double> sollStundenFr = const Value.absent(),
                Value<double> sollStundenMo = const Value.absent(),
                Value<double> sollStundenDi = const Value.absent(),
                Value<double> sollStundenMi = const Value.absent(),
                Value<double> sollStundenDo = const Value.absent(),
                Value<double> sollStundenFrTag = const Value.absent(),
                Value<double> sollStundenSa = const Value.absent(),
                Value<double> sollStundenSo = const Value.absent(),
                Value<String?> standardZeitenProTag = const Value.absent(),
                Value<bool> pausenregelAktiv = const Value.absent(),
                Value<int> pausenSchwelleMin = const Value.absent(),
                Value<int> pausenMindestMin = const Value.absent(),
                Value<int> standardBeginnMin = const Value.absent(),
                Value<int> standardEndeMin = const Value.absent(),
                Value<int> standardPauseMin = const Value.absent(),
                Value<int?> standardBeginnFrMin = const Value.absent(),
                Value<int?> standardEndeFrMin = const Value.absent(),
                Value<int?> standardPauseFrMin = const Value.absent(),
                Value<DateTime?> anfangsstandStichtag = const Value.absent(),
                Value<double> anfangsstandUrlaubTage = const Value.absent(),
                Value<int> anfangsstandZeitausgleichMin = const Value.absent(),
                Value<bool> urlaubFrGetrennt = const Value.absent(),
                Value<double> anfangsstandUrlaubFrTage = const Value.absent(),
                Value<bool> firmenurlaubAktiv = const Value.absent(),
                Value<double> anfangsstandFirmenurlaubTage =
                    const Value.absent(),
              }) => UserSettingsCompanion.insert(
                userId: userId,
                sollModus: sollModus,
                sollStundenTag: sollStundenTag,
                sollStundenMoDo: sollStundenMoDo,
                sollStundenFr: sollStundenFr,
                sollStundenMo: sollStundenMo,
                sollStundenDi: sollStundenDi,
                sollStundenMi: sollStundenMi,
                sollStundenDo: sollStundenDo,
                sollStundenFrTag: sollStundenFrTag,
                sollStundenSa: sollStundenSa,
                sollStundenSo: sollStundenSo,
                standardZeitenProTag: standardZeitenProTag,
                pausenregelAktiv: pausenregelAktiv,
                pausenSchwelleMin: pausenSchwelleMin,
                pausenMindestMin: pausenMindestMin,
                standardBeginnMin: standardBeginnMin,
                standardEndeMin: standardEndeMin,
                standardPauseMin: standardPauseMin,
                standardBeginnFrMin: standardBeginnFrMin,
                standardEndeFrMin: standardEndeFrMin,
                standardPauseFrMin: standardPauseFrMin,
                anfangsstandStichtag: anfangsstandStichtag,
                anfangsstandUrlaubTage: anfangsstandUrlaubTage,
                anfangsstandZeitausgleichMin: anfangsstandZeitausgleichMin,
                urlaubFrGetrennt: urlaubFrGetrennt,
                anfangsstandUrlaubFrTage: anfangsstandUrlaubFrTage,
                firmenurlaubAktiv: firmenurlaubAktiv,
                anfangsstandFirmenurlaubTage: anfangsstandFirmenurlaubTage,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserSettingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
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
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$UserSettingsTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$UserSettingsTableReferences
                                    ._userIdTable(db)
                                    .id,
                              )
                              as T;
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

typedef $$UserSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$ZeitexaDb,
      $UserSettingsTable,
      UserSetting,
      $$UserSettingsTableFilterComposer,
      $$UserSettingsTableOrderingComposer,
      $$UserSettingsTableAnnotationComposer,
      $$UserSettingsTableCreateCompanionBuilder,
      $$UserSettingsTableUpdateCompanionBuilder,
      (UserSetting, $$UserSettingsTableReferences),
      UserSetting,
      PrefetchHooks Function({bool userId})
    >;
typedef $$PlacesTableCreateCompanionBuilder =
    PlacesCompanion Function({
      Value<int> id,
      required String name,
      Value<DateTime> lastUsedAt,
      Value<int> useCount,
    });
typedef $$PlacesTableUpdateCompanionBuilder =
    PlacesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> lastUsedAt,
      Value<int> useCount,
    });

final class $$PlacesTableReferences
    extends BaseReferences<_$ZeitexaDb, $PlacesTable, Place> {
  $$PlacesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TimeEntriesTable, List<TimeEntry>>
  _timeEntriesRefsTable(_$ZeitexaDb db) => MultiTypedResultKey.fromTable(
    db.timeEntries,
    aliasName: 'places__id__time_entries__ort_id',
  );

  $$TimeEntriesTableProcessedTableManager get timeEntriesRefs {
    final manager = $$TimeEntriesTableTableManager(
      $_db,
      $_db.timeEntries,
    ).filter((f) => f.ortId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_timeEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlacesTableFilterComposer extends Composer<_$ZeitexaDb, $PlacesTable> {
  $$PlacesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get useCount => $composableBuilder(
    column: $table.useCount,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> timeEntriesRefs(
    Expression<bool> Function($$TimeEntriesTableFilterComposer f) f,
  ) {
    final $$TimeEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timeEntries,
      getReferencedColumn: (t) => t.ortId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimeEntriesTableFilterComposer(
            $db: $db,
            $table: $db.timeEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlacesTableOrderingComposer
    extends Composer<_$ZeitexaDb, $PlacesTable> {
  $$PlacesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get useCount => $composableBuilder(
    column: $table.useCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlacesTableAnnotationComposer
    extends Composer<_$ZeitexaDb, $PlacesTable> {
  $$PlacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get useCount =>
      $composableBuilder(column: $table.useCount, builder: (column) => column);

  Expression<T> timeEntriesRefs<T extends Object>(
    Expression<T> Function($$TimeEntriesTableAnnotationComposer a) f,
  ) {
    final $$TimeEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timeEntries,
      getReferencedColumn: (t) => t.ortId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimeEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.timeEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlacesTableTableManager
    extends
        RootTableManager<
          _$ZeitexaDb,
          $PlacesTable,
          Place,
          $$PlacesTableFilterComposer,
          $$PlacesTableOrderingComposer,
          $$PlacesTableAnnotationComposer,
          $$PlacesTableCreateCompanionBuilder,
          $$PlacesTableUpdateCompanionBuilder,
          (Place, $$PlacesTableReferences),
          Place,
          PrefetchHooks Function({bool timeEntriesRefs})
        > {
  $$PlacesTableTableManager(_$ZeitexaDb db, $PlacesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> lastUsedAt = const Value.absent(),
                Value<int> useCount = const Value.absent(),
              }) => PlacesCompanion(
                id: id,
                name: name,
                lastUsedAt: lastUsedAt,
                useCount: useCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<DateTime> lastUsedAt = const Value.absent(),
                Value<int> useCount = const Value.absent(),
              }) => PlacesCompanion.insert(
                id: id,
                name: name,
                lastUsedAt: lastUsedAt,
                useCount: useCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$PlacesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({timeEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (timeEntriesRefs) db.timeEntries],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (timeEntriesRefs)
                    await $_getPrefetchedData<Place, $PlacesTable, TimeEntry>(
                      currentTable: table,
                      referencedTable: $$PlacesTableReferences
                          ._timeEntriesRefsTable(db),
                      managerFromTypedResult: (p0) => $$PlacesTableReferences(
                        db,
                        table,
                        p0,
                      ).timeEntriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.ortId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlacesTableProcessedTableManager =
    ProcessedTableManager<
      _$ZeitexaDb,
      $PlacesTable,
      Place,
      $$PlacesTableFilterComposer,
      $$PlacesTableOrderingComposer,
      $$PlacesTableAnnotationComposer,
      $$PlacesTableCreateCompanionBuilder,
      $$PlacesTableUpdateCompanionBuilder,
      (Place, $$PlacesTableReferences),
      Place,
      PrefetchHooks Function({bool timeEntriesRefs})
    >;
typedef $$TimeEntriesTableCreateCompanionBuilder =
    TimeEntriesCompanion Function({
      Value<int> id,
      required int userId,
      required DateTime datum,
      required Tagesart tagesart,
      Value<int?> ortId,
      Value<int?> beginnMin,
      Value<int> pauseMin,
      Value<int?> endeMin,
      Value<String> notiz,
      Value<SonderurlaubGrund?> sonderurlaubGrund,
      Value<int?> urlaubMinuten,
      Value<bool> halberTag,
    });
typedef $$TimeEntriesTableUpdateCompanionBuilder =
    TimeEntriesCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<DateTime> datum,
      Value<Tagesart> tagesart,
      Value<int?> ortId,
      Value<int?> beginnMin,
      Value<int> pauseMin,
      Value<int?> endeMin,
      Value<String> notiz,
      Value<SonderurlaubGrund?> sonderurlaubGrund,
      Value<int?> urlaubMinuten,
      Value<bool> halberTag,
    });

final class $$TimeEntriesTableReferences
    extends BaseReferences<_$ZeitexaDb, $TimeEntriesTable, TimeEntry> {
  $$TimeEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$ZeitexaDb db) =>
      db.users.createAlias('time_entries__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlacesTable _ortIdTable(_$ZeitexaDb db) =>
      db.places.createAlias('time_entries__ort_id__places__id');

  $$PlacesTableProcessedTableManager? get ortId {
    final $_column = $_itemColumn<int>('ort_id');
    if ($_column == null) return null;
    final manager = $$PlacesTableTableManager(
      $_db,
      $_db.places,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ortIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ZeitbloeckeTable, List<Zeitblock>>
  _zeitbloeckeRefsTable(_$ZeitexaDb db) => MultiTypedResultKey.fromTable(
    db.zeitbloecke,
    aliasName: 'time_entries__id__zeitbloecke__eintrag_id',
  );

  $$ZeitbloeckeTableProcessedTableManager get zeitbloeckeRefs {
    final manager = $$ZeitbloeckeTableTableManager(
      $_db,
      $_db.zeitbloecke,
    ).filter((f) => f.eintragId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_zeitbloeckeRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TimeEntriesTableFilterComposer
    extends Composer<_$ZeitexaDb, $TimeEntriesTable> {
  $$TimeEntriesTableFilterComposer({
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

  ColumnFilters<DateTime> get datum => $composableBuilder(
    column: $table.datum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Tagesart, Tagesart, int> get tagesart =>
      $composableBuilder(
        column: $table.tagesart,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get beginnMin => $composableBuilder(
    column: $table.beginnMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pauseMin => $composableBuilder(
    column: $table.pauseMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endeMin => $composableBuilder(
    column: $table.endeMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notiz => $composableBuilder(
    column: $table.notiz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SonderurlaubGrund?, SonderurlaubGrund, int>
  get sonderurlaubGrund => $composableBuilder(
    column: $table.sonderurlaubGrund,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get urlaubMinuten => $composableBuilder(
    column: $table.urlaubMinuten,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get halberTag => $composableBuilder(
    column: $table.halberTag,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlacesTableFilterComposer get ortId {
    final $$PlacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ortId,
      referencedTable: $db.places,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlacesTableFilterComposer(
            $db: $db,
            $table: $db.places,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> zeitbloeckeRefs(
    Expression<bool> Function($$ZeitbloeckeTableFilterComposer f) f,
  ) {
    final $$ZeitbloeckeTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.zeitbloecke,
      getReferencedColumn: (t) => t.eintragId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZeitbloeckeTableFilterComposer(
            $db: $db,
            $table: $db.zeitbloecke,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TimeEntriesTableOrderingComposer
    extends Composer<_$ZeitexaDb, $TimeEntriesTable> {
  $$TimeEntriesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get datum => $composableBuilder(
    column: $table.datum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tagesart => $composableBuilder(
    column: $table.tagesart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get beginnMin => $composableBuilder(
    column: $table.beginnMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pauseMin => $composableBuilder(
    column: $table.pauseMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endeMin => $composableBuilder(
    column: $table.endeMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notiz => $composableBuilder(
    column: $table.notiz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sonderurlaubGrund => $composableBuilder(
    column: $table.sonderurlaubGrund,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get urlaubMinuten => $composableBuilder(
    column: $table.urlaubMinuten,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get halberTag => $composableBuilder(
    column: $table.halberTag,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlacesTableOrderingComposer get ortId {
    final $$PlacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ortId,
      referencedTable: $db.places,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlacesTableOrderingComposer(
            $db: $db,
            $table: $db.places,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimeEntriesTableAnnotationComposer
    extends Composer<_$ZeitexaDb, $TimeEntriesTable> {
  $$TimeEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get datum =>
      $composableBuilder(column: $table.datum, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Tagesart, int> get tagesart =>
      $composableBuilder(column: $table.tagesart, builder: (column) => column);

  GeneratedColumn<int> get beginnMin =>
      $composableBuilder(column: $table.beginnMin, builder: (column) => column);

  GeneratedColumn<int> get pauseMin =>
      $composableBuilder(column: $table.pauseMin, builder: (column) => column);

  GeneratedColumn<int> get endeMin =>
      $composableBuilder(column: $table.endeMin, builder: (column) => column);

  GeneratedColumn<String> get notiz =>
      $composableBuilder(column: $table.notiz, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SonderurlaubGrund?, int>
  get sonderurlaubGrund => $composableBuilder(
    column: $table.sonderurlaubGrund,
    builder: (column) => column,
  );

  GeneratedColumn<int> get urlaubMinuten => $composableBuilder(
    column: $table.urlaubMinuten,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get halberTag =>
      $composableBuilder(column: $table.halberTag, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlacesTableAnnotationComposer get ortId {
    final $$PlacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ortId,
      referencedTable: $db.places,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlacesTableAnnotationComposer(
            $db: $db,
            $table: $db.places,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> zeitbloeckeRefs<T extends Object>(
    Expression<T> Function($$ZeitbloeckeTableAnnotationComposer a) f,
  ) {
    final $$ZeitbloeckeTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.zeitbloecke,
      getReferencedColumn: (t) => t.eintragId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZeitbloeckeTableAnnotationComposer(
            $db: $db,
            $table: $db.zeitbloecke,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TimeEntriesTableTableManager
    extends
        RootTableManager<
          _$ZeitexaDb,
          $TimeEntriesTable,
          TimeEntry,
          $$TimeEntriesTableFilterComposer,
          $$TimeEntriesTableOrderingComposer,
          $$TimeEntriesTableAnnotationComposer,
          $$TimeEntriesTableCreateCompanionBuilder,
          $$TimeEntriesTableUpdateCompanionBuilder,
          (TimeEntry, $$TimeEntriesTableReferences),
          TimeEntry,
          PrefetchHooks Function({
            bool userId,
            bool ortId,
            bool zeitbloeckeRefs,
          })
        > {
  $$TimeEntriesTableTableManager(_$ZeitexaDb db, $TimeEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimeEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimeEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimeEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<DateTime> datum = const Value.absent(),
                Value<Tagesart> tagesart = const Value.absent(),
                Value<int?> ortId = const Value.absent(),
                Value<int?> beginnMin = const Value.absent(),
                Value<int> pauseMin = const Value.absent(),
                Value<int?> endeMin = const Value.absent(),
                Value<String> notiz = const Value.absent(),
                Value<SonderurlaubGrund?> sonderurlaubGrund =
                    const Value.absent(),
                Value<int?> urlaubMinuten = const Value.absent(),
                Value<bool> halberTag = const Value.absent(),
              }) => TimeEntriesCompanion(
                id: id,
                userId: userId,
                datum: datum,
                tagesart: tagesart,
                ortId: ortId,
                beginnMin: beginnMin,
                pauseMin: pauseMin,
                endeMin: endeMin,
                notiz: notiz,
                sonderurlaubGrund: sonderurlaubGrund,
                urlaubMinuten: urlaubMinuten,
                halberTag: halberTag,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                required DateTime datum,
                required Tagesart tagesart,
                Value<int?> ortId = const Value.absent(),
                Value<int?> beginnMin = const Value.absent(),
                Value<int> pauseMin = const Value.absent(),
                Value<int?> endeMin = const Value.absent(),
                Value<String> notiz = const Value.absent(),
                Value<SonderurlaubGrund?> sonderurlaubGrund =
                    const Value.absent(),
                Value<int?> urlaubMinuten = const Value.absent(),
                Value<bool> halberTag = const Value.absent(),
              }) => TimeEntriesCompanion.insert(
                id: id,
                userId: userId,
                datum: datum,
                tagesart: tagesart,
                ortId: ortId,
                beginnMin: beginnMin,
                pauseMin: pauseMin,
                endeMin: endeMin,
                notiz: notiz,
                sonderurlaubGrund: sonderurlaubGrund,
                urlaubMinuten: urlaubMinuten,
                halberTag: halberTag,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TimeEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({userId = false, ortId = false, zeitbloeckeRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (zeitbloeckeRefs) db.zeitbloecke,
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
                        if (userId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.userId,
                                    referencedTable:
                                        $$TimeEntriesTableReferences
                                            ._userIdTable(db),
                                    referencedColumn:
                                        $$TimeEntriesTableReferences
                                            ._userIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (ortId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.ortId,
                                    referencedTable:
                                        $$TimeEntriesTableReferences
                                            ._ortIdTable(db),
                                    referencedColumn:
                                        $$TimeEntriesTableReferences
                                            ._ortIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (zeitbloeckeRefs)
                        await $_getPrefetchedData<
                          TimeEntry,
                          $TimeEntriesTable,
                          Zeitblock
                        >(
                          currentTable: table,
                          referencedTable: $$TimeEntriesTableReferences
                              ._zeitbloeckeRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TimeEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).zeitbloeckeRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.eintragId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TimeEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$ZeitexaDb,
      $TimeEntriesTable,
      TimeEntry,
      $$TimeEntriesTableFilterComposer,
      $$TimeEntriesTableOrderingComposer,
      $$TimeEntriesTableAnnotationComposer,
      $$TimeEntriesTableCreateCompanionBuilder,
      $$TimeEntriesTableUpdateCompanionBuilder,
      (TimeEntry, $$TimeEntriesTableReferences),
      TimeEntry,
      PrefetchHooks Function({bool userId, bool ortId, bool zeitbloeckeRefs})
    >;
typedef $$ZeitbloeckeTableCreateCompanionBuilder =
    ZeitbloeckeCompanion Function({
      Value<int> id,
      required int eintragId,
      required int beginnMin,
      Value<int?> endeMin,
      Value<int> pauseMin,
    });
typedef $$ZeitbloeckeTableUpdateCompanionBuilder =
    ZeitbloeckeCompanion Function({
      Value<int> id,
      Value<int> eintragId,
      Value<int> beginnMin,
      Value<int?> endeMin,
      Value<int> pauseMin,
    });

final class $$ZeitbloeckeTableReferences
    extends BaseReferences<_$ZeitexaDb, $ZeitbloeckeTable, Zeitblock> {
  $$ZeitbloeckeTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TimeEntriesTable _eintragIdTable(_$ZeitexaDb db) =>
      db.timeEntries.createAlias('zeitbloecke__eintrag_id__time_entries__id');

  $$TimeEntriesTableProcessedTableManager get eintragId {
    final $_column = $_itemColumn<int>('eintrag_id')!;

    final manager = $$TimeEntriesTableTableManager(
      $_db,
      $_db.timeEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eintragIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ZeitbloeckeTableFilterComposer
    extends Composer<_$ZeitexaDb, $ZeitbloeckeTable> {
  $$ZeitbloeckeTableFilterComposer({
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

  ColumnFilters<int> get beginnMin => $composableBuilder(
    column: $table.beginnMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endeMin => $composableBuilder(
    column: $table.endeMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pauseMin => $composableBuilder(
    column: $table.pauseMin,
    builder: (column) => ColumnFilters(column),
  );

  $$TimeEntriesTableFilterComposer get eintragId {
    final $$TimeEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eintragId,
      referencedTable: $db.timeEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimeEntriesTableFilterComposer(
            $db: $db,
            $table: $db.timeEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ZeitbloeckeTableOrderingComposer
    extends Composer<_$ZeitexaDb, $ZeitbloeckeTable> {
  $$ZeitbloeckeTableOrderingComposer({
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

  ColumnOrderings<int> get beginnMin => $composableBuilder(
    column: $table.beginnMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endeMin => $composableBuilder(
    column: $table.endeMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pauseMin => $composableBuilder(
    column: $table.pauseMin,
    builder: (column) => ColumnOrderings(column),
  );

  $$TimeEntriesTableOrderingComposer get eintragId {
    final $$TimeEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eintragId,
      referencedTable: $db.timeEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimeEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.timeEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ZeitbloeckeTableAnnotationComposer
    extends Composer<_$ZeitexaDb, $ZeitbloeckeTable> {
  $$ZeitbloeckeTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get beginnMin =>
      $composableBuilder(column: $table.beginnMin, builder: (column) => column);

  GeneratedColumn<int> get endeMin =>
      $composableBuilder(column: $table.endeMin, builder: (column) => column);

  GeneratedColumn<int> get pauseMin =>
      $composableBuilder(column: $table.pauseMin, builder: (column) => column);

  $$TimeEntriesTableAnnotationComposer get eintragId {
    final $$TimeEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eintragId,
      referencedTable: $db.timeEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimeEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.timeEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ZeitbloeckeTableTableManager
    extends
        RootTableManager<
          _$ZeitexaDb,
          $ZeitbloeckeTable,
          Zeitblock,
          $$ZeitbloeckeTableFilterComposer,
          $$ZeitbloeckeTableOrderingComposer,
          $$ZeitbloeckeTableAnnotationComposer,
          $$ZeitbloeckeTableCreateCompanionBuilder,
          $$ZeitbloeckeTableUpdateCompanionBuilder,
          (Zeitblock, $$ZeitbloeckeTableReferences),
          Zeitblock,
          PrefetchHooks Function({bool eintragId})
        > {
  $$ZeitbloeckeTableTableManager(_$ZeitexaDb db, $ZeitbloeckeTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ZeitbloeckeTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ZeitbloeckeTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ZeitbloeckeTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> eintragId = const Value.absent(),
                Value<int> beginnMin = const Value.absent(),
                Value<int?> endeMin = const Value.absent(),
                Value<int> pauseMin = const Value.absent(),
              }) => ZeitbloeckeCompanion(
                id: id,
                eintragId: eintragId,
                beginnMin: beginnMin,
                endeMin: endeMin,
                pauseMin: pauseMin,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int eintragId,
                required int beginnMin,
                Value<int?> endeMin = const Value.absent(),
                Value<int> pauseMin = const Value.absent(),
              }) => ZeitbloeckeCompanion.insert(
                id: id,
                eintragId: eintragId,
                beginnMin: beginnMin,
                endeMin: endeMin,
                pauseMin: pauseMin,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ZeitbloeckeTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({eintragId = false}) {
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
                    if (eintragId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.eintragId,
                                referencedTable: $$ZeitbloeckeTableReferences
                                    ._eintragIdTable(db),
                                referencedColumn: $$ZeitbloeckeTableReferences
                                    ._eintragIdTable(db)
                                    .id,
                              )
                              as T;
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

typedef $$ZeitbloeckeTableProcessedTableManager =
    ProcessedTableManager<
      _$ZeitexaDb,
      $ZeitbloeckeTable,
      Zeitblock,
      $$ZeitbloeckeTableFilterComposer,
      $$ZeitbloeckeTableOrderingComposer,
      $$ZeitbloeckeTableAnnotationComposer,
      $$ZeitbloeckeTableCreateCompanionBuilder,
      $$ZeitbloeckeTableUpdateCompanionBuilder,
      (Zeitblock, $$ZeitbloeckeTableReferences),
      Zeitblock,
      PrefetchHooks Function({bool eintragId})
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
    extends Composer<_$ZeitexaDb, $AppSettingsTable> {
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
    extends Composer<_$ZeitexaDb, $AppSettingsTable> {
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
    extends Composer<_$ZeitexaDb, $AppSettingsTable> {
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
          _$ZeitexaDb,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$ZeitexaDb, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$ZeitexaDb db, $AppSettingsTable table)
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
          updateCompanionCallback:
              ({
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
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$ZeitexaDb,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (AppSetting, BaseReferences<_$ZeitexaDb, $AppSettingsTable, AppSetting>),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$BrandingsTableCreateCompanionBuilder =
    BrandingsCompanion Function({
      Value<int> id,
      Value<String> firmenname,
      Value<String> adresse,
      Value<String> telefon,
      Value<String> email,
      Value<Uint8List?> logo,
      Value<int> akzentFarbe,
    });
typedef $$BrandingsTableUpdateCompanionBuilder =
    BrandingsCompanion Function({
      Value<int> id,
      Value<String> firmenname,
      Value<String> adresse,
      Value<String> telefon,
      Value<String> email,
      Value<Uint8List?> logo,
      Value<int> akzentFarbe,
    });

class $$BrandingsTableFilterComposer
    extends Composer<_$ZeitexaDb, $BrandingsTable> {
  $$BrandingsTableFilterComposer({
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

  ColumnFilters<String> get firmenname => $composableBuilder(
    column: $table.firmenname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get adresse => $composableBuilder(
    column: $table.adresse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telefon => $composableBuilder(
    column: $table.telefon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get logo => $composableBuilder(
    column: $table.logo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get akzentFarbe => $composableBuilder(
    column: $table.akzentFarbe,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BrandingsTableOrderingComposer
    extends Composer<_$ZeitexaDb, $BrandingsTable> {
  $$BrandingsTableOrderingComposer({
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

  ColumnOrderings<String> get firmenname => $composableBuilder(
    column: $table.firmenname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adresse => $composableBuilder(
    column: $table.adresse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telefon => $composableBuilder(
    column: $table.telefon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get logo => $composableBuilder(
    column: $table.logo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get akzentFarbe => $composableBuilder(
    column: $table.akzentFarbe,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BrandingsTableAnnotationComposer
    extends Composer<_$ZeitexaDb, $BrandingsTable> {
  $$BrandingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firmenname => $composableBuilder(
    column: $table.firmenname,
    builder: (column) => column,
  );

  GeneratedColumn<String> get adresse =>
      $composableBuilder(column: $table.adresse, builder: (column) => column);

  GeneratedColumn<String> get telefon =>
      $composableBuilder(column: $table.telefon, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<Uint8List> get logo =>
      $composableBuilder(column: $table.logo, builder: (column) => column);

  GeneratedColumn<int> get akzentFarbe => $composableBuilder(
    column: $table.akzentFarbe,
    builder: (column) => column,
  );
}

class $$BrandingsTableTableManager
    extends
        RootTableManager<
          _$ZeitexaDb,
          $BrandingsTable,
          Branding,
          $$BrandingsTableFilterComposer,
          $$BrandingsTableOrderingComposer,
          $$BrandingsTableAnnotationComposer,
          $$BrandingsTableCreateCompanionBuilder,
          $$BrandingsTableUpdateCompanionBuilder,
          (Branding, BaseReferences<_$ZeitexaDb, $BrandingsTable, Branding>),
          Branding,
          PrefetchHooks Function()
        > {
  $$BrandingsTableTableManager(_$ZeitexaDb db, $BrandingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BrandingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BrandingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BrandingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> firmenname = const Value.absent(),
                Value<String> adresse = const Value.absent(),
                Value<String> telefon = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<Uint8List?> logo = const Value.absent(),
                Value<int> akzentFarbe = const Value.absent(),
              }) => BrandingsCompanion(
                id: id,
                firmenname: firmenname,
                adresse: adresse,
                telefon: telefon,
                email: email,
                logo: logo,
                akzentFarbe: akzentFarbe,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> firmenname = const Value.absent(),
                Value<String> adresse = const Value.absent(),
                Value<String> telefon = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<Uint8List?> logo = const Value.absent(),
                Value<int> akzentFarbe = const Value.absent(),
              }) => BrandingsCompanion.insert(
                id: id,
                firmenname: firmenname,
                adresse: adresse,
                telefon: telefon,
                email: email,
                logo: logo,
                akzentFarbe: akzentFarbe,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BrandingsTableProcessedTableManager =
    ProcessedTableManager<
      _$ZeitexaDb,
      $BrandingsTable,
      Branding,
      $$BrandingsTableFilterComposer,
      $$BrandingsTableOrderingComposer,
      $$BrandingsTableAnnotationComposer,
      $$BrandingsTableCreateCompanionBuilder,
      $$BrandingsTableUpdateCompanionBuilder,
      (Branding, BaseReferences<_$ZeitexaDb, $BrandingsTable, Branding>),
      Branding,
      PrefetchHooks Function()
    >;
typedef $$ImportedEntriesTableCreateCompanionBuilder =
    ImportedEntriesCompanion Function({
      Value<int> id,
      required String quellUsername,
      required String quellDisplayName,
      required String monat,
      required DateTime datum,
      required Tagesart tagesart,
      Value<String> ort,
      Value<int?> beginnMin,
      Value<int> pauseMin,
      Value<int?> endeMin,
      Value<String> notiz,
      Value<SonderurlaubGrund?> sonderurlaubGrund,
      Value<int?> urlaubMinuten,
      required double sollStunden,
      Value<DateTime> importZeit,
    });
typedef $$ImportedEntriesTableUpdateCompanionBuilder =
    ImportedEntriesCompanion Function({
      Value<int> id,
      Value<String> quellUsername,
      Value<String> quellDisplayName,
      Value<String> monat,
      Value<DateTime> datum,
      Value<Tagesart> tagesart,
      Value<String> ort,
      Value<int?> beginnMin,
      Value<int> pauseMin,
      Value<int?> endeMin,
      Value<String> notiz,
      Value<SonderurlaubGrund?> sonderurlaubGrund,
      Value<int?> urlaubMinuten,
      Value<double> sollStunden,
      Value<DateTime> importZeit,
    });

class $$ImportedEntriesTableFilterComposer
    extends Composer<_$ZeitexaDb, $ImportedEntriesTable> {
  $$ImportedEntriesTableFilterComposer({
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

  ColumnFilters<String> get quellUsername => $composableBuilder(
    column: $table.quellUsername,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quellDisplayName => $composableBuilder(
    column: $table.quellDisplayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get monat => $composableBuilder(
    column: $table.monat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get datum => $composableBuilder(
    column: $table.datum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Tagesart, Tagesart, int> get tagesart =>
      $composableBuilder(
        column: $table.tagesart,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get ort => $composableBuilder(
    column: $table.ort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get beginnMin => $composableBuilder(
    column: $table.beginnMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pauseMin => $composableBuilder(
    column: $table.pauseMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endeMin => $composableBuilder(
    column: $table.endeMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notiz => $composableBuilder(
    column: $table.notiz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SonderurlaubGrund?, SonderurlaubGrund, int>
  get sonderurlaubGrund => $composableBuilder(
    column: $table.sonderurlaubGrund,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get urlaubMinuten => $composableBuilder(
    column: $table.urlaubMinuten,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sollStunden => $composableBuilder(
    column: $table.sollStunden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importZeit => $composableBuilder(
    column: $table.importZeit,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImportedEntriesTableOrderingComposer
    extends Composer<_$ZeitexaDb, $ImportedEntriesTable> {
  $$ImportedEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get quellUsername => $composableBuilder(
    column: $table.quellUsername,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quellDisplayName => $composableBuilder(
    column: $table.quellDisplayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get monat => $composableBuilder(
    column: $table.monat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get datum => $composableBuilder(
    column: $table.datum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tagesart => $composableBuilder(
    column: $table.tagesart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ort => $composableBuilder(
    column: $table.ort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get beginnMin => $composableBuilder(
    column: $table.beginnMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pauseMin => $composableBuilder(
    column: $table.pauseMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endeMin => $composableBuilder(
    column: $table.endeMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notiz => $composableBuilder(
    column: $table.notiz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sonderurlaubGrund => $composableBuilder(
    column: $table.sonderurlaubGrund,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get urlaubMinuten => $composableBuilder(
    column: $table.urlaubMinuten,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sollStunden => $composableBuilder(
    column: $table.sollStunden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importZeit => $composableBuilder(
    column: $table.importZeit,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImportedEntriesTableAnnotationComposer
    extends Composer<_$ZeitexaDb, $ImportedEntriesTable> {
  $$ImportedEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get quellUsername => $composableBuilder(
    column: $table.quellUsername,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quellDisplayName => $composableBuilder(
    column: $table.quellDisplayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get monat =>
      $composableBuilder(column: $table.monat, builder: (column) => column);

  GeneratedColumn<DateTime> get datum =>
      $composableBuilder(column: $table.datum, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Tagesart, int> get tagesart =>
      $composableBuilder(column: $table.tagesart, builder: (column) => column);

  GeneratedColumn<String> get ort =>
      $composableBuilder(column: $table.ort, builder: (column) => column);

  GeneratedColumn<int> get beginnMin =>
      $composableBuilder(column: $table.beginnMin, builder: (column) => column);

  GeneratedColumn<int> get pauseMin =>
      $composableBuilder(column: $table.pauseMin, builder: (column) => column);

  GeneratedColumn<int> get endeMin =>
      $composableBuilder(column: $table.endeMin, builder: (column) => column);

  GeneratedColumn<String> get notiz =>
      $composableBuilder(column: $table.notiz, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SonderurlaubGrund?, int>
  get sonderurlaubGrund => $composableBuilder(
    column: $table.sonderurlaubGrund,
    builder: (column) => column,
  );

  GeneratedColumn<int> get urlaubMinuten => $composableBuilder(
    column: $table.urlaubMinuten,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sollStunden => $composableBuilder(
    column: $table.sollStunden,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get importZeit => $composableBuilder(
    column: $table.importZeit,
    builder: (column) => column,
  );
}

class $$ImportedEntriesTableTableManager
    extends
        RootTableManager<
          _$ZeitexaDb,
          $ImportedEntriesTable,
          ImportedEntry,
          $$ImportedEntriesTableFilterComposer,
          $$ImportedEntriesTableOrderingComposer,
          $$ImportedEntriesTableAnnotationComposer,
          $$ImportedEntriesTableCreateCompanionBuilder,
          $$ImportedEntriesTableUpdateCompanionBuilder,
          (
            ImportedEntry,
            BaseReferences<_$ZeitexaDb, $ImportedEntriesTable, ImportedEntry>,
          ),
          ImportedEntry,
          PrefetchHooks Function()
        > {
  $$ImportedEntriesTableTableManager(
    _$ZeitexaDb db,
    $ImportedEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportedEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportedEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportedEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> quellUsername = const Value.absent(),
                Value<String> quellDisplayName = const Value.absent(),
                Value<String> monat = const Value.absent(),
                Value<DateTime> datum = const Value.absent(),
                Value<Tagesart> tagesart = const Value.absent(),
                Value<String> ort = const Value.absent(),
                Value<int?> beginnMin = const Value.absent(),
                Value<int> pauseMin = const Value.absent(),
                Value<int?> endeMin = const Value.absent(),
                Value<String> notiz = const Value.absent(),
                Value<SonderurlaubGrund?> sonderurlaubGrund =
                    const Value.absent(),
                Value<int?> urlaubMinuten = const Value.absent(),
                Value<double> sollStunden = const Value.absent(),
                Value<DateTime> importZeit = const Value.absent(),
              }) => ImportedEntriesCompanion(
                id: id,
                quellUsername: quellUsername,
                quellDisplayName: quellDisplayName,
                monat: monat,
                datum: datum,
                tagesart: tagesart,
                ort: ort,
                beginnMin: beginnMin,
                pauseMin: pauseMin,
                endeMin: endeMin,
                notiz: notiz,
                sonderurlaubGrund: sonderurlaubGrund,
                urlaubMinuten: urlaubMinuten,
                sollStunden: sollStunden,
                importZeit: importZeit,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String quellUsername,
                required String quellDisplayName,
                required String monat,
                required DateTime datum,
                required Tagesart tagesart,
                Value<String> ort = const Value.absent(),
                Value<int?> beginnMin = const Value.absent(),
                Value<int> pauseMin = const Value.absent(),
                Value<int?> endeMin = const Value.absent(),
                Value<String> notiz = const Value.absent(),
                Value<SonderurlaubGrund?> sonderurlaubGrund =
                    const Value.absent(),
                Value<int?> urlaubMinuten = const Value.absent(),
                required double sollStunden,
                Value<DateTime> importZeit = const Value.absent(),
              }) => ImportedEntriesCompanion.insert(
                id: id,
                quellUsername: quellUsername,
                quellDisplayName: quellDisplayName,
                monat: monat,
                datum: datum,
                tagesart: tagesart,
                ort: ort,
                beginnMin: beginnMin,
                pauseMin: pauseMin,
                endeMin: endeMin,
                notiz: notiz,
                sonderurlaubGrund: sonderurlaubGrund,
                urlaubMinuten: urlaubMinuten,
                sollStunden: sollStunden,
                importZeit: importZeit,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImportedEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$ZeitexaDb,
      $ImportedEntriesTable,
      ImportedEntry,
      $$ImportedEntriesTableFilterComposer,
      $$ImportedEntriesTableOrderingComposer,
      $$ImportedEntriesTableAnnotationComposer,
      $$ImportedEntriesTableCreateCompanionBuilder,
      $$ImportedEntriesTableUpdateCompanionBuilder,
      (
        ImportedEntry,
        BaseReferences<_$ZeitexaDb, $ImportedEntriesTable, ImportedEntry>,
      ),
      ImportedEntry,
      PrefetchHooks Function()
    >;

class $ZeitexaDbManager {
  final _$ZeitexaDb _db;
  $ZeitexaDbManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db, _db.userSettings);
  $$PlacesTableTableManager get places =>
      $$PlacesTableTableManager(_db, _db.places);
  $$TimeEntriesTableTableManager get timeEntries =>
      $$TimeEntriesTableTableManager(_db, _db.timeEntries);
  $$ZeitbloeckeTableTableManager get zeitbloecke =>
      $$ZeitbloeckeTableTableManager(_db, _db.zeitbloecke);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$BrandingsTableTableManager get brandings =>
      $$BrandingsTableTableManager(_db, _db.brandings);
  $$ImportedEntriesTableTableManager get importedEntries =>
      $$ImportedEntriesTableTableManager(_db, _db.importedEntries);
}
