//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import MapKit
import SwiftUI

struct MapItemInfoView: View {
    @Binding var selectedResult: MKMapItem?
    @Binding var route: MKRoute?

    @State private var lookAroundScene: MKLookAroundScene?

    private var travelTime: String? {
        guard let route else { return nil }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: route.expectedTravelTime)
    }

    var body: some View {
        LookAroundPreview(initialScene: lookAroundScene)
            .overlay(alignment: .bottomTrailing) {
                HStack {
                    Text("\(selectedResult?.name ?? "")")
                    if let travelTime {
                        Text(travelTime)
                    }
                }
                .font(.caption)
                .foregroundStyle(.white)
                .padding(10)
            }
            .onAppear {
                getLookAroundScene()
            }
            .onChange(of: selectedResult) {
                getLookAroundScene()
            }
    }

    private func getLookAroundScene() {
        guard let selectedResult else { return }

        print("hwy? \(selectedResult)")

        lookAroundScene = nil
        Task {
            let request = MKLookAroundSceneRequest(mapItem: selectedResult)
            lookAroundScene = try? await request.scene
            print("hwy? \(lookAroundScene)")
        }
    }
}

#Preview {
    var applePark = {
        let addressDictionary: [String: Any] = [
            "Street": "3330 Pruneridge Ave",
            "City": "Santa Clara",
            "State": "CA",
            "ZIP": "95051",
            "Country": "United States"
        ]
        var placemark = MKPlacemark(
            coordinate: CLLocationCoordinate2D(latitude: 37.33015700, longitude: -121.98801550),
            addressDictionary: addressDictionary
        )

        let mapItem = MKMapItem(
            placemark: placemark
        )
        mapItem.name = "Maywood Park"

        return mapItem
    }

    MapItemInfoView(
        selectedResult: .constant(nil),
        route: .constant(nil)
    )
    .frame(height: 128)
    .clipShape(RoundedRectangle(cornerRadius: 10))
    .padding()

    MapItemInfoView(
        selectedResult: .constant(applePark()),
        route: .constant(nil)
    )
    .frame(height: 128)
    .clipShape(RoundedRectangle(cornerRadius: 10))
    .padding()
}
