import Foundation

class ZarliLogger {
    #if DEBUG
    static var isDebugEnabled: Bool = false
    
    static func debug(_ message: String) {
        guard isDebugEnabled else { return }
        print("[Zarli Debug] \(message)")
    }
    
    static func warning(_ message: String) {
        guard isDebugEnabled else { return }
        print("[Zarli Warning] \(message)")
    }
    
    static func error(_ message: String) {
        print("[Zarli Error] \(message)")
    }
    #else
    // In release builds, these become no-ops and get optimized away completely
    @inlinable static func debug(_ message: String) {}
    @inlinable static func warning(_ message: String) {}
    @inlinable static func error(_ message: String) {}
    #endif
}
