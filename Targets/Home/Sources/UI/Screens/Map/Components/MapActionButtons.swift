//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import MapKit
import SwiftUI

struct MapActionButtons: View {
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
                        "Toggle Marker UI",
                        systemImage: "mappin.and.ellipse",
                        isOn: $showCustomMarker
                    )
                    .toggleStyle(.button)
                }

                HStack {
                    Image(systemName: "magnifyingglass")

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
                .padding(8)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.label.opacity(0.25), lineWidth: 1)
                }
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

            print(searchResults)

            isLoading = false

            // Reset map and show all results
            position = .automatic
        }
    }
}

#Preview {
    MapActionButtons(
        position: .constant(.automatic),
        searchResults: .constant([]),
        showCustomMarker: .constant(false)
    )
}
