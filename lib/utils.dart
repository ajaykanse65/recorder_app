import 'dart:io';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';


String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  return "${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
}
String formatDurationList(Duration d) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  return "${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
}

String formatTimestamp(DateTime timestamp) {
  return DateFormat("d MMM yyyy hh:mm a").format(timestamp);
}

Future<bool> requestPermissions(BuildContext context) async {
  try {
    final micStatus = await Permission.microphone.request();
    PermissionStatus storageStatus = PermissionStatus.granted;

    if (Platform.isAndroid) {
      if (Platform.version.contains("11") || Platform.version.contains("12") || Platform.version.contains("13")) {
        storageStatus = await Permission.manageExternalStorage.request();
      } else {
        storageStatus = await Permission.storage.request();
      }
    }

    if (micStatus.isPermanentlyDenied || storageStatus.isPermanentlyDenied) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Permissions Required"),
          content: Text("Microphone and storage access are required. Please enable them in app settings."),
          actions: [
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
              child: Text("Open Settings"),
            ),
          ],
        ),
      );
      return false;
    }

    if (!micStatus.isGranted || !storageStatus.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Permissions denied. Cannot continue.")),
      );
      return false;
    }

    return true;
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error requesting permissions: $e")),
    );
    return false;
  }
}

