import 'package:flutter/material.dart';
import 'package:flutter_calender/models/category.dart';
import 'package:flutter_calender/providers/category_provider.dart';
import 'package:flutter_calender/widgets/common/snackbar_helper.dart';
import 'package:provider/provider.dart';

/// 카테고리 관리 화면
///
/// 카테고리 목록 조회, 추가, 수정, 삭제를 담당합니다.
class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('카테고리 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '카테고리 추가',
            onPressed: () => _showCategoryDialog(context, null),
          ),
        ],
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, _) {
          final categories = categoryProvider.categories;

          if (categories.isEmpty) {
            return const Center(
              child: Text(
                '카테고리가 없습니다.\n+ 버튼을 눌러 추가하세요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              return _CategoryListTile(
                category: category,
                onEdit: () => _showCategoryDialog(context, category),
                onDelete: () => _confirmDelete(context, category),
              );
            },
          );
        },
      ),
    );
  }

  /// 카테고리 추가/수정 다이얼로그
  void _showCategoryDialog(BuildContext context, Category? existing) {
    showDialog(
      context: context,
      builder: (_) => _CategoryDialog(existing: existing),
    );
  }

  /// 카테고리 삭제 확인 다이얼로그
  void _confirmDelete(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('카테고리 삭제'),
        content: Text(
          '"${category.name}" 카테고리를 삭제하시겠습니까?\n'
          '해당 카테고리가 지정된 할일은 카테고리가 없어집니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final provider = Provider.of<CategoryProvider>(
                context,
                listen: false,
              );
              await provider.deleteCategory(category.id);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// 카테고리 목록 아이템
class _CategoryListTile extends StatelessWidget {
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryListTile({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: category.color.withAlpha(40),
          child: Icon(category.icon, color: category.color, size: 20),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: '수정',
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.red,
              ),
              tooltip: '삭제',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

/// 카테고리 추가/수정 다이얼로그
class _CategoryDialog extends StatefulWidget {
  /// null이면 추가 모드, 값이 있으면 수정 모드
  final Category? existing;

  const _CategoryDialog({this.existing});

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final _nameController = TextEditingController();
  late Color _selectedColor;
  late IconData _selectedIcon;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _nameController.text = widget.existing!.name;
      _selectedColor = widget.existing!.color;
      _selectedIcon = widget.existing!.icon;
    } else {
      _selectedColor = CategoryColors.palette.first;
      _selectedIcon = (CategoryIcons.list.first['icon'] as IconData);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return AlertDialog(
      title: Text(isEdit ? '카테고리 수정' : '카테고리 추가'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이름 입력
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '카테고리 이름',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),

            // 색상 선택
            const Text('색상', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CategoryColors.palette.map((color) {
                final isSelected =
                    _selectedColor.toARGB32() == color.toARGB32();
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black54 : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 아이콘 선택
            const Text('아이콘', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CategoryIcons.list.map((item) {
                final icon = item['icon'] as IconData;
                final isSelected = _selectedIcon.codePoint == icon.codePoint;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _selectedColor.withAlpha(40)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? _selectedColor
                            : Colors.grey.withAlpha(80),
                        width: isSelected ? 1.5 : 0.8,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? _selectedColor : Colors.grey,
                      size: 22,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(onPressed: _save, child: Text(isEdit ? '수정' : '추가')),
      ],
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      // 검증 메시지 표시
      SnackbarHelper.showInfo(context, '카테고리 이름을 입력해주세요.');
      return;
    }

    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    final category = Category(
      id:
          widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      colorValue: _selectedColor.toARGB32(),
      iconCode: _selectedIcon.codePoint,
    );

    try {
      if (widget.existing != null) {
        await categoryProvider.updateCategory(category);
      } else {
        await categoryProvider.addCategory(category);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        // 에러 메시지 표시
        SnackbarHelper.showError(context, '저장 중 오류가 발생했습니다.');
      }
    }
  }
}
