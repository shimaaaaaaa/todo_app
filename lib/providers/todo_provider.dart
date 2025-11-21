import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../models/user_stats.dart';
import '../repositories/todo_repository.dart';

final todoRepositoryProvider = Provider((ref) => TodoRepository());

final todoListProvider = StateNotifierProvider<TodoListNotifier, List<Task>>((ref) {
  return TodoListNotifier(ref.read(todoRepositoryProvider), ref);
});

class TodoListNotifier extends StateNotifier<List<Task>> {
  final TodoRepository _repository;
  final Ref _ref;

  TodoListNotifier(this._repository, this._ref) : super([]) {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    state = await _repository.loadTasks();
  }

  Future<void> addTask(String title, int points) async {
    final newTask = Task(title: title, points: points);
    state = [...state, newTask];
    await _repository.saveTasks(state);
  }

  Future<void> updateTask(String id, String newTitle, int newPoints) async {
    state = [
      for (final task in state)
        if (task.id == id)
          Task(id: task.id, title: newTitle, points: newPoints)
        else
          task,
    ];
    await _repository.saveTasks(state);
  }

  Future<void> removeTask(String id) async {
    state = state.where((task) => task.id != id).toList();
    await _repository.saveTasks(state);
  }

  Future<void> completeTask(String id) async {
    final task = state.firstWhere((t) => t.id == id);
    
    // Add points
    _ref.read(userStatsProvider.notifier).addPoints(task.points);

    // Remove from list
    await removeTask(id);
  }
}

final userStatsProvider = StateNotifierProvider<UserStatsNotifier, UserStats>((ref) {
  return UserStatsNotifier(ref.read(todoRepositoryProvider));
});

class UserStatsNotifier extends StateNotifier<UserStats> {
  final TodoRepository _repository;

  UserStatsNotifier(this._repository) : super(UserStats()) {
    _loadStats();
  }

  Future<void> _loadStats() async {
    state = await _repository.loadUserStats();
  }

  Future<void> addPoints(int points) async {
    state = state.copyWith(totalPoints: state.totalPoints + points);
    await _repository.saveUserStats(state);
  }
}
