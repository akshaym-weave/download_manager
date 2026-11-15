// CANDIDATE NOTE: Implement your solution in this file. You may change private
// implementation details and add helpers. Preserve the existing public
// constructor, methods, and getters so the provided UI remains compatible.

import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'download_service.dart';
import 'download_task.dart';

class DownloadManager extends ChangeNotifier {
  DownloadManager(this.service, {this.maxConcurrent = 3});

  final DownloadService service;
  final int maxConcurrent;
  final Map<String, DownloadTask> _tasks = {};
  final Queue<String> _queue = Queue<String>();
  final Map<String, StreamSubscription<DownloadEvent>> _subscriptions = {};
  bool _disposed = false;

  List<DownloadTask> get tasks => List.unmodifiable(_tasks.values);

  int get activeCount => _tasks.values
      .where((task) => task.status == DownloadStatus.running)
      .length;

  double get aggregateProgress {
    final total =
        _tasks.values.fold<int>(0, (sum, task) => sum + task.totalBytes);
    final received =
        _tasks.values.fold<int>(0, (sum, task) => sum + task.receivedBytes);
    return total == 0 ? 0 : received / total;
  }

  void addAll(Iterable<DownloadTask> tasks) {
    if (_disposed) return;
    for (final task in tasks) {
      if (_tasks.containsKey(task.id)) continue;
      _tasks[task.id] = task.copyWith(status: DownloadStatus.queued);
      _queue.addLast(task.id);
    }
    _pump();
    notifyListeners();
  }

  void _pump() {
    while (!_disposed && _queue.isNotEmpty) {
      _start(_queue.removeFirst());
    }
  }

  void _start(String id) {
    if (_disposed) return;
    final task = _tasks[id];
    if (task == null) return;
    final running = task.copyWith(
      status: DownloadStatus.running,
      attempt: task.attempt + 1,
      clearError: true,
    );
    _tasks[id] = running;
    _subscriptions[id] = service
        .start(
          taskId: id,
          attempt: running.attempt,
          totalBytes: running.totalBytes,
        )
        .listen(
          (event) => _onEvent(id, event),
          onError: (Object error) => _fail(id, '$error'),
        );
  }

  void _onEvent(String id, DownloadEvent event) {
    if (_disposed) return;
    final task = _tasks[id];
    if (task == null) return;
    switch (event) {
      case DownloadProgress():
        _tasks[id] = task.copyWith(receivedBytes: event.receivedBytes);
      case DownloadCompleted():
        _tasks[id] = task.copyWith(
          receivedBytes: task.totalBytes,
          status: DownloadStatus.completed,
        );
        _pump();
      case DownloadFailed():
        _fail(id, event.message);
    }
    notifyListeners();
  }

  void _fail(String id, String message) {
    if (_disposed) return;
    final task = _tasks[id];
    if (task == null) return;
    _tasks[id] = task.copyWith(status: DownloadStatus.failed, error: message);
    _pump();
    notifyListeners();
  }

  void pause(String id) {
    final task = _tasks[id];
    if (task?.status != DownloadStatus.running) return;
    // Deliberately incorrect: the old stream remains subscribed.
    _tasks[id] = task!.copyWith(status: DownloadStatus.paused);
    _pump();
    notifyListeners();
  }

  void resume(String id) {
    final task = _tasks[id];
    if (task?.status != DownloadStatus.paused) return;
    _tasks[id] = task!.copyWith(status: DownloadStatus.queued);
    _queue.addLast(id);
    _pump();
    notifyListeners();
  }

  void retry(String id) {
    final task = _tasks[id];
    if (task?.status != DownloadStatus.failed) return;
    _tasks[id] =
        task!.copyWith(status: DownloadStatus.queued, clearError: true);
    _queue.addLast(id);
    _pump();
    notifyListeners();
  }

  void cancel(String id) {
    final task = _tasks[id];
    if (task == null || task.status == DownloadStatus.completed) return;
    // Deliberately incorrect: queued IDs and active subscriptions are retained.
    _tasks[id] = task.copyWith(status: DownloadStatus.cancelled);
    _pump();
    notifyListeners();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    for (final subscription in _subscriptions.values) {
      unawaited(subscription.cancel());
    }
    _subscriptions.clear();
    _queue.clear();
    super.dispose();
  }
}
