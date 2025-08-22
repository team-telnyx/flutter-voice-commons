import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../lib/telnyx_common.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Mock shared preferences
  SharedPreferences.setMockInitialValues({});
  group('TelnyxVoipClient', () {
    late TelnyxVoipClient client;

    setUp(() {
      client = TelnyxVoipClient();
    });

    tearDown(() {
      client.dispose();
    });

    test('should initialize with disconnected state', () {
      expect(client.currentConnectionState.runtimeType.toString(), 'Disconnected');
      expect(client.currentCalls, isEmpty);
      expect(client.currentActiveCall, isNull);
    });

    test('should expose connection state stream', () {
      expect(client.connectionState, isNotNull);
      expect(client.connectionState, isA<Stream>());
    });

    test('should expose calls stream', () {
      expect(client.calls, isNotNull);
      expect(client.calls, isA<Stream>());
    });

    test('should expose active call stream', () {
      expect(client.activeCall, isNotNull);
      expect(client.activeCall, isA<Stream>());
    });

    test('should throw when disposed', () {
      client.dispose();

      expect(
        () => client.login(CredentialConfig(
          sipUser: 'test',
          sipPassword: 'test',
          sipCallerIDName: 'Test User',
          sipCallerIDNumber: 'test',
          logLevel: LogLevel.info,
          debug: false,
        )),
        throwsStateError,
      );
    });

    group('Configuration', () {
      test('should accept credential config', () {
        final config = CredentialConfig(
          sipUser: 'testuser',
          sipPassword: 'testpass',
          sipCallerIDName: 'Test User',
          sipCallerIDNumber: 'testuser',
          notificationToken: 'testtoken',
          logLevel: LogLevel.info,
          debug: true,
        );

        expect(config.sipUser, equals('testuser'));
        expect(config.sipPassword, equals('testpass'));
        expect(config.sipCallerIDName, equals('Test User'));
        expect(config.sipCallerIDNumber, equals('testuser'));
        expect(config.notificationToken, equals('testtoken'));
        expect(config.debug, isTrue);
      });

      test('should accept token config', () {
        final config = TokenConfig(
          sipToken: 'testtoken',
          sipCallerIDName: 'Test User',
          sipCallerIDNumber: 'testuser',
          notificationToken: 'fcmtoken',
          logLevel: LogLevel.info,
          debug: false,
        );

        expect(config.sipToken, equals('testtoken'));
        expect(config.sipCallerIDName, equals('Test User'));
        expect(config.sipCallerIDNumber, equals('testuser'));
        expect(config.notificationToken, equals('fcmtoken'));
        expect(config.debug, isFalse);
      });
    });
  });

  group('Call', () {
    test('should create call with required parameters', () {
      final call = Call(
        destination: '+1234567890',
        onAction: (callId, action, [params]) {},
      );

      expect(call.destination, equals('+1234567890'));
      expect(call.isIncoming, isFalse);
      expect(call.callId, isNotEmpty);
    });

    test('should create incoming call', () {
      final call = Call(
        callerName: 'John Doe',
        callerNumber: '+1234567890',
        isIncoming: true,
        onAction: (callId, action, [params]) {},
      );

      expect(call.callerName, equals('John Doe'));
      expect(call.callerNumber, equals('+1234567890'));
      expect(call.isIncoming, isTrue);
    });

    test('should expose state streams', () {
      final call = Call(
        destination: '+1234567890',
        onAction: (callId, action, [params]) {},
      );

      expect(call.callState, isA<Stream<CallState>>());
      expect(call.isMuted, isA<Stream<bool>>());
      expect(call.isHeld, isA<Stream<bool>>());

      call.dispose();
    });

    test('should update state and notify listeners', () async {
      final call = Call(
        destination: '+1234567890',
        onAction: (callId, action, [params]) {},
      );

      final states = <CallState>[];
      call.callState.listen(states.add);

      call.updateState(CallState.ringing);
      call.updateState(CallState.active);

      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, contains(CallState.ringing));
      expect(states, contains(CallState.active));

      call.dispose();
    });
  });

  group('CallState', () {
    test('should have correct state capabilities', () {
      expect(CallState.ringing.canAnswer, isTrue);
      expect(CallState.active.canAnswer, isFalse);

      expect(CallState.active.canHangup, isTrue);
      expect(CallState.ended.canHangup, isFalse);

      expect(CallState.active.canHold, isTrue);
      expect(CallState.held.canHold, isFalse);

      expect(CallState.held.canUnhold, isTrue);
      expect(CallState.active.canUnhold, isFalse);

      expect(CallState.active.canMute, isTrue);
      expect(CallState.ringing.canMute, isFalse);

      expect(CallState.active.isActive, isTrue);
      expect(CallState.held.isActive, isFalse);

      expect(CallState.ended.isTerminated, isTrue);
      expect(CallState.error.isTerminated, isTrue);
      expect(CallState.active.isTerminated, isFalse);
    });
  });

  group('ConnectionState', () {
    test('should create different connection states', () {
      const disconnected = Disconnected();
      const connecting = Connecting();
      const connected = Connected();

      expect(disconnected.runtimeType.toString(), 'Disconnected');
      expect(connecting.runtimeType.toString(), 'Connecting');
      expect(connected.runtimeType.toString(), 'Connected');
    });

    test('should handle equality correctly', () {
      const disconnected1 = Disconnected();
      const disconnected2 = Disconnected();
      const connecting = Connecting();

      expect(disconnected1 == disconnected2, isTrue);
      expect(disconnected1 == connecting, isFalse);
    });
  });
}
