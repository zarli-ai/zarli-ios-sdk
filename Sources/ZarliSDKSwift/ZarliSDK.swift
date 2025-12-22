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
    public static let shared = ZarliSDK()
    
    public private(set) var apiKey: String?
    
    private init() {}
    
    /// Initializes the Zarli SDK with the given configuration
    public func initialize(configuration: ZarliConfiguration, completion: ((Bool) -> Void)? = nil) {
        self.apiKey = configuration.apiKey
        ZarliLogger.logLevel = configuration.isDebugMode ? .debug : .error
        ZarliLogger.debug("ZarliSDK initializing with API Key: \(configuration.apiKey)")
        
        // Pre-warm the User Agent so it's ready for ad requests
        UserAgentFetcher.shared.fetch { ua in
            ZarliLogger.debug("User Agent pre-warmed: \(ua)")
            completion?(true)
        }
    }
    
    /// Legacy Initialization
    @available(*, deprecated, message: "Use initialize(configuration:) instead")
    public func initialize(apiKey: String, isDebugMode: Bool = false, completion: ((Bool) -> Void)? = nil) {
        let config = ZarliConfiguration(apiKey: apiKey, isDebugMode: isDebugMode)
        self.initialize(configuration: config, completion: completion)
    }
}
