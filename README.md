# DrainageTwin

Drainage Twin é um projeto voltado para detecção e prevenção de alagamentos e enchetes. O seu sistema será integrado com um modelo de predição, que alimentará as informações e os alertas no mapa. O projeto está na fase de MVP.

DrainageTwin is a Flutter project. This document will guide you through setting up the development environment, installing dependencies, and running the application on various platforms.

## Prerequisites

Ensure that you have the following installed on your development machine:

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Android Studio or Visual Studio Code with Flutter plugin
- Xcode for iOS development (macOS only)

## Step-by-step Guide

### 1. Set Up the Flutter Environment

Start by verifying your Flutter setup using the command:

```bash
$ flutter doctor
```

Your output should look similar to this for a properly set up environment:

```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.24.5, on Debian GNU/Linux 12 (bookworm) 6.1.0-28-amd64, locale en_US.UTF-8)
[✓] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
[✓] Chrome - develop for the web
[✓] Linux toolchain - develop for Linux desktop
[✓] Android Studio (version 2024.2)
[✓] IntelliJ IDEA Community Edition (version 2024.3)
[✓] VS Code (version 1.95.3)
[✓] Connected device (2 available)
[✓] Network resources
```

Make sure there are no issues reported.

### 2. Install Project Dependencies

Run the following command to install and update the project dependencies:

```bash
$ flutter pub get && flutter pub upgrade
```

### 3. Configure Google Maps API Key

You need to set up your Google Maps API key for the application to work on Android, iOS, and Web platforms.

- **Android**: Add your API key in `~/android/app/src/main/AndroidManifest.xml`:

```xml
<application>
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_API_KEY" />
</application>
```

- **iOS**: Add your API key in `~/ios/Runner/AppDelegate.swift`:

```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey("YOUR_API_KEY")
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

- **Web**: Add your API key in `~/web/index.html`:

```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY"></script>
```

**Note**: Replace `YOUR_API_KEY` with your actual API key.

### 4. Run the App

Once you've configured your environment and dependencies, you can run the app on your device using:

```bash
$ flutter run
```

## Troubleshooting

- If you face any issues with running `flutter doctor`, ensure that the necessary SDKs are properly installed and that your environment variables are set up correctly.
- Verify that your API keys are valid and have the appropriate permissions for your intended use.

## App running in Android simulator

Due to file size restriction from Github and recording from simulator from Intellij, the video is in low quality.

https://github.com/user-attachments/assets/3e97acc2-3ff3-4bfd-81fd-6fa5a1968176

## License

This project is licensed under the [Your License] License. See the LICENSE file for details.
