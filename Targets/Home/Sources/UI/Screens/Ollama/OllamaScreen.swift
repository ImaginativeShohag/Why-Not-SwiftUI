//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import MarkdownUI
import SwiftUI

// MARK: - Destination

public extension Destination {
    final class Ollama: BaseDestination {
        override public func getScreen() -> any View {
            OllamaScreen()
        }
    }
}

// MARK: - UI

struct OllamaScreen: View {
    @State private var viewModel: OllamaViewModel
    @State var prompt = "Why is the sky blue? Answer briefly."

    init(viewModel: OllamaViewModel = OllamaViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            VStack {
                if viewModel.messages.isEmpty {
                    ContentUnavailableView(
                        "Ask anything!",
                        systemImage: "message"
                    )
                } else {
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(viewModel.messages) { model in
                                ChatBubbleView(
                                    message: model.message,
                                    isMe: model.type == .question,
                                    isError: model.type == .error
                                )
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .defaultScrollAnchor(.bottom)
                }

                HStack {
                    TextField("Ask anything...", text: $prompt)
                        .submitLabel(.go)
                        .onSubmit {
                            ask()
                        }
                        .disabled(viewModel.isStreaming)

                    if viewModel.isStreaming {
                        ProgressView()
                    } else {
                        Button {
                            ask()
                        } label: {
                            Image(systemName: "paperplane")
                        }
                    }
                }
                .padding()
                .background(Material.regular)
            }
        }
        .navigationTitle("Ollama Example")
        .navigationBarTitleDisplayMode(.inline)
    }

    func ask() {
        viewModel.ask(prompt)

        prompt = ""
    }
}

#if DEBUG

#Preview("Empty") {
    NavigationStack {
        OllamaScreen(
            viewModel: OllamaViewModel(forPreview: true, hasData: false)
        )
    }
}

#Preview("Success") {
    NavigationStack {
        OllamaScreen(
            viewModel: OllamaViewModel(forPreview: true)
        )
    }
}

#Preview("Streaming") {
    NavigationStack {
        OllamaScreen(
            viewModel: OllamaViewModel(forPreview: true, isStreamming: true)
        )
    }
}

#Preview("Error") {
    NavigationStack {
        OllamaScreen(
            viewModel: OllamaViewModel(forPreview: true, isError: true)
        )
    }
}

#endif

struct ChatBubbleView: View {
    let message: String
    let isMe: Bool
    let isError: Bool

    init(message: String, isMe: Bool, isError: Bool = false) {
        self.message = message
        self.isMe = isMe
        self.isError = isError
    }

    var body: some View {
        HStack {
            if isMe {
                Spacer()
            }

            Markdown(message)
                .markdownTextStyle(\.text) {
                    ForegroundColor(
                        (isMe || isError) ? .white : .black
                    )
                }
                .padding(10)
                .background(
                    isError ? Color.red :
                        (isMe ? Color.blue : Color.gray.opacity(0.3))
                )
                .cornerRadius(16)

            if !isMe {
                Spacer()
            }
        }
        .padding(isMe ? .trailing : .leading, 16)
        .padding(.vertical, 4)
    }
}

#Preview("ChatBubbleView") {
    VStack {
        ChatBubbleView(message: "Hello, how are you?", isMe: false)
        ChatBubbleView(message: "I'm doing great, thanks!", isMe: true)
        ChatBubbleView(
            message: "Hello, how are you?",
            isMe: false,
            isError: true
        )
        ChatBubbleView(
            message: "I'm doing great, thanks!",
            isMe: true,
            isError: true
        )
    }
    .padding()
}
