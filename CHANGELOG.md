## [0.1.0](https://github.com/team-telnyx/flutter-voice-commons/releases/tag/0.1.0) (2026-03-08)

### Enhancement
- Bump `telnyx_webrtc` dependency from `^3.4.0` to `^4.1.0`, incorporating all improvements from SDK versions 3.4.1 through 4.1.0.
- Expose `callControlId` on the `Call` model, available when a call uses Telnyx Call Control. The ID is propagated from the SDK's Call object on answer.
- Automatic call quality reporting is now enabled by default (handled internally by the SDK — no opt-in required). Reports are posted to voice-sdk-proxy on call end.
- Improved TURN/STUN server configuration with UDP support for better connectivity.
- Missed call push notifications (introduced in SDK 4.0.0) are handled automatically by commons — no app-level changes required.

## [0.0.2-beta](https://github.com/team-telnyx/flutter-voice-commons/releases/tag/0.0.1-beta) (2025-10-21)

### Enhancement
- Bump telnyx_webrtc dependency to 3.1.0 to incorporate latest WebRTC improvements and bug fixes.
- Implement connection quality metric callback to monitor connection state in real-time. (Updates in 30 second intervals)
- Allow for fetching and applying of preferred codecs from telnyx_voip_client for new calls. 

## [0.0.1-beta](https://github.com/team-telnyx/flutter-voice-commons/releases/tag/0.0.1-beta) (2025-08-25)

### Enhancement
- Initial beta release of the Flutter Voice Commons SDK, providing foundational VoIP functionalities for Flutter applications.
- Features include:
  - SIP Credential Login
  - Connection State Monitoring
  - Outgoing Call Handling
  - Call State Display
  - Native UI Integration (CallKit for iOS, ConnectionService for Android)
  - Push Notification Handling for Background Calls on both platforms 