import 'package:flutter/material.dart';

/// 할일 카테고리 모델
///
/// 할일을 분류하는 카테고리 정보를 담습니다.
class Category {
  /// 카테고리 고유 ID
  final String id;

  /// 카테고리 이름
  final String name;

  /// 카테고리 색상 (Color.value로 저장)
  final int colorValue;

  /// 카테고리 아이콘 코드 (IconData.codePoint)
  final int iconCode;

  const Category({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconCode,
  });

  /// Color 객체로 반환
  Color get color => Color(colorValue);

  /// IconData 객체로 반환
  ///
  /// Web 빌드시 아이콘 폰트 트리 셰이킹을 위해
  /// **반드시 const IconData (Icons.*)** 만 사용해야 합니다.
  /// 따라서 동적 IconData 생성 대신, 카테고리 id에 따라
  /// 미리 정의된 Icons.* 상수를 반환하도록 합니다.
  IconData get icon {
    switch (id) {
      case 'work':
        return Icons.work_outline;
      case 'personal':
        return Icons.person_outline;
      case 'shopping':
        return Icons.shopping_cart_outlined;
      case 'health':
        return Icons.favorite_border;
      case 'study':
        return Icons.school_outlined;
      default:
        // 예기치 않은 id의 경우에도 트리 셰이킹을 유지하기 위해
        // 고정된 아이콘 상수를 반환합니다.
        return Icons.label_outline;
    }
  }

  /// 불변 객체를 위한 copyWith
  Category copyWith({
    String? id,
    String? name,
    int? colorValue,
    int? iconCode,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      iconCode: iconCode ?? this.iconCode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 기본 카테고리 목록
class DefaultCategories {
  DefaultCategories._();

  static List<Category> get list => [
    Category(
      id: 'work',
      name: '업무',
      colorValue: Colors.blue.toARGB32(),
      iconCode: Icons.work_outline.codePoint,
    ),
    Category(
      id: 'personal',
      name: '개인',
      colorValue: Colors.green.toARGB32(),
      iconCode: Icons.person_outline.codePoint,
    ),
    Category(
      id: 'shopping',
      name: '쇼핑',
      colorValue: Colors.orange.toARGB32(),
      iconCode: Icons.shopping_cart_outlined.codePoint,
    ),
    Category(
      id: 'health',
      name: '건강',
      colorValue: Colors.red.toARGB32(),
      iconCode: Icons.favorite_border.codePoint,
    ),
    Category(
      id: 'study',
      name: '학습',
      colorValue: Colors.purple.toARGB32(),
      iconCode: Icons.school_outlined.codePoint,
    ),
  ];
}

/// 선택 가능한 카테고리 색상 팔레트
class CategoryColors {
  CategoryColors._();

  static const List<Color> palette = [
    Color(0xFF2196F3), // 파랑
    Color(0xFF4CAF50), // 초록
    Color(0xFFFF9800), // 주황
    Color(0xFFF44336), // 빨강
    Color(0xFF9C27B0), // 보라
    Color(0xFF009688), // 청록
    Color(0xFFE91E63), // 핑크
    Color(0xFF795548), // 갈색
    Color(0xFF607D8B), // 회청색
    Color(0xFFFF5722), // 진주황
  ];
}

/// 선택 가능한 카테고리 아이콘 목록
class CategoryIcons {
  CategoryIcons._();

  static const List<Map<String, dynamic>> list = [
    {'icon': Icons.work_outline, 'label': '업무'},
    {'icon': Icons.person_outline, 'label': '개인'},
    {'icon': Icons.shopping_cart_outlined, 'label': '쇼핑'},
    {'icon': Icons.favorite_border, 'label': '건강'},
    {'icon': Icons.school_outlined, 'label': '학습'},
    {'icon': Icons.home_outlined, 'label': '집'},
    {'icon': Icons.directions_run, 'label': '운동'},
    {'icon': Icons.restaurant_menu, 'label': '음식'},
    {'icon': Icons.flight_outlined, 'label': '여행'},
    {'icon': Icons.music_note_outlined, 'label': '취미'},
    {'icon': Icons.attach_money, 'label': '금융'},
    {'icon': Icons.phone_outlined, 'label': '연락'},
  ];
}
