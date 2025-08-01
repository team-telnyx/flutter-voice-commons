import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telnyx_common/telnyx_common.dart';

import '../firebase_options.dart';

/// Helper class for managing application permissions and platform-specific tokens.
class AppPermissions {
  /// Request necessary permissions at app launch.
  static Future<void> requestPermissions() async {
    print('[Permissions] Requesting app permissions...');
    
    // Request microphone permission for voice calls
    final microphoneStatus = await Permission.microphone.request();
    print('[Permissions] Microphone permission: $microphoneStatus');
    
    // Request notification permission
    final notificationStatus = await Permission.notification.request();
    print('[Permissions] Notification permission: $notificationStatus');

    // Check if any critical permissions are denied
    if (microphoneStatus.isDenied) {
      print('[Permissions] Warning: Microphone permission denied - voice calls will not work');
    }
    
    if (notificationStatus.isDenied) {
      print('[Permissions] Warning: Notification permission denied - you may miss incoming calls');
    }
  }

  /// Get the notification token for the current platform.
  /// Returns null for web, Firebase token for Android, and iOS push token for iOS.
  /// This method gracefully handles Firebase configuration issues by returning null.
  static Future<String?> getNotificationTokenForPlatform() async {
    String? token;

    if (kIsWeb) {
      return null;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        // Try to get Firebase token for Android push notifications
        // If no apps are initialized, initialize one now with explicit options
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        }
        token = await FirebaseMessaging.instance.getToken();
        print('[Permissions] Successfully got Firebase token: ${token?.substring(0, 20)}...');
      } catch (e) {
        print('[Permissions] Firebase initialization/token retrieval failed: $e');
        print('[Permissions] This is normal for example apps without full Firebase setup.');
        print('[Permissions] Push notifications will not work, but voice calls will still function.');
        return null;
      }
    } else if (Platform.isIOS) {
      try {
        token = await TelnyxVoipClient().getiOSPushToken();
        print('[Permissions] Successfully got iOS push token');
      } catch (e) {
        print('[Permissions] Failed to get iOS push token: $e');
        return null;
      }
    }
    
    return token;
  }
}