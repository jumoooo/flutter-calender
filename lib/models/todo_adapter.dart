import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_calender/models/todo.dart';

/// Todo 모델을 위한 Hive TypeAdapter (v2: 하위 호환)
///
/// 기존 데이터(v1: categoryId/dueDate/time 없음)를 그대로 읽을 수 있습니다.
/// 새 필드는 바이너리 끝에 추가되며, availableBytes로 존재 여부를 판별합니다.
class TodoAdapter extends TypeAdapter<Todo> {
  @override
  final int typeId = 0;

  @override
  Todo read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();

    // nullable String: hasDescription bool → 값 읽기
    final hasDescription = reader.readBool();
    final description = hasDescription ? reader.readString() : null;

    final dateMilliseconds = reader.readInt();
    final completed = reader.readBool();
    final priorityIndex = reader.readByte();

    String? categoryId;
    if (reader.availableBytes > 0) {
      final hasCategoryId = reader.readBool();
      if (hasCategoryId) categoryId = reader.readString();
    }

    // dueDate (DateTime?)
    DateTime? dueDate;
    if (reader.availableBytes > 0) {
      final hasDueDate = reader.readBool();
      if (hasDueDate) {
        dueDate = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
      }
    }

    // todoTime (TimeOfDay? → hour byte + minute byte)
    TimeOfDay? todoTime;
    if (reader.availableBytes > 0) {
      final hasTime = reader.readBool();
      if (hasTime) {
        final hour = reader.readByte();
        final minute = reader.readByte();
        todoTime = TimeOfDay(hour: hour, minute: minute);
      }
    }

    return Todo(
      id: id,
      title: title,
      description: description,
      date: DateTime.fromMillisecondsSinceEpoch(dateMilliseconds),
      completed: completed,
      priority: TodoPriority
          .values[priorityIndex.clamp(0, TodoPriority.values.length - 1)],
      categoryId: categoryId,
      dueDate: dueDate,
      todoTime: todoTime,
    );
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeBool(obj.description != null);
    if (obj.description != null) {
      writer.writeString(obj.description!);
    }
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeBool(obj.completed);
    writer.writeByte(obj.priority.index);

    writer.writeBool(obj.categoryId != null);
    writer.writeBool(obj.categoryId != null);
    if (obj.categoryId != null) {
      writer.writeString(obj.categoryId!);
    }

    // dueDate
    writer.writeBool(obj.dueDate != null);
    if (obj.dueDate != null) {
      writer.writeInt(obj.dueDate!.millisecondsSinceEpoch);
    }

    // todoTime
    writer.writeBool(obj.todoTime != null);
    if (obj.todoTime != null) {
      writer.writeByte(obj.todoTime!.hour);
      writer.writeByte(obj.todoTime!.minute);
    }
  }
}
