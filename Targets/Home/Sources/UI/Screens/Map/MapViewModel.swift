//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import CoreLocation
import SwiftUI

@Observable
class MapViewModel: NSObject {
    var locationAuthorizationStatus = LocationAuthorizationStatus.noDetermined

    let places: [MapPlace] = MapPlace.places
    let locationManager = CLLocationManager()

    override init() {
        super.init()

        locationManager.delegate = self

        updateAuthorizationStatus(locationManager)
    }

    private func updateAuthorizationStatus(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse: // Location services are available.
            locationAuthorizationStatus = .authorized

        case .restricted, .denied: // Location services currently unavailable.
            locationAuthorizationStatus = .denied

        case .notDetermined: // Authorization not determined yet.
            locationAuthorizationStatus = .noDetermined

        default:
            break
        }
    }

    func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
}

// MARK: - Delegates

extension MapViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        updateAuthorizationStatus(manager)
    }
}

// MARK: - Enums

enum LocationAuthorizationStatus {
    case authorized
    case denied
    case noDetermined
}
