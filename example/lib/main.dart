import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:telnyx_common/telnyx_common.dart';

import 'utils/app_permissions.dart';
import 'debug_helper.dart';

// Background message handler for Firebase push notifications
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
      title: 'Telnyx Common Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: HomeScreen(voipClient: voipClient),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final TelnyxVoipClient voipClient;

  const HomeScreen({super.key, required this.voipClient});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _sipUserController = TextEditingController();
  final _sipPasswordController = TextEditingController();
  final _sipCallerIdNameController = TextEditingController();
  final _sipCallerIdNumberController = TextEditingController();
  final _destinationController = TextEditingController();

  TelnyxConnectionState _connectionState = Disconnected();
  List<Call> _calls = [];
  Call? _activeCall;
  bool _isLoginExpanded = true;

  late StreamSubscription _connectionSubscription;
  late StreamSubscription _callsSubscription;
  late StreamSubscription _activeCallSubscription;

  @override
  void initState() {
    super.initState();

    // Set default values for demo purposes
    _sipUserController.text = 'your_sip_user';
    _sipPasswordController.text = 'your_sip_password';
    _sipCallerIdNameController.text = 'Demo User';
    _sipCallerIdNumberController.text = '+1234567890';
    _destinationController.text = '+1987654321';

    // Listen to connection state changes
    _connectionSubscription = widget.voipClient.connectionState.listen((state) {
      setState(() {
        _connectionState = state;
        // Auto-collapse login section when connected
        if (state is Connected) {
          _isLoginExpanded = false;
        }
      });
    });

    // Listen to calls changes
    _callsSubscription = widget.voipClient.calls.listen((calls) {
      setState(() {
        _calls = calls;
      });
    });

    // Listen to active call changes
    _activeCallSubscription = widget.voipClient.activeCall.listen((call) {
      setState(() {
        _activeCall = call;
      });
    });
  }

  @override
  void dispose() {
    _connectionSubscription.cancel();
    _callsSubscription.cancel();
    _activeCallSubscription.cancel();
    _sipUserController.dispose();
    _sipPasswordController.dispose();
    _sipCallerIdNameController.dispose();
    _sipCallerIdNumberController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    try {
      final config = CredentialConfig(
        sipUser: _sipUserController.text,
        sipPassword: _sipPasswordController.text,
        sipCallerIDName: _sipCallerIdNameController.text,
        sipCallerIDNumber: _sipCallerIdNumberController.text,
        logLevel: LogLevel.none,
        debug: false,
        notificationToken: await AppPermissions.getNotificationTokenForPlatform()
      );

      await widget.voipClient.login(config);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    try {
      await widget.voipClient.logout();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }

  Future<void> _makeCall() async {
    try {
      await widget.voipClient.newCall(
        destination: _destinationController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Calling ${_destinationController.text}...')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Call failed: $e')),
        );
      }
    }
  }

  String _getTelnyxConnectionStateText() {
    switch (_connectionState) {
      case Disconnected():
        return 'Disconnected';
      case Connecting():
        return 'Connecting...';
      case Connected():
        return 'Connected';
      case ConnectionError():
        return 'Error';
    }
  }

  Color _getTelnyxConnectionStateColor() {
    switch (_connectionState) {
      case Disconnected():
        return Colors.red;
      case Connecting():
        return Colors.orange;
      case Connected():
        return Colors.green;
      case ConnectionError():
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Telnyx Common Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connection Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Connection Status',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          color: _getTelnyxConnectionStateColor(),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(_getTelnyxConnectionStateText()),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Login Form (Expandable)
            Card(
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Row(
                    children: [
                      const Text(
                        'Login Credentials',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (_connectionState is Connected) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      ],
                    ],
                  ),
                  subtitle: _connectionState is Connected
                      ? const Text('Connected', style: TextStyle(color: Colors.green))
                      : null,
                  initiallyExpanded: _isLoginExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _isLoginExpanded = expanded;
                    });
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _sipUserController,
                            decoration: const InputDecoration(
                              labelText: 'SIP User',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _sipPasswordController,
                            decoration: const InputDecoration(
                              labelText: 'SIP Password',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _sipCallerIdNameController,
                            decoration: const InputDecoration(
                              labelText: 'Caller ID Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _sipCallerIdNumberController,
                            decoration: const InputDecoration(
                              labelText: 'Caller ID Number',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed:
                                      _connectionState is Disconnected
                                          ? _login
                                          : null,
                                  child: const Text('Login'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed:
                                      _connectionState is Connected
                                          ? _logout
                                          : null,
                                  child: const Text('Logout'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Call Controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Make a Call',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _destinationController,
                      decoration: const InputDecoration(
                        labelText: 'Destination Number',
                        border: OutlineInputBorder(),
                        hintText: '+1234567890',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _connectionState is Connected
                          ? _makeCall
                          : null,
                      child: const Text('Make Call'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Call State
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Call State',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Active Calls: ${_calls.length}'),
                    if (_activeCall != null) ...[
                      const SizedBox(height: 8),
                      Text('Active Call ID: ${_activeCall!.callId}'),
                      Text('Call State: ${_activeCall!.currentState}'),
                      if (_activeCall!.callerNumber != null)
                        Text('Caller: ${_activeCall!.callerNumber}'),
                      if (_activeCall!.callerName != null)
                        Text('Destination: ${_activeCall!.callerName}'),
                    ] else
                      const Text('No active calls'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Debug Controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Debug Controls',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: DebugHelper.logStateFlags,
                            child: const Text('Log State'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: DebugHelper.resetAllFlags,
                            child: const Text('Reset Flags'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info Text
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About This Demo',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This is a basic demonstration of the telnyx_common module. '
                      'It shows how to:\n'
                      '• Login with SIP credentials\n'
                      '• Monitor connection state\n'
                      '• Make outgoing calls\n'
                      '• Display call state information\n\n'
                      'Incoming calls will automatically show via CallKit (iOS) '
                      'or ConnectionService (Android) when push notifications are configured.\n\n'
                      'Debug Controls help troubleshoot state reset issues.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
