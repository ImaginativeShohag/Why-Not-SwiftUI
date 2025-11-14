//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import NavigationKit
import SwiftUI

// MARK: - Destination

public extension Destination {
    final class TodoIntro: BaseDestination {
        override public func getScreen() -> any View {
            IntroScreen()
        }
    }
}

// MARK: - UI

struct IntroScreen: View {
    @AppStorage("selectedDataSource") private var selectedDataSource: DataSourceType = .swiftData

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Choose your storage")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Select the storage option that best suits your needs. SwiftData offers a modern, streamlined approach, while CoreData provides a robust, established framework.")
                .font(.body)
                .foregroundColor(.secondary)

            ForEach(DataSourceType.allCases) { option in
                Button(action: {
                    selectedDataSource = option
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(option.rawValue)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)

                            Text(option.description)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }

                        Spacer()

                        Image(systemName: selectedDataSource == option ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selectedDataSource == option ? .blue : .gray)
                            .imageScale(.large)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                (selectedDataSource == option ? Color.blue : Color.gray).opacity(0.4),
                                lineWidth: 1
                            )
                    )
                }
            }

            Spacer()

            Button {
                DataSourceController.shared.setSource(selectedDataSource)

                NavController.shared.navigateTo(Destination.TodoHome())
            } label: {
                Text("Start")
                    .frame(maxWidth: .infinity)
                    .padding(4)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Todo Data Storage")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        IntroScreen()
    }
}
