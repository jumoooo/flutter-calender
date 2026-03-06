import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_calender/utils/hive_migration.dart';

void main() {
  group('HiveMigration 테스트', () {
    late Directory tempDir;

    setUpAll(() async {
      // 테스트용 Hive 초기화 (임시 디렉토리 사용)
      tempDir = Directory.systemTemp.createTempSync('hive_migration_test_');
      Hive.init(tempDir.path);
    });

    tearDownAll(() async {
      // 모든 테스트 후 Hive 정리
      try {
        await Hive.close();
      } catch (e) {
        // 무시
      }
      // 임시 디렉토리 정리
      try {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      } catch (e) {
        // 무시
      }
    });

    test('마이그레이션 성공 테스트', () async {
      // Given: 새로운 Box
      const boxName = 'test_migration';

      // When: 마이그레이션 실행
      final result = await HiveMigration.migrate(boxName);

      // Then: 마이그레이션이 성공했는지 확인
      expect(result, isTrue);
    });

    test('저장된 버전 확인 테스트', () async {
      // Given: 마이그레이션 실행
      const boxName = 'test_version';
      await HiveMigration.migrate(boxName);

      // When: 저장된 버전 확인
      final savedVersion = await HiveMigration.getSavedVersion();

      // Then: 현재 버전과 일치하는지 확인
      expect(savedVersion, equals(HiveMigration.currentVersion));
    });

    test('중복 마이그레이션 실행 테스트', () async {
      // Given: 이미 마이그레이션된 상태
      const boxName = 'test_duplicate';
      await HiveMigration.migrate(boxName);
      final firstVersion = await HiveMigration.getSavedVersion();

      // When: 다시 마이그레이션 실행
      final result = await HiveMigration.migrate(boxName);
      final secondVersion = await HiveMigration.getSavedVersion();

      // Then: 마이그레이션이 성공하고 버전이 유지되는지 확인
      expect(result, isTrue);
      expect(secondVersion, equals(firstVersion));
      expect(secondVersion, equals(HiveMigration.currentVersion));
    });

    test('버전 정보 초기화 테스트', () async {
      // Given: 마이그레이션 실행
      const boxName = 'test_reset';
      await HiveMigration.migrate(boxName);
      final beforeReset = await HiveMigration.getSavedVersion();
      expect(beforeReset, greaterThan(0));

      // When: 버전 정보 초기화
      await HiveMigration.resetVersion();

      // Then: 버전이 0으로 초기화되었는지 확인
      final afterReset = await HiveMigration.getSavedVersion();
      expect(afterReset, equals(0));
    });
  });
}
