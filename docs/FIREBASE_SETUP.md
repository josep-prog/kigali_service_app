# Firebase Setup Instructions

## Step 1: Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click "Add project"
3. Enter project name: "Kigali City Directory"
4. Enable/disable Google Analytics (optional)
5. Click "Create project"

## Step 2: Add Flutter App to Firebase

### Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### Configure Firebase

```bash
cd kigali_city_services
flutterfire configure
```

This will:
- Create Firebase apps for Android and iOS
- Generate `firebase_options.dart` file
- Configure platform-specific files

## Step 3: Enable Authentication

1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Click "Sign-in method" tab
4. Click "Email/Password"
5. Enable "Email/Password"
6. Click "Save"

## Step 4: Create Firestore Database

1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Select "Start in production mode"
4. Choose location closest to Rwanda (e.g., europe-west)
5. Click "Enable"

## Step 5: Deploy Security Rules

1. In Firestore Database, click "Rules" tab
2. Replace with the following rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    match /listings/{listingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
                      request.resource.data.createdBy == request.auth.uid;
      allow update, delete: if request.auth.uid == resource.data.createdBy;
    }
  }
}
```

3. Click "Publish"

## Step 6: Google Maps Setup

### Get API Key

1. Go to https://console.cloud.google.com
2. Select your Firebase project
3. Go to "APIs & Services" → "Credentials"
4. Click "Create Credentials" → "API Key"
5. Copy the API key

### Enable Required APIs

1. Go to "APIs & Services" → "Library"
2. Search and enable:
   - Maps SDK for Android
   - Maps SDK for iOS

### Configure Android

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...>
    <application ...>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_API_KEY_HERE"/>
        ...
    </application>
</manifest>
```

### Configure iOS

Edit `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Step 7: Install Dependencies

```bash
flutter pub get
```

## Step 8: Run the App

```bash
flutter run
```

## Verification Checklist

- [ ] Firebase project created
- [ ] Flutter app configured with FlutterFire CLI
- [ ] Authentication enabled (Email/Password)
- [ ] Firestore database created
- [ ] Security rules deployed
- [ ] Google Maps API key obtained
- [ ] Maps SDK enabled for Android and iOS
- [ ] API key configured in Android and iOS
- [ ] Dependencies installed
- [ ] App runs successfully
