//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import CoreLocation
import SwiftUI
import MapKit

@Observable
class MapViewModel: NSObject {
    var locationAuthorizationStatus = LocationAuthorizationStatus.noDetermined
    var userCurrentLocation: CLLocation?
    
    let places: [MKMapItem] = MapPlace.places.map { $0.toMapItem() }
    
    private let locationManager = CLLocationManager()

    override init() {
        super.init()

        locationManager.delegate = self

        updateAuthorizationStatus(locationManager)
    }

    private func updateAuthorizationStatus(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse: // Location services are available.
            locationAuthorizationStatus = .authorized
            
            startLocationUpdate()

        case .restricted, .denied: // Location services currently unavailable.
            locationAuthorizationStatus = .denied
            
            startLocationUpdate()

        case .notDetermined: // Authorization not determined yet.
            locationAuthorizationStatus = .noDetermined

        default:
            break
        }
    }

    func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func startLocationUpdate() {
        if locationManager.authorizationStatus != .denied {
            locationManager.startUpdatingLocation()
        }
    }
}

// MARK: - Delegates

extension MapViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        updateAuthorizationStatus(manager)
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        userCurrentLocation = locations.last
    }
}

// MARK: - Enums

enum LocationAuthorizationStatus {
    case authorized
    case denied
    case noDetermined
}
