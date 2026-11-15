// CANDIDATE NOTE: This file is the provided demo UI. Do not modify it for
// this exercise. Make your solution changes in lib/download_manager.dart
// and add your tests in test/exercise_test.dart.

import 'package:flutter/material.dart';

import 'download_manager.dart';
import 'download_service.dart';
import 'download_task.dart';

void main() => runApp(const DownloadManagerApp());

class DownloadManagerApp extends StatelessWidget {
  const DownloadManagerApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme:
            ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
        home: const DownloadScreen(),
      );
}

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  late DownloadManager manager;

  @override
  void initState() {
    super.initState();
    _createManager();
  }

  void _createManager() {
    manager = DownloadManager(const DemoDownloadService());
    manager.addAll(List.generate(
      6,
      (index) => DownloadTask(
        id: 'file-$index',
        name: 'Project asset ${index + 1}.zip',
        totalBytes: (index + 2) * 1000000,
      ),
    ));
  }

  void _reload() {
    final previousManager = manager;
    setState(_createManager);
    previousManager.dispose();
  }

  @override
  void dispose() {
    manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: manager,
        builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: const Text('Download queue'),
        actions: [
          IconButton(
            key: const Key('reload-button'),
            tooltip: 'Restart all downloads',
            onPressed: _reload,
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${manager.activeCount}/${manager.maxConcurrent} active',
                      key: const Key('active-count'),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      key: const Key('aggregate-progress'),
                      value: manager.aggregateProgress.clamp(0, 1),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  key: const Key('download-list'),
                  itemCount: manager.tasks.length,
                  itemBuilder: (context, index) => _DownloadRow(
                      task: manager.tasks[index], manager: manager),
                ),
              ),
            ],
          ),
        ),
      );
}

class _DownloadRow extends StatelessWidget {
  const _DownloadRow({required this.task, required this.manager});

  final DownloadTask task;
  final DownloadManager manager;

  @override
  Widget build(BuildContext context) => ListTile(
        key: ValueKey(task.id),
        title: Text(task.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.error ?? task.status.name),
            LinearProgressIndicator(value: task.progress.clamp(0, 1)),
          ],
        ),
        trailing: Wrap(
          spacing: 4,
          children: [
            if (task.status == DownloadStatus.running)
              IconButton(
                tooltip: 'Pause',
                onPressed: () => manager.pause(task.id),
                icon: const Icon(Icons.pause),
              ),
            if (task.status == DownloadStatus.paused)
              IconButton(
                tooltip: 'Resume',
                onPressed: () => manager.resume(task.id),
                icon: const Icon(Icons.play_arrow),
              ),
            if (task.status == DownloadStatus.failed)
              IconButton(
                tooltip: 'Retry',
                onPressed: () => manager.retry(task.id),
                icon: const Icon(Icons.refresh),
              ),
            if (task.status != DownloadStatus.completed &&
                task.status != DownloadStatus.cancelled)
              IconButton(
                tooltip: 'Cancel',
                onPressed: () => manager.cancel(task.id),
                icon: const Icon(Icons.close),
              ),
          ],
        ),
      );
}
