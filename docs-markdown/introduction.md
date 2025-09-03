# Telnyx Common - Introduction

> ⚠️ **Beta Release**: This package is currently in beta. While functional, small bugs may occur. Please report any issues you encounter to help us improve the stability.

## Overview

Telnyx Common is a high-level, state-agnostic, drop-in module for the Telnyx Flutter SDK that simplifies WebRTC voice calling integration. This package provides a streamlined interface for handling background state management, push notifications, native call UI, and call state management, eliminating the most complex parts of implementing the Telnyx Voice SDK.

## Table of Contents

- [What is Telnyx Common?](#what-is-telnyx-common)
- [Key Features](#key-features)
- [What Telnyx Common Handles For You](#what-telnyx-common-handles-for-you)
- [Architecture Overview](#architecture-overview)
- [When to Use Telnyx Common](#when-to-use-telnyx-common)
- [Next Steps](#next-steps)

## What is Telnyx Common?

Telnyx Common is a comprehensive Flutter package that abstracts away the complexity of implementing WebRTC voice calling functionality. It sits on top of the lower-level `telnyx_webrtc` package and provides a unified, easy-to-use API for developers who want to integrate voice calling capabilities into their Flutter applications without dealing with the intricate details of WebRTC, push notifications, and platform-specific implementations.

## Key Features

- **🚀 Drop-in Integration**: Simple, high-level API that abstracts away WebRTC complexity
- **📱 Native Call UI**: Automatic integration with iOS CallKit and Android ConnectionService
- **🔔 Push Notifications**: Comprehensive push notification handling for incoming calls
- **🔄 State Management Agnostic**: Uses Dart Streams, works with any state management solution
- **🌐 Background Handling**: Automatic background/foreground lifecycle management
- **📞 Multiple Call Support**: Handle multiple simultaneous calls with ease
- **🎛️ Call Controls**: Mute, hold, DTMF, and call transfer capabilities

## What Telnyx Common Handles For You

Without the `telnyx_common` module, developers using the lower-level `telnyx_webrtc` package would need to manually implement:

### 1. Background State Detection and Reconnection
- Monitor app lifecycle changes using `WidgetsBindingObserver`
- Detect when the app goes to background/foreground
- Manually disconnect WebSocket connections when backgrounded
- Store credentials securely for reconnection
- Implement reconnection logic with proper error handling
- Handle edge cases like calls during background transitions

### 2. Push Notification Call Handling
- Parse incoming push notification payloads
- Extract call metadata from various push formats
- Initialize WebRTC client in background isolate
- Connect to Telnyx servers from push notification
- Handle call state synchronization between isolates
- Manage the complex flow of answering/declining from notifications

### 3. Native Call UI Integration (CallKit/ConnectionService)
- Implement platform channels for iOS CallKit (or Flutter library equivalent)
- Implement platform channels for Android ConnectionService (or Flutter library equivalent)
- Handle all CallKit delegate methods
- Manage ConnectionService lifecycle
- Synchronize native UI actions with WebRTC state
- Handle audio session management
- Deal with platform-specific quirks and edge cases

### 4. Complex State Management
- Track connection states across app lifecycle
- Manage multiple simultaneous calls
- Handle state transitions during network changes
- Implement proper cleanup on errors
- Coordinate between push notifications and active sessions

### 5. Platform-Specific Push Token Management
- Implement Firebase Cloud Messaging for Android
- Implement PushKit for iOS VoIP notifications
- Handle token refresh and registration
- Manage different token types per platform
- Coordinate token updates with Telnyx backend

### 6. Error Recovery and Edge Cases
- Network disconnection during calls
- App termination during active calls
- Push notifications while app is already connected
- Race conditions between user actions and push events
- Memory management in background isolates

## Architecture Overview

Telnyx Common follows a layered architecture approach:

```
┌─────────────────────────────────────┐
│           Your Flutter App          │
├─────────────────────────────────────┤
│         Telnyx Common API           │
│    (TelnyxVoipClient, Streams)      │
├─────────────────────────────────────┤
│       Background Management         │
│   (Lifecycle, Push Notifications)   │
├─────────────────────────────────────┤
│        Native UI Integration        │
│     (CallKit, ConnectionService)    │
├─────────────────────────────────────┤
│         Telnyx WebRTC SDK           │
│      (Low-level WebRTC calls)       │
└─────────────────────────────────────┘
```

### Core Components

1. **TelnyxVoipClient**: The main interface that provides high-level methods for authentication, call management, and state monitoring.

2. **TelnyxVoiceApp**: A wrapper widget that handles complete SDK lifecycle management, including Firebase initialization and background handlers.

3. **Stream-based State Management**: All state changes are exposed through Dart Streams, making it compatible with any state management solution (Provider, BLoC, Riverpod, etc.).

4. **Automatic Background Handling**: The SDK automatically manages app lifecycle transitions, ensuring calls work seamlessly when the app is backgrounded or terminated.

## When to Use Telnyx Common

### ✅ Use Telnyx Common When:
- You want to quickly integrate voice calling into your Flutter app
- You need native call UI (CallKit/ConnectionService) support
- You want push notification handling for incoming calls
- You prefer a high-level, easy-to-use API
- You want automatic background/foreground state management
- You're building a production app that needs reliable voice calling

### ❌ Consider Lower-Level SDK When:
- You need fine-grained control over WebRTC implementation
- You want to implement custom call UI without native integration
- You have specific requirements that the high-level API doesn't support
- You're building a specialized use case that requires direct WebRTC access

## Next Steps

Now that you understand what Telnyx Common is and what it provides, you can proceed to:

1. **[Setup Guide](setup.md)**: Learn how to install and configure Telnyx Common in your Flutter project
2. **[Usage Guide](usage.md)**: Discover how to implement authentication, make calls, and handle incoming calls

The setup process involves adding the package to your project, configuring platform-specific settings, and setting up the necessary permissions and services for both Android and iOS platforms.