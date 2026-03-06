import 'package:flutter/material.dart';

/// 할일 모델
///
/// 할일의 정보를 담는 데이터 클래스입니다.
class Todo {
  /// 할일 고유 ID
  final String id;

  /// 할일 제목
  final String title;

  /// 할일 설명 (선택사항)
  final String? description;

  /// 할일 날짜
  final DateTime date;

  /// 완료 여부
  final bool completed;

  /// 우선순위
  final TodoPriority priority;

  /// 카테고리 ID (선택사항)
  final String? categoryId;

  /// 기한 (선택사항)
  final DateTime? dueDate;

  /// 할일 시간 (선택사항)
  final TimeOfDay? todoTime;

  Todo({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    this.completed = false,
    this.priority = TodoPriority.normal,
    this.categoryId,
    this.dueDate,
    this.todoTime,
  });

  /// 불변 객체를 위한 copyWith 메서드
  Todo copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    bool? completed,
    TodoPriority? priority,
    String? categoryId,
    DateTime? dueDate,
    TimeOfDay? todoTime,
    // null로 명시적으로 지우기 위한 플래그
    bool clearDescription = false,
    bool clearCategoryId = false,
    bool clearDueDate = false,
    bool clearTodoTime = false,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      date: date ?? this.date,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      todoTime: clearTodoTime ? null : (todoTime ?? this.todoTime),
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'completed': completed,
      'priority': priority.name,
      'categoryId': categoryId,
      'dueDate': dueDate?.toIso8601String(),
      'todoTimeHour': todoTime?.hour,
      'todoTimeMinute': todoTime?.minute,
    };
  }

  /// JSON에서 생성
  factory Todo.fromJson(Map<String, dynamic> json) {
    // 우선순위 파싱 (잘못된 값은 normal로 fallback)
    TodoPriority parsePriority(dynamic raw) {
      try {
        switch (raw as String?) {
          case 'veryLow':
            return TodoPriority.veryLow;
          case 'low':
            return TodoPriority.low;
          case 'high':
            return TodoPriority.high;
          case 'veryHigh':
            return TodoPriority.veryHigh;
          case 'medium': // 이전 버전 호환
          case 'normal':
          default:
            return TodoPriority.normal;
        }
      } catch (_) {
        return TodoPriority.normal;
      }
    }

    // 날짜 파싱 (실패 시 오늘 날짜로 fallback)
    DateTime parseDate(dynamic raw) {
      try {
        return DateTime.parse(raw as String);
      } catch (_) {
        return DateTime.now();
      }
    }

    // TimeOfDay 파싱 (hour/minute이 모두 있을 때만)
    TimeOfDay? parseTime(dynamic hour, dynamic minute) {
      try {
        if (hour == null || minute == null) return null;
        return TimeOfDay(hour: hour as int, minute: minute as int);
      } catch (_) {
        return null;
      }
    }

    return Todo(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? '제목 없음',
      description: json['description'] as String?,
      date: parseDate(json['date']),
      completed: json['completed'] as bool? ?? false,
      priority: parsePriority(json['priority']),
      categoryId: json['categoryId'] as String?,
      dueDate: json['dueDate'] != null ? parseDate(json['dueDate']) : null,
      todoTime: parseTime(json['todoTimeHour'], json['todoTimeMinute']),
    );
  }

  /// 기한이 지났는지 여부 (오늘 기준)
  bool get isOverdue {
    if (dueDate == null || completed) return false;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final dueDateOnly = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return dueDateOnly.isBefore(todayDate);
  }

  /// 기한이 오늘인지 여부
  bool get isDueToday {
    if (dueDate == null || completed) return false;
    final today = DateTime.now();
    return dueDate!.year == today.year &&
        dueDate!.month == today.month &&
        dueDate!.day == today.day;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Todo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 할일 우선순위
enum TodoPriority {
  veryLow, // 매우 낮음
  low, // 낮음
  normal, // 보통
  high, // 높음
  veryHigh, // 매우 높음
}

/// 할일 정렬 타입
enum TodoSortType {
  /// 추가 순 (기본)
  byCreation,

  /// 우선순위 높은 순
  byPriority,

  /// 기한 빠른 순 (기한 없는 항목은 뒤로)
  byDueDate,

  /// 이름 가나다 순
  byTitle,
}
