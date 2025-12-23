import UIKit

class UserAgentFetcher {
    static let shared = UserAgentFetcher()
    private var cachedUserAgent: String?
    
    private init() {}
    
    func fetch(completion: @escaping (String) -> Void) {
        if let ua = cachedUserAgent {
            completion(ua)
            return
        }
        
        let userAgent = buildUserAgent()
        cachedUserAgent = userAgent
        completion(userAgent)
    }
    
    private func buildUserAgent() -> String {
        let device = UIDevice.current
        let systemVersion = device.systemVersion.replacingOccurrences(of: ".", with: "_")
        let model = device.model
        
        // Construct a standard iOS user agent string
        // Format: Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148
        return "Mozilla/5.0 (\(model); CPU \(model) OS \(systemVersion) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
    }
}
