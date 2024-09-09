//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Alamofire
import Core
import SwiftUI

/// # Setup
///
/// 1. Install Ollama from here: https://ollama.com/download
/// 2. Run Ollama
/// 3. Update the `ollamaModel` and `ollamaEndpoint` constants.
///
/// Enjoy!

/// The model that you already downloaded in Ollama and want to use with the app.
///
/// Documentation: https://github.com/ollama/ollama/blob/main/README.md#pull-a-model
/// Models: https://ollama.com/library
private let ollamaModel = "llama3.1:8b"

/// The web address where Ollama is served.
///
/// Documentation: https://github.com/ollama/ollama/blob/main/README.md#rest-api
private let ollamaEndpoint = "http://localhost:11434"

@Observable
class OllamaViewModel {
    var state: UIState<String> = .data(data: "")
    var isStreaming: Bool = false

    @ObservationIgnored private var isPreview: Bool = false
    @ObservationIgnored private var currentContext: [Int]? = nil

    let session = Session(
        eventMonitors: [AlamofireLogger()]
    )

    func ask(_ prompt: String) {
        guard !isPreview else { return }
        guard !prompt.isEmpty else { return }

        isStreaming = true

        // Initialize the text.
        let previousText = state.getData() ?? ""

        var resultText = """
        \(previousText)

        **Question:** \(prompt)

        **Answer:** 
        """

        // Push the question.

        if previousText.isEmpty {
            state = .data(
                data: "**Question:** \(prompt)"
            )
        }

        // Generate the answer.

        let apiEndpoint = URL(string: ollamaEndpoint + "/api/generate")!

        let parameters = OllamaRequest(
            model: ollamaModel,
            prompt: prompt,
            context: currentContext
        )

        session.streamRequest(
            apiEndpoint,
            method: .post,
            parameters: parameters,
            encoder: JSONParameterEncoder.default
        )
        .responseStreamDecodable(
            of: OllamaResponse.self,
            stream: { stream in
                switch stream.event {
                case let .stream(result):
                    switch result {
                    case let .success(response):
                        resultText += response.response

                        self.state = .data(
                            data: resultText
                        )

                        if let context = response.context {
                            self.currentContext = context
                        }
                    case let .failure(error):
                        self.state = .error(message: error.localizedDescription)

                        self.isStreaming = false
                    }

                case .complete:
                    self.isStreaming = false
                }
            }
        )
        .resume()
    }
}

#if DEBUG

extension OllamaViewModel {
    convenience init(
        forPreview: Bool,
        isLoading: Bool = false,
        isError: Bool = false,
        hasData: Bool = true,
        isStreamming: Bool = false
    ) {
        self.init()

        isPreview = true
        isStreaming = isStreamming

        if isLoading {
            state = .loading
        } else if isError {
            state = .error(message: "Something went wrong!")
        } else if !hasData {
            state = .data(data: "")
        } else {
            state = .data(data: """
            Lorem Ipsum  
            Lorem Ipsum  


            Lorem Ipsum  

            Lorem Ipsum  
            """)
        }
    }
}

#endif

// MARK: - Models

struct OllamaRequest: Codable {
    let model, prompt: String
    let context: [Int]?
}

struct OllamaResponse: Codable {
    let model, createdAt, response: String
    let done: Bool
    let doneReason: String?
    let context: [Int]?
    let totalDuration, loadDuration, promptEvalCount, promptEvalDuration: Int?
    let evalCount, evalDuration: Int?

    enum CodingKeys: String, CodingKey {
        case model
        case createdAt = "created_at"
        case response, done
        case doneReason = "done_reason"
        case context
        case totalDuration = "total_duration"
        case loadDuration = "load_duration"
        case promptEvalCount = "prompt_eval_count"
        case promptEvalDuration = "prompt_eval_duration"
        case evalCount = "eval_count"
        case evalDuration = "eval_duration"
    }
}
