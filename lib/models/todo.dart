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

  Todo({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    this.completed = false,
    this.priority = TodoPriority.normal,
  });

  /// 불변 객체를 위한 copyWith 메서드
  Todo copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    bool? completed,
    TodoPriority? priority,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
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
    };
  }

  /// JSON에서 생성
  factory Todo.fromJson(Map<String, dynamic> json) {
    TodoPriority _parsePriority(dynamic raw) {
      final value = raw as String?;
      switch (value) {
        case 'veryLow':
          return TodoPriority.veryLow;
        case 'low':
          return TodoPriority.low;
        case 'normal':
          return TodoPriority.normal;
        case 'high':
          return TodoPriority.high;
        case 'veryHigh':
          return TodoPriority.veryHigh;
        case 'medium':
          return TodoPriority.normal;
        default:
          return TodoPriority.normal;
      }
    }

    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      completed: json['completed'] as bool? ?? false,
      priority: _parsePriority(json['priority']),
    );
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
  veryLow,  // 매우 낮음
  low,      // 낮음
  normal,   // 보통
  high,     // 높음
  veryHigh, // 매우 높음
}
