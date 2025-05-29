import 'dart:async';
import 'package:flutter/material.dart';
import 'package:recorder_app/services/recording_service.dart';
import '../services/db_service.dart';
import '../models/recording_model.dart';

class RecordingProvider with ChangeNotifier {
  final RecordingService _recordingService = RecordingService();

  final DBService _dbService = DBService();
  List<Recording> _recordings = [];
  bool _isLoading = true;

  List<Recording> get recordings => _recordings;
  bool get isLoading => _isLoading;
  bool _isRecording = false;
  Duration _duration = Duration.zero;
  DateTime? _startTime;
  String? _currentPath;
  Timer? _timer;

  bool get isRecording => _isRecording;
  Duration get duration => _duration;

  int? currentlyPlayingId;
  Duration remainingDuration = Duration.zero;
  Timer? countdownTimer;


  RecordingProvider() {
    loadRecordings();
  }

  Future<void> togglePlayback(Recording rec) async {
    if (currentlyPlayingId == rec.id) {
      await _recordingService.stop();
      stopCountdown();
      currentlyPlayingId = null;
    } else {
      await _recordingService.stop(); // stop existing
      stopCountdown();

      await _recordingService.play(rec.filePath);
      currentlyPlayingId = rec.id;
      remainingDuration = rec.duration;
      startCountdown();
    }

    notifyListeners();
  }

  void startCountdown() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingDuration.inSeconds <= 1) {
        stopCountdown();
        _recordingService.stop();
        currentlyPlayingId = null;
      } else {
        remainingDuration -= const Duration(seconds: 1);
      }
      notifyListeners();
    });
  }

  void stopCountdown() {
    countdownTimer?.cancel();
    countdownTimer = null;
    notifyListeners();
  }

  Future<void> loadRecordings() async {
    _isLoading = true;
    notifyListeners();

    _recordings = await _dbService.getAllRecordings();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteRecording(Recording recording) async {

      await _dbService.deleteRecording(recording.id!);
      _recordings.remove(recording);
      _recordingService.stop();
      stopCountdown();
      currentlyPlayingId = null;

    notifyListeners();
  }

  Future<void> startRecording() async {
    await _recordingService.stop();
    _startTime = DateTime.now();
    _currentPath = await _recordingService.startRecording();
    _duration = Duration.zero;
    _isRecording = true;

    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      _duration += Duration(seconds: 1);
      notifyListeners();
    });

    notifyListeners();
  }

  Future<void> stopRecording() async {
    _timer?.cancel();
    _isRecording = false;

    if (_currentPath != null && _startTime != null) {
      final data = await _recordingService.stopRecording(_currentPath!, _startTime!);
      if (data != null) {
        final recording = Recording(
          filePath: data.path,
          timestamp: data.timestamp,
          duration: data.duration,
        );
        await _dbService.insertRecording(recording);
      }
    }

    _duration = Duration.zero;
    loadRecordings();
    notifyListeners();
  }

  void disposeRecording() {
    _timer?.cancel();
    _recordingService.dispose();
  }
}
