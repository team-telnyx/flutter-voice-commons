import 'dart:async';
import 'callkit_adapter.dart';
import '../push/notification_display_service.dart';
import 'callkit_event_handler.dart';

typedef CallKitBridgeEventCallback = void Function(
    String callId, Map<String, dynamic> extra);

/// Bridge class that extends CallKitAdapter to integrate with the new architecture.
///
/// This bridge allows the existing PushNotificationGateway to work with the new
/// NotificationDisplayService and CallKitEventHandler while maintaining
/// backward compatibility with the existing CallKitAdapter interface.
class CallKitAdapterBridge extends CallKitAdapter {
  final NotificationDisplayService _displayService;
  final CallKitEventHandler _eventHandler;
  final CallKitBridgeEventCallback? _onCallAcceptEvent;
  final CallKitBridgeEventCallback? _onCallDeclineEvent;
  final CallKitBridgeEventCallback? _onCallEndEvent;
  final CallKitBridgeEventCallback? _onCallTimeoutEvent;
  final CallKitBridgeEventCallback? _onCallIncomingEvent;

  bool _initialized = false;

  /// Creates a new CallKitAdapterBridge.
  ///
  /// [displayService] - The notification display service to delegate UI calls to
  /// [eventHandler] - The event handler for CallKit events
  /// [onCallAccepted] - Callback for when a call is accepted
  /// [onCallDeclined] - Callback for when a call is declined
  /// [onCallEnded] - Callback for when a call is ended
  CallKitAdapterBridge({
    required NotificationDisplayService displayService,
    required CallKitEventHandler eventHandler,
    required super.onCallAccepted,
    required super.onCallDeclined,
    required super.onCallEnded,
    CallKitBridgeEventCallback? onCallAcceptEvent,
    CallKitBridgeEventCallback? onCallDeclineEvent,
    CallKitBridgeEventCallback? onCallEndEvent,
    CallKitBridgeEventCallback? onCallTimeoutEvent,
    CallKitBridgeEventCallback? onCallIncomingEvent,
  })  : _displayService = displayService,
        _eventHandler = eventHandler,
        _onCallAcceptEvent = onCallAcceptEvent,
        _onCallDeclineEvent = onCallDeclineEvent,
        _onCallEndEvent = onCallEndEvent,
        _onCallTimeoutEvent = onCallTimeoutEvent,
        _onCallIncomingEvent = onCallIncomingEvent;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize ONLY the event handler (not the parent CallKitAdapter)
    // This avoids the conflict between two event listeners
    await _eventHandler.initialize();

    // Set up our event handler to coordinate with the new architecture
    _eventHandler.setEventCallbacks(
      onCallAccept: _handleCallAcceptEvent,
      onCallDecline: _handleCallDeclineEvent,
      onCallEnd: _handleCallEndEvent,
      onCallTimeout: _handleCallTimeoutEvent,
      onCallIncoming: _handleCallIncomingEvent,
    );

    _initialized = true;
    print('CallKitAdapterBridge: Initialized successfully');
  }

  void _handleCallAcceptEvent(String callId, Map<String, dynamic> extra) {
    final callback = _onCallAcceptEvent;
    if (callback != null) {
      callback(callId, extra);
      return;
    }

    onCallAccepted(callId);
  }

  void _handleCallDeclineEvent(String callId, Map<String, dynamic> extra) {
    final callback = _onCallDeclineEvent;
    if (callback != null) {
      callback(callId, extra);
      return;
    }

    onCallDeclined(callId);
  }

  void _handleCallEndEvent(String callId, Map<String, dynamic> extra) {
    final callback = _onCallEndEvent;
    if (callback != null) {
      callback(callId, extra);
      return;
    }

    onCallEnded(callId);
  }

  void _handleCallTimeoutEvent(String callId, Map<String, dynamic> extra) {
    final callback = _onCallTimeoutEvent;
    if (callback != null) {
      callback(callId, extra);
      return;
    }

    onCallDeclined(callId);
  }

  void _handleCallIncomingEvent(String callId, Map<String, dynamic> extra) {
    final callback = _onCallIncomingEvent;
    if (callback != null) {
      callback(callId, extra);
      return;
    }

    print('CallKitAdapterBridge: Incoming call event for $callId');
  }

  @override
  Future<void> showIncomingCall({
    required String callId,
    required String callerName,
    required String callerNumber,
    Map<String, dynamic> extra = const {},
  }) async {
    try {
      // Delegate to the new display service
      await _displayService.showIncomingCall(
        callId: callId,
        callerName: callerName,
        callerNumber: callerNumber,
        extra: extra,
      );
      print(
          'CallKitAdapterBridge: Showed incoming call via display service for $callId');
    } catch (e) {
      print(
          'CallKitAdapterBridge: Error showing incoming call via display service: $e');

      // Fallback to parent implementation if display service fails
      try {
        await super.showIncomingCall(
          callId: callId,
          callerName: callerName,
          callerNumber: callerNumber,
          extra: extra,
        );
        print(
            'CallKitAdapterBridge: Fallback to parent implementation succeeded for $callId');
      } catch (fallbackError) {
        print('CallKitAdapterBridge: Fallback also failed: $fallbackError');
      }
    }
  }

  @override
  Future<void> startOutgoingCall({
    required String callId,
    required String destination,
    String? callerName,
    Map<String, dynamic> extra = const {},
  }) async {
    try {
      // Try using the new display service first
      await _displayService.showOutgoingCall(
        callId: callId,
        callerName: callerName ?? 'Outgoing Call',
        destination: destination,
        extra: extra,
      );
      print(
          'CallKitAdapterBridge: Started outgoing call via display service for $callId');
    } catch (e) {
      print(
          'CallKitAdapterBridge: Error starting outgoing call via display service: $e');

      // Fallback to parent implementation
      try {
        await super.startOutgoingCall(
          callId: callId,
          destination: destination,
          callerName: callerName,
          extra: extra,
        );
        print(
            'CallKitAdapterBridge: Fallback to parent implementation succeeded for $callId');
      } catch (fallbackError) {
        print('CallKitAdapterBridge: Fallback also failed: $fallbackError');
      }
    }
  }

  @override
  Future<void> endCall(String callId) async {
    try {
      // Try the new display service first
      await _displayService.endCall(callId);
      print('CallKitAdapterBridge: Ended call via display service for $callId');
    } catch (e) {
      print('CallKitAdapterBridge: Error ending call via display service: $e');

      // Fallback to parent implementation
      try {
        await super.endCall(callId);
        print(
            'CallKitAdapterBridge: Fallback to parent implementation succeeded for $callId');
      } catch (fallbackError) {
        print('CallKitAdapterBridge: Fallback also failed: $fallbackError');
      }
    }
  }

  @override
  void dispose() {
    if (!_initialized) return;

    // Clean up our resources first
    _initialized = false;

    // Dispose the event handler instead of calling super.dispose()
    // since we're using the event handler directly
    _eventHandler.dispose();

    print('CallKitAdapterBridge: Disposed');
  }
}
