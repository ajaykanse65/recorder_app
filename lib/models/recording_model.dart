class Recording {
  final int? id;
  final String filePath;
  final DateTime timestamp;
  final Duration duration;

  Recording({
    this.id,
    required this.filePath,
    required this.timestamp,
    required this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filePath': filePath,
      'timestamp': timestamp.toIso8601String(),
      'duration': duration.inSeconds,
    };
  }

  factory Recording.fromMap(Map<String, dynamic> map) {
    return Recording(
      id: map['id'],
      filePath: map['filePath'],
      timestamp: DateTime.parse(map['timestamp']),
      duration: Duration(seconds: map['duration']),
    );
  }
}
