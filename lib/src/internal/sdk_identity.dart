import 'package:telnyx_webrtc/config/telnyx_config.dart';

/// The single source of truth for the SDK identity emitted by telnyx_common.
///
/// This file is the only place in the Commons package where `webrtc-flutter-commons`
/// identity literals live. Other call sites (e.g. [ConfigHelper]) MUST import
/// these constants instead of repeating the literals, so the wire payload,
/// the cached stored config, and the in-memory reconnect config all agree.
///
const String commonsSdkName = 'webrtc-flutter-commons';
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
