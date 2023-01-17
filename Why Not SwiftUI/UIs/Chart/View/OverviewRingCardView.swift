//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct OverviewRingCardView: View {
    let audits = [
        AuditData(name: "FOH", ring: RingChartRing(progress: 72, color: Color.green)),
        AuditData(name: "Critical System", ring: RingChartRing(progress: 36, color: Color.red)),
        AuditData(name: "Backstage And Remote", ring: RingChartRing(progress: 91, color: Color.purple)),
        AuditData(name: "Store Exterior", ring: RingChartRing(progress: 72, color: Color.green)),
        AuditData(name: "AV System", ring: RingChartRing(progress: 36, color: Color.red)),
        AuditData(name: "Vertical Transportation", ring: RingChartRing(progress: 91, color: Color.purple)),
        AuditData(name: "XYZ", ring: RingChartRing(progress: 72, color: Color.green))
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Audit Overview:")
                .fontStyle(size: 18)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                ZStack {
                    Text("90%")

                    RingChart(
                        rings: audits.map { $0.ring },
                        ringWidth: 10,
                        ringGap: 3
                    )
                    .frame(width: 250, height: 250)
                }
                .frame(width: 270, height: 270)
                .padding(.top, 16)
            }
            .frame(maxWidth: .infinity)

            ForEach(audits) { audit in
                HStack {
                    Text("•")
                        .fontStyle(size: 20)
                        .foregroundColor(audit.ring.color)

                    Text("\(audit.name)")

                    Spacer()

                    Text("\(Int(audit.ring.progress))%")
                        .foregroundColor(audit.ring.color)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(16)
    }
}

struct AuditData: Identifiable {
    let id = UUID().uuidString
    let name: String
    let ring: RingChartRing
}

struct OverviewRingCardView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewRingCardView()
    }
}
