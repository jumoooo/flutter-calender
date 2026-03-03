import 'package:hive/hive.dart';
import 'package:flutter_calender/models/todo.dart';

/// Todo 모델을 위한 Hive TypeAdapter
/// 
/// Hive에서 Todo 객체를 저장하고 불러오기 위한 어댑터입니다.
class TodoAdapter extends TypeAdapter<Todo> {
  @override
  final int typeId = 0; // 고유한 타입 ID (0-223 사이의 값)

  @override
  Todo read(BinaryReader reader) {
    // 바이너리에서 읽어서 Todo 객체로 변환
    final id = reader.readString();
    final title = reader.readString();
    // nullable String 처리: null 여부를 먼저 읽고, null이 아니면 값을 읽음
    final hasDescription = reader.readBool();
    final description = hasDescription ? reader.readString() : null;
    final dateMilliseconds = reader.readInt();
    final completed = reader.readBool();
    final priorityIndex = reader.readByte();

    return Todo(
      id: id,
      title: title,
      description: description,
      date: DateTime.fromMillisecondsSinceEpoch(dateMilliseconds),
      completed: completed,
      priority: TodoPriority.values[priorityIndex],
    );
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    // Todo 객체를 바이너리로 변환하여 저장
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    // nullable String 처리: null 여부를 먼저 쓰고, null이 아니면 값을 씀
    writer.writeBool(obj.description != null);
    if (obj.description != null) {
      writer.writeString(obj.description!);
    }
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeBool(obj.completed);
    writer.writeByte(obj.priority.index);
  }
}
