import java.io.File
import java.util.Properties

pluginManagement {
    val flutterSdkPath = run {
        val props = java.util.Properties()
        val file = java.io.File(rootDir, "local.properties")
        if (file.exists()) {
            props.load(file.inputStream())
        }
        props.getProperty("flutter.sdk") ?: throw GradleException("flutter.sdk not set in local.properties")
    }
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.6.0" apply false  // 🔥 TUZATILDI: Flutter 3.41.9 recommended version
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version "4.3.15" apply false
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false  // 🔥 TUZATILDI: Flutter recommended Kotlin version
}

include(":app")