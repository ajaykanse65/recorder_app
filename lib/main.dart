import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recorder_app/providers/recording_provider.dart';
import 'package:recorder_app/screens/recording_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('recording_path');
    final startStr = prefs.getString('start_time');

    if (path != null && startStr != null) {
      final start = DateTime.parse(startStr);
      final file = File(path);

      if (await file.exists()) {
        final end = DateTime.now();
        final duration = end.difference(start);

        // Open or create the database
        final db = await openDatabase('recordings.db',
            version: 1,
            onCreate: (db, version) {
              return db.execute(
                'CREATE TABLE IF NOT EXISTS recordings(id INTEGER PRIMARY KEY AUTOINCREMENT, filePath TEXT, duration INTEGER, timestamp TEXT)',
              );
            });

        // Insert the metadata
        await db.insert('recordings', {
          'filePath': path,
          'duration': duration.inSeconds,
          'timestamp': start.toIso8601String(),
        });

        // Clear the stored recovery data
        prefs.remove('recording_path');
        prefs.remove('start_time');
      }
    }


    return Future.value(true);
  });
}

Future<void> tryRecoverRecording() async {
  final prefs = await SharedPreferences.getInstance();
  final path = prefs.getString('recording_path');
  final startStr = prefs.getString('start_time');

  if (path != null && startStr != null) {
    final start = DateTime.parse(startStr);
    final file = File(path);

    if (await file.exists()) {
      final end = DateTime.now();
      final duration = end.difference(start);

      final db = await openDatabase('recordings.db', version: 1,
          onCreate: (db, version) {
            return db.execute(
              'CREATE TABLE IF NOT EXISTS recordings(id INTEGER PRIMARY KEY AUTOINCREMENT, filePath TEXT, duration INTEGER, timestamp TEXT)',
            );
          });

      await db.insert('recordings', {
        'filePath': path,
        'duration': duration.inSeconds,
        'timestamp': start.toIso8601String(),
      });

      prefs.remove('recording_path');
      prefs.remove('start_time');
    }
  }
}


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  await tryRecoverRecording();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecordingProvider())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Recorder App',
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        ),
        home: RecordingScreen(),
      ),
    );
  }
}

