//
//  BackgroundWeatherScheduler.swift
//  WeatherWise
//

import BackgroundTasks
import Foundation

enum BackgroundWeatherScheduler {
    static let taskIdentifier = "com.weatherActivity.WeatherWise.weatherRefresh"

    static func register(handler: @escaping (BGAppRefreshTask) -> Void) {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            guard let refreshTask = task as? BGAppRefreshTask else {
                task.setTaskCompleted(success: false)
                return
            }
            handler(refreshTask)
        }
    }

    static func schedule(after interval: TimeInterval) {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: max(interval, 15 * 60))
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Scheduled background weather refresh")
        } catch {
            print("Could not schedule background refresh: \(error)")
        }
    }
}
