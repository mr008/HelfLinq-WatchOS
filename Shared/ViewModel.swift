//
//  ViewModel.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 02/02/23.
//

import Foundation
import SwiftUI
import AVKit

class ViewModel: ObservableObject {
    
    @Published var isInteracting = false
    @Published var messages: [MessageRow] = []
    @Published var inputMessage: String = ""
    var task: Task<Void, Never>?
    
    #if !os(watchOS)
    private var synthesizer: AVSpeechSynthesizer?
    #endif
    
    private var api: LLMClient
    
    var title: String {
        "HelfLinq"
    }
    
    var navigationTitle: String {
        api.provider.navigationTitle
    }
    
    init(api: LLMClient, enableSpeech: Bool = false) {
        self.api = api
        #if !os(watchOS)
        if enableSpeech {
            synthesizer = .init()
        }
        #endif
    }
    
    func updateClient(_ client: LLMClient) {
        self.messages = []
        self.api = client
    }
    
    @MainActor
    func sendTapped() async {
        let text = inputMessage
        inputMessage = ""
        if api.provider == .chatGPT {
            await send(text: text)
        } else {
            await sendWithoutStream(text: text)
        }
    }
    
    @MainActor
    func clearMessages() {
        stopSpeaking()
        api.deleteHistoryList()
        withAnimation { [weak self] in
            self?.messages = []
        }
    }
    
    @MainActor
    func retry(message: MessageRow) async {
        guard let index = messages.firstIndex(where: { $0.id == message.id }) else {
            return
        }
        self.messages.remove(at: index)
        if api.provider == .chatGPT {
            await send(text: message.sendText)
        } else {
            await sendWithoutStream(text: message.sendText)
        }
    }
    
    func cancelStreamingResponse() {
        self.task?.cancel()
        self.task = nil
    }
    
    
    @MainActor
    private func send(text: String) async {
        isInteracting = true
        var streamText = ""
        var messageRow = MessageRow(
            isInteracting: true,
            sendImage: "profile",
            send: .rawText(text),
            responseImage: api.provider.imageName,
            response: .rawText(streamText),
            responseError: nil)
        
        self.messages.append(messageRow)
        
        do {
            let stream = try await api.sendMessageStream(text: text)
            for try await text in stream {
                streamText += text
                messageRow.response = .rawText(streamText.trimmingCharacters(in: .whitespacesAndNewlines))
                self.messages[self.messages.count - 1] = messageRow
            }
        } catch {
            messageRow.responseError = error.localizedDescription
        }
        
        messageRow.isInteracting = false
        self.messages[self.messages.count - 1] = messageRow
        isInteracting = false
        speakLastResponse()
        
    }
    
    @MainActor
    private func sendWithoutStream(text: String) async {
        isInteracting = true
        var messageRow = MessageRow(
            isInteracting: true,
            sendImage: "profile",
            send: .rawText(text),
            responseImage: api.provider.imageName,
            response: .rawText(""),
            responseError: nil)
        
        self.messages.append(messageRow)
        
        do {
            let responseText = try await api.sendMessage(text)
            try Task.checkCancellation()
            messageRow.response = .rawText(responseText)
        } catch {
            messageRow.responseError = error.localizedDescription
        }
        
        messageRow.isInteracting = false
        self.messages[self.messages.count - 1] = messageRow
        isInteracting = false
        speakLastResponse()
    }
    
    func speakLastResponse() {
        #if !os(watchOS)
        guard let synthesizer, let responseText = self.messages.last?.responseText, !responseText.isEmpty else {
            return
        }
        stopSpeaking()
        let utterance = AVSpeechUtterance(string: responseText)
        utterance.voice = .init(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.2
        synthesizer.speak(utterance )
        #endif
    }
    
    func stopSpeaking() {
        #if !os(watchOS)
        synthesizer?.stopSpeaking(at: .immediate)
        #endif
    }
    
}



