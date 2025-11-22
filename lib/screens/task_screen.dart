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
  void _showAddDialog() {
    final titleController = TextEditingController();
    final pointsController = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新しいタスク'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: '内容'),
              autofocus: true,
            ),
            TextField(
              controller: pointsController,
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
              final title = titleController.text.trim();
              final points = int.tryParse(pointsController.text) ?? 0;
              if (title.isNotEmpty) {
                ref.read(todoListProvider.notifier).addTask(title, points);
                Navigator.pop(context);
              }
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Task task) {
    final editTitleController = TextEditingController(text: task.title);
    final editPointsController = TextEditingController(
      text: task.points.toString(),
    );

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
                ref
                    .read(todoListProvider.notifier)
                    .updateTask(task.id, newTitle, newPoints);
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
      appBar: AppBar(title: const Text('タスクリスト')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: todoList.length + 1,
          itemBuilder: (context, index) {
            if (index == todoList.length) {
              // Add Button
              return InkWell(
                onTap: _showAddDialog,
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    color: Colors.grey[200],
                  ),
                  child: const Icon(Icons.add, size: 40, color: Colors.grey),
                ),
              );
            }

            final task = todoList[index];
            return CircularTaskItem(
              key: ValueKey(task.id),
              task: task,
              onTap: () => _showEditDialog(task),
              onCompleted: () {
                ref.read(todoListProvider.notifier).completeTask(task.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${task.title} を完了！ ${task.points}pt 獲得！'),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class CircularTaskItem extends StatefulWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onCompleted;

  const CircularTaskItem({
    super.key,
    required this.task,
    required this.onTap,
    required this.onCompleted,
  });

  @override
  State<CircularTaskItem> createState() => _CircularTaskItemState();
}

class _CircularTaskItemState extends State<CircularTaskItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.2),
        weight: 40,
      ), // Pop up
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 0.0),
        weight: 60,
      ), // Shrink away
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _colorAnimation =
        ColorTween(begin: Colors.blue[100], end: Colors.greenAccent).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleLongPress() async {
    // Play completion animation
    await _controller.forward();
    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      onLongPress: _handleLongPress,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _colorAnimation.value,
                  border: Border.all(
                    color: _controller.isAnimating ? Colors.green : Colors.blue,
                    width: 2,
                  ),
                  boxShadow: _isPressed
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                padding: const EdgeInsets.all(8),
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.task.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.task.points} pt',
                style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
