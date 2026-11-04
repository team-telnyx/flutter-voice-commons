import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telnyx_webrtc/telnyx_client.dart';
import 'package:telnyx_webrtc/call.dart' as core;
import 'package:telnyx_webrtc/model/telnyx_message.dart';
import 'package:telnyx_webrtc/model/socket_method.dart';
import 'package:telnyx_webrtc/model/verto/receive/received_message_body.dart';
import 'package:telnyx_common/src/internal/calls/call_state_controller.dart';
import 'package:telnyx_common/src/internal/session/session_manager.dart';
import 'package:telnyx_common/src/models/call_state.dart';

class ProbeCoreCall extends Mock implements core.Call {
  ProbeCoreCall(this.callId);
  @override
  String? callId;
  @override
  core.CallHandler callHandler = core.CallHandler((_) {}, null);
}

class ProbeClient implements TelnyxClient {
  final List<core.Call> createdCalls = [];
  core.Call get probeCall => createdCalls.last;
  @override
  void Function(TelnyxMessage) onSocketMessageReceived = (_) {};
  @override
  dynamic noSuchMethod(Invocation i) {
    if (i.memberName == #newInvite) {
      final call = ProbeCoreCall('core-signaling-${createdCalls.length}');
      createdCalls.add(call);
      return call;
    }
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  late ProbeClient client;
  late SessionManager session;
  late CallStateController controller;

  setUp(() {
    client = ProbeClient();
    session = SessionManager();
    controller = CallStateController(client, session);
  });
  tearDown(() {
    controller.dispose();
    session.dispose();
  });

  Future<void> receive(String method, String? id, {bool dialog = false}) async {
    client.onSocketMessageReceived(TelnyxMessage(
      socketMethod: method,
      message: ReceivedMessage.fromJson({
        'method': method,
        'params': dialog
            ? {
                'dialogParams': {'callID': id}
              }
            : {if (id != null) 'callID': id},
      }),
    ));
    await Future<void>.delayed(Duration.zero);
  }

  for (final method in [
    SocketMethod.ringing,
    SocketMethod.answer,
    SocketMethod.bye
  ]) {
    test('valid outbound $method is routed by core signaling ID', () async {
      final call = await controller.newCall('destination', false);
      expect(call.callId, isNot(client.probeCall.callId));
      await receive(method, client.probeCall.callId);
      final observed = call.currentState;
      final expected = method == SocketMethod.answer
          ? CallState.active
          : method == SocketMethod.ringing
              ? CallState.ringing
              : CallState.ended;
      expect(observed, expected,
          reason: 'valid signaling ID must resolve its Commons call');
    });

    test('$method for a removed call cannot affect the next outbound call',
        () async {
      await controller.newCall('first', false);
      final previousId = client.probeCall.callId;
      await receive(SocketMethod.bye, previousId);
      expect(controller.currentCalls, isEmpty);
      final next = await controller.newCall('second', false);
      final nextId = client.probeCall.callId;
      await receive(method, previousId);
      expect(next.currentState, CallState.initiating);
      await receive(SocketMethod.ringing, nextId);
      expect(next.currentState, CallState.ringing);
      await receive(SocketMethod.answer, nextId);
      expect(next.currentState, CallState.active);
    });

    test('$method for an unknown nonempty ID has no state fallback', () async {
      final call = await controller.newCall('destination', false);
      await receive(method, 'unknown-stale-id');
      expect(call.currentState, CallState.initiating);
    });

    test('$method targets only its matching concurrent call', () async {
      final first = await controller.newCall('first', false);
      final second = await controller.newCall('second', false);
      await receive(method, client.probeCall.callId);
      expect(first.currentState, CallState.initiating);
      final expected = method == SocketMethod.answer
          ? CallState.active
          : method == SocketMethod.ringing
              ? CallState.ringing
              : CallState.ended;
      expect(second.currentState, expected);
    });
  }

  for (final method in [SocketMethod.ringing, SocketMethod.answer]) {
    test('$method resolves the dialogParams signaling ID fallback', () async {
      final call = await controller.newCall('destination', false);
      await receive(method, client.probeCall.callId, dialog: true);
      expect(call.currentState,
          method == SocketMethod.answer ? CallState.active : CallState.ringing);
    });
    test('$method without an ID preserves the legacy fallback', () async {
      final call = await controller.newCall('destination', false);
      await receive(method, null);
      expect(call.currentState,
          method == SocketMethod.answer ? CallState.active : CallState.ringing);
    });
  }

  test('incoming call ends, then outgoing call ignores late incoming messages',
      () async {
    await receive(SocketMethod.invite, 'incoming-signaling-id');
    final incoming = controller.currentCalls.single;
    expect(incoming.isIncoming, isTrue);
    await receive(SocketMethod.answer, incoming.callId);
    expect(incoming.currentState, CallState.active);
    await receive(SocketMethod.bye, incoming.callId);
    expect(controller.currentCalls, isEmpty);

    final outgoing = await controller.newCall('destination', false);
    for (final method in [
      SocketMethod.ringing,
      SocketMethod.answer,
      SocketMethod.bye
    ]) {
      await receive(method, incoming.callId);
      expect(outgoing.currentState, CallState.initiating);
    }
    await receive(SocketMethod.answer, client.probeCall.callId);
    expect(outgoing.currentState, CallState.active);
  });

  test('local hangup removes signaling association before the next call',
      () async {
    final first = await controller.newCall('first', false);
    final firstId = client.probeCall.callId;
    await first.hangup();
    await Future<void>.delayed(Duration.zero);
    expect(controller.currentCalls, isEmpty);
    final next = await controller.newCall('second', false);
    await receive(SocketMethod.answer, firstId);
    expect(next.currentState, CallState.initiating);
    await receive(SocketMethod.answer, client.probeCall.callId);
    expect(next.currentState, CallState.active);
  });
}
