import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { stream ->
        localProperties.load(stream)
    }
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode")
val flutterVersionName = localProperties.getProperty("flutter.versionName")

android {
    namespace = "com.twoja_nazwa.smarthouseiot"
    compileSdk = 36 // ZMIANA: Podniesiono wersję zgodnie z błędem
    ndkVersion = "27.0.12077973" // ZMIANA: Nowsza wersja NDK

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "com.twoja_nazwa.smarthouseiot"
        minSdk = flutter.minSdkVersion
        targetSdk = 36 // ZMIANA: Dopasowano do compileSdk
        versionCode = flutterVersionCode?.toIntOrNull() ?: 1
        versionName = flutterVersionName ?: "1.0"
    }

    buildTypes {
        release {
            // Enable ProGuard/R8 for code obfuscation and optimization
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("debug")
        }
        debug {
            isMinifyEnabled = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
  // ...

  // Import the Firebase BoM
  implementation(platform("com.google.firebase:firebase-bom:34.5.0"))

  // When using the BoM, you don't specify versions in Firebase library dependencies

  // Add the dependency for the Firebase SDK for Google Analytics
  implementation("com.google.firebase:firebase-analytics")

  // TODO: Add the dependencies for any other Firebase products you want to use
  // See https://firebase.google.com/docs/android/setup#available-libraries
  // For example, add the dependencies for Firebase Authentication and Cloud Firestore
  implementation("com.google.firebase:firebase-auth")
  implementation("com.google.firebase:firebase-firestore")
    // Play Core (needed for deferred components / split install classes used by Flutter)
    // Play Core dependency intentionally omitted; rely on existing platform artifacts and
    // the proguard -dontwarn rules added to suppress missing Play Core classes during R8.

}