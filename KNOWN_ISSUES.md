# MLB Manager — Known Issues & Limitations

## Device & Platform Specifics
1. **Speech-to-Text Offline Languages**:
   - Bengali speech recognition accuracy depends on whether the host Android device has installed the Google offline Bengali language pack. In the absence of an offline language pack, the system provides standard manual input and fallback text review.
2. **Biometric Support**:
   - Devices without physical biometric hardware (fingerprint/face) gracefully fall back to numerical App PIN authentication.
3. **Receipt OCR**:
   - Handwritten Bengali grocery slips may vary in OCR clarity depending on image quality. MLB Manager enforces mandatory user review and editing before saving any OCR output.
