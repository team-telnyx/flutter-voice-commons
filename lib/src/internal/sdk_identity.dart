import 'package:telnyx_webrtc/config/telnyx_config.dart';

/// The single source of truth for the SDK identity emitted by telnyx_common.
///
/// This file is the only place in the Commons package where `flutter_commons`
/// identity literals live. Other call sites (e.g. [ConfigHelper]) MUST import
/// these constants instead of repeating the literals, so the wire payload,
/// the cached stored config, and the in-memory reconnect config all agree.
///
/// ## Versioning
///
/// `commonsSdkVersion` is the release-controlled version of the telnyx_common
/// package. It MUST be kept in lock-step with the top-level `version:` field
/// of `pubspec.yaml`:
///
///   - On release, `scripts/release/release.sh bump <version>` updates BOTH
///     `pubspec.yaml` and this constant in a single edit, so the next release
///     identifies itself correctly on the wire.
///   - In tests, [commonsSdkVersionPubspecSync] (a drift guard) reads
///     `pubspec.yaml` from disk and fails the suite if the two diverge.
///
/// Do NOT hand-edit `commonsSdkVersion` for a release without bumping
/// `pubspec.yaml` in the same commit — the drift guard test will fail.
const String commonsSdkName = 'flutter_commons';

// Kept in lock-step with the `version:` field of pubspec.yaml via
// `scripts/release/release.sh bump`. See the file-level dartdoc above.
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
