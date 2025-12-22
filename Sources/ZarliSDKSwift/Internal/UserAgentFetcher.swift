import WebKit
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
        
        DispatchQueue.main.async {
            // WKWebView must be created on main thread
            let webView = WKWebView()
            webView.evaluateJavaScript("navigator.userAgent") { [weak self] result, error in
                if let ua = result as? String {
                    self?.cachedUserAgent = ua
                    completion(ua)
                } else {
                    // Fallback if something goes wrong
                    let device = UIDevice.current
                    let fallback = "Mozilla/5.0 (\(device.model); CPU OS \(device.systemVersion.replacingOccurrences(of: ".", with: "_")) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
                    self?.cachedUserAgent = fallback
                    completion(fallback)
                }
            }
        }
    }
}
