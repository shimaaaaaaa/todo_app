import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/providers/todo_provider.dart';
import 'package:todo_app/repositories/todo_repository.dart';

void main() {
  // Mock SharedPreferences
  SharedPreferences.setMockInitialValues({});

  test('Task addition and completion logic', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final todoNotifier = container.read(todoListProvider.notifier);
    // Initialize userStatsProvider and wait for its constructor's async load to finish
    container.read(userStatsProvider);
    await Future.delayed(const Duration(milliseconds: 50));

    // 1. Add Task
    await todoNotifier.addTask('Test Task', 10);
    var tasks = container.read(todoListProvider);
    expect(tasks.length, 1);
    expect(tasks.first.title, 'Test Task');
    expect(tasks.first.points, 10);

    // 2. Complete Task
    final taskId = tasks.first.id;
    await todoNotifier.completeTask(taskId);

    // Verify Task Removed
    tasks = container.read(todoListProvider);
    expect(tasks.isEmpty, true);

    // Verify Points Added
    final userStats = container.read(userStatsProvider);
    expect(userStats.totalPoints, 10);
  });
}
