plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // The Kotlin/R package, NOT the published id. It stays `com.turnkey.wtms`
    // for every flavour: renaming it would move MainActivity and the
    // generated R class, and each client's published identity is the
    // `applicationId` below instead.
    namespace = "com.turnkey.wtms"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // No applicationId here on purpose: every flavour sets its own, and a
        // default would be the one that silently shipped if a flavour were
        // ever forgotten.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ONE APP, ONE CLIENT PER FLAVOUR.
    //
    // This replaces the folder-per-client copying the project used to do
    // (`tanker_app_wtms` and `tanker_app_tademo`, which only ever differed by
    // the API URL, the application id and the app name). A copy meant every
    // fix had to be made twice and one of the two was always behind; a
    // flavour means there is one codebase and the difference is declared.
    //
    // **This file is the only one to edit to add a client.** Copy a block
    // below, give it the client's name, applicationId and app_name, and the
    // Dart side needs nothing: `lib/core/config/client_flavor.dart` reads
    // Flutter's own `appFlavor` constant and derives the panel address as
    // `https://<flavour>.turnkeyinfotech.live/api`. Only a client whose panel
    // is somewhere else has to be named there as well.
    // Off by default in this AGP, and the flavours below set `app_name`
    // through it: without this the build fails with "Product Flavor wtms
    // contains custom resource values, but the feature is disabled."
    buildFeatures {
        resValues = true
    }

    flavorDimensions += "client"

    productFlavors {
        create("wtms") {
            dimension = "client"
            applicationId = "com.turnkey.wtms"
            // Drives `android:label` in the manifest, so the launcher name
            // comes from here rather than being hard-coded per copy.
            resValue("string", "app_name", "WTMS")
        }

        create("tademo") {
            dimension = "client"
            applicationId = "com.turnkey.tademo"
            resValue("string", "app_name", "TA Demo")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
