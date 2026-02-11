## [0.0.3-beta](https://github.com/team-telnyx/flutter-voice-commons/releases/tag/0.0.3-beta) (2026-02-11)

### Breaking
- **Requires telnyx_webrtc 4.0.0+**: Updated dependency constraint from `^3.4.0` to `^4.0.0`. This change is required to support the new iOS MISSED CALL push notification handling introduced in telnyx_webrtc 4.0.0.

### Enhancement
- Full support for iOS `MISSED_CALL` push notifications. When a call is either missed or an invitation is cancelled before being answered, a missed call notification is now displayed instead of an incoming call UI.

### Note
- Implementations using this version should ensure they handle `MISSED_CALL` notifications appropriately. The SDK will automatically display these as missed call notifications, but custom handling may be desired for callback functionality.

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
