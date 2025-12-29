import 'dart:io';

import 'package:jnigen/jnigen.dart';

void main(List<String> args) {
  final packageRoot = Platform.script.resolve('../');
  generateJniBindings(
    Config(
      outputConfig: OutputConfig(
        dartConfig: DartCodeOutputConfig(
          path: packageRoot.resolve(
            'lib/data/services/jni_bindings_service.dart',
          ),
          structure: OutputStructure.singleFile,
        ),
      ),
      androidSdkConfig: AndroidSdkConfig(addGradleDeps: true),
      sourcePath: [packageRoot.resolve('android/app/src/main/kotlin')],
      classes: [
        'com.example.solar_alarm.services.Alarm',
        'com.example.solar_alarm.services.Prayer',
        'com.example.solar_alarm.services.Logger',
        // 'com.example.solar_alarm.services.PermissionService',
      ],
    ),
  );
}
