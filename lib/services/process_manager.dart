import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

enum JobStatus { pending, running, completed, failed, cancelled }

class Job {
  final String id;
  final String name;
  final String command;
  final List<String> arguments;
  final String workingDirectory;
  JobStatus status;
  final List<String> logs;
  Process? _process;
  DateTime? startTime;
  DateTime? endTime;
  int? exitCode;

  Job({
    required this.id,
    required this.name,
    required this.command,
    required this.arguments,
    required this.workingDirectory,
    this.status = JobStatus.pending,
  }) : logs = [];

  double get progress {
    if (status == JobStatus.completed) return 1.0;
    if (status == JobStatus.pending) return 0.0;
    // For running jobs, we estimate based on log content
    return 0.5;
  }
}

class ProcessManager extends ChangeNotifier {
  final List<Job> _jobs = [];
  List<Job> get jobs => List.unmodifiable(_jobs);
  
  List<Job> get runningJobs => _jobs.where((j) => j.status == JobStatus.running).toList();
  List<Job> get completedJobs => _jobs.where((j) => j.status == JobStatus.completed || j.status == JobStatus.failed).toList();

  Future<Job> startJob({
    required String name,
    required String command,
    required List<String> arguments,
    required String workingDirectory,
  }) async {
    final job = Job(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      command: command,
      arguments: arguments,
      workingDirectory: workingDirectory,
    );
    
    _jobs.insert(0, job);
    notifyListeners();
    
    await _executeJob(job);
    return job;
  }

  Future<void> _executeJob(Job job) async {
    job.status = JobStatus.running;
    job.startTime = DateTime.now();
    job.logs.add('[${_formatTime(job.startTime!)}] Starting: ${job.command} ${job.arguments.join(' ')}');
    notifyListeners();

    try {
      job._process = await Process.start(
        job.command,
        job.arguments,
        workingDirectory: job.workingDirectory,
        runInShell: true,
      );

      job._process!.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
        job.logs.add(line);
        notifyListeners();
      });

      job._process!.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
        job.logs.add('[ERROR] $line');
        notifyListeners();
      });

      job.exitCode = await job._process!.exitCode;
      job.endTime = DateTime.now();
      job.status = job.exitCode == 0 ? JobStatus.completed : JobStatus.failed;
      job.logs.add('[${_formatTime(job.endTime!)}] Process exited with code ${job.exitCode}');
    } catch (e) {
      job.status = JobStatus.failed;
      job.endTime = DateTime.now();
      job.logs.add('[ERROR] Failed to start process: $e');
    }
    
    notifyListeners();
  }

  void cancelJob(String jobId) {
    final job = _jobs.firstWhere((j) => j.id == jobId);
    if (job._process != null && job.status == JobStatus.running) {
      job._process!.kill();
      job.status = JobStatus.cancelled;
      job.endTime = DateTime.now();
      job.logs.add('[${_formatTime(job.endTime!)}] Job cancelled by user');
      notifyListeners();
    }
  }

  void clearCompletedJobs() {
    _jobs.removeWhere((j) => j.status == JobStatus.completed || j.status == JobStatus.failed || j.status == JobStatus.cancelled);
    notifyListeners();
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }
}
