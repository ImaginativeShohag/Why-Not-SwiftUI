//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import MapKit
import NavigationKit
import SwiftUI

// MARK: - Destination

public extension Destination {
    final class Map: BaseDestination {
        override public func getScreen() -> any View {
            MapScreen()
        }
    }
}

// MARK: - UI

/// # Further Reading:
/// - Meet MapKit for SwiftUI: https://developer.apple.com/videos/play/wwdc2023/10043/
/// - WWDCNotes: https://wwdcnotes.com/documentation/wwdcnotes/wwdc23-10043-meet-mapkit-fo

struct MapScreen: View {
    @State private var viewModel = MapViewModel()
    @State private var position: MapCameraPosition = .automatic
    @State private var selection: MapPlace?
    @State private var showPreLocationAuthorizationSection: Bool = false

    @Namespace var mapScope

    var body: some View {
        Map(position: $position, selection: $selection, scope: mapScope) {
            // Districts of Bangladesh
            ForEach(viewModel.places, id: \.name) { place in
                Marker(
                    place.name,
                    systemImage: "mappin.and.ellipse",
                    coordinate: place.location
                )
                .tag(place)
            }

            // Cox's Bazar
            Annotation(
                "Cox's Bazar",
                coordinate: CLLocationCoordinate2D(
                    latitude: 21.5164985,
                    longitude: 91.8819745
                )
            ) {
                Image(systemName: "beach.umbrella")
                    .padding(4)
                    .foregroundStyle(.white)
                    .background(Color.blue)
                    .cornerRadius(4)
                    .scaleEffect(
                        selection == MapPlace.coxsBazarMapPlace ? 1.5 : 1,
                        anchor: .bottom
                    )
                    .animation(.default, value: selection)
            }
            .tag(MapPlace.coxsBazarMapPlace)
        }
        .mapControls {
            MapScaleView()
        }
        .mapControlVisibility(.visible)
        .overlay(alignment: .bottomTrailing) {
            VStack {
                if viewModel.locationAuthorizationStatus == .authorized {
                    MapUserLocationButton(scope: mapScope)
                }
                MapPitchToggle(scope: mapScope)
                MapCompass(scope: mapScope)
            }
            .mapControlVisibility(.visible)
            .padding(.trailing, 10)
            .buttonBorderShape(.circle)
        }
        .mapScope(mapScope)
        .safeAreaInset(edge: .bottom) {
            VStack {
                if viewModel.locationAuthorizationStatus == .noDetermined {
                    MapWarningView {
                        Text("Cannot access your location. Please allow location access.")
                            .multilineTextAlignment(.center)

                        Button {
                            showPreLocationAuthorizationSection = true
                        } label: {
                            Text("Allow")
                        }
                    }
                } else if viewModel.locationAuthorizationStatus == .denied {
                    MapWarningView {
                        Text("Cannot access your location. Please allow locaiton access in the settings.")
                            .multilineTextAlignment(.center)
                    }
                }

                Button {
                    position = .automatic
                } label: {
                    Image(systemName: "map")
                    Text("Show All Locations")
                }
                .buttonStyle(.borderedProminent)
                .disabled(position == .automatic)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .animation(.default, value: viewModel.locationAuthorizationStatus)
            .animation(.default, value: position)
            .background(.thinMaterial)
        }
        .sheet(item: $selection) { mapPlace in
            MapPlaceDetailsSheet(item: mapPlace)
                .presentationDragIndicator(.visible)
                .presentationDetents([.medium])
        }
        .fullScreenCover(isPresented: $showPreLocationAuthorizationSection) {
            LocationAuthorizationPreAlertSection(
                onClickAllow: {
                    showPreLocationAuthorizationSection = false

                    viewModel.requestLocationAuthorization()
                }
            )
        }
    }
}

#Preview {
    MapScreen()
}
