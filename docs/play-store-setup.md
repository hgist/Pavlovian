# Pavlovian — Play Store Phase 2 Setup

App-side preparation steps for publishing to Google Play Store.
Captured from the session where Phase 2 was originally executed.

---

## Phase 2 — App-side preparation *(half a day)*

### Step 1 — Rename application ID

Original applicationId was `com.hst.pavlovian.pavlovian` (Flutter scaffold
quirk — the package was nested under itself). Play Store freezes the
applicationId at first publish, so we rename to `com.hst.pavlovian`
before submitting.

**Files changed:**

- `android/app/build.gradle.kts`
  ```kotlin
  android {
      namespace = "com.hst.pavlovian"          // was "com.hst.pavlovian.pavlovian"
      ...
      defaultConfig {
          applicationId = "com.hst.pavlovian"  // was "com.hst.pavlovian.pavlovian"
      }
  }
  ```
- Moved Kotlin source:
  ```
  android/app/src/main/kotlin/com/hst/pavlovian/pavlovian/MainActivity.kt
                                            ↓
  android/app/src/main/kotlin/com/hst/pavlovian/MainActivity.kt
  ```
- `MainActivity.kt` first line:
  ```kotlin
  package com.hst.pavlovian       // was com.hst.pavlovian.pavlovian
  ```

**Side effect:** Phones with the old applicationId installed see the
new build as a separate app. Uninstall the old one before installing
the new one to avoid two icons.

### Step 2 — Wire release keystore (config side)

Make `build.gradle.kts` read a `key.properties` file when present
(production builds) and fall back to debug signing when absent (local
dev). The keystore + passwords never land in git.

**`android/app/build.gradle.kts`** — top of file:

```kotlin
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Load android/key.properties (NOT committed to git — see .gitignore).
// File format:
//   storeFile=C:/secure/pavlovian-keystore.jks
//   storePassword=...
//   keyAlias=pavlovian
//   keyPassword=...
val keystoreProperties = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) load(FileInputStream(f))
}
val hasReleaseKeystore = keystoreProperties.getProperty("storeFile") != null
```

**Inside `android { ... }`** — add a `signingConfigs` block and change
the release `buildTypes` block:

```kotlin
signingConfigs {
    if (hasReleaseKeystore) {
        create("release") {
            storeFile = file(keystoreProperties.getProperty("storeFile"))
            storePassword = keystoreProperties.getProperty("storePassword")
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
        }
    }
}

buildTypes {
    release {
        signingConfig = if (hasReleaseKeystore)
            signingConfigs.getByName("release")
        else
            signingConfigs.getByName("debug")
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

**`.gitignore`** — append:

```
# Signing keystore and password file — NEVER commit these.
android/key.properties
*.jks
*.keystore
```

### Step 3 — Manual steps YOU need to do

The interactive commands below can't be automated from the IDE.

#### A. Generate the keystore

In a Windows terminal (anywhere — not necessarily inside the project):

```
keytool -genkey -v -keystore C:\Keys\pavlovian-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias pavlovian
```

Pick any folder for `C:\Keys\` that lives OUTSIDE the project tree.
You'll be prompted for:

- **Keystore password** — pick something memorable + strong. Save it
  in a password manager.
- Name, organization, country — these end up in the X.509 certificate.
  For a personal app, your real name and `IL` are fine.
- **Key password** — easiest to make it the same as the keystore
  password (press Enter when asked "same as keystore?").

🔥 **BACK UP `pavlovian-keystore.jks` IMMEDIATELY.** Copy it to OneDrive,
a USB stick, anywhere off the dev machine. Losing this file means you
can never publish updates to this app on Play Store — you'd have to
create a brand-new app listing and lose every install. There is no
recovery from Google.

#### B. Create `android/key.properties`

In `C:\Workspace\AI\Pavlovians\android\key.properties`:

```
storeFile=C:/Keys/pavlovian-keystore.jks
storePassword=YOUR_KEYSTORE_PASSWORD
keyAlias=pavlovian
keyPassword=YOUR_KEY_PASSWORD
```

Note **forward slashes** in `storeFile=` — Gradle reads them more
reliably than backslashes on Windows.

#### C. Build the AAB (Play Store format)

```
flutter build appbundle --release
```

Output: `build\app\outputs\bundle\release\app-release.aab` (~10–15 MB,
smaller than the APK). This is the file you upload to Play Console.

#### D. (Optional) Verify signing works locally

```
flutter build apk --release
flutter install -d <phone-id>
```

If install succeeds, signing is wired up correctly. The phone will
show this as a fresh app because the applicationId changed — uninstall
the previous version first.

---

## What gets uploaded vs what gets retained locally

| File                          | Where it lives          | Commit to git? |
|-------------------------------|-------------------------|----------------|
| `app-release.aab`             | `build/app/outputs/...` | No (gitignored) |
| `app-release.apk`             | `build/app/outputs/...` | No (gitignored) |
| `pavlovian-keystore.jks`      | `C:\Keys\` (or backup)  | **NEVER**       |
| `android/key.properties`      | local only              | **NEVER**       |
| `build.gradle.kts` (config)   | repo                    | Yes             |

---

## Recovery checklist if the dev machine dies

You need TWO files restored to publish updates:

1. `pavlovian-keystore.jks` — from your backup
2. `android/key.properties` — recreate by hand using the keystore
   passwords you saved in your password manager

Without (1) you cannot publish any update to the Play Store listing.
