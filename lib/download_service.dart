// CANDIDATE NOTE: The event types, service interface, and demo service in this
// file are provided and must remain unchanged. You may implement DownloadService
// in your test file to support your tests.

sealed class DownloadEvent {
  const DownloadEvent();
}

class DownloadProgress extends DownloadEvent {
  const DownloadProgress(this.receivedBytes);
  final int receivedBytes;
}

class DownloadCompleted extends DownloadEvent {
  const DownloadCompleted();
}

class DownloadFailed extends DownloadEvent {
  const DownloadFailed(this.message);
  final String message;
}

abstract class DownloadService {
  Stream<DownloadEvent> start({
    required String taskId,
    required int attempt,
    required int totalBytes,
  });
}

class DemoDownloadService implements DownloadService {
  const DemoDownloadService({this.tick = const Duration(milliseconds: 350)});
  final Duration tick;

  @override
  Stream<DownloadEvent> start({
    required String taskId,
    required int attempt,
    required int totalBytes,
  }) async* {
    const steps = 10;
    for (var step = 1; step <= steps; step++) {
      await Future<void>.delayed(tick);
      yield DownloadProgress((totalBytes * step / steps).round());
    }
    yield const DownloadCompleted();
  }
}
