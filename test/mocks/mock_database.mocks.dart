// Mocks generated by Mockito 5.4.0 from annotations
// in possystem/test/mocks/mock_database.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:mockito/mockito.dart' as _i1;
import 'package:possystem/services/database.dart' as _i3;
import 'package:sqflite/sqflite.dart' as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeDatabase_0 extends _i1.SmartFake implements _i2.Database {
  _FakeDatabase_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [Database].
///
/// See the documentation for Mockito's code generation for more information.
class MockDatabase extends _i1.Mock implements _i3.Database {
  MockDatabase() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.Database get db => (super.noSuchMethod(
        Invocation.getter(#db),
        returnValue: _FakeDatabase_0(
          this,
          Invocation.getter(#db),
        ),
      ) as _i2.Database);
  @override
  set db(_i2.Database? _db) => super.noSuchMethod(
        Invocation.setter(
          #db,
          _db,
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i4.Future<List<Object?>> batchUpdate(
    String? table,
    List<Map<String, Object?>>? data, {
    required String? where,
    required List<List<Object>>? whereArgs,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #batchUpdate,
          [
            table,
            data,
          ],
          {
            #where: where,
            #whereArgs: whereArgs,
          },
        ),
        returnValue: _i4.Future<List<Object?>>.value(<Object?>[]),
      ) as _i4.Future<List<Object?>>);
  @override
  _i4.Future<void> reset(
    String? table, [
    _i4.Future<void> Function(String)? del = _i2.deleteDatabase,
  ]) =>
      (super.noSuchMethod(
        Invocation.method(
          #reset,
          [
            table,
            del,
          ],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
  @override
  _i4.Future<int?> count(
    String? table, {
    String? where,
    List<Object>? whereArgs,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #count,
          [table],
          {
            #where: where,
            #whereArgs: whereArgs,
          },
        ),
        returnValue: _i4.Future<int?>.value(),
      ) as _i4.Future<int?>);
  @override
  _i4.Future<void> delete(
    String? table,
    Object? id, {
    String? keyName = r'id',
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #delete,
          [
            table,
            id,
          ],
          {#keyName: keyName},
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
  @override
  _i4.Future<Map<String, Object?>?> getLast(
    String? table, {
    String? orderByKey = r'id',
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    _i3.JoinQuery? join,
    int? count = 1,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #getLast,
          [table],
          {
            #orderByKey: orderByKey,
            #columns: columns,
            #where: where,
            #whereArgs: whereArgs,
            #join: join,
            #count: count,
          },
        ),
        returnValue: _i4.Future<Map<String, Object?>?>.value(),
      ) as _i4.Future<Map<String, Object?>?>);
  @override
  _i4.Future<void> initialize({
    String? path,
    _i3.DbOpener? opener = _i2.openDatabase,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #initialize,
          [],
          {
            #path: path,
            #opener: opener,
          },
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
  @override
  _i4.Future<int> push(
    String? table,
    Map<String, Object?>? data,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #push,
          [
            table,
            data,
          ],
        ),
        returnValue: _i4.Future<int>.value(0),
      ) as _i4.Future<int>);
  @override
  _i4.Future<List<Map<String, Object?>>> query(
    String? table, {
    String? where,
    List<Object?>? whereArgs,
    List<String>? columns,
    _i3.JoinQuery? join,
    String? groupBy,
    String? orderBy,
    int? limit,
    int? offset = 0,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #query,
          [table],
          {
            #where: where,
            #whereArgs: whereArgs,
            #columns: columns,
            #join: join,
            #groupBy: groupBy,
            #orderBy: orderBy,
            #limit: limit,
            #offset: offset,
          },
        ),
        returnValue: _i4.Future<List<Map<String, Object?>>>.value(
            <Map<String, Object?>>[]),
      ) as _i4.Future<List<Map<String, Object?>>>);
  @override
  _i4.Future<void> tolerateMigration({
    int? newVersion = 7,
    int? oldVersion,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #tolerateMigration,
          [],
          {
            #newVersion: newVersion,
            #oldVersion: oldVersion,
          },
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
  @override
  _i4.Future<int> update(
    String? table,
    Object? key,
    Map<String, Object?>? data, {
    dynamic keyName = r'id',
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #update,
          [
            table,
            key,
            data,
          ],
          {#keyName: keyName},
        ),
        returnValue: _i4.Future<int>.value(0),
      ) as _i4.Future<int>);
}
