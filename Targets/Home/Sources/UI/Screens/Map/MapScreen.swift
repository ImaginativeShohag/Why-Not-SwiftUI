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
    @Namespace private var mapScope

    @State private var viewModel = MapViewModel()
    @State private var position: MapCameraPosition = .automatic
    @State private var showPreLocationAuthorizationSection: Bool = false
    @State private var showCustomMarker = false
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var route: MKRoute?
    @State private var selectedResult: MKMapItem?
    @State private var searchResults: [MKMapItem] = MapPlace.places
        .map { $0.toMapItem() }

    var body: some View {
        Map(position: $position, selection: $selectedResult, scope: mapScope) {
            ForEach(searchResults, id: \.self) { result in
                if showCustomMarker {
                    Annotation(
                        result.name ?? "Unknown",
                        coordinate: result.placemark.coordinate
                    ) {
                        Image(systemName: "mappin.and.ellipse")
                            .padding(4)
                            .foregroundStyle(.white)
                            .background(
                                Gradient(
                                    colors: [
                                        Color.pink,
                                        Color.purple,
                                        Color.indigo
                                    ]
                                )
                            )
                            .cornerRadius(8)
                            .scaleEffect(
                                selectedResult == result ? 1.5 : 1,
                                anchor: .bottom
                            )
                            .animation(.default, value: selectedResult)
                    }
                } else {
                    Marker(item: result)
                }
            }

            if let route {
                MapPolyline(route)
                    .stroke(.red, lineWidth: 5)
            }
        }
        .navigationTitle("Map")
        .toolbarTitleDisplayMode(.inline)
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
                        Text("Cannot access your location. Please allow location access in the settings.")
                            .multilineTextAlignment(.center)
                    }
                }

                if selectedResult != nil {
                    MapItemInfoView(selectedResult: $selectedResult, route: $route)
                        .frame(height: 128)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                MapActionButtons(
                    position: $position,
                    searchResults: $searchResults,
                    showCustomMarker: $showCustomMarker,
                    visibleRegion: visibleRegion
                )
            }
            .padding([.top, .horizontal])
            .frame(maxWidth: .infinity)
            .animation(.default, value: viewModel.locationAuthorizationStatus)
            .animation(.default, value: position)
            .animation(.default, value: selectedResult)
            .background(.thinMaterial)
        }
        .fullScreenCover(isPresented: $showPreLocationAuthorizationSection) {
            LocationAuthorizationPreAlertSection(
                onClickAllow: {
                    showPreLocationAuthorizationSection = false

                    viewModel.requestLocationAuthorization()
                }
            )
        }
        .onChange(of: selectedResult) {
            getDirections()
        }
        .onMapCameraChange { context in
            visibleRegion = context.region
        }
    }

    private func getDirections() {
        route = nil

        guard let visibleRegion else { return }
        guard let selectedResult else { return }

        let request = MKDirections.Request()
        request.source = MKMapItem(
            placemark: MKPlacemark(
                coordinate: viewModel.userCurrentLocation?.coordinate ?? visibleRegion.center
            )
        )
        request.destination = selectedResult

        Task {
            let directions = MKDirections(request: request)
            let response = try? await directions.calculate()
            route = response?.routes.first
        }
    }
}

#Preview {
    MapScreen()
}
