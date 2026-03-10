import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Hive 데이터 마이그레이션 유틸리티
///
/// 앱 버전 업데이트 시 데이터 형식 변경을 처리합니다.
class HiveMigration {
  // Private 생성자로 인스턴스화 방지
  HiveMigration._();

  /// 현재 데이터 스키마 버전
  static const int currentVersion = 1;

  /// 버전 정보를 저장할 Box 이름
  static const String _versionBoxName = 'app_version';

  /// 버전 정보 키
  static const String _versionKey = 'data_version';

  /// 마이그레이션 실행
  ///
  /// 앱 시작 시 호출하여 필요한 마이그레이션을 수행합니다.
  ///
  /// [boxName] 마이그레이션할 Box 이름
  ///
  /// 반환값: 마이그레이션 성공 여부
  static Future<bool> migrate(String boxName) async {
    Box? versionBox;
    try {
      // 버전 정보 Box 열기
      versionBox = await Hive.openBox(_versionBoxName);

      // 현재 저장된 버전 확인
      final savedVersion = versionBox.get(_versionKey, defaultValue: 0) as int;

      debugPrint('현재 데이터 버전: $savedVersion, 목표 버전: $currentVersion');

      // 버전이 같으면 마이그레이션 불필요
      if (savedVersion >= currentVersion) {
        debugPrint('마이그레이션 불필요: 이미 최신 버전입니다.');
        return true;
      }

      // 버전별 마이그레이션 실행
      for (
        int version = savedVersion + 1;
        version <= currentVersion;
        version++
      ) {
        debugPrint('버전 $version 마이그레이션 시작...');

        final success = await _migrateToVersion(boxName, version);
        if (!success) {
          debugPrint('버전 $version 마이그레이션 실패');
          return false;
        }

        // 버전 정보 업데이트
        await versionBox.put(_versionKey, version);
        debugPrint('버전 $version 마이그레이션 완료');
      }

      return true;
    } catch (e) {
      debugPrint('마이그레이션 오류: $e');
      return false;
    } finally {
      // ✅ Box 누수 방지: 성공/실패/예외 모두 닫힘 보장
      try {
        await versionBox?.close();
      } catch (_) {}
    }
  }

  /// 특정 버전으로 마이그레이션
  ///
  /// [boxName] 마이그레이션할 Box 이름
  /// [targetVersion] 목표 버전
  ///
  /// 반환값: 마이그레이션 성공 여부
  static Future<bool> _migrateToVersion(
    String boxName,
    int targetVersion,
  ) async {
    switch (targetVersion) {
      case 1:
        // 버전 1: 초기 버전 (마이그레이션 없음)
        return true;

      // 향후 버전 추가 예시:
      // case 2:
      //   return await _migrateToVersion2(boxName);
      // case 3:
      //   return await _migrateToVersion3(boxName);

      default:
        debugPrint('알 수 없는 버전: $targetVersion');
        return false;
    }
  }

  /// 버전 2로 마이그레이션 (예시)
  ///
  /// 향후 데이터 구조 변경 시 사용할 수 있는 예시입니다.
  ///
  /// [boxName] 마이그레이션할 Box 이름
  ///
  /// 반환값: 마이그레이션 성공 여부
  // static Future<bool> _migrateToVersion2(String boxName) async {
  //   try {
  //     final box = await Hive.openBox(boxName);
  //
  //     // 예시: 모든 Todo에 새 필드 추가
  //     final keys = box.keys.toList();
  //     for (final key in keys) {
  //       final todo = box.get(key);
  //       if (todo != null) {
  //         // 데이터 변환 로직
  //         // 예: todo.copyWith(newField: defaultValue)
  //         await box.put(key, todo);
  //       }
  //     }
  //
  //     return true;
  //   } catch (e) {
  //     debugPrint('버전 2 마이그레이션 오류: $e');
  //     return false;
  //   }
  // }

  /// 현재 저장된 버전 확인
  ///
  /// 반환값: 저장된 버전 (없으면 0)
  static Future<int> getSavedVersion() async {
    try {
      final versionBox = await Hive.openBox(_versionBoxName);
      return versionBox.get(_versionKey, defaultValue: 0) as int;
    } catch (e) {
      debugPrint('버전 확인 오류: $e');
      return 0;
    }
  }

  /// 버전 정보 초기화 (테스트/디버깅용)
  ///
  /// 주의: 실제 사용 시 데이터 손실 위험이 있습니다.
  static Future<void> resetVersion() async {
    try {
      final versionBox = await Hive.openBox(_versionBoxName);
      await versionBox.delete(_versionKey);
      debugPrint('버전 정보 초기화 완료');
    } catch (e) {
      debugPrint('버전 정보 초기화 오류: $e');
    }
  }
}
