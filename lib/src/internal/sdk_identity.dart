import 'package:telnyx_webrtc/config/telnyx_config.dart';

const String commonsSdkName = 'flutter_commons';
const String commonsSdkVersion = '0.2.0';

CredentialConfig withCommonsCredentialIdentity(CredentialConfig config) =>
    CredentialConfig(
      sipUser: config.sipUser,
      sipPassword: config.sipPassword,
      sipCallerIDName: config.sipCallerIDName,
      sipCallerIDNumber: config.sipCallerIDNumber,
      notificationToken: config.notificationToken,
      autoReconnect: config.autoReconnect,
      logLevel: config.logLevel,
      debug: config.debug,
      customLogger: config.customLogger,
      ringTonePath: config.ringTonePath,
      ringbackPath: config.ringbackPath,
      reconnectionTimeout: config.reconnectionTimeout,
      region: config.region,
      fallbackOnRegionFailure: config.fallbackOnRegionFailure,
      mobileSdkName: commonsSdkName,
      mobileSdkVersion: commonsSdkVersion,
    );

TokenConfig withCommonsTokenIdentity(TokenConfig config) => TokenConfig(
      sipToken: config.sipToken,
      sipCallerIDName: config.sipCallerIDName,
      sipCallerIDNumber: config.sipCallerIDNumber,
      notificationToken: config.notificationToken,
      autoReconnect: config.autoReconnect,
      logLevel: config.logLevel,
      debug: config.debug,
      customLogger: config.customLogger,
      ringTonePath: config.ringTonePath,
      ringbackPath: config.ringbackPath,
      reconnectionTimeout: config.reconnectionTimeout,
      region: config.region,
      fallbackOnRegionFailure: config.fallbackOnRegionFailure,
      mobileSdkName: commonsSdkName,
      mobileSdkVersion: commonsSdkVersion,
    );
