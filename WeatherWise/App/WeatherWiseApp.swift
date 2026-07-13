//
//  WeatherWiseApp.swift
//  WeatherWise
//
//  Created by Kshitij Kumar on 1/6/25.
//

import BackgroundTasks
import SwiftUI

@main
struct WeatherWiseApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var viewModel = WeatherViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .onAppear {
                    appDelegate.viewModel = viewModel
                    viewModel.startMonitoring()
                }
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    weak var viewModel: WeatherViewModel?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        BackgroundWeatherScheduler.register { [weak self] task in
            self?.handleBackgroundRefresh(task)
        }
        return true
    }

    private func handleBackgroundRefresh(_ task: BGAppRefreshTask) {
        let interval = viewModel?.criteria.checkInterval ?? WeatherCriteria.default.checkInterval
        BackgroundWeatherScheduler.schedule(after: interval)

        let refreshTask = Task { @MainActor in
            let success = await self.viewModel?.performWeatherCheck(sendNotificationIfIdeal: true) ?? false
            task.setTaskCompleted(success: success)
        }

        task.expirationHandler = {
            refreshTask.cancel()
        }
    }
}
