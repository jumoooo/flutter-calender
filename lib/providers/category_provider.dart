import 'package:flutter/foundation.dart' hide Category;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_calender/models/category.dart';

/// 카테고리 상태 관리 Provider
///
/// Hive를 사용하여 카테고리 데이터를 영구 저장합니다.
class CategoryProvider with ChangeNotifier {
  /// Hive Box 이름
  static const String _boxName = 'categories';

  /// Hive Box 인스턴스
  Box<Category>? _box;

  /// 카테고리 목록 (메모리 캐시)
  List<Category> _categories = [];

  /// 카테고리 목록 getter (읽기 전용)
  List<Category> get categories => List.unmodifiable(_categories);

  /// ID로 카테고리 찾기 (없으면 null)
  Category? getById(String? id) {
    if (id == null) return null;
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Hive Box 초기화 및 기본 카테고리 생성
  Future<void> initialize() async {
    try {
      _box = await Hive.openBox<Category>(_boxName);
      await _loadCategories();

      // 기본 카테고리가 없으면 생성
      if (_categories.isEmpty) {
        await _createDefaultCategories();
      }
    } catch (e) {
      debugPrint('CategoryProvider 초기화 오류: $e');
      // 오류 시 기본 카테고리를 메모리에만 로드
      _categories = List.from(DefaultCategories.list);
      notifyListeners();
    }
  }

  /// Hive에서 카테고리 로드
  Future<void> _loadCategories() async {
    if (_box == null) return;
    _categories = _box!.values.toList();
    notifyListeners();
  }

  /// 기본 카테고리 생성
  Future<void> _createDefaultCategories() async {
    for (final category in DefaultCategories.list) {
      await _saveCategory(category);
    }
    await _loadCategories();
  }

  /// 카테고리 추가
  Future<void> addCategory(Category category) async {
    try {
      _categories.add(category);
      await _saveCategory(category);
      notifyListeners();
    } catch (e) {
      _categories.remove(category);
      debugPrint('카테고리 추가 오류: $e');
      rethrow;
    }
  }

  /// 카테고리 업데이트
  Future<void> updateCategory(Category updatedCategory) async {
    final index = _categories.indexWhere((c) => c.id == updatedCategory.id);
    if (index == -1) return;

    final previousCategory = _categories[index];
    try {
      _categories[index] = updatedCategory;
      await _saveCategory(updatedCategory);
      notifyListeners();
    } catch (e) {
      _categories[index] = previousCategory;
      debugPrint('카테고리 수정 오류: $e');
      rethrow;
    }
  }

  /// 카테고리 삭제
  Future<void> deleteCategory(String id) async {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index == -1) return;

    final categoryToDelete = _categories[index];
    try {
      _categories.removeAt(index);
      await _deleteCategory(id);
      notifyListeners();
    } catch (e) {
      _categories.insert(index, categoryToDelete);
      debugPrint('카테고리 삭제 오류: $e');
      rethrow;
    }
  }

  /// Hive에 카테고리 저장
  Future<void> _saveCategory(Category category) async {
    if (_box == null) return;
    await _box!.put(category.id, category);
  }

  /// Hive에서 카테고리 삭제
  Future<void> _deleteCategory(String id) async {
    if (_box == null) return;
    await _box!.delete(id);
  }

  @override
  void dispose() {
    _box?.close();
    super.dispose();
  }
}
