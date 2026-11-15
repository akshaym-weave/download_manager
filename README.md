# Senior download manager coding round

Read `QUESTIONS.md` before changing code. The app runs, but its scheduler and stream
lifecycle behavior are deliberately incorrect.

## Setup before the interview clock

```sh
flutter --version
flutter pub get
flutter analyze
flutter run -d chrome
flutter test
```

The download service is a deterministic local simulation. Do not add HTTP, file-system,
storage, or platform-plugin integration. No particular state-management package is required.
