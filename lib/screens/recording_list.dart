import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recorder_app/utils.dart';
import '../providers/recording_provider.dart';
import '../services/recording_service.dart';

class SavedRecordingsScreen extends StatelessWidget {
  const SavedRecordingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recordingProvider = Provider.of<RecordingProvider>(context);
    final currentlyPlayingId = recordingProvider.currentlyPlayingId;


    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.blue),
        title: Text(
          "All Recordings",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800
          ),
        ),
      ),
      body: SafeArea(
        child: recordingProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : recordingProvider.recordings.isEmpty
            ? const Center(
            child: Text("No recordings found",
                style: TextStyle(color: Colors.white)))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: recordingProvider.recordings.length,
                itemBuilder: (context, index) {
                  final rec = recordingProvider.recordings[index];
                  final isPlaying = currentlyPlayingId == rec.id;

                  return ListTile(
                    title: Text(
                      "Recording ${rec.id}",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    subtitle: Text(
                      formatTimestamp(rec.timestamp),
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatDurationList(
                            isPlaying
                                ? recordingProvider.remainingDuration
                                : rec.duration,
                          ),
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            recordingProvider.deleteRecording(rec);
                          },
                          child: const Icon(Icons.delete, color: Colors.redAccent),
                        ),
                      ],
                    ),
                    onTap: () {
                      recordingProvider.togglePlayback(rec);
                    },
                  );
                },
              ),
            )
      
          ],
        ),
      ),
    );
  }
}

