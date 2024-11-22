//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation
import NavigationKit
import SwiftUI
import WebKit

// MARK: - Destination

public extension Destination {
    final class WebView: BaseDestination {
        override public func getScreen() -> any View {
            WebViewScreen()
        }
    }
}

// MARK: - UI

struct WebViewScreen: View {
    @Environment(\.dismiss) private var dismiss

    @State private var url: String
    @State private var title = "Browser"
    @State private var isLoading = false
    @State private var progress: Double = 0.0
    @State private var canGoBack: Bool = false
    @State private var canGoForward: Bool = false
    @State private var canRefresh: Bool = false
    @State private var error: String? = nil

    private let webView = WKWebView()

    init(
        url: String = "https://github.com/ImaginativeShohag"
    ) {
        self.url = url
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                HStack {
                    Button {
                        webView.goBack()
                    } label: {
                        Image(systemName: "chevron.left.circle")
                    }
                    .disabled(!canGoBack)

                    Button {
                        webView.goForward()
                    } label: {
                        Image(systemName: "chevron.right.circle")
                    }
                    .disabled(!canGoForward)

                    ZStack(alignment: .trailing) {
                        TextField("Enter url", text: $url)
                            .submitLabel(.go)
                            .onSubmit {
                                go()
                            }
                            .padding(.trailing, canRefresh ? 24 : 0)

                        if canRefresh {
                            Button {
                                webView.reload()
                            } label: {
                                Image(systemName: "arrow.clockwise")
                            }
                            .padding(.trailing, 4)
                        }
                    }
                    .padding(4)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.systemGray3, lineWidth: 1)
                    }

                    Button {
                        go()
                    } label: {
                        Text("Go")
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)

                if self.isLoading {
                    ProgressView(value: progress, total: 1.0)
                        .progressViewStyle(.linear)
                }
            }
            .background(.regularMaterial)

            WebView(
                webView: webView,
                url: $url,
                title: $title,
                isLoading: $isLoading.animation(),
                progress: $progress.animation(),
                canGoBack: $canGoBack.animation(),
                canGoForward: $canGoForward.animation(),
                canRefresh: $canRefresh.animation(),
                error: $error.animation()
            )
            .ignoresSafeArea()
            .overlay {
                if let error {
                    ZStack {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.title)

                            Text(error)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.systemBackground)
                } else if webView.url == nil {
                    ZStack {
                        Text("Type a URL and tap Go.")
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.systemBackground)
                }
            }
        }
        .navigationBarTitle(title, displayMode: .inline)
    }

    private func go() {
        // Add "https://" prefix
        if !url.contains("://") {
            url = "https://" + url
        }

        // Let's go
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    private func goBack() {
        dismiss()
    }
}

#Preview("Initial") {
    NavigationStack {
        WebViewScreen()
    }
}

#Preview("Wrong URL 1") {
    NavigationStack {
        WebViewScreen(
            url: "wrong-url://example.com"
        )
    }
}

#Preview("Wrong URL 2") {
    NavigationStack {
        WebViewScreen(
            url: "https://examplelorem.com"
        )
    }
}

private struct WebView: UIViewRepresentable {
    let webView: WKWebView
    @Binding var url: String
    @Binding var title: String
    @Binding var isLoading: Bool
    @Binding var progress: Double
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var canRefresh: Bool
    @Binding var error: String?

    init(
        webView: WKWebView,
        url: Binding<String>,
        title: Binding<String>,
        isLoading: Binding<Bool>,
        progress: Binding<Double>,
        canGoBack: Binding<Bool>,
        canGoForward: Binding<Bool>,
        canRefresh: Binding<Bool>,
        error: Binding<String?>
    ) {
        self.webView = webView
        self._url = url
        self._title = title
        self._isLoading = isLoading
        self._progress = progress
        self._canGoBack = canGoBack
        self._canGoForward = canGoForward
        self._canRefresh = canRefresh
        self._error = error
    }

    func makeUIView(context: Context) -> some UIView {
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true

        return webView
    }

    func updateUIView(_: UIViewType, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView

        init(parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
            parent.canRefresh = false

            updateUrl(webView)
            updateNavigationButtons(webView)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.title = webView.title ?? ""
            parent.progress = 1.0
            parent.canRefresh = webView.url != nil
            parent.error = nil

            // We need this so that user can see the end of the progress.
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(0.5))

                self.parent.isLoading = false
            }

            updateUrl(webView)
            updateNavigationButtons(webView)
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            parent.progress = Double(webView.estimatedProgress)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("didFail")
            parent.isLoading = false
            parent.error = error.localizedDescription

            updateUrl(webView)
            updateNavigationButtons(webView)
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: any Error
        ) {
            parent.isLoading = false
            parent.error = error.localizedDescription

            updateUrl(webView)
            updateNavigationButtons(webView)
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            return .allow
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse) async -> WKNavigationResponsePolicy {
            parent.isLoading = false

            if let response = navigationResponse.response as? HTTPURLResponse {
                if response.statusCode == 401 {
                    parent.error = "(404) Page not found!"
                }
            }

            updateUrl(webView)
            updateNavigationButtons(webView)

            return .allow
        }

        // MARK: Methods

        func updateNavigationButtons(_ webView: WKWebView) {
            parent.canGoBack = webView.canGoBack
            parent.canGoForward = webView.canGoForward
        }

        func updateUrl(_ webView: WKWebView) {
            if let url = webView.url {
                parent.url = url.absoluteString
            }
        }
    }
}
