# Telnyx Common Example

This is a basic example demonstrating the use of the `telnyx_common` module for Flutter applications. The example shows how to integrate Telnyx WebRTC voice calling capabilities with minimal setup.

## Features Demonstrated

- **Login with SIP credentials**: Shows how to authenticate with Telnyx using SIP user/password
- **Connection state monitoring**: Displays real-time connection status
- **Outgoing calls**: Make calls to any destination number
- **Call state display**: Shows active call information and state
- **Native UI integration**: Automatic CallKit (iOS) and ConnectionService (Android) integration
- **Push notification handling**: Background call handling (when configured)

## Getting Started

### Prerequisites

1. A Telnyx account with SIP credentials
2. Flutter SDK installed
3. For push notifications (optional):
   - Firebase project configured for Android
   - iOS VoIP push certificates configured

### Running the Example

1. Navigate to the example directory:
   ```bash
   cd example
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Configuration

1. **SIP Credentials**: Enter your Telnyx SIP credentials in the login form:
   - SIP User: Your Telnyx SIP username
   - SIP Password: Your Telnyx SIP password
   - Caller ID Name: Display name for outgoing calls
   - Caller ID Number: Phone number for outgoing calls

2. **Push Notifications** (Optional):
   - For Android: Add your `google-services.json` file to `android/app/`
   - For iOS: Configure VoIP push certificates in your Apple Developer account
   - Update the login configuration to include push device tokens

## How It Works

### Basic Flow

1. **Initialization**: The app creates a `TelnyxVoipClient` with native UI and background handling enabled
2. **Login**: User enters SIP credentials and calls `voipClient.login()`
3. **Connection Monitoring**: The app listens to `connectionState` stream for status updates
4. **Making Calls**: User can make outgoing calls using `voipClient.newCall()`
5. **Call Management**: The app monitors active calls through the `calls` and `activeCall` streams

### Key Components

- **TelnyxVoiceApp**: Wrapper widget that handles Firebase initialization and background processing
- **TelnyxVoipClient**: Main client for WebRTC operations
- **Connection State**: Real-time connection status monitoring
- **Call State**: Active call tracking and management

### Native UI Integration

The example automatically integrates with:
- **iOS CallKit**: Native iOS call interface
- **Android ConnectionService**: Native Android call interface

When a call is received via push notification, the native UI will automatically appear, allowing users to answer or decline calls even when the app is in the background.

## Code Structure

```
example/
├── lib/
│   └── main.dart          # Main application with demo UI
├── pubspec.yaml           # Dependencies and configuration
└── README.md             # This file
```

## Key Code Snippets

### Client Initialization
```dart
final voipClient = TelnyxVoipClient(
  enableNativeUI: true,
  enableBackgroundHandling: true,
);
```

### Login with Credentials
```dart
final config = CredentialConfig(
  sipUser: 'your_sip_user',
  sipPassword: 'your_sip_password',
  sipCallerIDName: 'Your Name',
  sipCallerIDNumber: 'Your Number',
);

await voipClient.login(config);
```

### Making a Call
```dart
final call = await voipClient.newCall(destination: '+1234567890');
```

### Monitoring Connection State
```dart
voipClient.connectionState.listen((state) {
  print('Connection state: $state');
});
```

### Monitoring Calls
```dart
voipClient.calls.listen((calls) {
  print('Active calls: ${calls.length}');
});
```

## Platform Setup

### Android Setup

1. Add your `google-services.json` file to `android/app/`
2. Update `android/app/src/main/AndroidManifest.xml` with required permissions:
   ```xml
   <uses-permission android:name="android.permission.RECORD_AUDIO" />
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
   <uses-permission android:name="android.permission.WAKE_LOCK" />
   <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
   <uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
   ```

### iOS Setup

1. Update `ios/Runner/Info.plist`:
   ```xml
   <key>NSMicrophoneUsageDescription</key>
   <string>This app needs microphone access to make voice calls</string>
   
   <key>UIBackgroundModes</key>
   <array>
       <string>audio</string>
       <string>voip</string>
   </array>
   ```

2. Configure VoIP push notifications in your Apple Developer account

## Next Steps

This basic example demonstrates the core functionality of `telnyx_common`. For production applications, consider:

1. **Secure credential storage**: Use secure storage for SIP credentials
2. **Push notification setup**: Configure Firebase and iOS VoIP push for incoming calls
3. **Error handling**: Implement comprehensive error handling and retry logic
4. **UI/UX improvements**: Create a more polished user interface
5. **State management**: Integrate with your preferred state management solution (Provider, BLoC, Riverpod, etc.)
6. **Call controls**: Add mute, hold, DTMF, and other call control features

## Support

For more information about the `telnyx_common` module, refer to the main README.md in the parent directory or visit the [Telnyx documentation](https://developers.telnyx.com/).