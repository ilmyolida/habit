import java.util.Properties

fun properties(file: File): Properties {
    return Properties().apply {
        if (file.exists()) {
            file.inputStream().use { load(it) }
        }
    }
}

pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

val flutterSdkPath = requireNotNull(properties(file("local.properties")).getProperty("flutter.sdk")) {
    "flutter.sdk not set in local.properties"
}

includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "7.3.0" apply false  // 🔥 TUZATILDI: 8.11.1 -> 7.3.0 (Flutter bilan mos)
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version "4.3.15" apply false
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android") version "1.9.0" apply false  // 🔥 TUZATILDI: 2.2.20 -> 1.9.0
}

include(":app")