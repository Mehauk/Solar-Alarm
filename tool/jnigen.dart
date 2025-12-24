import 'dart:io';

import 'package:jnigen/jnigen.dart';

void main(List<String> args) {
  final packageRoot = Platform.script.resolve('../');
  generateJniBindings(
    Config(
      outputConfig: OutputConfig(
        dartConfig: DartCodeOutputConfig(
          // Required. Output path for generated bindings.
          path: packageRoot.resolve('lib/data/services/jni_bindings.g.dart'),
          // Optional. Write bindings into a single file (instead of one file per class).
          structure: OutputStructure.singleFile,
        ),
      ),
      // Optional. Configuration to search for Android SDK libraries.
      androidSdkConfig: AndroidSdkConfig(addGradleDeps: true),
      // Optional. List of directories that contain the source files for which to generate bindings.
      sourcePath: [packageRoot.resolve('android/app/src/main/kotlin')],
      // Required. List of classes or packages for which bindings should be generated.
      classes: [
        // Service classes
        'com.example.solar_alarm.services.Alarm',
        'com.example.solar_alarm.services.Prayer',
        'com.example.solar_alarm.services.Logger',
        // 'com.example.solar_alarm.services.PermissionService',
      ],
    ),
  );
}
