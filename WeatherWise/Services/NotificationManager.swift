//
//  NotificationManager.swift
//  WeatherWise
//
//  Created by Kshitij Kumar on 1/6/25.
//

//
//  NotificationManager.swift
//  WeatherWise
//
//  Created by Kshitij Kumar on 1/6/25.
//

import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {
        print("🔔 Initializing NotificationManager")
        requestAuthorization()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("✅ Notification permission granted")
                } else if let error = error {
                    print("❌ Error requesting notification permission: \(error)")
                } else {
                    print("❌ Notification permission denied")
                }
            }
        }
    }
    
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("📱 Notification Settings:")
            print("Authorization Status: \(settings.authorizationStatus)")
            print("Alert Setting: \(settings.alertSetting)")
            print("Sound Setting: \(settings.soundSetting)")
            print("Badge Setting: \(settings.badgeSetting)")
        }
    }
    
    func sendNotification(title: String, body: String) {
        print("📱 Attempting to send notification with title: \(title)")
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to send notification: \(error)")
            } else {
                print("✅ Successfully sent notification")
            }
        }
    }
}
