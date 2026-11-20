import 'package:drift/drift.dart';
import 'core_tables.dart';

class AiExtractions extends Table {
  TextColumn get id => text()();
  TextColumn get extractionType => text()(); // voice, ocr
  TextColumn get sourceFilePath => text().nullable()();
  TextColumn get extractedText => text()();
  TextColumn get extractedDataJson => text()();
  TextColumn get status => text().withDefault(
      const Constant('pending'))(); // pending, confirmed, discarded
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class AppSettings extends Table {
  TextColumn get id => text()();
  TextColumn get settingKey => text().unique()();
  TextColumn get settingValue => text()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class AuditLogs extends Table {
  TextColumn get id => text()();
  TextColumn get memberId => text().nullable().references(FamilyMembers, #id)();
  TextColumn get action => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  IntColumn get timestamp => integer()();
  TextColumn get detailsJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get fileName => text()();
  TextColumn get filePath => text()();
  TextColumn get mimeType => text().nullable()();
  IntColumn get fileSize => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
