import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telnyx_common/telnyx_common.dart';

import '../lib/src/utils/config_helper.dart';

/// Deterministic PushTokenProvider that lets tests drive token events.
class _FakePushTokenProvider implements PushTokenProvider {
  _FakePushTokenProvider(this._initialToken);
  final String? _initialToken;
  Function(String)? _onTokenRefresh;

  /// Emits a token refresh to the client under test.
  void fireTokenRefresh(String token) => _onTokenRefresh?.call(token);

  @override
  Future<String?> getToken() async => _initialToken;

  @override
  Future<void> setupTokenRefreshListener(
      Function(String) onTokenRefresh) async {
    _onTokenRefresh = onTokenRefresh;
  }

  @override
  void dispose() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Push-token precedence for login (single decision point)', () {
    test('deferred refresh wins over caller token and provider token', () {
      expect(
        TelnyxVoipClient.resolvePushTokenForLogin(
          deferredToken: 'deferred-new',
          callerToken: 'from-config',
          providerToken: 'live-provider',
        ),
        'deferred-new',
      );
    });

    test('caller token wins when no deferral is pending', () {
      expect(
        TelnyxVoipClient.resolvePushTokenForLogin(
          deferredToken: null,
          callerToken: 'from-config',
          providerToken: 'live-provider',
        ),
        'from-config',
      );
    });

    test('provider token is the last fallback', () {
      expect(
        TelnyxVoipClient.resolvePushTokenForLogin(
          deferredToken: null,
          callerToken: null,
          providerToken: 'live-provider',
        ),
        'live-provider',
      );
      expect(
        TelnyxVoipClient.resolvePushTokenForLogin(
          deferredToken: null,
          callerToken: null,
          providerToken: null,
        ),
        isNull,
      );
    });
  });

  group('Token refresh handling (VSUP-282 review fixes)', () {
    late TelnyxVoipClient client;
    late _FakePushTokenProvider provider;

    setUp(() {
      provider = _FakePushTokenProvider(null);
      client = TelnyxVoipClient(customTokenProvider: provider);
    });

    tearDown(() {
      client.dispose();
    });

    test('refresh with no stored config does not touch the session', () async {
      final states = <String>[];
      final deferredTokens = <String>[];
      final subState =
          client.connectionState.listen((s) => states.add(s.toString()));
      final subDeferred = client.onPushTokenDeferred.listen(deferredTokens.add);

      // No login happened yet — refresh must be a no-op.
      provider.fireTokenRefresh('token-abc');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(
          client.currentConnectionState.runtimeType.toString(), 'Disconnected');
      expect(states, isEmpty);
      expect(deferredTokens, isEmpty);
      await subState.cancel();
      await subDeferred.cancel();
    });

    test('refresh with unchanged token is skipped', () async {
      final states = <String>[];
      final deferredTokens = <String>[];
      final subState =
          client.connectionState.listen((s) => states.add(s.toString()));
      final subDeferred = client.onPushTokenDeferred.listen(deferredTokens.add);

      // Store config with the SAME token manually: login() is not usable in
      // unit tests (needs a socket), so simulate the stored state via the
      // public config helper path instead.
      final config = CredentialConfig(
        sipUser: 'user',
        sipPassword: 'pass',
        sipCallerIDName: 'Test',
        sipCallerIDNumber: '123',
        notificationToken: 'token-abc',
        logLevel: LogLevel.info,
        debug: false,
      );
      await ConfigHelper.saveConfig(config);

      // A refresh carrying the same token must be a no-op.
      provider.fireTokenRefresh('token-abc');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(
          client.currentConnectionState.runtimeType.toString(), 'Disconnected');
      expect(states, isEmpty);
      expect(deferredTokens, isEmpty);
      await subState.cancel();
      await subDeferred.cancel();
    });
  });
}
