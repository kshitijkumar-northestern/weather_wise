# WeatherWise

[![CI](https://github.com/kshitijkumar-northestern/weather_wise/actions/workflows/ci.yml/badge.svg)](https://github.com/kshitijkumar-northestern/weather_wise/actions/workflows/ci.yml)

## Smart Weather Activity Notifier

WeatherWise is an iOS application that monitors real-time weather conditions and notifies users when the weather matches their ideal outdoor criteria.

## Features

- **Real-time weather monitoring** using OpenWeatherMap (imperial units)
- **24-hour forecast** with a "next good weather window" banner that answers *when* to go outside
- **Customizable criteria** for temperature, humidity, wind, and check interval (persisted)
- **Smart local notifications** when conditions become ideal
- **Quiet hours** so ideal weather at 3 AM doesn't wake you up
- **Check history** of recent evaluations with pass/fail indicators
- **Background refresh** via `BGTaskScheduler` (best-effort; iOS controls timing)
- **Liquid Glass UI** — Apple's iOS 26 glass design language across every screen, with automatic material fallbacks on earlier iOS versions
- **MVVM architecture** with protocol-based services for unit testing

## Architecture

See [ARCHITECTURE.md](ARCHITECTURE.md) for layer diagrams, data flow, and design decisions.

High-level layout:

```
WeatherWise/
  App/           App entry + background registration
  DesignSystem/  Liquid Glass component library + sky backgrounds
  Models/        Domain models and API DTOs
  Services/      Networking, location, notifications, persistence
  ViewModels/    WeatherViewModel (UI state + orchestration)
  Views/         SwiftUI screens
```

## Technical stack

- SwiftUI + Swift Concurrency (async/await)
- CoreLocation
- UserNotifications
- BackgroundTasks (`BGAppRefreshTask`)
- URLSession + Codable
- Swift Testing (`import Testing`)

## Getting started

### Prerequisites

- Xcode 16.2 or later
- iOS 18.2+ device or simulator
- OpenWeatherMap API key

### Installation

1. Clone the repository.
2. Open `WeatherWise.xcodeproj` in Xcode.
3. Configure secrets:
   ```bash
   cp WeatherWise/Secrets.example.plist WeatherWise/Secrets.plist
   ```
   Replace `YOUR_API_KEY_HERE` with your OpenWeatherMap key.  
   `Secrets.plist` is gitignored.
4. Build and run on a device or simulator.
5. Allow **Location** and **Notifications** when prompted.

### Running tests

In Xcode: **Product → Test** (⌘U).  
Tests cover criteria evaluation, JSON decoding, persistence, and view-model behavior with mocks.

Continuous integration runs the unit test suite on every push and pull request
to `main` using GitHub Actions (macOS runner + iOS Simulator). See
[`.github/workflows/ci.yml`](.github/workflows/ci.yml).

## Configuration

Defaults (editable in **Settings** inside the app):

| Parameter | Default |
|-----------|---------|
| Temperature | 65°F – 77°F |
| Max humidity | &lt; 70% |
| Max wind | &lt; 12 mph |
| Check interval | 30 minutes |
| Quiet hours | Off (10 PM – 7 AM when enabled) |

Criteria and history are stored in `UserDefaults`.

## Privacy

WeatherWise requests:

- **Location (When In Use)** for accurate local weather
- **Notifications** for ideal-weather alerts

Background refresh may run while the app is not open; iOS schedules these tasks opportunistically.

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.

## Acknowledgements

- Weather data from [OpenWeatherMap](https://openweathermap.org/)
- UI patterns inspired by Apple’s Weather and system Settings apps
