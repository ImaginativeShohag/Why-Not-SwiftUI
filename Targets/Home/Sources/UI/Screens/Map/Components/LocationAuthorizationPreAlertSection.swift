//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct LocationAuthorizationPreAlertSection: View {
    let onClickAllow: () -> Void

    var body: some View {
        ScrollView {
            ZStack {
                Spacer().containerRelativeFrame([.horizontal, .vertical])
                
                VStack(alignment: .center) {
                    Image(systemName: "location.fill.viewfinder")
                        .resizable()
                        .frame(width: 64, height: 64)
                        .font(.title)
                    
                    Spacer()
                        .frame(height: 32)

                    Text(NSLocalizedString("location_service_instruction_text", bundle: .module, comment: ""))
                        .font(.title)

                    IconTextSection(
                        systemIcon: "heart.fill",
                        text: "Lorem Ipsum Dolor Sit Amet Consectetur Adipiscing Elit Aenean Quis"
                    )

                    IconTextSection(
                        systemIcon: "map.fill",
                        text: "Lorem Ipsum Dolor Sit Amet Consectetur Adipiscing Elit Aenean Quis"
                    )

                    IconTextSection(
                        systemIcon: "chart.bar.doc.horizontal.fill",
                        text: "Lorem Ipsum Dolor Sit Amet Consectetur Adipiscing Elit Aenean Quis"
                    )
                    
                    Spacer()
                        .frame(height: 16)

                    Button {
                        onClickAllow()
                    } label: {
                        Text(NSLocalizedString("allow_button_title", bundle: .module, comment: ""))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .font(.title)
                    .tint(Color.white)
                    .foregroundStyle(Color.pink)
                }
                .padding()
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(
            ZStack {
                Color.pink
            }
            .overlay(Gradient(colors: [Color.clear, Color.black.opacity(0.5)]))
            .ignoresSafeArea()
        )
    }
}

private struct IconTextSection: View {
    let systemIcon: String
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: systemIcon)
                .resizable()
                .padding(12)
                .background(Color.white)
                .foregroundStyle(Color.pink)
                .clipShape(Circle())
                .frame(width: 48, height: 48)

            Text(text)
                .font(.body)
                .multilineTextAlignment(.leading)
        }
        .padding()
    }
}

#Preview {
    LocationAuthorizationPreAlertSection(
        onClickAllow: {}
    )
}
