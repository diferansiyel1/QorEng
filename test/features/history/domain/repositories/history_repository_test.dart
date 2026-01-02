import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:engicore/features/history/domain/repositories/history_repository.dart';
import 'package:engicore/features/history/domain/entities/calculation_record.dart';

void main() {
  late Box<String> testBox;

  setUpAll(() async {
    // Initialize Hive for testing with in-memory storage
    Hive.init('./test_hive');
  });

  setUp(() async {
    // Create a new test box for each test
    testBox = await Hive.openBox<String>('test_history_box');
    await testBox.clear();
  });

  tearDown(() async {
    await testBox.clear();
    await testBox.close();
  });

  tearDownAll(() async {
    await Hive.close();
  });

  group('HistoryRepository', () {
    group('saveRecord', () {
      test('returns RepositorySuccess on successful save', () async {
        final repo = HistoryRepository(testBox);
        final record = CalculationRecord(
          id: 'test-id',
          title: 'Test Calculation',
          resultValue: '20.0 V',
          moduleType: ModuleType.electrical,
          timestamp: DateTime.now(),
        );

        final result = await repo.saveRecord(record);

        expect(result, isA<RepositorySuccess<void>>());
        expect(testBox.length, 1);
      });

      test('record data is correctly persisted', () async {
        final repo = HistoryRepository(testBox);
        final record = CalculationRecord(
          id: 'test-id',
          title: 'Test Calculation',
          resultValue: '20.0 V',
          moduleType: ModuleType.mechanical,
          timestamp: DateTime.now(),
        );

        await repo.saveRecord(record);

        final savedJson = testBox.get('test-id');
        expect(savedJson, isNotNull);
        expect(savedJson, contains('test-id'));
        expect(savedJson, contains('Test Calculation'));
      });
    });

    group('getAllRecords', () {
      test('returns empty list when no records exist', () {
        final repo = HistoryRepository(testBox);

        final records = repo.getAllRecords();

        expect(records, isEmpty);
      });

      test('returns all valid records sorted by timestamp descending',
          () async {
        final repo = HistoryRepository(testBox);
        final now = DateTime.now();

        final record1 = CalculationRecord(
          id: 'id-1',
          title: 'First',
          resultValue: '10.0',
          moduleType: ModuleType.chemical,
          timestamp: now.subtract(const Duration(hours: 2)),
        );

        final record2 = CalculationRecord(
          id: 'id-2',
          title: 'Second',
          resultValue: '20.0',
          moduleType: ModuleType.bioprocess,
          timestamp: now.subtract(const Duration(hours: 1)),
        );

        await repo.saveRecord(record1);
        await repo.saveRecord(record2);

        final records = repo.getAllRecords();

        expect(records.length, 2);
        expect(records[0].id, 'id-2'); // Newer first
        expect(records[1].id, 'id-1');
      });

      test('skips corrupted JSON records without crashing', () async {
        final repo = HistoryRepository(testBox);

        // Add a valid record
        final record = CalculationRecord(
          id: 'valid-id',
          title: 'Valid',
          resultValue: '42.0',
          moduleType: ModuleType.electrical,
          timestamp: DateTime.now(),
        );
        await repo.saveRecord(record);

        // Add corrupted JSON directly
        await testBox.put('corrupted-id', 'not valid json {{{');

        // Should not throw and should return only valid records
        final records = repo.getAllRecords();

        expect(records.length, 1);
        expect(records[0].id, 'valid-id');
      });
    });

    group('deleteRecord', () {
      test('returns RepositorySuccess on successful delete', () async {
        final repo = HistoryRepository(testBox);
        final record = CalculationRecord(
          id: 'delete-me',
          title: 'To Delete',
          resultValue: '0.0',
          moduleType: ModuleType.other,
          timestamp: DateTime.now(),
        );
        await repo.saveRecord(record);

        final result = await repo.deleteRecord('delete-me');

        expect(result, isA<RepositorySuccess<void>>());
        expect(testBox.length, 0);
      });
    });

    group('clearHistory', () {
      test('returns RepositorySuccess with count on successful clear',
          () async {
        final repo = HistoryRepository(testBox);

        // Add multiple records
        for (int i = 0; i < 5; i++) {
          final record = CalculationRecord(
            id: 'id-$i',
            title: 'Record $i',
            resultValue: '$i.0',
            moduleType: ModuleType.electrical,
            timestamp: DateTime.now(),
          );
          await repo.saveRecord(record);
        }

        expect(testBox.length, 5);

        final result = await repo.clearHistory();

        expect(result, isA<RepositorySuccess<int>>());
        final success = result as RepositorySuccess<int>;
        expect(success.data, 5);
        expect(testBox.length, 0);
      });
    });

    group('recordCount', () {
      test('returns correct count', () async {
        final repo = HistoryRepository(testBox);

        expect(repo.recordCount, 0);

        final record = CalculationRecord(
          id: 'test-id',
          title: 'Test',
          resultValue: '1.0',
          moduleType: ModuleType.mechanical,
          timestamp: DateTime.now(),
        );
        await repo.saveRecord(record);

        expect(repo.recordCount, 1);
      });
    });
  });
}
