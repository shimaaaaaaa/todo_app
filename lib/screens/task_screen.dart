import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../providers/todo_provider.dart';

class TaskScreen extends ConsumerStatefulWidget {
  const TaskScreen({super.key});

  @override
  ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController(text: '10'); // Default points

  @override
  void dispose() {
    _titleController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  void _addTask() {
    final title = _titleController.text.trim();
    final points = int.tryParse(_pointsController.text) ?? 0;

    if (title.isNotEmpty) {
      ref.read(todoListProvider.notifier).addTask(title, points);
      _titleController.clear();
      // Keep points as is or reset? Let's keep it for "next task" convenience
      // _pointsController.text = '10'; 
    }
  }

  void _showEditDialog(Task task) {
    final editTitleController = TextEditingController(text: task.title);
    final editPointsController = TextEditingController(text: task.points.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('タスクの編集'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editTitleController,
              decoration: const InputDecoration(labelText: '内容'),
              autofocus: true,
            ),
            TextField(
              controller: editPointsController,
              decoration: const InputDecoration(labelText: 'ポイント'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              final newTitle = editTitleController.text.trim();
              final newPoints = int.tryParse(editPointsController.text) ?? 0;
              if (newTitle.isNotEmpty) {
                ref.read(todoListProvider.notifier).updateTask(task.id, newTitle, newPoints);
                Navigator.pop(context);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todoList = ref.watch(todoListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('タスクリスト'),
      ),
      body: Column(
        children: [
          // Task Input Area (Top)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: '新しいタスク',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _pointsController,
                    decoration: const InputDecoration(
                      labelText: 'Pt',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _addTask,
                  icon: const Icon(Icons.add_circle, size: 40, color: Colors.blue),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Task List
          Expanded(
            child: todoList.isEmpty
                ? const Center(child: Text('タスクがありません'))
                : ListView.builder(
                    itemCount: todoList.length,
                    itemBuilder: (context, index) {
                      final task = todoList[index];
                      return Dismissible(
                        key: Key(task.id),
                        background: Container(color: Colors.red, alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 20), child: const Icon(Icons.delete, color: Colors.white)),
                        secondaryBackground: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                        onDismissed: (direction) {
                          ref.read(todoListProvider.notifier).removeTask(task.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${task.title} を削除しました')),
                          );
                        },
                        child: ListTile(
                          title: Text(task.title, style: const TextStyle(fontSize: 18)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('${task.points} pt', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          onTap: () => _showEditDialog(task),
                          onLongPress: () {
                            ref.read(todoListProvider.notifier).completeTask(task.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${task.title} を完了！ ${task.points}pt 獲得！')),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
