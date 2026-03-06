import 'package:hive/hive.dart';
import 'package:flutter_calender/models/category.dart';

/// Category 모델을 위한 Hive TypeAdapter
///
/// typeId = 1 (Todo는 0)
class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final int typeId = 1;

  @override
  Category read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final colorValue = reader.readInt();
    final iconCode = reader.readInt();

    return Category(
      id: id,
      name: name,
      colorValue: colorValue,
      iconCode: iconCode,
    );
  }

  @override
  void write(BinaryWriter writer, Category obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeInt(obj.colorValue);
    writer.writeInt(obj.iconCode);
  }
}
