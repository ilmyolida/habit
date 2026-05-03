pluginManagement {
    // 🔥 TUZATILDI: Flutter SDK path olish
    def flutterSdkPath = {
        def properties = new Properties()
        def localPropertiesFile = file("local.properties")
        if (localPropertiesFile.exists()) {
            localPropertiesFile.withInputStream { properties.load(it) }
        }
        def flutterSdkPath = properties.getProperty("flutter.sdk")
        assert flutterSdkPath != null, "flutter.sdk not set in local.properties"
        return flutterSdkPath
    }()
    
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "7.3.0" apply false  // 🔥 TUZATILDI: 8.11.1 -> 7.3.0 (Flutter bilan mos)
    id("org.jetbrains.kotlin.android") version "1.9.0" apply false  // 🔥 TUZATILDI: 2.2.20 -> 1.9.0
}

include(":app")