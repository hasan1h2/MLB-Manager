# MLB Manager — Android Build & Release Guide

## 1. Prerequisites
- Flutter 3.38+ / Dart 3.10+
- JDK 17
- Android SDK 34 (Command line tools or Android Studio)

---

## 2. Generating Code & Assets
Before building any release binary, ensure Drift code generation is up-to-date:
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

---

## 3. Building Android Release APK
To compile a universal APK:
```bash
flutter build apk --release
```
Output:
`build/app/outputs/flutter-apk/app-release.apk`

To compile split-per-ABI APKs (smaller file size):
```bash
flutter build apk --release --split-per-abi
```

---

## 4. Building Android App Bundle (AAB) for Google Play Store
```bash
flutter build appbundle --release
```
Output:
`build/app/outputs/bundle/release/app-release.aab`

---

## 5. Keystore & Signing Configuration
In production:
1. Generate keystore:
   ```bash
   keytool -genkey -v -keystore mlb_keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias mlb_key
   ```
2. Reference credentials in `android/key.properties`:
   ```properties
   storePassword=your_store_password
   keyPassword=your_key_password
   keyAlias=mlb_key
   storeFile=../mlb_keystore.jks
   ```
3. Update `android/app/build.gradle.kts` release signing config.
