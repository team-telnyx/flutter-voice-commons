import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telnyx_common/src/utils/config_helper.dart';
import 'package:telnyx_common/src/internal/sdk_identity.dart';
import 'package:telnyx_webrtc/config/telnyx_config.dart';
import 'package:telnyx_webrtc/utils/logging/log_level.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('credential and token connection configs carry Commons identity', () {
    final credential = withCommonsCredentialIdentity(CredentialConfig(
      sipUser: 'user',
      sipPassword: 'password',
      sipCallerIDName: 'Caller',
      sipCallerIDNumber: '1001',
      logLevel: LogLevel.none,
      debug: false,
    ));
    final token = withCommonsTokenIdentity(TokenConfig(
      sipToken: 'token',
      sipCallerIDName: 'Caller',
      sipCallerIDNumber: '1001',
      logLevel: LogLevel.none,
      debug: false,
    ));

    for (final config in [credential, token]) {
      expect(config.effectiveSdkName, commonsSdkName);
      expect(config.effectiveSdkVersion, commonsSdkVersion);
    }
  });

  test('stored credential config restores Flutter Commons identity', () async {
    await ConfigHelper.saveConfig(CredentialConfig(
      sipUser: 'user',
      sipPassword: 'password',
      sipCallerIDName: 'Caller',
      sipCallerIDNumber: '1001',
      logLevel: LogLevel.none,
      debug: false,
    ));

    final config = await ConfigHelper.getConfig() as CredentialConfig;
    expect(config.effectiveSdkName, commonsSdkName);
    expect(config.effectiveSdkVersion, commonsSdkVersion);
  });

  test('stored token config restores Flutter Commons identity', () async {
    await ConfigHelper.saveConfig(TokenConfig(
      sipToken: 'token',
      sipCallerIDName: 'Caller',
      sipCallerIDNumber: '1001',
      logLevel: LogLevel.none,
      debug: false,
    ));

    final config = await ConfigHelper.getConfig() as TokenConfig;
    expect(config.effectiveSdkName, commonsSdkName);
    expect(config.effectiveSdkVersion, commonsSdkVersion);
  });
}
