import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class RecordingService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  bool _isInited = false;
  bool _isInitedPlay = false;

  Future<void> _init() async {
    if (!_isInited) {
      await _recorder.openRecorder();
      _isInited = true;
    }
    if (!_isInitedPlay) {
      await _player.openPlayer();
      _isInitedPlay = true;
    }
  }


  Future<String> startRecording() async {
    await _init();

    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.aac';
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('recording_path', path);
    prefs.setString('start_time', DateTime.now().toIso8601String());

    await _recorder.startRecorder(toFile: path, codec: Codec.aacADTS);
    return path;
  }

  Future<RecordingData?> stopRecording(String path, DateTime startTime) async {
    if (!_recorder.isRecording) return null;

    await _recorder.stopRecorder();
    final endTime = DateTime.now();

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('recording_path');
    prefs.remove('start_time');

    return RecordingData(
      path: path,
      duration: endTime.difference(startTime),
      timestamp: startTime,
    );
  }

  Future<void> play(String path) async {
    await _init();
    await _player.startPlayer(fromURI: path);
  }

  Future<void> stop() async {
    if (_player.isPlaying) {
      await _player.stopPlayer();
    }
  }

  Future<void> dispose() async {
    await _recorder.closeRecorder();
    await _player.closePlayer();
    _isInitedPlay = false;
    _isInited = false;
  }
}

class RecordingData {
  final String path;
  final Duration duration;
  final DateTime timestamp;

  RecordingData({
    required this.path,
    required this.duration,
    required this.timestamp,
  });
}
