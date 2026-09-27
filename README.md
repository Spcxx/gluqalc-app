# GluQalc App

![Flutter](https://img.shields.io/badge/Flutter-3.13.2-02569B.svg)
![Dart](https://img.shields.io/badge/Dart-^3.13.2-0175C2.svg)
![Riverpod](https://img.shields.io/badge/Riverpod-3.4.2-764ABC.svg)
![Multiplatform](https://img.shields.io/badge/Platform-Android%20%7C%20Windows%20%7C%20Web%20%7C%20Linux-blue.svg)

Multiplatform client application for the GluQalc API, designed for nutrition tracking and insulin calculation. Built with Flutter, it provides a responsive interface for logging meals, managing products, and calculating insulin.

---

## Disclaimers

[![Medical Disclaimer](https://img.shields.io/badge/%E2%9A%A0%EF%B8%8F_Medical_Disclaimer-Read_Before_Use-red?style=for-the-badge)](./MEDICAL_DISCLAIMER.md)

- **Regulatory Disclaimer**: This software and its codebase have not been evaluated, cleared or approved by any regulatory health authority.
- **Intended Use**: This project is provided strictly for educational, research and academic purposes only. It is not a certified medical device and must not be used for clinical diagnosis, medical treatment or management of any health condition.

---

## Building

Requirements:
- [FVM (Flutter Version Management)](https://fvm.app/) installed globally.
- Platform dependencies (depending on your target platform).

To build production-ready binaries, make sure you use your production configuration file (prod.json) instead of dev.json.

1. Configure your environment editing the `prod.json` file.

2. Install project dependencies via FVM (it will automatically download the correct Flutter SDK version for this project):

```bash
fvm flutter pub get
````

3. Generate code (Freezed, Riverpod, Envied):

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

4. Build the application for your target platform.

### Android (APK / App Bundle)

To build a release APK:

```
fvm flutter build apk --release --dart-define-from-file=prod.json
```

The output binary will be located in `build/app/outputs/flutter-apk/`.

### Windows

To build a release executable for Windows:

```
fvm flutter build windows --release --dart-define-from-file=prod.json
```

The output executable will be located in `build/windows/x64/runner/release/`.

### Linux

To build a release binary for Linux:

```
fvm flutter build linux --release --dart-define-from-file=prod.json
```

The output binary will be located in `build/linux/x64/release/bundle/`.

### Web

To build a release version for Web:

```
fvm flutter build web --release --dart-define-from-file=prod.json
```

The output files will be located in `build/web/`.

---

## Development setup

Requirements:
- [FVM (Flutter Version Management)](https://fvm.app/) installed globally.
- Platform dependencies (depending on your target platform).

1. Configure your environment editing the `dev.json` file.

2. Install project dependencies via FVM (it will automatically download the correct Flutter SDK version for this project):

```bash
fvm flutter pub get
````

3. Generate code (Freezed, Riverpod, Envied):

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

4. Run the application with environment configuration:

```bash
fvm flutter run --dart-define-from-file=dev.json
```

---

## Usage

The GluQalc App is a client-side application that requires the GluQalc API to function. Ensure the API is running and reachable at the address specified in your environment configuration.

Official API repository: https://github.com/Spcxx/gluqalc-api

---

## What is in the project

- secure login with JWT and refresh token handling.
- logging daily meals with real-time macro and insulin dose calculations.
- local food database, Open Food Facts integration and barcode scanning support.
- tracking biometrics, nutrition targets and insulin-to-carb ratios.
- optimized, consistent and responsive layout for mobile (Android), desktop (Windows, Linux) and Web.

---

## Environment variables

The app uses `--dart-define-from-file` for configuration:

| Variable | Meaning |
| :--- | :--- |
| `API_URL` | Base URL for GluQalc API |
| `IS_PROD` | Production flag (true/false) |
| `GITHUB_API_URL` | Link to API repository |
| `GITHUB_APP_URL` | Link to App repository |
| `CONTACT_EMAIL` | Support/Contact email |
| `TOS_URL` | Terms of Service URL |
| `PRIVACY_URL` | Privacy Policy URL |
| `DISCLAIMER_URL` | Detailed Disclaimer URL |

---

## Stack

- Flutter (Material 3)
- Riverpod (with Code Generation)
- GoRouter
- Dio + Pretty Dio Logger
- Freezed + JSON Serializable
- Flutter Secure Storage
- Mobile Scanner
- Flutter SVG + Google Fonts

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
