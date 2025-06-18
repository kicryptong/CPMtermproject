// LocalNotification.swift

import Foundation
import UserNotifications
import SwiftUI

class LocalNotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    static let shared = LocalNotificationManager()
    
    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        requestAuthorization()
    }
    
    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission request error: \(error.localizedDescription)")
            } else {
                print(granted ? "✅ Notification permission granted" : "❌ Notification permission denied")
            }
        }
    }
    
    func sendWeatherWarningNotificationIfNeeded(weather: Weather) {
        var shouldNotify = false

        if ["Rain", "Drizzle", "Snow", "Fog", "Mist", "Haze"].contains(weather.main) {
            shouldNotify = true
        }

        if let temp = Double(weather.temperature), temp >= 33.0 || temp <= 5.0 {
            shouldNotify = true
        }

        if weather.windSpeed >= 10.0 {
            shouldNotify = true
        }

        if shouldNotify {
            // Translated notification messages
            sendNotification(title: "⚠️ Weather Warning", body: "Construction work may be impacted by the current weather.")
        }
    }
    
    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("📣 Notification scheduled successfully")
            }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
