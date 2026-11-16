# MLB Manager — Security Guidelines & Architecture

## Security Principles
MLB Manager handles highly sensitive financial records, business revenue, and family information on personal Android devices. As an offline-first system, all security boundaries exist locally.

---

## 1. Local App Lock (PIN & Biometrics)
- **App PIN**: 4 to 6 digit numerical PIN hashed with SHA-256 and salt, stored in `FlutterSecureStorage` (backed by Android Keystore).
- **Biometric Authentication**: Integrated via `local_auth` (`FlutterFragmentActivity`) using system biometric prompts (Fingerprint / Face Unlock).
- **Auto-Lock**: Configurable inactivity timeouts (Immediately, 1 min, 5 min, 15 min).
- **Lock Guard**: GetX route middleware / route guard intercepting access if locked.

---

## 2. Secure Local Storage
- Sensitive credentials, encryption keys, and security settings are stored in `FlutterSecureStorage`.
- General preferences (non-sensitive preferences like theme mode, active language) are kept in `SharedPreferences`.

---

## 3. Data Protection in Logs & Memory
- Never output real financial numbers, customer phone numbers, or account details into `debugPrint` or `print` in release mode.
- Audit logs store administrative actions locally with member attribution and timestamps without logging sensitive raw credentials.

---

## 4. Privacy & Offline Boundaries
- No financial or transaction records are transmitted to external servers.
- OCR text recognition executes locally on-device using ML Kit (`google_mlkit_text_recognition`).
- Speech-to-text processing uses local on-device recognizers where available.
- Backups are stored in user-designated local storage, encrypted or compressed per user instruction.
