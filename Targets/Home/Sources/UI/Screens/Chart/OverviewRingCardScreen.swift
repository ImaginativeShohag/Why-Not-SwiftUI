//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import CommonUI
import Core
import NavigationKit
import SwiftUI

// MARK: - Destination

public extension Destination {
    final class RingChartOverview: BaseDestination {
        override public func getScreen() -> any View {
            OverviewRingCardScreen()
        }
    }
}

// MARK: - UI

public struct OverviewRingCardScreen: View {
    let audits = [
        AuditData(name: "🍎 Apple", ring: RingChartRing(progress: 72, color: Color.red)),
        AuditData(name: "🍊 Orange", ring: RingChartRing(progress: 36, color: Color.orange)),
        AuditData(name: "🍌 Banana", ring: RingChartRing(progress: 91, color: Color.yellow)),
        AuditData(name: "🥭 Mango", ring: RingChartRing(progress: 72, color: Color.green)),
        AuditData(name: "🍍 Pineapple", ring: RingChartRing(progress: 91, color: Color.teal))
    ]

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                ZStack {
                    Text(NSLocalizedString("overview_ring_card_percentage_value", bundle: .module, comment: ""))
                        .font(.system(size: 20, weight: .bold))

                    RingChart(
                        rings: audits.map { $0.ring },
                        ringWidth: 12,
                        ringGap: 4
                    )
                    .frame(width: 250, height: 250)
                }
                .frame(width: 270, height: 270)
                .padding(.top, 16)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 32)

            ForEach(audits) { audit in
                HStack {
                    Text("•")
                        .fontStyle(size: 20)
                        .foregroundColor(audit.ring.color)

                    Text("\(audit.name)")
                        .font(.system(size: 16, weight: .medium))

                    Spacer()

                    Text("\(Int(audit.ring.progress))%")
                        .foregroundColor(audit.ring.color)
                        .font(.system(size: 16, weight: .bold))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.black.opacity(0.1), lineWidth: 2)
                }
                .padding(.vertical, 2)
                .padding(.horizontal, 32)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .navigationTitle(NSLocalizedString("ring_chart_overview_title", bundle: .module, comment: ""))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AuditData: Identifiable {
    let id = UUID().uuidString
    let name: String
    let ring: RingChartRing
}

struct OverviewRingCardView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewRingCardScreen()
    }
}
