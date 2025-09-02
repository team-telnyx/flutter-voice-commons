# Telnyx Common - Setup Guide

This guide will walk you through the complete setup process for integrating Telnyx Common into your Flutter application.

## Table of Contents

- [Installation](#installation)
- [Android Setup](#android-setup)
- [iOS Setup](#ios-setup)
- [Permissions](#permissions)
- [Firebase Configuration (Android Only)](#firebase-configuration-android-only)
- [Verification](#verification)

## Installation

Add `telnyx_common` to your `pubspec.yaml`:

```yaml
dependencies:
  telnyx_common: ^0.0.1-beta
```

Then run:

```bash
flutter pub get
```

## Android Setup

### 1. Add Firebase Configuration

Add your `google-services.json` file to `android/app/`:

```
android/
  app/
    google-services.json  # Add this file here
```

You can obtain this file from your Firebase Console:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (or create a new one)
3. Go to Project Settings → General
4. Download the `google-services.json` file for Android

### 2. Update AndroidManifest.xml

Add the following permissions and services to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Required Permissions -->
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
    
    <!-- Required for Notifications -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_PHONE_CALL"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MICROPHONE" />
    <uses-permission android:name="android.permission.MANAGE_OWN_CALLS"/>

    <application
        android:label="your_app_name"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Your existing activity configuration -->
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <!-- ... your existing intent filters ... -->
        </activity>

        <!-- Required Services for Call Handling -->
        <service
            android:name="com.hiennv.flutter_callkit_incoming.CallkitIncomingBroadcastReceiver"
            android:enabled="true"
            android:exported="true" />
        
        <!-- OngoingNotificationService for flutter_callkit_incoming -->
        <service
            android:name="com.hiennv.flutter_callkit_incoming.OngoingNotificationService"
            android:enabled="true"
            android:exported="false"
            android:foregroundServiceType="phoneCall|microphone" />
            
        <!-- Don't delete the meta-data below.
             This is used by the Flutter tool to generate GeneratedPluginRegistrant.java -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

### 3. Update build.gradle Files

Ensure your `android/app/build.gradle` has the necessary configurations:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
        // ... other configurations
    }
}

dependencies {
    // Firebase
    implementation platform('com.google.firebase:firebase-bom:32.2.3')
    implementation 'com.google.firebase:firebase-messaging'
    // ... other dependencies
}

// Add this at the bottom
apply plugin: 'com.google.gms.google-services'
```

And in your `android/build.gradle`:

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
        // ... other dependencies
    }
}
```

## iOS Setup

### 1. Update Info.plist

Add the following to `ios/Runner/Info.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Your existing configurations -->
    
    <!-- Microphone Permission -->
    <key>NSMicrophoneUsageDescription</key>
    <string>This app needs microphone access to make voice calls</string>
    
    <!-- Background Modes for VoIP -->
    <key>UIBackgroundModes</key>
    <array>
        <string>audio</string>
        <string>voip</string>
    </array>
    
    <!-- Your other existing configurations -->
</dict>
</plist>
```

### 2. Update AppDelegate.swift

For the easiest implementation, replace your `ios/Runner/AppDelegate.swift` with the following complete implementation:

```swift
import UIKit
import Flutter
import PushKit
import CallKit
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        // Configure audio session for VoIP
        configureAudioSession()
        
        // Register for VoIP push notifications
        registerForVoIPPushes()
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetooth, .allowBluetoothA2DP])
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    private func registerForVoIPPushes() {
        let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [.voIP]
    }
    
    // MARK: - PKPushRegistryDelegate
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let deviceToken = pushCredentials.token.map { String(format: "%02x", $0) }.joined()
        print("VoIP push token: \(deviceToken)")
        
        // Send token to Flutter
        if let controller = window?.rootViewController as? FlutterViewController {
            let channel = FlutterMethodChannel(name: "telnyx_common/push_token", binaryMessenger: controller.binaryMessenger)
            channel.invokeMethod("onVoIPTokenReceived", arguments: deviceToken)
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("VoIP push token invalidated")
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        print("Received VoIP push: \(payload.dictionaryPayload)")
        
        // Send push payload to Flutter
        if let controller = window?.rootViewController as? FlutterViewController {
            let channel = FlutterMethodChannel(name: "telnyx_common/push_notification", binaryMessenger: controller.binaryMessenger)
            channel.invokeMethod("onPushReceived", arguments: payload.dictionaryPayload)
        }
        
        completion()
    }
}
```

### 3. Enable Push Notifications Capability

1. Open your iOS project in Xcode (`ios/Runner.xcworkspace`)
2. Select your app target
3. Go to "Signing & Capabilities"
4. Click the "+" button and add "Push Notifications"
5. Click the "+" button and add "Background Modes"
6. Under Background Modes, enable:
   - Audio, AirPlay, and Picture in Picture
   - Voice over IP

## Permissions

### Runtime Permissions

The SDK requires certain runtime permissions. You can request them using the example implementation:

Create a file `lib/utils/app_permissions.dart`:

```dart
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AppPermissions {
  static Future<void> requestPermissions() async {
    // Request microphone permission
    await Permission.microphone.request();
    
    // Request notification permission
    await Permission.notification.request();
    
    // For Android, request phone permission for ConnectionService
    if (Platform.isAndroid) {
      await Permission.phone.request();
    }
  }
  
  static Future<String?> getNotificationTokenForPlatform() async {
    if (Platform.isAndroid) {
      // Get FCM token for Android
      return await FirebaseMessaging.instance.getToken();
    } else if (Platform.isIOS) {
      // For iOS, VoIP push tokens are handled natively by the AppDelegate
      // No Firebase required for iOS
      return null;
    }
    return null;
  }
}
```

Don't forget to add the required dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  permission_handler: ^11.0.1
  firebase_messaging: ^14.6.9  # Only required for Android
```

## Firebase Configuration (Android Only)

**Note:** Firebase is only required for Android push notifications. iOS uses native VoIP push notifications through PushKit/CallKit.

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select an existing one
3. Add your Android app to the project

### 2. Configure Cloud Messaging for Android

1. In Firebase Console, go to Project Settings
2. Navigate to the "Cloud Messaging" tab
3. Note your Server Key (you'll need this for Telnyx configuration)

## Verification

### Test Your Setup

Create a simple test to verify everything is working:

```dart
import 'package:flutter/material.dart';
import 'package:telnyx_common/telnyx_common.dart';
import 'utils/app_permissions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Request permissions
  await AppPermissions.requestPermissions();
  
  // Create VoIP client
  final voipClient = TelnyxVoipClient(
    enableNativeUI: true,
    enableBackgroundHandling: true,
  );
  
  runApp(MyApp(voipClient: voipClient));
}

class MyApp extends StatelessWidget {
  final TelnyxVoipClient voipClient;
  
  const MyApp({Key? key, required this.voipClient}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Telnyx Setup Test',
      home: Scaffold(
        appBar: AppBar(title: Text('Setup Verification')),
        body: Center(
          child: StreamBuilder<TelnyxConnectionState>(
            stream: voipClient.connectionState,
            builder: (context, snapshot) {
              final state = snapshot.data ?? Disconnected();
              return Text('Connection State: ${state.runtimeType}');
            },
          ),
        ),
      ),
    );
  }
}
```

### Common Setup Issues

1. **Android Build Errors**: Make sure your `minSdkVersion` is at least 21
2. **iOS Build Errors**: Ensure all capabilities are properly configured in Xcode
3. **Permission Denied**: Make sure all required permissions are declared in manifests
4. **Firebase Issues (Android)**: Verify that `google-services.json` is properly added to Android app folder

## Next Steps

Once your setup is complete, proceed to the [Usage Guide](usage.md) to learn how to:
- Authenticate with Telnyx
- Make and receive calls
- Handle call states and controls
- Implement push notification handling