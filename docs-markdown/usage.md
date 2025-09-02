# Telnyx Common - Usage Guide

This guide covers how to use Telnyx Common in your Flutter application, from basic authentication to advanced call handling.

## Table of Contents

- [Basic Setup](#basic-setup)
- [Using TelnyxVoiceApp](#using-telnyxvoiceapp)
- [Authentication](#authentication)
- [Making Calls](#making-calls)
- [Handling Incoming Calls](#handling-incoming-calls)
- [Call Controls](#call-controls)
- [State Management Integration](#state-management-integration)
- [Push Notification Handling](#push-notification-handling)
- [Background Handler](#background-handler)
- [Error Handling](#error-handling)
- [Advanced Usage](#advanced-usage)

## Basic Setup

### Creating a TelnyxVoipClient

```dart
import 'package:telnyx_common/telnyx_common.dart';

// Create a TelnyxVoipClient instance
final voipClient = TelnyxVoipClient(
  enableNativeUI: true,  // Enable CallKit/ConnectionService
  enableBackgroundHandling: true,  // Handle background state
);
```

### Listening to State Changes

```dart
// Listen to connection state changes
voipClient.connectionState.listen((state) {
  switch (state) {
    case Disconnected():
      print('Disconnected from Telnyx');
      break;
    case Connecting():
      print('Connecting to Telnyx...');
      break;
    case Connected():
      print('Connected to Telnyx');
      break;
    case ConnectionError():
      print('Connection error occurred');
      break;
  }
});

// Listen to call state changes
voipClient.calls.listen((calls) {
  print('Active calls: ${calls.length}');
  for (final call in calls) {
    print('Call ${call.callId}: ${call.currentState}');
  }
});

// Listen to active call changes
voipClient.activeCall.listen((call) {
  if (call != null) {
    print('Active call: ${call.callId}');
  } else {
    print('No active call');
  }
});
```

## Using TelnyxVoiceApp

For complete lifecycle management, use the `TelnyxVoiceApp` wrapper widget. This is the recommended approach for production applications.

### Complete App Setup

```dart
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:telnyx_common/telnyx_common.dart';
import 'utils/app_permissions.dart';

// Background push notification handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('[Background] Received push notification: ${message.data}');
  
  // TelnyxVoiceApp handles all the background push processing
  await TelnyxVoiceApp.handleBackgroundPush(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Request necessary permissions early
  await AppPermissions.requestPermissions();
  
  // Create the VoIP client with native UI and background handling enabled
  final voipClient = TelnyxVoipClient(
    enableNativeUI: true,
    enableBackgroundHandling: true,
  );
  
  // Initialize and run the app with TelnyxVoiceApp wrapper
  runApp(
    await TelnyxVoiceApp.initializeAndCreate(
      voipClient: voipClient,
      backgroundMessageHandler: _firebaseMessagingBackgroundHandler,
      child: MyApp(voipClient: voipClient),
    ),
  );
}

class MyApp extends StatelessWidget {
  final TelnyxVoipClient voipClient;

  const MyApp({super.key, required this.voipClient});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Voice App',
      home: HomeScreen(voipClient: voipClient),
    );
  }
}
```

### TelnyxVoiceApp Parameters

The `TelnyxVoiceApp.initializeAndCreate()` method accepts several parameters:

```dart
await TelnyxVoiceApp.initializeAndCreate(
  voipClient: voipClient,                    // Required: Your VoIP client
  child: MyApp(),                            // Required: Your app widget
  backgroundMessageHandler: _backgroundHandler, // Optional: Background push handler
  firebaseOptions: DefaultFirebaseOptions.currentPlatform, // Optional: Firebase config
  onPushNotificationProcessingStarted: () {  // Optional: Push processing started
    print('Processing push notification...');
  },
  onPushNotificationProcessingCompleted: () { // Optional: Push processing completed
    print('Push notification processed');
  },
  onAppLifecycleStateChanged: (state) {     // Optional: App lifecycle changes
    print('App lifecycle state: $state');
  },
  enableAutoReconnect: true,                 // Optional: Auto-reconnect (default: true)
  skipWebBackgroundDetection: true,          // Optional: Skip web detection (default: true)
);
```

## Authentication

### Using SIP Credentials

```dart
Future<void> loginWithCredentials() async {
  try {
    final credentialConfig = CredentialConfig(
      sipUser: 'your_sip_user',
      sipPassword: 'your_sip_password',
      sipCallerIDName: 'Your Name',
      sipCallerIDNumber: 'Your Number',
      logLevel: LogLevel.none,
      debug: false,
      // Push token for notifications (platform-specific)
      notificationToken: await AppPermissions.getNotificationTokenForPlatform(),
    );

    await voipClient.login(credentialConfig);
    print('Login successful!');
  } catch (e) {
    print('Login failed: $e');
  }
}
```

### Using SIP Token

```dart
Future<void> loginWithToken() async {
  try {
    final tokenConfig = TokenConfig(
      sipToken: 'your_sip_token',
      sipCallerIDName: 'Your Name',
      sipCallerIDNumber: 'Your Number',
      logLevel: LogLevel.none,
      debug: false,
      // Push token for notifications (platform-specific)
      notificationToken: await AppPermissions.getNotificationTokenForPlatform(),
    );

    await voipClient.loginWithToken(tokenConfig);
    print('Login successful!');
  } catch (e) {
    print('Login failed: $e');
  }
}
```

### Logout

```dart
Future<void> logout() async {
  try {
    await voipClient.logout();
    print('Logged out successfully');
  } catch (e) {
    print('Logout failed: $e');
  }
}
```

## Making Calls

### Basic Outgoing Call

```dart
Future<void> makeCall(String destination) async {
  try {
    final call = await voipClient.newCall(destination: destination);
    print('Calling $destination...');
    
    // Listen to call state changes
    call.callState.listen((state) {
      switch (state) {
        case CallState.ringing:
          print('Call is ringing...');
          break;
        case CallState.active:
          print('Call is active');
          break;
        case CallState.ended:
          print('Call ended');
          break;
        case CallState.held:
          print('Call is on hold');
          break;
      }
    });
  } catch (e) {
    print('Failed to make call: $e');
  }
}
```

### Call with Custom Headers

```dart
Future<void> makeCallWithHeaders(String destination) async {
  try {
    final call = await voipClient.newCall(
      destination: destination,
      customHeaders: {
        'X-Custom-Header': 'custom-value',
        'X-User-ID': 'user123',
      },
    );
    print('Call initiated with custom headers');
  } catch (e) {
    print('Failed to make call: $e');
  }
}
```

## Handling Incoming Calls

### Automatic Handling with Native UI

When using `TelnyxVoiceApp` with `enableNativeUI: true`, incoming calls are automatically displayed using the native call UI (CallKit on iOS, ConnectionService on Android). Users can answer or decline calls directly from the native interface.

### Manual Handling

```dart
void setupIncomingCallHandling() {
  voipClient.calls.listen((calls) {
    for (final call in calls) {
      if (call.isIncoming && call.currentState == CallState.ringing) {
        print('Incoming call from: ${call.callerNumber}');
        print('Caller name: ${call.callerName}');
        
        // Show your custom UI or handle automatically
        _handleIncomingCall(call);
      }
    }
  });
}

Future<void> _handleIncomingCall(Call call) async {
  // Show custom incoming call UI
  final shouldAnswer = await _showIncomingCallDialog(call);
  
  if (shouldAnswer) {
    await call.answer();
  } else {
    await call.decline();
  }
}

Future<bool> _showIncomingCallDialog(Call call) async {
  // Implement your custom incoming call UI
  // Return true to answer, false to decline
  return true; // Placeholder
}
```

### Answering and Declining Calls

```dart
// Answer an incoming call
await call.answer();

// Decline an incoming call
await call.decline();

// End an active call
await call.hangup();
```

## Call Controls

### Basic Call Controls

```dart
Future<void> handleCallControls(Call call) async {
  // Mute/unmute the call
  await call.toggleMute();
  
  // Hold/unhold the call
  await call.toggleHold();
  
  // Send DTMF tones
  await call.dtmf('1');
  await call.dtmf('*');
  await call.dtmf('#');
  
  // End the call
  await call.hangup();
}
```

### Listening to Call Properties

```dart
void setupCallPropertyListeners(Call call) {
  // Listen to mute state
  call.isMuted.listen((muted) {
    print('Call muted: $muted');
    // Update UI accordingly
  });
  
  // Listen to hold state
  call.isHeld.listen((held) {
    print('Call held: $held');
    // Update UI accordingly
  });
  
  // Listen to call state changes
  call.callState.listen((state) {
    print('Call state changed: $state');
    // Handle state-specific logic
  });
}
```

### Getting Current Call State

```dart
void checkCallState(Call call) {
  print('Call ID: ${call.callId}');
  print('Current State: ${call.currentState}');
  print('Is Incoming: ${call.isIncoming}');
  print('Caller Number: ${call.callerNumber}');
  print('Caller Name: ${call.callerName}');
  print('Is Muted: ${call.isMuted.value}');
  print('Is Held: ${call.isHeld.value}');
}
```

## State Management Integration

Telnyx Common works seamlessly with any state management solution through Dart Streams.

### With Provider

```dart
import 'package:provider/provider.dart';

class CallProvider extends ChangeNotifier {
  final TelnyxVoipClient _voipClient;
  TelnyxConnectionState _connectionState = Disconnected();
  List<Call> _calls = [];
  Call? _activeCall;
  
  CallProvider(this._voipClient) {
    _voipClient.connectionState.listen((state) {
      _connectionState = state;
      notifyListeners();
    });
    
    _voipClient.calls.listen((calls) {
      _calls = calls;
      notifyListeners();
    });
    
    _voipClient.activeCall.listen((call) {
      _activeCall = call;
      notifyListeners();
    });
  }
  
  TelnyxConnectionState get connectionState => _connectionState;
  List<Call> get calls => _calls;
  Call? get activeCall => _activeCall;
  
  Future<void> login(CredentialConfig config) async {
    await _voipClient.login(config);
  }
  
  Future<void> makeCall(String destination) async {
    await _voipClient.newCall(destination: destination);
  }
}

// Usage in main.dart
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CallProvider(voipClient),
      child: MyApp(),
    ),
  );
}
```

### With BLoC

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class CallEvent {}
class CallsUpdated extends CallEvent {
  final List<Call> calls;
  CallsUpdated(this.calls);
}

class ConnectionStateChanged extends CallEvent {
  final TelnyxConnectionState state;
  ConnectionStateChanged(this.state);
}

// States
abstract class CallState {}
class CallInitial extends CallState {}
class CallsLoaded extends CallState {
  final List<Call> calls;
  final TelnyxConnectionState connectionState;
  
  CallsLoaded(this.calls, this.connectionState);
}

// BLoC
class CallBloc extends Bloc<CallEvent, CallState> {
  final TelnyxVoipClient voipClient;
  
  CallBloc(this.voipClient) : super(CallInitial()) {
    voipClient.calls.listen((calls) {
      add(CallsUpdated(calls));
    });
    
    voipClient.connectionState.listen((state) {
      add(ConnectionStateChanged(state));
    });
    
    on<CallsUpdated>((event, emit) {
      // Handle calls update
    });
    
    on<ConnectionStateChanged>((event, emit) {
      // Handle connection state change
    });
  }
}
```

### With Riverpod

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final voipClientProvider = Provider<TelnyxVoipClient>((ref) {
  return TelnyxVoipClient(enableNativeUI: true);
});

final connectionStateProvider = StreamProvider<TelnyxConnectionState>((ref) {
  final client = ref.watch(voipClientProvider);
  return client.connectionState;
});

final callsProvider = StreamProvider<List<Call>>((ref) {
  final client = ref.watch(voipClientProvider);
  return client.calls;
});

final activeCallProvider = StreamProvider<Call?>((ref) {
  final client = ref.watch(voipClientProvider);
  return client.activeCall;
});

// Usage in widgets
class CallScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(connectionStateProvider);
    final calls = ref.watch(callsProvider);
    
    return connectionState.when(
      data: (state) => calls.when(
        data: (callList) => _buildCallList(callList),
        loading: () => CircularProgressIndicator(),
        error: (error, stack) => Text('Error: $error'),
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Connection Error: $error'),
    );
  }
}
```

## Push Notification Handling

### Automatic Handling

When using `TelnyxVoiceApp`, push notifications are handled automatically. The SDK will:

1. Process incoming call notifications
2. Display native call UI (CallKit/ConnectionService)
3. Handle call acceptance/rejection from native UI
4. Manage app lifecycle during calls

### Manual Push Handling

If you need custom push notification handling:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationHandler {
  static void initialize(TelnyxVoipClient voipClient) {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground push: ${message.data}');
      _handlePushNotification(voipClient, message);
    });
    
    // Handle background messages (when app is backgrounded but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from push notification: ${message.data}');
      _handlePushNotification(voipClient, message);
    });
  }
  
  static Future<void> _handlePushNotification(
    TelnyxVoipClient voipClient,
    RemoteMessage message,
  ) async {
    try {
      await voipClient.handlePushNotification(message.data);
    } catch (e) {
      print('Failed to handle push notification: $e');
    }
  }
}
```

## Background Handler

The background message handler is crucial for handling incoming calls when the app is terminated:

```dart
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('[Background] Processing push notification: ${message.data}');
  
  // Initialize Firebase if needed
  await Firebase.initializeApp();
  
  // Let TelnyxVoiceApp handle the background processing
  await TelnyxVoiceApp.handleBackgroundPush(message);
  
  print('[Background] Push notification processed');
}
```

**Important Notes:**
- The function must be a top-level function (not inside a class)
- It must be annotated with `@pragma('vm:entry-point')`
- It runs in a separate isolate, so it can't access your app's state directly

## Error Handling

### Connection Errors

```dart
void handleConnectionErrors() {
  voipClient.connectionState.listen((state) {
    if (state is ConnectionError) {
      print('Connection error: ${state.error}');
      
      // Implement retry logic
      _retryConnection();
    }
  });
}

Future<void> _retryConnection() async {
  await Future.delayed(Duration(seconds: 5));
  
  try {
    // Attempt to reconnect with stored credentials
    await voipClient.login(lastUsedCredentials);
  } catch (e) {
    print('Retry failed: $e');
  }
}
```

### Call Errors

```dart
Future<void> makeCallWithErrorHandling(String destination) async {
  try {
    final call = await voipClient.newCall(destination: destination);
    
    // Listen for call errors
    call.callState.listen((state) {
      if (state == CallState.ended) {
        // Check if call ended due to error
        print('Call ended');
      }
    });
    
  } on TelnyxException catch (e) {
    // Handle Telnyx-specific errors
    print('Telnyx error: ${e.message}');
    _showErrorDialog('Call Failed', e.message);
  } catch (e) {
    // Handle general errors
    print('General error: $e');
    _showErrorDialog('Error', 'An unexpected error occurred');
  }
}

void _showErrorDialog(String title, String message) {
  // Implement error dialog UI
}
```

## Advanced Usage

### Multiple Call Handling

```dart
void handleMultipleCalls() {
  voipClient.calls.listen((calls) {
    print('Total active calls: ${calls.length}');
    
    for (int i = 0; i < calls.length; i++) {
      final call = calls[i];
      print('Call ${i + 1}: ${call.callId} - ${call.currentState}');
      
      // Handle each call individually
      _setupCallHandling(call);
    }
  });
}

void _setupCallHandling(Call call) {
  call.callState.listen((state) {
    print('Call ${call.callId} state: $state');
    
    // Implement call-specific logic
    switch (state) {
      case CallState.active:
        _onCallActive(call);
        break;
      case CallState.held:
        _onCallHeld(call);
        break;
      case CallState.ended:
        _onCallEnded(call);
        break;
    }
  });
}
```

### Custom Call UI

```dart
class CustomCallScreen extends StatefulWidget {
  final Call call;
  
  const CustomCallScreen({Key? key, required this.call}) : super(key: key);
  
  @override
  _CustomCallScreenState createState() => _CustomCallScreenState();
}

class _CustomCallScreenState extends State<CustomCallScreen> {
  late StreamSubscription _callStateSubscription;
  late StreamSubscription _muteSubscription;
  late StreamSubscription _holdSubscription;
  
  @override
  void initState() {
    super.initState();
    
    _callStateSubscription = widget.call.callState.listen((state) {
      setState(() {
        // Update UI based on call state
      });
    });
    
    _muteSubscription = widget.call.isMuted.listen((muted) {
      setState(() {
        // Update mute button UI
      });
    });
    
    _holdSubscription = widget.call.isHeld.listen((held) {
      setState(() {
        // Update hold button UI
      });
    });
  }
  
  @override
  void dispose() {
    _callStateSubscription.cancel();
    _muteSubscription.cancel();
    _holdSubscription.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Call with ${widget.call.callerNumber ?? 'Unknown'}'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Call state display
          Text(
            'State: ${widget.call.currentState}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          
          SizedBox(height: 32),
          
          // Call control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Mute button
              StreamBuilder<bool>(
                stream: widget.call.isMuted,
                builder: (context, snapshot) {
                  final isMuted = snapshot.data ?? false;
                  return IconButton(
                    onPressed: () => widget.call.toggleMute(),
                    icon: Icon(isMuted ? Icons.mic_off : Icons.mic),
                    iconSize: 48,
                  );
                },
              ),
              
              // Hold button
              StreamBuilder<bool>(
                stream: widget.call.isHeld,
                builder: (context, snapshot) {
                  final isHeld = snapshot.data ?? false;
                  return IconButton(
                    onPressed: () => widget.call.toggleHold(),
                    icon: Icon(isHeld ? Icons.play_arrow : Icons.pause),
                    iconSize: 48,
                  );
                },
              ),
              
              // Hangup button
              IconButton(
                onPressed: () {
                  widget.call.hangup();
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.call_end),
                iconSize: 48,
                color: Colors.red,
              ),
            ],
          ),
          
          SizedBox(height: 32),
          
          // DTMF keypad
          _buildDTMFKeypad(),
        ],
      ),
    );
  }
  
  Widget _buildDTMFKeypad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['*', '0', '#'],
    ];
    
    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((key) {
            return ElevatedButton(
              onPressed: () => widget.call.dtmf(key),
              child: Text(key, style: TextStyle(fontSize: 24)),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
```

This comprehensive usage guide covers all the essential aspects of using Telnyx Common in your Flutter application. The SDK provides a powerful yet simple API that handles the complexity of WebRTC voice calling while giving you the flexibility to customize the user experience according to your needs.