// Top-level build file where you can add configuration options common to all sub-projects/modules.

plugins {
    id("com.android.application") version "8.1.1" apply false
    kotlin("android") version "1.9.0" apply false
    id("com.google.gms.google-services") version "4.3.15" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 🔥 TUZATILDI: build directory konfiguratsiyasi
val newBuildDir: Directory = rootProject.layout.buildDirectory
    .dir("../../build")
    .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// 🔥 TUZATILDI: evaluationDependsOn to'g'rilandi
subprojects {
    afterEvaluate {
        if (project.name != "app") {
            project.evaluationDependsOn(":app")
        }
    }
}

// 🔥 TUZATILDI: clean task to'g'rilandi
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}