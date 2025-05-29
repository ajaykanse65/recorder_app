import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recorder_app/screens/recording_list.dart';
import 'package:workmanager/workmanager.dart';
import '../providers/recording_provider.dart';
import '../utils.dart';

class RecordingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecordingProvider>(context);
    return  Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Recorder',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w800),),
        actions: [
          IconButton(
            icon: Icon(Icons.list,color: Colors.white,),
            onPressed: () => provider.isRecording ? null : Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SavedRecordingsScreen()),
            ) ,
          ),
        ],
      ),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                provider.isRecording ? "Recording..." : "Stopped",
                style: TextStyle(fontSize: 24,color: Colors.white),
              ),
              SizedBox(height: 10),
              if(provider.isRecording)...[
                Text(
                  formatDuration(provider.duration),
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold,color: Colors.white),
                ),
                SizedBox(height: 20),
              ],
              GestureDetector(
                onTap: provider.isRecording
                    ? provider.stopRecording
                    : () async {
                  final granted = await requestPermissions(context);
                  if (granted) {
                    await Workmanager().registerOneOffTask(
                      "recoveryTask",
                      "recordingRecovery",
                      constraints: Constraints(
                        networkType: NetworkType.not_required,
                        requiresCharging: false,
                      ),
                    );
                    await provider.startRecording();
                  }
                },
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                ),
              ),

            ],
          ),
        ),
    );

  }
}
