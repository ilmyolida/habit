plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // 🔥 QO‘SHILDI: Firebase uchun
}

// 🔥 QO‘SHILDI: JKS kalitini o'qish
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.habit.habit"
    compileSdk = 34  // 🔥 TUZATILDI: flutter.compileSdkVersion o'rniga
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.habit.habit"
        minSdk = 21  // 🔥 TUZATILDI: 21 dan past bo'lmasin
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true  // 🔥 QO‘SHILDI: MultiDex uchun
    }

    // 🔥 QO‘SHILDI: Signing konfiguratsiyasi
    signingConfigs {
        debug {
            storeFile file(System.getProperty("user.home") + "/.android/debug.keystore")
            storePassword "android"
            keyAlias "androiddebugkey"
            keyPassword "android"
        }
        release {
            if (keystorePropertiesFile.exists()) {
                keyAlias keystoreProperties['keyAlias']
                keyPassword keystoreProperties['keyPassword']
                storeFile file(keystoreProperties['storeFile'])
                storePassword keystoreProperties['storePassword']
            } else {
                // 🔥 MUHIM: Agar JKS bo'lmasa, debug bilan sign qiladi
                signingConfig = signingConfigs.debug
            }
        }
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.debug
            debuggable = true
            minifyEnabled = false
        }
        release {
            // 🔥 TUZATILDI: Release uchun release signing config
            signingConfig = signingConfigs.release
            minifyEnabled = true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}

// 🔥 QO‘SHILDI: Flutter source
flutter {
    source = "../.."
}

// 🔥 TUZATILDI: Dependencies to'g'ri joyga qo'yildi
dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.12.0"))
    
    // Firebase services
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.firebase:firebase-firestore'
    implementation 'com.google.firebase:firebase-messaging'
    implementation 'com.google.firebase:firebase-storage'
    
    // 🔥 QO‘SHILDI: MultiDex support
    implementation 'androidx.multidex:multidex:2.0.1'
    
    // 🔥 QO‘SHILDI: Biometric/Fingerprint support
    implementation 'androidx.biometric:biometric:1.1.0'
}