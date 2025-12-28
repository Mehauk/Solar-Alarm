# solar_alarm
An Application for creating alarms and tracking prayer times (with notifications)

## Getting Started

### Prerequisites
1. Dart/Flutter installed on your device (and added to path)
2. Android device or emulator

### Installation
1. Clone this repo
2. Get deps - `flutter pub get`
3. Run code generation
   - `dart run build_runner build` - freezed and jsonserializable
   - `flutter build apk` - required for next step
   - `dart ./tool/jnigen.dart` - JNI bindings
4. Finally run with - `flutter run`

```bash
flutter pub get
dart run build_runner build
flutter build apk
dart ./tool/jnigen.dart
flutter run
```