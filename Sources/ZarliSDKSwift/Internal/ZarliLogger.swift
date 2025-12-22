import Foundation

enum ZarliLogLevel {
    case none
    case error
    case debug
}

class ZarliLogger {
    static var logLevel: ZarliLogLevel = .error // Default to error only to be quiet
    
    static func debug(_ message: String) {
        guard logLevel == .debug else { return }
        print("[ZarliSDK] [DEBUG] \(message)")
    }
    
    static func error(_ message: String) {
        guard logLevel != .none else { return }
        print("[ZarliSDK] [ERROR] \(message)")
    }
}
