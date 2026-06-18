import 'dart:async';

import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telnyx_common/src/internal/callkit/callkit_adapter_bridge.dart';
import 'package:telnyx_common/src/internal/callkit/callkit_event_handler.dart';
import 'package:telnyx_common/src/internal/push/notification_display_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CallKitAdapterBridge', () {
    test('routes an accept event exactly once after double init', () async {
      var listenCount = 0;
      final events = StreamController<CallEvent?>.broadcast(
        onListen: () => listenCount++,
      );
      final acceptedCallIds = <String>[];
      final eventHandler = CallKitEventHandler(
        eventStreamProvider: () => events.stream,
      );
      final bridge = CallKitAdapterBridge(
        displayService: NotificationDisplayService(),
        eventHandler: eventHandler,
        onCallAccepted: acceptedCallIds.add,
        onCallDeclined: (_) {},
        onCallEnded: (_) {},
      );

      addTearDown(() async {
        bridge.dispose();
        await events.close();
      });

      await eventHandler.initialize();
      await bridge.initialize();

      events.add(
        CallEvent(
          <String, dynamic>{
            'id': 'call-1',
            'extra': <String, dynamic>{'source': 'test'},
          },
          Event.actionCallAccept,
        ),
      );

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(listenCount, 1);
      expect(acceptedCallIds, <String>['call-1']);
    });
  });
}
