import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'local_ledger.g.dart';

class LedgerEntries extends Table {
  TextColumn get id => text()();
  TextColumn get senderId => text()();
  TextColumn get receiverId => text()();
  IntColumn get amount => integer()();
  TextColumn get nonce => text().unique()();
  TextColumn get signature => text()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [LedgerEntries])
class LocalLedgerDatabase extends _$LocalLedgerDatabase {
  LocalLedgerDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<void> saveEntry(LedgerEntriesCompanion entry) => into(ledgerEntries).insert(entry);

  Future<List<LedgerEntry>> pending() {
    return (select(ledgerEntries)..where((tbl) => tbl.synced.equals(false))).get();
  }

  Future<void> markSynced(String id) {
    return (update(ledgerEntries)..where((tbl) => tbl.id.equals(id))).write(
      const LedgerEntriesCompanion(synced: Value(true)),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'nearpay_ledger.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
