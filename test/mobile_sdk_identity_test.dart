import 'dart:io';

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

  // Drift guard: commonsSdkVersion must stay in lock-step with the
  // `version:` field of pubspec.yaml. release.sh `bump` updates both in a
  // single edit; this test fails the suite if a hand-edit (or a partial
  // release.sh bump) leaves them out of sync. See sdk_identity.dart for the
  // full contract.
  test('commonsSdkVersionPubspecSync', () {
    final pubspecFile = File('pubspec.yaml');
    expect(
      pubspecFile.existsSync(),
      isTrue,
      reason: 'pubspec.yaml must exist at the package root for the drift guard',
    );
    final pubspecText = pubspecFile.readAsStringSync();
    final match = RegExp(r'^version:\s*(\S+)\s*$', multiLine: true)
        .firstMatch(pubspecText);
    expect(
      match,
      isNotNull,
      reason: 'pubspec.yaml must contain a top-level `version:` field',
    );
    final pubspecVersion = match!.group(1)!;
    expect(
      commonsSdkVersion,
      pubspecVersion,
      reason:
          'commonsSdkVersion (=$commonsSdkVersion) must equal pubspec.yaml '
          'version (=$pubspecVersion). Re-run '
          '`scripts/release/release.sh bump <version>` to update both.',
    );
  });
}
