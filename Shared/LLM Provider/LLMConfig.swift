import Foundation

struct LLMConfig: Identifiable, Hashable {
    
    var id: String { apiKey }
    let apiKey: String
    let userID: String  // <-- Add this line to include userID as a property of LLMConfig
    let type: ConfigType
    
    enum ConfigType: Hashable {
        case chatGPT(ChatGPTModel)
        case palm
    }
    
    func createClient() -> LLMClient {
        return ChatGPTAPI(userID: userID)  // <-- Pass the userID when creating ChatGPTAPI
    }
}
