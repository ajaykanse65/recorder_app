# Flutter Recorder App

A minimal Flutter app that allows users to record audio in three states: active, background/minimized, and when the phone is locked. It stores audio recordings locally and saves metadata in a SQLite database. The app is designed to handle edge cases like unexpected app termination during recording.

## Features

- Audio recording using `flutter_sound`
- Save recordings in app’s local documents directory
- Store metadata (file path, timestamp, duration) in `sqflite` database
- Recording works in:
  - Foreground (active state)
  - Background (minimized state)
  - Locked state
- Automatically handles app termination during recording

### Minimal UI

- **Recording Screen**: Start/Stop buttons, live duration, status
- **Recording List Screen**: View, play recordings, see metadata

---

## Project Structure

```
lib/
├── models/
│   └── recording_model.dart
├── providers/
│   └── recording_provider.dart
├── screens/
│   ├── recording_list.dart
│   └── recording_screen.dart
├── services/
│   ├── db_service.dart
│   └── recording_service.dart
├── utils.dart
└── main.dart
```

---

## Dependencies

```yaml
cupertino_icons: ^1.0.8
flutter_sound: ^9.28.0
permission_handler: ^12.0.0+1
sqflite: ^2.4.2
provider: ^6.1.5
intl: ^0.20.2
shared_preferences: ^2.5.3
workmanager:
  git:
    url: https://github.com/fluttercommunity/flutter_workmanager.git
    path: workmanager
    ref: main
```

---

## Setup Instructions

1. **Clone the Repository:**
   ```bash
   git clone git@github.com:ajaykanse65/recorder_app.git
   cd recorder_app
   ```

2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the App:**
   ```bash
   flutter run
   ```

4. **Permissions Setup:**
   - **Android:** Add permissions in `AndroidManifest.xml`
   - **iOS:** Add microphone usage description in `Info.plist`

---

## Edge Case Handling

### App Termination During Recording

When recording is in progress and the app is killed:
- Audio is finalized using `flutter_sound` cleanup
- Metadata is stored on app restart using `workmanager` recovery tasks
- Simulated and tested using manual app kill

---

## Screens

### Recording Screen
- Start/Stop recording buttons
- Live timer and status text

### Saved Recordings Screen
- ListView showing all recordings
- Tap to play & stop
- Timestamp, delete icon and duration

---

## Technical Details

- **Audio Recording:** `flutter_sound`
- **Database:** `sqflite`
- **Storage:** `path_provider`
- **Background Work:** `workmanager`
- **State Management:** `provider`
- **Permission Handling:** `permission_handler`
- **Audio Playback:** `flutter_sound`

---

## Notes

- Designed for functionality over aesthetics.
- Edge case handling is a key priority.
- Responsive on both Android and iOS.
