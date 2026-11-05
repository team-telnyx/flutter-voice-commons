library;

import 'package:telnyx_webrtc/telnyx_webrtc.dart'
    show CredentialConfig, TokenConfig;

/// Copies a published telnyx_webrtc [Config] subclass with a new
/// notification token, preserving every other field.
///
/// telnyx_webrtc does not expose `copyWith` (as of 4.5.x), so fields are
/// copied explicitly here. This MUST be kept in lockstep with the SDK's
/// Config surface — when telnyx_webrtc adds a new field, add it below or
/// callers' settings are silently reset to constructor defaults.

/// Returns a copy of [config] with [token] as the notification token.
CredentialConfig credentialConfigWithToken(
    CredentialConfig config, String token) {
  return CredentialConfig(
    sipUser: config.sipUser,
    sipPassword: config.sipPassword,
    sipCallerIDName: config.sipCallerIDName,
    sipCallerIDNumber: config.sipCallerIDNumber,
    notificationToken: token,
    autoReconnect: config.autoReconnect,
    logLevel: config.logLevel,
    debug: config.debug,
    customLogger: config.customLogger,
    ringTonePath: config.ringTonePath,
    ringbackPath: config.ringbackPath,
    reconnectionTimeout: config.reconnectionTimeout,
    pushAnswerTimeout: config.pushAnswerTimeout,
    region: config.region,
    fallbackOnRegionFailure: config.fallbackOnRegionFailure,
    forceRelayCandidate: config.forceRelayCandidate,
    pushWhenActive: config.pushWhenActive,
    iceServers: config.iceServers,
    serverConfiguration: config.serverConfiguration,
    callReportInterval: config.callReportInterval,
    callReportLogLevel: config.callReportLogLevel,
    callReportMaxLogEntries: config.callReportMaxLogEntries,
    enableCallReports: config.enableCallReports,
    debugOutput: config.debugOutput,
    debugLogLevel: config.debugLogLevel,
    debugLogMaxEntries: config.debugLogMaxEntries,
    callReportFlushInterval: config.callReportFlushInterval,
    prefetchIceCandidates: config.prefetchIceCandidates,
    autoRecoverCalls: config.autoRecoverCalls,
    hangupOnBeforeUnload: config.hangupOnBeforeUnload,
    maxReconnectAttempts: config.maxReconnectAttempts,
    enableStructuredErrors: config.enableStructuredErrors,
    enableSignalingHealthMonitor: config.enableSignalingHealthMonitor,
    mediaPermissionsRecovery: config.mediaPermissionsRecovery,
    mobileSdkName: config.mobileSdkName,
    mobileSdkVersion: config.mobileSdkVersion,
  );
}

/// Returns a copy of [config] with [token] as the notification token.
TokenConfig tokenConfigWithToken(TokenConfig config, String token) {
  return TokenConfig(
    sipToken: config.sipToken,
    sipCallerIDName: config.sipCallerIDName,
    sipCallerIDNumber: config.sipCallerIDNumber,
    notificationToken: token,
    autoReconnect: config.autoReconnect,
    logLevel: config.logLevel,
    debug: config.debug,
    customLogger: config.customLogger,
    ringTonePath: config.ringTonePath,
    ringbackPath: config.ringbackPath,
    reconnectionTimeout: config.reconnectionTimeout,
    pushAnswerTimeout: config.pushAnswerTimeout,
    region: config.region,
    fallbackOnRegionFailure: config.fallbackOnRegionFailure,
    forceRelayCandidate: config.forceRelayCandidate,
    pushWhenActive: config.pushWhenActive,
    iceServers: config.iceServers,
    serverConfiguration: config.serverConfiguration,
    callReportInterval: config.callReportInterval,
    callReportLogLevel: config.callReportLogLevel,
    callReportMaxLogEntries: config.callReportMaxLogEntries,
    enableCallReports: config.enableCallReports,
    debugOutput: config.debugOutput,
    debugLogLevel: config.debugLogLevel,
    debugLogMaxEntries: config.debugLogMaxEntries,
    callReportFlushInterval: config.callReportFlushInterval,
    prefetchIceCandidates: config.prefetchIceCandidates,
    autoRecoverCalls: config.autoRecoverCalls,
    hangupOnBeforeUnload: config.hangupOnBeforeUnload,
    maxReconnectAttempts: config.maxReconnectAttempts,
    enableStructuredErrors: config.enableStructuredErrors,
    enableSignalingHealthMonitor: config.enableSignalingHealthMonitor,
    mediaPermissionsRecovery: config.mediaPermissionsRecovery,
    mobileSdkName: config.mobileSdkName,
    mobileSdkVersion: config.mobileSdkVersion,
  );
}
