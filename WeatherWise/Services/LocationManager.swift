//
//  LocationManager.swift
//  WeatherWise
//
//  Created by Kshitij Kumar on 1/6/25.
//

import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var error: Error?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        if authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
            print("Starting location updates")
        } else {
            print("Location permission denied")
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        print("Authorization status changed to: \(authorizationStatus.rawValue)")
        
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location permission granted")
            manager.startUpdatingLocation()
        case .denied, .restricted:
            error = NSError(domain: "LocationError",
                          code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Location access denied. Please enable it in Settings."])
            print("Location permission denied")
        case .notDetermined:
            print("Location permission not determined")
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("Location received: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            self.location = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
        self.error = error
    }
}
