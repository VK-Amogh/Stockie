# Stockie App (Flutter Implementation)

This directory contains the source code for the Stockie client application. It is built using Flutter and targets Windows (primary), Android, and iOS.

## 🛠️ Development Setup

### Prerequisites
- **Flutter SDK**: Stable channel (latest version recommended).
- **Dart SDK**: Included with Flutter.
- **IDE**: VS Code (recommended) or Android Studio.
- **Extensions**: Flutter & Dart plugins for your IDE.

### Installation
1.  **Get Dependencies**:
    ```bash
    flutter pub get
    ```

2.  **Run Code Generator** (If using freezed/json_serializable later):
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

3.  **Run the App**:
    ```bash
    flutter run
    ```
    *Select 'Windows' as your device if testing desktop features.*

## 🏗️ Architecture & Folder Structure

We follow a feature-first or layer-based architecture:

- `lib/main.dart`: Application entry point and route configuration.
- `lib/theme/`: `AppTheme` class defining colors (`AppColors`), typography, and global styles.
- `lib/models/`: Data classes (e.g., `Product`, `Invoice`).
- `lib/screens/`: UI logic, separated by feature (e.g., `inventory/`, `sales/`).
- `lib/services/`: Business logic and external data handling (e.g., `AuthService`).
- `lib/utils/`: Shared utilities (Search logic, Pricing calculators).

## 🧪 Testing

Run unit and widget tests:
```bash
flutter test
```

## 📦 Building for Production

**Windows (exe):**
```bash
flutter build windows
```
*Output: `build/windows/runner/Release/`*

**Android (apk):**
```bash
flutter build apk --release
```
*Output: `build/app/outputs/flutter-apk/app-release.apk`*

## 📝 Coding Standards
- Use **CamelCase** for classes and **snake_case** for filenames/variables.
- Keep widgets small and reusable.
- Put logic in Services/Controllers, not inside UI widgets where possible.
