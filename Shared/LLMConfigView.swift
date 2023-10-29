import SwiftUI

struct LLMConfigView: View {
    
    let onStartChatTapped: (_ result: LLMConfig) -> Void
    @State var apiKey = ""
    @State var userID = ""  // <-- Add this line for userID
    @State var llmProvider = LLMProvider.chatGPT
    @State var chatGPTModel = ChatGPTModel.gpt3Turbo
    
    var body: some View {
        List { sectionsView }
    }
    
    @ViewBuilder
    var sectionsView: some View {

        Section("Login") {
            TextField("Enter User ID", text: $userID)  // <-- Add this TextField for userID
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
        
        Section {
            Button("Start Logging Now") {
                let type: LLMConfig.ConfigType
                switch llmProvider {
                case .chatGPT:
                    type = .chatGPT(chatGPTModel)
                case .palm:
                    type = .palm
                }
                
                // Modify this line to pass the userID when you're initializing the LLMConfig
                self.onStartChatTapped(.init(apiKey: apiKey, userID: userID, type: type))
            }
            .frame(maxWidth: .infinity)
            // Ensure the button is disabled when either apiKey or userID fields are empty
            .disabled( userID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            
        } footer: {
            Text(llmProvider.footerInfo)
                .padding(.vertical)
        }
    }
}

struct LLMConfigView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LLMConfigView { result in
                
            }
        }
    }
}
