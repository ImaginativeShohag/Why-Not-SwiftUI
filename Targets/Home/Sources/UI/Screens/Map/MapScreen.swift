//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import MapKit
import NavigationKit
import SwiftUI

// todo: route form current user location

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
    @State private var selection: MapPlace?
    @State private var showPreLocationAuthorizationSection: Bool = false

    @State private var visibleRegion: MKCoordinateRegion?
    @State private var route: MKRoute?
    @State private var selectedResult: MKMapItem?
    @State private var searchResults: [MKMapItem] = MapPlace.places
        .map { $0.toMapItem() }

    @State private var showCustomMarker = false

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
                            .background(Color.red)
                            .cornerRadius(4)
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
                    .stroke(.blue, lineWidth: 5)
            }
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
                        Text("Cannot access your location. Please allow location access in the settings.")
                            .multilineTextAlignment(.center)
                    }
                }

                if let selectedResult {
                    ItemInfoView(selectedResult: $selectedResult, route: $route)
                        .frame(height: 128)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                ActionButtons(
                    position: $position,
                    searchResults: $searchResults,
                    showCustomMarker: $showCustomMarker,
                    visibleRegion: visibleRegion
                )
            }
            .padding()
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

    func getDirections() {
        route = nil
        guard let visibleRegion else { return }
        guard let selectedResult else { return }
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: visibleRegion.center))
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

struct ItemInfoView: View {
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

    func getLookAroundScene() {
        guard let selectedResult else { return }

        lookAroundScene = nil
        Task {
            let request = MKLookAroundSceneRequest(mapItem: selectedResult)
            lookAroundScene = try? await request.scene
        }
    }
}

struct ActionButtons: View {
    @Binding var position: MapCameraPosition
    @Binding var searchResults: [MKMapItem]
    @Binding var showCustomMarker: Bool
    var visibleRegion: MKCoordinateRegion?

    @State private var isLoading = false

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button {
                        position = .automatic
                    } label: {
                        Label("Show All", systemImage: "map")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(position == .automatic)

                    Toggle(
                        "Custom marker",
                        systemImage: "mappin.and.ellipse",
                        isOn: $showCustomMarker
                    )
                    .toggleStyle(.button)
                }

                HStack {
                    Button {
                        search(for: "playground")
                    } label: {
                        Label("Playgrounds", systemImage: "figure.and.child.holdinghands")
                    }

                    Button {
                        search(for: "beach")
                    } label: {
                        Label("Beaches", systemImage: "beach.umbrella")
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .disabled(isLoading)
            .opacity(isLoading ? 0 : 1)

            if isLoading {
                ProgressView()
            }
        }
        .animation(.default, value: isLoading)
    }

    private func search(for query: String) {
        guard let visibleRegion else { return }

        isLoading = true

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        request.region = visibleRegion

        Task {
            let search = MKLocalSearch(request: request)
            let response = try? await search.start()
            searchResults = response?.mapItems ?? []

            isLoading = false
        }
    }
}
