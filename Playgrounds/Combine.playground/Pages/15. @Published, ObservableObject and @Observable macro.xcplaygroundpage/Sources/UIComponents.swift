import SwiftUI

// MARK: - Extensions

public extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

// MARK: - Components

public struct KeyValueSectionView: View {
    let key: String
    let value: String

    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }

    public var body: some View {
        Text("\(key): \(value)")
            .padding()
            .border(Color.black, width: 1)
            .background(Color.random)
    }
}

public struct ButtonSectionView: View {
    let label: String
    let action: () -> Void

    public init(label: String, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }

    public var body: some View {
        Button {
            action()
        } label: {
            Text(label)
        }
        .padding()
        .background(Color.random)
        .cornerRadius(16)
    }
}
