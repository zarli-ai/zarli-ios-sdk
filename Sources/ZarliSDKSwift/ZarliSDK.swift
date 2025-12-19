import Foundation

public class ZarliSDK {
    public static let shared = ZarliSDK()
    
    public private(set) var apiKey: String?
    
    private init() {}
    
    public func initialize(apiKey: String, completion: ((Bool) -> Void)? = nil) {
        self.apiKey = apiKey
        print("ZarliSDK initialized with API Key: \(apiKey)")
        completion?(true)
    }
}
