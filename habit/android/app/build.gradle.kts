plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // 🔥 QO‘SHILDI: Firebase uchun
}

android {
    namespace = "com.habit.habit"
    compileSdk = 36  // 🔥 TUZATILDI: flutter.compileSdkVersion o'rniga
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.habit.habit"
        minSdk = flutter.minSdkVersion  // 🔥 TUZATILDI: 21 dan past bo'lmasin
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true  // 🔥 QO‘SHILDI: MultiDex uchun
    }

    buildTypes {
        getByName("debug") {
            isDebuggable = true
            isMinifyEnabled = false
        }
        getByName("release") {
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

// 🔥 QO‘SHILDI: Flutter source
flutter {
    source = "../.."
}

// 🔥 TUZATILDI: Dependencies to'g'ri joyga qo'yildi
dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:2.1.0")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
    implementation(platform("com.google.firebase:firebase-bom:34.12.0"))
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-messaging")
    implementation("com.google.firebase:firebase-storage")
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("androidx.biometric:biometric:1.1.0")
}
