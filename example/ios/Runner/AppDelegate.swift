import UIKit
import AVFAudio
import CallKit
import PushKit
import Flutter
import flutter_callkit_incoming

@main
@objc class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate, CallkitIncomingAppDelegate {
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Setup VoIP push notifications
    let mainQueue = DispatchQueue.main
    let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
    voipRegistry.delegate = self
    voipRegistry.desiredPushTypes = [PKPushType.voIP]
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // MARK: - PKPushRegistryDelegate for VoIP Push
  
  func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
    let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
    print("[AppDelegate] VoIP push token: \(deviceToken)")
    // Token is automatically passed to Flutter
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(deviceToken)
  }
  
  func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
    guard type == .voIP else { return }
    
    print("[AppDelegate] Received VoIP push: \(payload.dictionaryPayload)")
    
    // Parse Telnyx push notification
    if let metadata = payload.dictionaryPayload["metadata"] as? [String: Any] {
      let callID = (metadata["call_id"] as? String) ?? UUID().uuidString
      let callerName = (metadata["caller_name"] as? String) ?? "Unknown"
      let callerNumber = (metadata["caller_number"] as? String) ?? "Unknown"
      
      let data = flutter_callkit_incoming.Data(id: callID, nameCaller: callerName, handle: callerNumber, type: 0)
      data.extra = payload.dictionaryPayload as NSDictionary
      data.uuid = callID
      
      // Show CallKit UI
      SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(data, fromPushKit: true)
      
      completion()
    } else {
      // Fallback for generic push notifications
      let callID = UUID().uuidString
      let data = flutter_callkit_incoming.Data(id: callID, nameCaller: "Incoming Call", handle: "Unknown", type: 0)
      data.extra = payload.dictionaryPayload as NSDictionary
      data.uuid = callID
      
      SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(data, fromPushKit: true)
      completion()
    }
  }
  
  // MARK: - CallKit Action Handlers (Required by CallkitIncomingAppDelegate)
  func onAccept(_ call: flutter_callkit_incoming.Call, _ action: CXAnswerCallAction) {
    print("[AppDelegate] Call accepted: \(call.id)")
    action.fulfill()
  }
  
  func onDecline(_ call: flutter_callkit_incoming.Call, _ action: CXEndCallAction) {
    print("[AppDelegate] Call declined: \(call.id)")
    action.fulfill()
  }
  
  func onEnd(_ call: flutter_callkit_incoming.Call, _ action: CXEndCallAction) {
    print("[AppDelegate] Call ended: \(call.id)")
    action.fulfill()
  }
  
  func onTimeOut(_ call: flutter_callkit_incoming.Call) {
    print("[AppDelegate] Call timed out: \(call.id)")
  }
}