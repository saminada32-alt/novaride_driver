plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.novaride.driver"
    compileSdk = flutter.compileSdkVersion
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
        applicationId = "com.novaride.driver"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["googleMapsApiKey"] =
            (project.findProperty("GOOGLE_MAPS_API_KEY") as String?) ?: ""
    }

    signingConfigs {
        create("release") {
            val keystorePath = System.getenv("ANDROID_KEYSTORE_PATH")
            if (!keystorePath.isNullOrBlank()) {
                storeFile = file(keystorePath)
                storePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
                keyAlias = System.getenv("ANDROID_KEY_ALIAS")
                keyPassword = System.getenv("ANDROID_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            // Minify strips plugin classes on some Samsung/Huawei devices → instant crash.
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

// Refuse to ship a release build silently signed with the debug keystore.
gradle.taskGraph.whenReady {
    val buildingRelease = allTasks.any { it.name.contains("Release") }
    if (!buildingRelease) return@whenReady

    val requiredEnvVars = listOf(
        "ANDROID_KEYSTORE_PATH",
        "ANDROID_KEYSTORE_PASSWORD",
        "ANDROID_KEY_ALIAS",
        "ANDROID_KEY_PASSWORD",
    )
    val missing = requiredEnvVars.filter { System.getenv(it).isNullOrBlank() }
    if (missing.isNotEmpty()) {
        throw GradleException(
            "Refusing to build a release APK/AAB without a real release keystore. " +
                "Missing environment variable(s): ${missing.joinToString(", ")}. " +
                "This build will NOT fall back to debug signing."
        )
    }

    val keystoreFile = file(System.getenv("ANDROID_KEYSTORE_PATH"))
    if (!keystoreFile.exists()) {
        throw GradleException(
            "ANDROID_KEYSTORE_PATH points to '${keystoreFile.absolutePath}', which does not exist. " +
                "Refusing to fall back to debug signing for a release build."
        )
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

flutter {
    source = "../.."
}
