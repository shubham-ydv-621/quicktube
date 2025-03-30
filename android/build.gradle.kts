plugins {
    id("com.android.application") version "8.3.0" apply false // ✅ Add version here
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false
}

buildscript {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.3.0") // ✅ Ensure correct Gradle Plugin
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.22")
        classpath("com.google.gms:google-services:4.4.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    afterEvaluate {
        if (project.name != "app") {
            evaluationDependsOn(":app")
        }
    }
}

// ✅ Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
