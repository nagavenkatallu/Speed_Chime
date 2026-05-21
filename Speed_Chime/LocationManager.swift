//
//  LocationManager.swift
//  Speed_Chime
//
//  Created by Venkat Allu on 5/21/26.
//

import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var currentSpeed: CLLocationSpeed = 0.0

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.requestAlwaysAuthorization()
        
        // Configure the initial CoreLocation permissions required for background updates
        manager.allowsBackgroundLocationUpdates = true
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Convert speed from meters/second to mph (1 m/s = 2.23694 mph)
        let speedInMPH = max(location.speed * 2.23694, 0)
        currentSpeed = speedInMPH
        
        print("Current Speed (from GPX Simulator): \(Int(currentSpeed)) mph")
    }
}
