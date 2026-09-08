import FirebaseCore
import FirebaseMessaging
import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let mapsApiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
       !mapsApiKey.isEmpty {
      GMSServices.provideAPIKey(mapsApiKey)
    } else {
      // Missing ios/Flutter/Maps.xcconfig (gitignored) — maps will not load
      // until GOOGLE_MAPS_API_KEY is set there. Fail loudly instead of
      // silently shipping a build with no maps.
      assertionFailure("GOOGLE_MAPS_API_KEY is not set — see ios/Flutter/Maps.xcconfig")
    }
    FirebaseApp.configure()
    UNUserNotificationCenter.current().delegate = self
    Messaging.messaging().delegate = self
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
