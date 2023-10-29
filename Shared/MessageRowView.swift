//
//  MessageRowView.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 02/02/23.
//

import SwiftUI

struct MessageRowView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    let message: MessageRow
    let retryCallback: (MessageRow) -> Void
    
    var imageSize: CGSize {
        #if os(iOS) || os(macOS)
        CGSize(width: 25, height: 25)
        #elseif os(watchOS)
        CGSize(width: 20, height: 20)
        #else
        CGSize(width: 80, height: 80)
        #endif
    }
    
    var body: some View {
        VStack(spacing: 0) {
            messageRow(rowType: message.send, image: message.sendImage, bgColor: colorScheme == .light ? .white : Color(red: 52/255, green: 53/255, blue: 65/255, opacity: 0.5))
            
            if let response = message.response {
                Divider()
                messageRow(rowType: response, image: message.responseImage, bgColor: colorScheme == .light ? .gray.opacity(0.1) : Color(red: 52/255, green: 53/255, blue: 65/255, opacity: 1), responseError: message.responseError, showDotLoading: message.isInteracting)
                Divider()
            }
        }
    }
    
    func messageRow(rowType: MessageRowType, image: String, bgColor: Color, responseError: String? = nil, showDotLoading: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            messageRowContent(rowType: rowType, image: image, responseError: responseError, showDotLoading: showDotLoading)
        }
        
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(bgColor)
    }
    
    @ViewBuilder
    func messageRowContent(rowType: MessageRowType, image: String, responseError: String? = nil, showDotLoading: Bool = false) -> some View {
        if image.hasPrefix("http"), let url = URL(string: image) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .frame(width: imageSize.width, height: imageSize.height)
            } placeholder: {
                ProgressView()
            }

        } else {
            Image(image)
                .resizable()
                .frame(width: imageSize.width, height: imageSize.height)
        }
        
        VStack(alignment: .leading) {
            switch rowType {
            case .attributed(let attributedOutput):
                attributedView(results: attributedOutput.results)
                
            case .rawText(let text):
                if !text.isEmpty {
                    Text(text)
                        .multilineTextAlignment(.leading)
                }
            }
            
            if let error = responseError {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.leading)
                
                Button("Try Again") {
                    retryCallback(message)
                }
                .foregroundColor(.accentColor)
                .padding(.top)
            }
            
            if showDotLoading {
                DotLoadingView()
                    .frame(width: 60, height: 30)
                
            }
        }
    }
    
    func attributedView(results: [ParserResult]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(results) { parsed in
                if parsed.isCodeBlock {
                    Text(parsed.attributedString)
                } else {
                    Text(parsed.attributedString)
                }
            }
        }
    }
    
}

struct MessageRowView_Previews: PreviewProvider {
    
    static let message = MessageRow(
        isInteracting: true, sendImage: "profile",
        send: .rawText("What is SwiftUI?"),
        responseImage: "openai",
        response: responseMessageRowType)
    
    static let message2 = MessageRow(
        isInteracting: false, sendImage: "profile",
        send: .rawText("What is SwiftUI?"),
        responseImage: "openai",
        response: .rawText(""),
        responseError: "ChatGPT is currently not available")
        
    static var previews: some View {
        NavigationStack {
            ScrollView {
                MessageRowView(message: message, retryCallback: { messageRow in
                    
                })
                    
                MessageRowView(message: message2, retryCallback: { messageRow in
                    
                })
                  
            }
            .previewLayout(.sizeThatFits)
        }
    }
    
    static var responseMessageRowType: MessageRowType {
        MessageRowType.rawText(rawString)
    }
    
    static var rawString: String {
        "SwiftUI is a user interface framework that allows developers to design and develop user interfaces for iOS, macOS, watchOS, and tvOS applications using Swift, a programming language developed by Apple Inc."
    }
}


