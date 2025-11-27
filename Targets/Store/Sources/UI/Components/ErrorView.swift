//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import LocalizeKit
import SwiftUI

struct ErrorView: View {
    let message: String
    let onRetryClick: () -> Void

    var body: some View {
        ContentUnavailableView(
            label: {
                Label(message, systemImage: "exclamationmark.triangle")
            },
            actions: {
                Button("store_retry".localize(default: "Retry", comment: "Retry button text")) {
                    onRetryClick()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
            }
        )
    }
}

#Preview {
    ErrorView(
        message: "Something went wrong. Try again.",
        onRetryClick: {
            //
        }
    )
}
