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
/// Command: Model List: `ollama list`
private let ollamaModel = "llama3.1:8b"

/// The web address where Ollama is served.
///
/// Documentation: https://github.com/ollama/ollama/blob/main/README.md#rest-api
private let ollamaEndpoint = "http://localhost:11434"

@Observable
class OllamaViewModel {
    var messages: [ChatMessage] = []
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

        // Push the question.

        withAnimation {
            messages.append(
                ChatMessage(
                    message: prompt,
                    type: .question
                )
            )
        }

        // Initialize the answer text.

        var resultText = ""

        // Push the answer.

        let answerChatMessage = ChatMessage(
            message: resultText,
            type: .answer
        )

        withAnimation {
            messages.append(answerChatMessage)
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

                        answerChatMessage.message = resultText

                        if let context = response.context {
                            self.currentContext = context
                        }

                    case let .failure(error):
                        answerChatMessage.message = "Error: \(error.localizedDescription)"
                        answerChatMessage.type = .error

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
        isError: Bool = false,
        hasData: Bool = true,
        isStreamming: Bool = false
    ) {
        self.init()

        isPreview = true
        isStreaming = isStreamming

        if isError {
            messages.append(
                contentsOf: [
                    ChatMessage(
                        message: "Lorem ipsum dolor?",
                        type: .question
                    ),
                    ChatMessage(
                        message: "Error: Something went wrong!",
                        type: .error
                    ),
                ]
            )
        } else if hasData {
            messages.append(
                contentsOf: [
                    ChatMessage(
                        message: "Lorem ipsum dolor?",
                        type: .question
                    ),
                    ChatMessage(
                        message: "Error: Something went wrong!",
                        type: .answer
                    ),
                    ChatMessage(
                        message: "Lorem ipsum dolor?",
                        type: .question
                    ),
                    ChatMessage(
                        message: "Error: Something went wrong!",
                        type: .answer
                    ),
                ]
            )
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

@Observable
class ChatMessage: Identifiable {
    let id = UUID()
    var message: String
    var type: ChatMessageType

    init(message: String, type: ChatMessageType) {
        self.message = message
        self.type = type
    }
}

extension ChatMessage: Equatable {
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id
    }
}

enum ChatMessageType {
    case question
    case answer
    case error
}
