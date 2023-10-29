//
//  LLMProvider.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 03/06/23.
//

import Foundation

enum LLMProvider: Identifiable, CaseIterable {
    
    case chatGPT
    case palm
    
    var id: Self { self }
    
    var text: String {
        switch self {
        case .chatGPT:
            return "OpenAI ChatGPT"
        case .palm:
            return "Google PaLM"
        }
    }
    
    var footerInfo: String {
        switch self {
        case .chatGPT:
            return """
HealthLink is an innovative online calorie tracking database, leveraging the power of artificial intelligence (AI) to help you manage your nutritional intake. Launched in Oct 2023 at CalHack 10.0, HealthLink revolutionizes the way you monitor your calories, making it easier than ever to maintain a healthy lifestyle.
"""
        case .palm:
            return """
PaLM (Pathways Language Model) is a 540 billion parameter transformer-based large language model developed by Google AI.Researchers also trained smaller versions of PaLM, 8 and 62 billion parameter models, to test the effects of model scale.
            
PaLM is capable of a wide range of tasks, including commonsense reasoning, arithmetic reasoning, joke explanation, code generation, and translation. When combined with chain-of-thought prompting, PaLM achieved significantly better performance on datasets requiring reasoning of multiple steps, such as word problems and logic-based questions.
"""
        }
    }
    
    var navigationTitle: String {
        switch self {
        case .chatGPT:
            return "Back"
            
        case .palm:
            return "XCA PaLMChat"
        }
    }
    
    var imageName: String {
        switch self {
        case .chatGPT:
            return "openai"
        case .palm:
            return "palm"
        }
    }
}
