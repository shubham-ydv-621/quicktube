plugins {
    id("com.android.application") 
    id("com.google.gms.google-services") 
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.shubham.quicktube"
    compileSdk = 35
    ndkVersion = "25.2.9519653"
   compileOptions {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}
kotlinOptions {
    jvmTarget = "17"
}
  // ✅ Make sure this version exists in your system

    defaultConfig {
        applicationId = "com.shubham.quicktube"
        minSdk = 24  // ✅ Recommended: Change 23 → 24 if using Firebase
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.11.0"))  // ✅ Update if needed
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-messaging")
}
