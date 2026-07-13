//
//  NotificationService.swift
//  WeatherWise
//

import Foundation
import UserNotifications

final class NotificationService: Notifying {
    static let shared = NotificationService()

    private var lastNotificationTime: Date?
    private let minimumInterval: TimeInterval = 2

    init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error {
                print("Error requesting notification permission: \(error)")
            } else {
                print(granted ? "Notification permission granted" : "Notification permission denied")
            }
        }
    }

    func sendNotification(title: String, body: String) {
        if let lastTime = lastNotificationTime,
           Date().timeIntervalSince(lastTime) < minimumInterval {
            print("Skipping notification - too soon after last one")
            return
        }

        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let self else { return }
            guard settings.authorizationStatus == .authorized ||
                  settings.authorizationStatus == .provisional else {
                print("Notifications not authorized")
                return
            }

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
                if let error {
                    print("Failed to send notification: \(error)")
                } else {
                    self.lastNotificationTime = Date()
                }
            }
        }
    }
}
