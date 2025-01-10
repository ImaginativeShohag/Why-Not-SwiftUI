//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import CoreLocation
import MapKit

struct MapPlace: Identifiable, Hashable, Equatable {
    var id: String {
        name
    }

    let name: String
    let location: CLLocationCoordinate2D

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(location.latitude)
        hasher.combine(location.longitude)
    }

    static func == (lhs: MapPlace, rhs: MapPlace) -> Bool {
        lhs.name == rhs.name &&
            lhs.location.latitude == rhs.location.latitude &&
            lhs.location.longitude == rhs.location.longitude
    }

    func toMapItem() -> MKMapItem {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: location))
        mapItem.name = name
        return mapItem
    }
}

extension MapPlace {
    static let places: [MapPlace] = [
        MapPlace(
            name: "Barisal Division",
            location: CLLocationCoordinate2D(latitude: 22.6954585, longitude: 90.3187848)
        ),
        MapPlace(
            name: "Chattogram Division",
            location: CLLocationCoordinate2D(latitude: 22.3260781, longitude: 91.7498278)
        ),
        MapPlace(
            name: "Dhaka Division",
            location: CLLocationCoordinate2D(latitude: 23.7807777, longitude: 90.3492858)
        ),
        MapPlace(
            name: "Khulna Division",
            location: CLLocationCoordinate2D(latitude: 22.8454448, longitude: 89.4624617)
        ),
        MapPlace(
            name: "Mymensingh Division",
            location: CLLocationCoordinate2D(latitude: 24.7489639, longitude: 90.3789864)
        ),
        MapPlace(
            name: "Rajshahi Division",
            location: CLLocationCoordinate2D(latitude: 24.3802282, longitude: 88.5709965)
        ),
        MapPlace(
            name: "Rangpur Division",
            location: CLLocationCoordinate2D(latitude: 25.7499116, longitude: 89.2270261)
        ),
        MapPlace(
            name: "Sylhet Division",
            location: CLLocationCoordinate2D(latitude: 24.8998373, longitude: 91.8259625)
        )
    ]
}
