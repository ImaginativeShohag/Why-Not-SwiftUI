//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct TextPreviewScreen: View {
    var body: some View {
        ScrollView {
            HStack(spacing: 8) {
                VStack(alignment: .leading) {
                    Group {
                        Text("L")
                            .fontStyle(fontFamily: .robotoSlab, size: 46, weight: .bold)
                            + Text("orem")
                            .fontStyle(fontFamily: .robotoSlab, size: 42, weight: .semibold)
                            + Text(" ipsum!")
                            .fontStyle(fontFamily: .robotoSlab, size: 36, weight: .regular)
                    }
                    .shadow(color: Color(.systemBackground), radius: 0, x: 2, y: 2)
                    .shadow(color: Color(.label).opacity(0.35), radius: 0, x: 1, y: 1)
                    .padding(.bottom, 8)

                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
                        .fontStyle(size: 24, weight: .light)
                        .foregroundColor(Color(.label))
                }

                Text("L\nO\nR\nE\nM")
                    .foregroundColor(Color(.label).opacity(0.1))
                    .fontStyle(size: 96, weight: .black)
                    .fixedSize()
            }
            .padding()
        }
    }
}

struct TextPreviewScreen_Previews: PreviewProvider {
    static var previews: some View {
        TextPreviewScreen()
    }
}
