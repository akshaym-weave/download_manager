// CANDIDATE NOTE: This file defines the provided task model and statuses.
// Do not modify it for this exercise.

enum DownloadStatus { queued, running, paused, completed, failed, cancelled }

class DownloadTask {
  const DownloadTask({
    required this.id,
    required this.name,
    required this.totalBytes,
    this.receivedBytes = 0,
    this.status = DownloadStatus.queued,
    this.attempt = 0,
    this.error,
  });

  final String id;
  final String name;
  final int totalBytes;
  final int receivedBytes;
  final DownloadStatus status;
  final int attempt;
  final String? error;

  double get progress => totalBytes <= 0 ? 0 : receivedBytes / totalBytes;

  DownloadTask copyWith({
    int? receivedBytes,
    DownloadStatus? status,
    int? attempt,
    String? error,
    bool clearError = false,
  }) =>
      DownloadTask(
        id: id,
        name: name,
        totalBytes: totalBytes,
        receivedBytes: receivedBytes ?? this.receivedBytes,
        status: status ?? this.status,
        attempt: attempt ?? this.attempt,
        error: clearError ? null : error ?? this.error,
      );
}
