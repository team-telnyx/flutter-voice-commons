import 'package:flutter_test/flutter_test.dart';
import 'package:telnyx_common/src/utils/config_token_copier.dart';
import 'package:telnyx_common/telnyx_common.dart';
import 'package:telnyx_webrtc/model/tx_ice_server.dart';
import 'package:telnyx_webrtc/model/tx_server_configuration.dart';

void main() {
  group('ConfigTokenCopier preserves the full published Config surface', () {
    test('credential config: all fields survive the token swap', () {
      final original = CredentialConfig(
        sipUser: 'user',
        sipPassword: 'pass',
        sipCallerIDName: 'Caller',
        sipCallerIDNumber: '+120****0100',
        notificationToken: 'old-token',
        autoReconnect: false,
        logLevel: LogLevel.warning,
        debug: true,
        ringTonePath: '/ring.aac',
        ringbackPath: '/back.aac',
        reconnectionTimeout: 42,
        pushAnswerTimeout: 77,
        region: Region.usCentral,
        fallbackOnRegionFailure: false,
        forceRelayCandidate: true,
        pushWhenActive: true,
        iceServers: [
          TxIceServer(urls: ['stun:stun.example.com'])
        ],
        serverConfiguration: TxServerConfiguration(
          host: 'https://control.example.com',
          port: 8443,
        ),
        callReportInterval: 9000,
        callReportLogLevel: 'info',
        callReportMaxLogEntries: 250,
        enableCallReports: false,
        debugOutput: DebugOutput.file,
        debugLogLevel: DebugLogLevel.debug,
        debugLogMaxEntries: 333,
        callReportFlushInterval: 4321,
        prefetchIceCandidates: false,
        autoRecoverCalls: false,
        hangupOnBeforeUnload: false,
        maxReconnectAttempts: 3,
        enableStructuredErrors: false,
        enableSignalingHealthMonitor: false,
        mediaPermissionsRecovery: MediaPermissionsRecoveryConfig(
          enabled: true,
          timeout: 12345,
        ),
        mobileSdkName: 'telnyx_common',
        mobileSdkVersion: '1.2.3',
      );

      final copy = credentialConfigWithToken(original, 'new-token');

      expect(copy.notificationToken, 'new-token');
      expect(copy.sipUser, 'user');
      expect(copy.sipPassword, 'pass');
      expect(copy.sipCallerIDName, 'Caller');
      expect(copy.sipCallerIDNumber, '+120****0100');
      expect(copy.autoReconnect, false);
      expect(copy.logLevel, LogLevel.warning);
      expect(copy.debug, true);
      expect(copy.ringTonePath, '/ring.aac');
      expect(copy.ringbackPath, '/back.aac');
      expect(copy.reconnectionTimeout, 42);
      expect(copy.pushAnswerTimeout, 77);
      expect(copy.region, Region.usCentral);
      expect(copy.fallbackOnRegionFailure, false);
      expect(copy.forceRelayCandidate, true);
      expect(copy.pushWhenActive, true);
      expect(copy.iceServers!.length, 1);
      expect(copy.iceServers![0].urls, ['stun:stun.example.com']);
      expect(copy.serverConfiguration!.host, 'https://control.example.com');
      expect(copy.serverConfiguration!.port, 8443);
      expect(copy.callReportInterval, 9000);
      expect(copy.callReportLogLevel, 'info');
      expect(copy.callReportMaxLogEntries, 250);
      expect(copy.enableCallReports, false);
      expect(copy.debugOutput, DebugOutput.file);
      expect(copy.debugLogLevel, DebugLogLevel.debug);
      expect(copy.debugLogMaxEntries, 333);
      expect(copy.callReportFlushInterval, 4321);
      expect(copy.prefetchIceCandidates, false);
      expect(copy.autoRecoverCalls, false);
      expect(copy.hangupOnBeforeUnload, false);
      expect(copy.maxReconnectAttempts, 3);
      expect(copy.enableStructuredErrors, false);
      expect(copy.enableSignalingHealthMonitor, false);
      expect(copy.mediaPermissionsRecovery!.enabled, true);
      expect(copy.mediaPermissionsRecovery!.timeout, 12345);
      expect(copy.mobileSdkName, 'telnyx_common');
      expect(copy.mobileSdkVersion, '1.2.3');
    });

    test('token config: all fields survive the token swap', () {
      final original = TokenConfig(
        sipToken: 'jwt-token-value',
        sipCallerIDName: 'Caller',
        sipCallerIDNumber: '+120****0100',
        notificationToken: 'old-token',
        autoReconnect: false,
        logLevel: LogLevel.warning,
        debug: true,
        reconnectionTimeout: 42,
        pushAnswerTimeout: 77,
        pushWhenActive: true,
        maxReconnectAttempts: 3,
        mobileSdkName: 'telnyx_common',
        mobileSdkVersion: '1.2.3',
      );

      final copy = tokenConfigWithToken(original, 'new-token');

      expect(copy.notificationToken, 'new-token');
      expect(copy.sipToken, 'jwt-token-value');
      expect(copy.sipCallerIDName, 'Caller');
      expect(copy.sipCallerIDNumber, '+120****0100');
      expect(copy.autoReconnect, false);
      expect(copy.logLevel, LogLevel.warning);
      expect(copy.debug, true);
      expect(copy.reconnectionTimeout, 42);
      expect(copy.pushAnswerTimeout, 77);
      expect(copy.pushWhenActive, true);
      expect(copy.maxReconnectAttempts, 3);
      expect(copy.mobileSdkName, 'telnyx_common');
      expect(copy.mobileSdkVersion, '1.2.3');
    });
  });
}
