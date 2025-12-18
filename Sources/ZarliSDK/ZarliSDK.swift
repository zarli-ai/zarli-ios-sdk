import Foundation

public class ZarliSDK {
    public static let shared = ZarliSDK()
    
    private init() {}
    
    public func initialize(apiKey: String, completion: ((Bool) -> Void)? = nil) {
        // TODO: Implement initialization logic
        print("ZarliSDK initialized with API Key: \(apiKey)")
        completion?(true)
    }
}
