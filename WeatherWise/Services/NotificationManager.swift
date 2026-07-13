//
//  NotificationManager.swift
//  WeatherWise
//
//  Created by Kshitij Kumar on 1/6/25.
//

import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private var lastNotificationTime: Date?
    private let minimumInterval: TimeInterval = 2
    
    private init() {
        print("Initializing NotificationManager")
        requestAuthorization()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error)")
            } else {
                print("Notification permission denied")
            }
        }
    }
    
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification Settings:")
            print("Authorization Status: \(settings.authorizationStatus.rawValue)")
            print("Alert Setting: \(settings.alertSetting.rawValue)")
            print("Sound Setting: \(settings.soundSetting.rawValue)")
            print("Badge Setting: \(settings.badgeSetting.rawValue)")
        }
    }
    
    func sendNotification(title: String, body: String) {
        if let lastTime = lastNotificationTime,
           Date().timeIntervalSince(lastTime) < minimumInterval {
            print("Skipping notification - too soon after last one")
            return
        }
        
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let self = self else { return }
            
            guard settings.authorizationStatus == .authorized ||
                  settings.authorizationStatus == .provisional else {
                print("Notifications not authorized")
                return
            }
            
            print("Sending notification with title: \(title)")
            
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
            
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to send notification: \(error)")
                } else {
                    print("Successfully sent notification")
                    self.lastNotificationTime = Date()
                }
            }
        }
    }
}
