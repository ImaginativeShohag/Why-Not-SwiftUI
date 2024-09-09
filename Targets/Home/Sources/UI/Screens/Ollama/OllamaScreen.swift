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
            switch viewModel.state {
            case .loading:
                ProgressView()

            case .error(let message):
                ContentUnavailableView(
                    message,
                    systemImage: "exclamationmark.triangle"
                )

            case .data(let response):
                VStack {
                    if response.isEmpty {
                        ContentUnavailableView(
                            "Ask anything!",
                            systemImage: "message"
                        )
                    } else {
                        ScrollView {
                            VStack(alignment: .leading) {
                                Markdown(response)
                                    .padding()
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

#Preview("Loading") {
    NavigationStack {
        OllamaScreen(
            viewModel: OllamaViewModel(forPreview: true, isLoading: true)
        )
    }
}

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
