plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.solar_alarm"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions { jvmTarget = JavaVersion.VERSION_11.toString() }

    defaultConfig {
        // TODO: Specify your own unique Application ID
        // (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.solar_alarm"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter { source = "../.." }
// Gradle stub for listing dependencies in JNIgen. If found in
// android/build.gradle.kts, please delete the following function.
tasks.register<DefaultTask>("getReleaseCompileClasspath") {
    doLast {
        try {
            val app = project(":app")
            val android = app.android
            val classPaths = mutableListOf(android.bootClasspath.first()) // Access the first element directly
            for (variant in android.applicationVariants) {
                if (variant.name == "release") {
                    val javaCompile = variant.javaCompileProvider.get()
                    classPaths.addAll(javaCompile.classpath.files)
                }
            }
            for (classPath in classPaths) {
                println(classPath)
            }
        } catch (e: Exception) {
            System.err.println("Gradle stub cannot find JAR libraries. This might be because no APK build has happened yet.")
            throw e
        }
    }
    System.err.println("If you are seeing this error in `flutter build` output, it is likely that JNIgen left some stubs in the build.gradle file. Please restore that file from your version control system or manually remove the stub functions named getReleaseCompileClasspath and / or getSources.")
}
