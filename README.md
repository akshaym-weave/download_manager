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

## Expected behavior demo

[Watch or download the candidate demo video](docs/download-manager-candidate-demo.mp4)
(2 minutes 23 seconds; silent, with on-screen explanations).

The demo covers queue order, concurrency, progress, pause/resume, cancellation,
failure/retry, late updates, and cleanup. It uses the reference app with scripted local
events and shows expected behavior without solution code.
