import Foundation

public struct ZarliConfiguration {
    public let apiKey: String
    public let isDebugMode: Bool
    
    public init(apiKey: String, isDebugMode: Bool = false) {
        self.apiKey = apiKey
        self.isDebugMode = isDebugMode
    }
}

public class ZarliSDK {
    public static let version = "1.0.0"
    public static let shared = ZarliSDK()
    
    public private(set) var apiKey: String?
    
    private init() {}
    
    /// Initializes the Zarli SDK with the given configuration
    public func initialize(configuration: ZarliConfiguration, completion: ((Bool) -> Void)? = nil) {
        self.apiKey = configuration.apiKey
        
        #if DEBUG
        ZarliLogger.isDebugEnabled = configuration.isDebugMode
        #endif
        
        ZarliLogger.debug("ZarliSDK initializing with API Key: \(configuration.apiKey)")
        
        // Pre-warm the User Agent so it's ready for ad requests
        UserAgentFetcher.shared.fetch { ua in
            ZarliLogger.debug("User Agent pre-warmed: \(ua)")
            completion?(true)
        }
    }
}
