# Waves

## Overview
Waves is a short-form social networking app powered by the [Hive blockchain](https://hive.io) and built with [Flutter](https://flutter.dev).

This repository contains the Flutter client, supporting Android, iOS, and the web. Use the instructions below to get the project running on your device and to keep your development environment up to date.

## Features

- Connects to the decentralized Hive blockchain for content and rewards
- Built with Flutter 3.32+ with support for mobile and web targets
- Includes Firebase configuration for analytics and messaging
- Provides a modern social networking experience tailored for quick updates

Follow the steps below to set up Flutter and run the application on your mobile device or emulator.

## Prerequisites

Before you begin, ensure you have the following installed on your system:
- Flutter SDK (version 3.32.0 or later)
- Visual Studio Code or Android Studio
- Git

## Getting Started

### Step 1: Download and Install Flutter

1. **Download and Install Flutter:**
   - Visit the Flutter official website: [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install) to download the Flutter SDK for your operating system.
   
2. **Verify Installation:**
   - Run the following command in your terminal to verify Flutter is correctly installed:
     ```bash
     flutter doctor
     ```

### Step 2: Set Up Visual Studio Code or Android Studio

## Set Up Visual Studio Code

1. **Download and Install VS Code:**
   - Visit the Visual Studio Code website: [https://code.visualstudio.com/](https://code.visualstudio.com/) and download the installer for your operating system.

2. **Install Flutter and Dart Plugins:**
   - Open VS Code.
   - Go to the Extensions view by clicking on the Extensions icon in the Activity Bar on the side of the window.
   - Search for "Flutter" and click Install.
   - This will also install the Dart plugin.

## Set Up Android Studio 

1. **Download and Install Android Studio:**
   - Visit the Android Studio website: [https://developer.android.com/studio](https://developer.android.com/studio) and download the installer for your operating system.

2. **Install Flutter and Dart Plugins:**
   - Open Android Studio.
   - Go to `File > Settings > Plugins`.
   - Search for "Flutter" and click Install. This will also install the Dart plugin.
   - Restart Android Studio.

3. **Set Up Android Emulator (Optional):**
   - Open Android Studio.
   - Go to `Tools > AVD Manager` and create a new Virtual Device.
   - Follow the instructions to set up an Android emulator.

### Step 3: Clone the Project

1. **Clone the Repository:**
   - Clone this project repository:
     ```bash
     git clone https://github.com/ecency/ecency-waves.git
     cd ecency-waves
     ```
 

### Step 4: Run the App

1. **Run the App:**
   - The commands below should be run at the root of the project directory.
   - Open your project in VS Code or Android Studio.
   - Connect your mobile device via USB or start an emulator.
   - Run the following command to get the app dependencies in your terminal:
     ```bash
     flutter pub get
     ```
   - Ensure your device is detected by running:
     ```bash
     flutter devices
     ```
   - Run the app using:
     ```bash
     flutter run
     ```
   - For web builds, ensure you have a Chrome or Edge browser installed and run:
     ```bash
     flutter run -d chrome
     ```

## Contributing

We welcome community contributions! Please open an issue to discuss feature ideas or bug reports, and submit pull requests following the repository's coding guidelines. Make sure to run the Flutter analyzer and tests before submitting changes.

## Additional Resources

- Flutter Official Documentation: [https://flutter.dev/docs](https://flutter.dev/docs)
- Flutter YouTube Channel: [https://www.youtube.com/c/flutterdev](https://www.youtube.com/c/flutterdev)
- Dart Official Documentation: [https://dart.dev/guides](https://dart.dev/guides)
- Visual Studio Code Documentation: [https://code.visualstudio.com/docs](https://code.visualstudio.com/docs)
- Android Studio Documentation: [https://developer.android.com/studio/intro](https://developer.android.com/studio/intro)

## License

This project is licensed under the [MIT License](./LICENSE).

