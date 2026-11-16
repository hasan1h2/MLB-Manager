# My Life & Business Manager (MLB Manager) — Project Setup Guide

## Overview
**MLB Manager** is a complete, offline-first personal finance, family management, and multi-business accounting system built with Flutter, Dart, GetX, SQLite, and Drift ORM.

---

## 1. Prerequisites
- **Flutter SDK**: 3.38.x or compatible stable channel (Dart 3.10.x / Dart 3.x)
- **Java Development Kit**: JDK 17 (Required for Android Gradle Plugin 8.x)
- **Android SDK**: Android API 34+ (compileSdk 34, targetSdk 34, minSdk 23)
- **Android Studio / VS Code**: With Flutter and Dart plugins installed.

---

## 2. Dependencies Setup
Clone or locate the repository directory:
```bash
cd "c:\Users\mdhas\OneDrive\Desktop\WEB SITE\MLB Manager"
flutter pub get
```

---

## 3. Code Generation (Drift & Build Runner)
This project uses Drift ORM with code generation. Whenever schema or queries are modified, run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

For continuous watch during development:
```bash
dart run build_runner watch --delete-conflicting-outputs
```

---

## 4. Running the Application
### Run on Connected Android Device or Emulator
```bash
flutter run
```

### Run in Profile Mode
```bash
flutter run --profile
```

### Build APK
```bash
flutter build apk --release
```

---

## 5. Automated Tests & Static Analysis
Run static analysis:
```bash
flutter analyze
```

Run all unit, database, and integration tests:
```bash
flutter test
```
