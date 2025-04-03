# WeatherWise

## Smart Weather Activity Notifier

WeatherWise is an iOS application that monitors real-time weather conditions and notifies users when the weather is ideal for outdoor activities. Never miss a perfect day outdoors again!

## Features

- **Real-time Weather Monitoring**: Continuously tracks weather conditions in your location
- **Smart Notifications**: Sends alerts when the weather is perfect for outdoor activities
- **Location-based**: Uses your current location for accurate weather information
- **Customizable Criteria**: Define your ideal weather parameters (temperature, humidity, wind speed)
- **Clean Interface**: Simple, intuitive UI displays current weather conditions
- **Background Processing**: Works quietly in the background, only alerting you when needed

## Technical Implementation

WeatherWise is built with modern iOS development technologies:

- **SwiftUI**: For building the entire user interface
- **CoreLocation**: To access the user's current location
- **UserNotifications**: For delivering timely weather alerts
- **URLSession**: For API communication with OpenWeatherMap
- **MVVM Architecture**: For clean separation of concerns
- **Codable Protocol**: For efficient JSON data handling
- **Async/Await**: For modern concurrency patterns
- **Background Processing**: For continuous weather monitoring

## Getting Started

### Prerequisites
- Xcode 16.2 or later
- iOS 18.2+ device or simulator
- OpenWeatherMap API key

### Installation
1. Clone the repository
   ```bash
   git clone https://github.com/yourusername/WeatherWise.git
   ```

2. Open `WeatherWise.xcodeproj` in Xcode

3. Insert your OpenWeatherMap API key in `WeatherService.swift`
   ```swift
   private let apiKey = "YOUR_API_KEY_HERE"
   ```

4. Build and run the application on your device or simulator

## Configuration

### Weather Parameters
The app determines ideal weather conditions based on these default parameters:
- Temperature: 65°F - 77°F
- Humidity: Less than 70%
- Wind Speed: Less than 12 mph

These parameters can be adjusted in `WeatherModel.swift`:

```swift
var isGoodWeather: Bool {
    return temperature >= 65 && temperature <= 77 && 
           humidity < 70 &&
           windSpeed < 12
}
```

### Notification Frequency
By default, the app checks weather conditions every 30 minutes. For testing purposes, this interval is set to 60 seconds. Adjust this in `WeatherService.swift`:

```swift
private let weatherCheckInterval: TimeInterval = 60 // Set to 1800 for 30 minutes
```

## Privacy

WeatherWise requires the following permissions:
- Location access to provide accurate weather data
- Notification permission to alert you about ideal weather conditions

These permissions are requested when you first launch the app.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- Weather data provided by [OpenWeatherMap](https://openweathermap.org/)
- Icons and UI design inspiration from Apple's Weather app
